# ⚡ Electro Task Manager — Full-Stack Application

Electro is a high-fidelity, premium **Full-Stack Task Management Application** designed to deliver a modern, smooth, and secure user experience. It consists of a Node.js/Express/MongoDB Atlas backend API and a cross-platform Flutter mobile application.

---

## 📱 APK Download Link

🚀 **[Download the Electro Mobile App (APK)](https://drive.google.com/file/d/1Ge4Jh0YXCB0F3JNy8Cdtkp8bBwXESo0u/view?usp=sharing)**

---

## ✨ Features & UI/UX Enhancements

### 1. Modern Design & Creative Interfaces
*   **Theme-Aware Premium SnackBars:** Global floating SnackBars with optimized high-contrast colors (e.g. Neon Indigo on dark backgrounds and dark slate on light backgrounds).
*   **Creative Bottom Sheets:** Bottom sheet forms for adding tasks and projects featuring drag handles, circular gradient icons, and keyboard-responsive paddings.
*   **Animated Priority Selection Chips:** Custom-built interactive selectors inside the Task Sheet with micro-scale animations and priority-specific color tags (Emerald/Amber/Crimson).
*   **Interactive Animated Checkboxes:** Spring-scale animations and color transitions when completing tasks.
*   **Entrance Staggered Animations:** Staggered list fade-in and slide-up effects to prevent layout popping.

### 2. Multi-Language (EN/AR) & RTL Directionality
*   **Automatic System Detection:** Detects device locale on initial launch (supporting `ar`/`en`, defaulting to `en`).
*   **RTL Dismissible Alignments:** Swipe-to-delete layouts adjust icon placement (`AlignmentDirectional.centerEnd`) automatically matching RTL or LTR views.

### 3. State Management & Navigation Guarding
*   **Zero-Flicker Updates:** Optimistic state updates for creating, toggle checking, and deleting tasks/projects without showing intrusive full-screen loading indicators.
*   **Double-Press Back to Exit:** Root screen pop protection via a `BackButtonListener` that exits the app only on double back-press.
*   **GoRouter Redirection:** Safe, clean routing using path-nested route history.

### 4. Advanced Security Controls
*   **Backend Protection:** Rate limiters (brute-force protection on auth routes) and `helmet` security headers.
*   **Secure Storage:** JWT tokens are stored locally on the device using keychain/keystore security via `FlutterSecureStorage`.
*   **Interception & Auto-Logout:** Network requests automatically append the secure token. If the backend returns a `401 Unauthorized` (e.g. token expired), a global interceptor automatically deletes the token and redirects the user to the login screen.

---

## 🏗️ Architecture

### 📂 Backend Structure (MVC API)
```
task-manager-api/
├── src/
│   ├── config/      # DB Connection (MongoDB Atlas)
│   ├── middleware/  # JWT Auth & Rate Limiters
│   ├── models/      # Mongoose Schemas (User, Project, Task)
│   ├── routes/      # REST API Controllers (auth, projects, tasks)
│   └── app.js       # App entry point (CORS, Helmet, express.json)
```

### 📂 Frontend Structure (Flutter Clean Architecture)
```
lib/
├── core/
│   ├── constants/   # API & Storage config keys
│   ├── network/     # Dio Client with JWT interceptors
│   ├── theme/       # AppColors & AppTheme settings
│   └── locale/      # Language settings cubits
├── features/        # Auth, Projects, Tasks, Profile (divided into Model, Repo, Cubit, Screens)
├── widgets/         # Shared creative widgets (AnimatedCheckbox, FadeInSlide, StatusChip)
├── router/          # AppRouter & GoRouter Refresh Streams
└── main.dart        # MaterialApp entry point
```

---

## 🛠️ Tech Stack & Dependencies

### Backend Packages
*   **Express** — REST routing framework
*   **Mongoose** — MongoDB object modeling
*   **BcryptJS** — Hashing passwords securely
*   **JsonWebToken** — Bearer token generation
*   **Helmet** — Securing HTTP headers
*   **Express-Rate-Limit** — Preventing brute-force attacks
*   **Cors** — Cross-Origin Request Sharing

### Frontend Packages
*   **flutter_bloc** — State management (Cubit/BLoC)
*   **dio** — HTTP networking client
*   **go_router** — Declarative navigation
*   **flutter_secure_storage** — Encrypted device storage
*   **shared_preferences** — Simple settings persistence
*   **easy_localization** — Translation manager (i18n)

---

## 🚀 Installation & Running Guide

### Prerequisites
*   Node.js (v16+)
*   Flutter SDK (v3.19+)
*   Git

---

### Backend API Setup

1.  **Navigate into directory:**
    ```bash
    cd task-manager-api
    ```
2.  **Install node packages:**
    ```bash
    npm install
    ```
3.  **Run in development mode:**
    ```bash
    npm run dev
    ```
    *The API will start running locally on `http://localhost:5000`.*

---

### Frontend Flutter Setup

1.  **Navigate to the root directory:**
    ```bash
    cd ..
    ```
2.  **Fetch dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Configure API Constants:**
    Verify the base URL inside `lib/core/constants/api_constants.dart`:
    ```dart
    static const String baseUrl = 'https://electro-task.onrender.com/api'; // Or your local host URL
    ```
4.  **Run on connected emulator or device:**
    ```bash
    flutter run
    ```

---

## 🛡️ Verification Results
*   **Static Analysis:** Passes clean with `No issues found!` when executing `flutter analyze`.
*   **Vulnerability Scan:** Node.js dependencies audited with `found 0 vulnerabilities`.
