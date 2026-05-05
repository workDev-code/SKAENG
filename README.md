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

Luồng chuẩn: Flutter **không** giữ `GEMINI_API_KEY`; mỗi request gửi **`Authorization: Bearer <Firebase ID token>`**.

#### Mobile (Android / iOS) — khuyến nghị

1. Firebase Console → **Authentication** → **Anonymous** → bật.
2. Thêm app Android/iOS vào project (đúng bundle/package như trong repo).
3. Một lần trong thư mục app Flutter:

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

   Lệnh này ghi đè `lib/firebase_options.dart` và thường tạo/thêm cấu hình native (ví dụ `android/app/google-services.json`, plugin Gradle nếu CLI đề xuất). Làm theo output của CLI cho đến khi build Android/iOS chạy được.

4. Chạy app (máy ảo/emulator gọi `localhost`; **điện thoại thật** cần IP máy dev, ví dụ `http://192.168.1.10:8080`):

   ```bash
   flutter run --dart-define=BACKEND_BASE_URL=http://<host>:8080
   ```

Backend và điện thoại phải cùng mạng; không trỏ `localhost` trên máy thật vì đó là chính điện thoại — **trừ** khi bạn dùng **`adb reverse`** (Android, xem dưới).

#### Chạy Flutter trên điện thoại thật

**Chung**

1. Cài Flutter/SDK đủ (Android Studio / Xcode theo platform).
2. Chạy backend trên máy dev (`npm run dev` trong `backend/`), có `GEMINI_API_KEY` trong `.env`.
3. Điện thoại và máy dev **cùng Wi‑Fi** (hoặc USB để debug; có thể dùng USB + reverse cổng).
4. Firebase: đã `flutterfire configure`, **Anonymous** bật, bundle/package khớp app.

**Lấy URL backend cho máy thật**

- Cách A — **IP LAN** (ổn định cho cả Android & iOS): trên máy dev xem IP (ví dụ `192.168.1.10`), chạy:

  ```bash
  flutter run --dart-define=BACKEND_BASE_URL=http://192.168.1.10:8080
  ```

  Tường lửa máy dev không được chặn cổng `8080`. Backend Node mặc định lắng nghe mọi interface nên máy trong LAN có thể gọi được.

- Cách B — **Android + USB**: không cần IP nếu reverse cổng (chỉ thiết bị đang cắm USB):

  ```bash
  adb reverse tcp:8080 tcp:8080
  flutter run --dart-define=BACKEND_BASE_URL=http://127.0.0.1:8080
  ```

  Mỗi lần gắn máy lại có thể cần chạy lại `adb reverse`.

**Android**

1. **Cài đặt** → **Giới thiệu về điện thoại** → bấm 7 lần **Số bản dựng** → bật **Tùy chọn nhà phát triển**.
2. **Tùy chọn nhà phát triển** → bật **USB debugging**.
3. Cắm USB → chấp nhận RSA fingerprint trên điện thoại.
4. Trên máy dev: `flutter devices` — phải thấy thiết bị; chạy `flutter run` (thêm `--dart-define=BACKEND_BASE_URL=...` như trên).

**iOS**

1. Mở `ios/Runner.xcworkspace` trong Xcode một lần → **Signing & Capabilities** → chọn **Team** (Apple ID dev).
2. Cắm iPhone → tin cậy máy tính trên điện thoại nếu được hỏi.
3. `flutter devices` có iPhone → `flutter run --dart-define=BACKEND_BASE_URL=http://<IP-LAN-máy-dev>:8080`.

*(USB-only reverse cổng như Android không áp dụng giống hệt cho iOS; nên dùng IP LAN hoặc tunnel khác nếu cần.)*

#### Desktop Linux / test nhanh

Token JWT tạm (hết hạn sau ~1h):

```bash
flutter run \
  --dart-define=BACKEND_BASE_URL=http://localhost:8080 \
  --dart-define=FIREBASE_ID_TOKEN=<firebase_id_token>
```

#### Tuỳ chọn: Firebase chỉ qua dart-define (không dùng `firebase_options.dart`)

Giữ `CONFIGURE_ME` trong `lib/firebase_options.dart` và truyền `FB_*` như trước (Android ví dụ):

```bash
flutter run \
  --dart-define=BACKEND_BASE_URL=http://localhost:8080 \
  --dart-define=FB_PROJECT_ID=your_project \
  --dart-define=FB_MESSAGING_SENDER_ID=your_sender_id \
  --dart-define=FB_ANDROID_API_KEY=your_android_api_key \
  --dart-define=FB_ANDROID_APP_ID=your_android_app_id
```

(iOS/Web: thêm bộ `FB_IOS_*` / `FB_WEB_*` tương ứng.)

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
