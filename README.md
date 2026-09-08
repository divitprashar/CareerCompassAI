# CareerCompass AI 🤖

### Navigate Your Future with Success

CareerCompass AI is an AI-powered career guidance web application designed to help students explore suitable career paths and courses based on their interests and preferences.

The application combines a structured career dataset with a locally running Large Language Model (LLM) to provide interactive and personalized career guidance.

---

## 🚀 Features

* 🤖 AI-powered career guidance
* 💬 Interactive career counseling chat
* 🎯 Interest-based career recommendations
* 📚 Course recommendations for careers
* 📊 Career, course, and field datasets
* 🔒 Locally running AI model using Ollama
* ⚡ Optimized for slower CPU-based laptops
* 🔄 Session-based conversation history

---

## 🧠 How It Works

1. The student interacts with the CareerCompass AI web interface.
2. User messages are sent to the Flask backend.
3. User profile information is stored using Flask sessions.
4. The application matches user interests with career skills stored in the dataset.
5. Relevant career recommendations are selected.
6. Recommended courses are retrieved for each career.
7. The student profile and recommendation data are provided as context to the AI model.
8. The LLM generates a concise and personalized response.

---

## 🏗️ System Architecture

```text
User
  ↓
Web Interface
  ↓
Flask Backend
  ↓
Career Recommendation System
  ↓
CSV Datasets
  ↓
Ollama + Llama 3.2
  ↓
Personalized Career Guidance
```

---

## 🛠️ Technologies Used

| Technology    | Purpose                    |
| ------------- | -------------------------- |
| Python        | Backend programming        |
| Flask         | Web application framework  |
| Flask-Session | Session management         |
| HTML          | Web page structure         |
| CSS           | User interface styling     |
| JavaScript    | Frontend interaction       |
| CSV           | Career and course datasets |
| JSON          | Data exchange              |
| Ollama        | Local LLM runtime          |
| Llama 3.2     | AI language model          |

---

## 📊 Recommendation System

CareerCompass AI uses a simple interest-based matching system.

The application:

* Reads career information from CSV datasets.
* Compares student interests with required career skills.
* Scores careers based on matching skills.
* Returns the top matching careers.
* Retrieves recommended courses for each career.

The AI model then uses this information to provide conversational guidance.

---

## 📁 Project Structure

```text
CareerCompassAI/
│
├── app.py
├── requirements.txt
├── run.bat
├── setup.bat
│
├── data/
│   ├── careers.csv
│   ├── courses.csv
│   └── fields.csv
│
├── templates/
│   ├── index.html
│   ├── chat.html
│   └── how_it_works.html
│
├── static/
│   └── ...
│
└── documentation/
    └── Technical documentation files
```

---

## ⚙️ Installation

### 1. Clone the repository

```bash
git clone https://github.com/divitprashar/CareerCompassAI.git
```

### 2. Open the project folder

```bash
cd CareerCompassAI
```

### 3. Install Python dependencies

```bash
pip install -r requirements.txt
```

### 4. Install Ollama

CareerCompass AI uses Ollama to run the AI model locally.

Install Ollama and download the required model:

```bash
ollama pull llama3.2:3b
```

### 5. Run the application

```bash
python app.py
```

Then open:

```text
http://localhost:5000
```

---

## 🤖 AI Configuration

The project currently uses:

* **Model:** Llama 3.2 3B
* **LLM Runtime:** Ollama
* **Response Streaming:** Disabled
* **Maximum Response Length:** 200 tokens
* **Conversation History:** Last 10 messages

The configuration is optimized to support slower or CPU-only laptops.

---

## 🔌 API Endpoints

| Endpoint              | Method | Description                |
| --------------------- | ------ | -------------------------- |
| `/`                   | GET    | Home page                  |
| `/how-it-works`       | GET    | Project explanation page   |
| `/chat`               | GET    | AI chat interface          |
| `/api/chat`           | POST   | Send messages to the AI    |
| `/api/update-profile` | POST   | Update student profile     |
| `/api/reset`          | POST   | Reset the chat session     |
| `/api/recommend`      | POST   | Get career recommendations |
| `/api/fields`         | GET    | Retrieve available fields  |
| `/api/careers`        | GET    | Retrieve career data       |
| `/api/courses`        | GET    | Retrieve course data       |

---

## 🔮 Future Improvements

* Improved career recommendation algorithm
* More detailed student profiling
* Larger career and course datasets
* Machine learning-based recommendations
* Enhanced user interface
* Deployment as an online application
* User feedback system

---

## 📚 Documentation

The repository includes additional technical documentation explaining the architecture and internal working of CareerCompass AI.

---

## 👨‍💻 Developer

**Divit Prashar**

Student developer interested in Artificial Intelligence, programming, and building technology-based solutions.

---

### ⭐ CareerCompass AI

**Navigate Your Future with Success**
