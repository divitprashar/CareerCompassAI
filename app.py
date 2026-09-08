import os
import json
import csv
import requests
from flask import Flask, render_template, request, jsonify, session
from flask_session import Session

app = Flask(__name__)
app.secret_key = "career-counselor-secret-2024"
app.config["SESSION_TYPE"] = "filesystem"
app.config["SESSION_FILE_DIR"] = "./flask_sessions"
Session(app)

OLLAMA_URL   = "http://localhost:11434/api/chat"
OLLAMA_TAGS  = "http://localhost:11434/api/tags"
MODEL_NAME   = "llama3.2:3b"

# Tuned for slow/CPU-only laptops:
#   connect_timeout — how long to wait for Ollama to accept the connection
#   read_timeout    — how long to wait for the model to finish generating
CONNECT_TIMEOUT = 10
READ_TIMEOUT    = 300   # 5 minutes — enough for slow CPUs

# ── Load datasets ──────────────────────────────────────────────────────────────

def load_csv(filename):
    path = os.path.join("data", filename)
    rows = []
    with open(path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            rows.append(row)
    return rows

COURSES = load_csv("courses.csv")
CAREERS = load_csv("careers.csv")
FIELDS  = load_csv("fields.csv")

COURSE_MAP = {c["course_id"]: c for c in COURSES}

# ── Recommendation helpers ─────────────────────────────────────────────────────

def get_career_recommendations(interests, field=None, level=None):
    """Score careers by matching interests/skills against career required_skills."""
    interests_lower = [i.strip().lower() for i in interests]
    scored = []
    for career in CAREERS:
        if field and career["field"].lower() != field.lower():
            continue
        skills = [s.strip().lower() for s in career["required_skills"].split(",")]
        score = sum(1 for i in interests_lower if any(i in s or s in i for s in skills))
        if score > 0:
            scored.append((score, career))
    scored.sort(key=lambda x: -x[0])
    return [c for _, c in scored[:5]]

def get_courses_for_career(career):
    course_ids = [cid.strip() for cid in career["recommended_courses"].split(",")]
    courses = []
    for cid in course_ids:
        if cid in COURSE_MAP:
            c = COURSE_MAP[cid]
            courses.append(c)
    return courses

def build_context_summary(profile):
    """Build a rich text context from user profile to inject into LLM prompt."""
    lines = ["=== Student Profile ==="]
    for k, v in profile.items():
        if v:
            lines.append(f"{k.replace('_', ' ').title()}: {v}")

    interests = [i.strip() for i in profile.get("interests", "").split(",") if i.strip()]
    field = profile.get("field", "")
    careers = get_career_recommendations(interests, field)

    lines.append("\n=== Top Recommended Careers ===")
    for i, career in enumerate(careers, 1):
        lines.append(f"{i}. {career['career_title']} ({career['field']}) — Avg Salary: ₹{int(career['avg_salary_inr']):,}/year — Growth: {career['job_growth']}")
        course_list = get_courses_for_career(career)
        course_names = ", ".join(c["course_name"] for c in course_list)
        lines.append(f"   Recommended Courses: {course_names}")

    lines.append("\n=== Available Fields ===")
    for f in FIELDS:
        lines.append(f"- {f['field_name']}: {f['description']}")

    return "\n".join(lines)

# ── Ollama ─────────────────────────────────────────────────────────────────────

def chat_with_ollama(messages):
    payload = {
        "model": MODEL_NAME,
        "messages": messages,
        "stream": False,
        "options": {
            "temperature": 0.7,
            "num_predict": 200,   # max tokens per reply — keeps responses short and fast
            "num_ctx": 2048,      # context window — smaller = faster on low-RAM laptops
            "top_k": 20,          # reduces sampling space = faster generation
            "top_p": 0.8,
        }
    }
    try:
        resp = requests.post(
            OLLAMA_URL,
            json=payload,
            timeout=(CONNECT_TIMEOUT, READ_TIMEOUT)  # (connect, read) tuple
        )
        if resp.status_code == 404:
            return ("⚠️ AI model not found. Open Command Prompt and run:\n\n"
                    "    ollama pull llama3.2:3b\n\n"
                    "Wait for download to finish (~2GB), then try again.")
        resp.raise_for_status()
        data = resp.json()
        return data["message"]["content"]
    except requests.exceptions.ConnectionError:
        return ("⚠️ Ollama is not running.\n\n"
                "Open Command Prompt and run:\n\n"
                "    ollama serve\n\n"
                "Keep that window open, then refresh this page.")
    except requests.exceptions.Timeout:
        return ("⚠️ The AI took too long to respond (timeout after 5 minutes).\n\n"
                "This usually means your laptop CPU is under heavy load.\n"
                "Tips to fix:\n"
                "  • Close other apps (browser tabs, Office, etc.)\n"
                "  • Wait 30 seconds and try again\n"
                "  • Use a shorter message\n"
                "  • Switch to a faster model: ollama pull llama3.2:1b\n"
                "    (then update MODEL_NAME in app.py to llama3.2:1b)")
    except Exception as e:
        return f"⚠️ Error: {str(e)}"

# Kept short deliberately — shorter system prompt = faster first token on slow CPUs
SYSTEM_PROMPT = """You are Career Compass AI, a career counselor for Indian graduation students.
Keep ALL replies under 120 words. Be warm, specific, and concise.
Ask one question at a time. When you have enough info, give 2-3 career and course recommendations with a one-line reason each.
Use the student profile and recommendation data provided below."""

# ── Routes ─────────────────────────────────────────────────────────────────────

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/how-it-works")
def how_it_works():
    return render_template("how_it_works.html")

@app.route("/chat")
def chat_page():
    return render_template("chat.html")

@app.route("/api/chat", methods=["POST"])
def api_chat():
    data = request.get_json()
    user_message = data.get("message", "").strip()
    if not user_message:
        return jsonify({"error": "Empty message"}), 400

    # Init session
    if "messages" not in session:
        session["messages"] = []
    if "profile" not in session:
        session["profile"] = {}

    # Extract profile info from message (simple keyword detection)
    profile = session["profile"]
    msg_lower = user_message.lower()

    # Build system message with current context
    context = build_context_summary(profile) if any(profile.values()) else ""
    system_content = SYSTEM_PROMPT
    if context:
        system_content += f"\n\n{context}"

    # Append user message to history
    session["messages"].append({"role": "user", "content": user_message})

    # Keep only the last 10 messages (5 exchanges) — prevents slow responses
    # as history grows. Older context is preserved in the system prompt profile.
    recent_messages = session["messages"][-10:]

    # Build messages list for Ollama
    ollama_messages = [{"role": "system", "content": system_content}] + recent_messages

    # Get response
    reply = chat_with_ollama(ollama_messages)

    # Store assistant reply
    session["messages"].append({"role": "assistant", "content": reply})
    session.modified = True

    return jsonify({"reply": reply})

@app.route("/api/update-profile", methods=["POST"])
def update_profile():
    data = request.get_json()
    if "profile" not in session:
        session["profile"] = {}
    session["profile"].update(data)
    session.modified = True
    return jsonify({"status": "ok"})

@app.route("/api/reset", methods=["POST"])
def reset_chat():
    session.clear()
    return jsonify({"status": "reset"})

@app.route("/api/recommend", methods=["POST"])
def api_recommend():
    data = request.get_json()
    interests = data.get("interests", "").split(",")
    field = data.get("field", "")
    careers = get_career_recommendations(interests, field)
    result = []
    for career in careers:
        courses = get_courses_for_career(career)
        result.append({
            "career": career,
            "courses": courses
        })
    return jsonify(result)

@app.route("/api/fields")
def api_fields():
    return jsonify(FIELDS)

@app.route("/api/careers")
def api_careers():
    return jsonify(CAREERS)

@app.route("/api/courses")
def api_courses():
    return jsonify(COURSES)

if __name__ == "__main__":
    os.makedirs("flask_sessions", exist_ok=True)
    print("\n" + "="*50)
    print("  Career Compass AI — Navigate Your Future with Success")
    print("  Open your browser and go to:")
    print("  http://localhost:5000")
    print("="*50 + "\n")
    app.run(debug=False, host="0.0.0.0", port=5000)
