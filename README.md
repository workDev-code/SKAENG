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
