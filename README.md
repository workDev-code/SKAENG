# Scan & Learn English

**Concept:** Chụp ảnh → AI nhận diện đồ vật → Hiện từ tiếng Anh + phát âm + lưu từ vựng.

---

## Màn hình cần build

| Screen | Mô tả |
|--------|--------|
| **1. Camera / Scanner** | Chụp hoặc upload ảnh |
| **2. Result** | Từ tiếng Anh, nghĩa, phát âm, ví dụ câu |
| **3. Vocabulary List** | Danh sách từ đã lưu |
| **4. Flashcard** *(optional)* | Ôn lại từ đã học |

---

## Tech stack

| Công nghệ | Vai trò |
|-----------|---------|
| **Flutter** | UI |
| **Gemini Vision API** | Nhận diện đồ vật (free tier) |
| **flutter_tts** | Phát âm |
| **Hive** | Lưu từ vựng local |

## Backend (proxy bảo mật cho Gemini)

Mục tiêu: **không bao giờ để `GEMINI_API_KEY` nằm trong Flutter**. Flutter đăng nhập bằng **Firebase Auth**, gửi ảnh + **Firebase ID token** lên backend, backend verify token rồi mới gọi Gemini.

### API

- `GET /health` → `{ ok: true }`
- `POST /analyze-image` (bắt buộc header `Authorization: Bearer <Firebase ID token>`)

Body:

```json
{
  "imageBase64": "<base64>",
  "mimeType": "image/jpeg"
}
```

Response (200):

```json
{
  "englishWord": "water bottle",
  "vietnameseTranslation": "chai nước",
  "pronunciationGuide": "WAW-ter BAH-tl",
  "exampleSentence": "I drank water from a bottle."
}
```

### Chạy backend local (Node)

Trong terminal:

```bash
cd backend
cp .env.example .env
# set GEMINI_API_KEY trong backend/.env
npm run dev
```

### Chạy backend local (Docker)

```bash
cp backend/.env.example backend/.env
# set GEMINI_API_KEY trong backend/.env
docker compose up --build
```

### Chạy Flutter qua backend proxy

```bash
flutter run \
  --dart-define=BACKEND_BASE_URL=http://localhost:8080 \
  --dart-define=FIREBASE_ID_TOKEN=<firebase_id_token>
```

---

## Thời gian prototype

- **Ngày 1:** Camera + gọi Gemini API → có kết quả
- **Ngày 2:** Lưu từ + Vocabulary list
- **Ngày 3:** UI đẹp + phát âm

---

## Prompt đầu tiên cho Cursor

```
Build a Flutter app called "Scan & Learn English"
for Vietnamese users learning English.

Core feature:
- User takes a photo or picks from gallery
- App sends image to Gemini Vision API
- API returns: English word, Vietnamese translation,
  pronunciation guide, example sentence
- User can save words to local vocabulary list
- Vocabulary list screen to review saved words

Tech stack:
- Flutter + Dart
- Gemini Vision API for image recognition
- flutter_tts for pronunciation
- Hive for local storage

Before writing any code:
1. Show folder structure
2. List all dependencies
3. Show data model for saved word
4. Ask for my approval

Wait for approval before implementing.
```
