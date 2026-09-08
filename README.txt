============================================================
  Career Compass AI — Offline Career Counselor
  Graduation Course Recommendation System
============================================================

WHAT THIS IS
------------
Career Compass AI is a fully offline AI-powered career counselor
that runs on your Windows laptop without any internet connection.
It uses a local AI model (Llama 3.2 via Ollama) to chat with
students and recommend graduation courses and career paths.


FIRST-TIME SETUP (needs internet once)
---------------------------------------
1. Install Python 3.11+
   - Download from: https://www.python.org/downloads/
   - IMPORTANT: Check "Add Python to PATH" during installation

2. Install Ollama
   - Download from: https://ollama.com/download
   - Run the Windows installer

3. Double-click:  setup.bat
   - Installs Python packages (Flask etc.)
   - Downloads the AI model (~2GB, one-time only)

4. After setup is complete, the app opens automatically.


RUNNING THE APP (after setup)
------------------------------
Double-click:  run.bat

The app will:
  - Start the Ollama AI engine automatically
  - Start the Flask web server
  - Open your browser at http://localhost:5000

Works completely OFFLINE after the first setup.


PAGES
-----
  /               Home page with features and field explorer
  /how-it-works   Full explanation of how the system works
  /chat           AI chat interface for recommendations


FILES
-----
  app.py              Main Flask application
  setup.bat           One-time setup script
  run.bat             App launcher (use this daily)
  requirements.txt    Python dependencies
  data/
    courses.csv       40+ graduation courses
    careers.csv       30+ career paths with salary data
    fields.csv        8 academic fields
  templates/
    base.html         Shared navigation layout
    index.html        Home page
    how_it_works.html How-it-works explanation page
    chat.html         Chat interface


SYSTEM REQUIREMENTS
--------------------
  - Windows 10 or Windows 11
  - Python 3.11 or newer
  - 4 GB RAM minimum (8 GB recommended)
  - 5 GB free disk space (for the AI model)
  - Browser: Chrome, Edge, or Firefox


CUSTOMIZING THE DATASETS
-------------------------
You can add more courses or careers by editing the CSV files
in the data/ folder using Excel or Notepad.

  data/courses.csv  — Add new courses (follow column format)
  data/careers.csv  — Add new careers with salary and skills
  data/fields.csv   — Add new academic fields


TROUBLESHOOTING
---------------
  "AI Offline" in chat:
    - Open Command Prompt and run: ollama serve
    - Or make sure Ollama is installed and running

  App won't start:
    - Make sure Python is installed and in PATH
    - Run: python --version  (should show 3.11+)
    - Run: pip install -r requirements.txt

  Slow AI responses:
    - Normal on CPU-only laptops (5-20 seconds)
    - Try a smaller model: ollama pull llama3.2:1b
    - Then change MODEL_NAME in app.py to: llama3.2:1b


============================================================
  Career Compass AI — No internet needed after setup.
  Your data stays on your laptop. Private & secure.
============================================================

