

## Overview

You are building a **Task Manager Mobile App** in Flutter that connects to a **custom REST API** you will build and deploy for free. Do **not** use JSONPlaceholder or any mock API — build and host a real backend.

**State Management:** BLoC / Cubit  
**Theme:** Dark & Light mode (persisted)  
**Localization:** Arabic & English via `easy_localization`

---

## Part 1 — Build & Deploy the Backend API

### 1.1 Tech Stack for the API

| Layer | Choice |
|---|---|
| Runtime | Node.js |
| Framework | Express.js |
| Database | MongoDB Atlas (free tier) |
| Auth | JWT (jsonwebtoken) |
| Hosting | Render.com (free tier) |
| Password Hashing | bcryptjs |

### 1.2 Project Structure

```
task-manager-api/
├── src/
│   ├── config/
│   │   └── db.js
│   ├── middleware/
│   │   └── auth.js
│   ├── models/
│   │   ├── User.js
│   │   ├── Project.js
│   │   └── Task.js
│   ├── routes/
│   │   ├── auth.js
│   │   ├── projects.js
│   │   └── tasks.js
│   └── app.js
├── .env
├── package.json
└── README.md
```

### 1.3 Step-by-Step API Setup

#### Step 1 — Initialize the project

```bash
mkdir task-manager-api && cd task-manager-api
npm init -y
npm install express mongoose jsonwebtoken bcryptjs dotenv cors
npm install --save-dev nodemon
```

Add to `package.json` scripts:
```json
"scripts": {
  "start": "node src/app.js",
  "dev": "nodemon src/app.js"
}
```

#### Step 2 — Create the `.env` file

```env
PORT=5000
MONGO_URI=mongodb+srv://<username>:<password>@cluster0.mongodb.net/taskmanager?retryWrites=true&w=majority
JWT_SECRET=your_super_secret_key_here
JWT_EXPIRES_IN=7d
```

#### Step 3 — Database connection (`src/config/db.js`)

```javascript
const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('MongoDB connected');
  } catch (err) {
    console.error(err.message);
    process.exit(1);
  }
};

module.exports = connectDB;
```

#### Step 4 — Models

**`src/models/User.js`**
```javascript
const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
}, { timestamps: true });

module.exports = mongoose.model('User', UserSchema);
```

**`src/models/Project.js`**
```javascript
const mongoose = require('mongoose');

const ProjectSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: { type: String },
  status: { type: String, enum: ['active', 'completed', 'archived'], default: 'active' },
  owner: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
}, { timestamps: true });

module.exports = mongoose.model('Project', ProjectSchema);
```

**`src/models/Task.js`**
```javascript
const mongoose = require('mongoose');

const TaskSchema = new mongoose.Schema({
  title: { type: String, required: true },
  status: { type: String, enum: ['pending', 'in_progress', 'done'], default: 'pending' },
  priority: { type: String, enum: ['low', 'medium', 'high'], default: 'medium' },
  project: { type: mongoose.Schema.Types.ObjectId, ref: 'Project', required: true },
  owner: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
}, { timestamps: true });

module.exports = mongoose.model('Task', TaskSchema);
```

#### Step 5 — Auth Middleware (`src/middleware/auth.js`)

```javascript
const jwt = require('jsonwebtoken');

module.exports = (req, res, next) => {
  const token = req.header('Authorization')?.replace('Bearer ', '');
  if (!token) return res.status(401).json({ message: 'No token, access denied' });

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch {
    res.status(401).json({ message: 'Invalid token' });
  }
};
```

#### Step 6 — Auth Routes (`src/routes/auth.js`)

```javascript
const router = require('express').Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

router.post('/register', async (req, res) => {
  try {
    const { name, email, password } = req.body;
    let user = await User.findOne({ email });
    if (user) return res.status(400).json({ message: 'User already exists' });

    const hashed = await bcrypt.hash(password, 10);
    user = await User.create({ name, email, password: hashed });

    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRES_IN });
    res.status(201).json({ token, user: { id: user._id, name: user.name, email: user.email } });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email });
    if (!user) return res.status(400).json({ message: 'Invalid credentials' });

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(400).json({ message: 'Invalid credentials' });

    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRES_IN });
    res.json({ token, user: { id: user._id, name: user.name, email: user.email } });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.get('/me', require('../middleware/auth'), async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-password');
    res.json(user);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
```

#### Step 7 — Project Routes (`src/routes/projects.js`)

```javascript
const router = require('express').Router();
const auth = require('../middleware/auth');
const Project = require('../models/Project');

router.get('/', auth, async (req, res) => {
  try {
    const projects = await Project.find({ owner: req.user.id }).sort({ createdAt: -1 });
    res.json(projects);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.post('/', auth, async (req, res) => {
  try {
    const project = await Project.create({ ...req.body, owner: req.user.id });
    res.status(201).json(project);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.get('/:id', auth, async (req, res) => {
  try {
    const project = await Project.findOne({ _id: req.params.id, owner: req.user.id });
    if (!project) return res.status(404).json({ message: 'Project not found' });
    res.json(project);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
```

#### Step 8 — Task Routes (`src/routes/tasks.js`)

```javascript
const router = require('express').Router();
const auth = require('../middleware/auth');
const Task = require('../models/Task');

router.get('/project/:projectId', auth, async (req, res) => {
  try {
    const tasks = await Task.find({ project: req.params.projectId, owner: req.user.id });
    res.json(tasks);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.post('/', auth, async (req, res) => {
  try {
    const task = await Task.create({ ...req.body, owner: req.user.id });
    res.status(201).json(task);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.patch('/:id', auth, async (req, res) => {
  try {
    const task = await Task.findOneAndUpdate(
      { _id: req.params.id, owner: req.user.id },
      req.body,
      { new: true }
    );
    if (!task) return res.status(404).json({ message: 'Task not found' });
    res.json(task);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
```

#### Step 9 — Main App (`src/app.js`)

```javascript
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const connectDB = require('./config/db');

const app = express();
connectDB();

app.use(cors());
app.use(express.json());

app.use('/api/auth', require('./routes/auth'));
app.use('/api/projects', require('./routes/projects'));
app.use('/api/tasks', require('./routes/tasks'));

app.get('/', (req, res) => res.json({ message: 'Task Manager API is running' }));

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
```

### 1.4 Set Up MongoDB Atlas (Free)

1. Go to [mongodb.com/cloud/atlas](https://www.mongodb.com/cloud/atlas) and create a free account
2. Create a **free M0 cluster**
3. Add a database user (username + password)
4. Under Network Access → Allow IP `0.0.0.0/0` (required for Render)
5. Get your connection string and paste it in `.env` as `MONGO_URI`

### 1.5 Deploy to Render.com (Free)

1. Push your backend to a **public GitHub repo**
2. Go to [render.com](https://render.com) and sign up
3. Click **New → Web Service** → connect your GitHub repo
4. Set:
   - **Build Command:** `npm install`
   - **Start Command:** `npm start`
   - **Environment:** Node
5. Add environment variables from your `.env` file in the Render dashboard
6. Click **Deploy**
7. Your API base URL will be: `https://your-app-name.onrender.com`

> **Important:** Free Render services sleep after 15 minutes of inactivity. The first request after sleeping may take ~30 seconds. This is acceptable for the assessment.

### 1.6 API Endpoints Reference

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| POST | `/api/auth/register` | No | Register new user |
| POST | `/api/auth/login` | No | Login and get JWT |
| GET | `/api/auth/me` | Yes | Get current user profile |
| GET | `/api/projects` | Yes | List all projects |
| POST | `/api/projects` | Yes | Create a project |
| GET | `/api/projects/:id` | Yes | Get project details |
| GET | `/api/tasks/project/:projectId` | Yes | Get tasks for a project |
| POST | `/api/tasks` | Yes | Create a task |
| PATCH | `/api/tasks/:id` | Yes | Update task (mark done, change status) |

---

## Part 2 — Flutter App Implementation

### 2.1 Flutter Project Setup

```bash
flutter create task_manager_app
cd task_manager_app
```

### 2.2 `pubspec.yaml` Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State Management
  flutter_bloc: ^8.1.5

  # HTTP Client
  dio: ^5.4.3

  # Secure Token Storage
  flutter_secure_storage: ^9.0.0

  # Navigation
  go_router: ^13.2.5

  # Localization
  easy_localization: ^3.0.7

  # Theme Persistence
  shared_preferences: ^2.2.3

  # UI Helpers
  flutter_spinkit: ^5.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/translations/
```

### 2.3 Folder Structure — Clean Architecture with Cubit

```
lib/
├── core/
│   ├── constants/
│   │   └── api_constants.dart
│   ├── network/
│   │   └── dio_client.dart
│   └── theme/
│       ├── app_theme.dart
│       ├── theme_cubit.dart
│       └── theme_state.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/user_model.dart
│   │   │   └── repositories/auth_repository.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── auth_cubit.dart
│   │       │   └── auth_state.dart
│   │       └── screens/
│   │           ├── login_screen.dart
│   │           └── register_screen.dart
│   ├── projects/
│   │   ├── data/
│   │   │   ├── models/project_model.dart
│   │   │   └── repositories/project_repository.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── project_cubit.dart
│   │       │   └── project_state.dart
│   │       └── screens/
│   │           ├── projects_screen.dart
│   │           └── project_detail_screen.dart
│   ├── tasks/
│   │   ├── data/
│   │   │   ├── models/task_model.dart
│   │   │   └── repositories/task_repository.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── task_cubit.dart
│   │       │   └── task_state.dart
│   │       └── widgets/
│   │           └── add_task_sheet.dart
│   └── profile/
│       └── presentation/
│           └── screens/profile_screen.dart
├── router/
│   └── app_router.dart
├── widgets/
│   ├── app_button.dart
│   ├── app_text_field.dart
│   ├── empty_state_widget.dart
│   ├── error_widget.dart
│   ├── loading_overlay.dart
│   └── status_chip.dart
└── main.dart

assets/
└── translations/
    ├── en.json
    └── ar.json
```

---

## Part 3 — Localization Setup (easy_localization)

### 3.1 Create Translation Files

**`assets/translations/en.json`**
```json
{
  "app_name": "Task Manager",
  "login": "Login",
  "register": "Register",
  "email": "Email",
  "password": "Password",
  "name": "Name",
  "logout": "Logout",
  "projects": "Projects",
  "no_projects": "No projects yet. Create one!",
  "add_project": "Add Project",
  "project_title": "Project Title",
  "project_description": "Description",
  "tasks": "Tasks",
  "no_tasks": "No tasks yet. Add one!",
  "add_task": "Add Task",
  "task_title": "Task Title",
  "mark_done": "Mark as Done",
  "status_pending": "Pending",
  "status_in_progress": "In Progress",
  "status_done": "Done",
  "priority_low": "Low",
  "priority_medium": "Medium",
  "priority_high": "High",
  "profile": "Profile",
  "settings": "Settings",
  "dark_mode": "Dark Mode",
  "language": "Language",
  "error_invalid_credentials": "Invalid email or password",
  "error_user_exists": "User already exists",
  "error_generic": "Something went wrong. Please try again.",
  "loading": "Loading...",
  "retry": "Retry",
  "save": "Save",
  "cancel": "Cancel",
  "field_required": "This field is required",
  "invalid_email": "Please enter a valid email"
}
```

**`assets/translations/ar.json`**
```json
{
  "app_name": "مدير المهام",
  "login": "تسجيل الدخول",
  "register": "إنشاء حساب",
  "email": "البريد الإلكتروني",
  "password": "كلمة المرور",
  "name": "الاسم",
  "logout": "تسجيل الخروج",
  "projects": "المشاريع",
  "no_projects": "لا توجد مشاريع بعد. أنشئ مشروعاً!",
  "add_project": "إضافة مشروع",
  "project_title": "اسم المشروع",
  "project_description": "الوصف",
  "tasks": "المهام",
  "no_tasks": "لا توجد مهام بعد. أضف مهمة!",
  "add_task": "إضافة مهمة",
  "task_title": "اسم المهمة",
  "mark_done": "تعيين كمنجز",
  "status_pending": "قيد الانتظار",
  "status_in_progress": "جارٍ التنفيذ",
  "status_done": "منجز",
  "priority_low": "منخفض",
  "priority_medium": "متوسط",
  "priority_high": "مرتفع",
  "profile": "الملف الشخصي",
  "settings": "الإعدادات",
  "dark_mode": "الوضع الداكن",
  "language": "اللغة",
  "error_invalid_credentials": "البريد الإلكتروني أو كلمة المرور غير صحيحة",
  "error_user_exists": "المستخدم موجود بالفعل",
  "error_generic": "حدث خطأ ما. يرجى المحاولة مجدداً.",
  "loading": "جارٍ التحميل...",
  "retry": "إعادة المحاولة",
  "save": "حفظ",
  "cancel": "إلغاء",
  "field_required": "هذا الحقل مطلوب",
  "invalid_email": "يرجى إدخال بريد إلكتروني صحيح"
}
```

### 3.2 Register Assets in `pubspec.yaml`

```yaml
flutter:
  assets:
    - assets/translations/
```

---

## Part 4 — Theme Setup (Dark & Light)

### 4.1 `lib/core/theme/app_theme.dart`

```dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB),
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Color(0xFF2563EB),
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB),
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Color(0xFF1E293B),
      foregroundColor: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
```

### 4.2 `lib/core/theme/theme_state.dart`

```dart
import 'package:flutter/material.dart';

class ThemeState {
  final ThemeMode themeMode;
  const ThemeState(this.themeMode);
}
```

### 4.3 `lib/core/theme/theme_cubit.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState(ThemeMode.light));

  static const _key = 'theme_mode';

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_key) ?? false;
    emit(ThemeState(isDark ? ThemeMode.dark : ThemeMode.light));
  }

  Future<void> toggleTheme() async {
    final isDark = state.themeMode == ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, !isDark);
    emit(ThemeState(!isDark ? ThemeMode.dark : ThemeMode.light));
  }
}
```

---

## Part 5 — Language (Locale) Cubit

### 5.1 `lib/core/locale/locale_state.dart`

```dart
import 'dart:ui';

class LocaleState {
  final Locale locale;
  const LocaleState(this.locale);
}
```

### 5.2 `lib/core/locale/locale_cubit.dart`

```dart
import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit() : super(const LocaleState(Locale('en')));

  static const _key = 'locale';

  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'en';
    emit(LocaleState(Locale(code)));
  }

  Future<void> changeLocale(BuildContext context, String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, languageCode);
    await context.setLocale(Locale(languageCode));
    emit(LocaleState(Locale(languageCode)));
  }
}
```

---

## Part 6 — Auth Feature (Cubit)

### 6.1 `lib/features/auth/data/models/user_model.dart`

```dart
class UserModel {
  final String id;
  final String name;
  final String email;

  const UserModel({required this.id, required this.name, required this.email});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] ?? json['_id'],
    name: json['name'],
    email: json['email'],
  );
}
```

### 6.2 `lib/features/auth/data/repositories/auth_repository.dart`

```dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

class AuthRepository {
  final Dio dio;
  final FlutterSecureStorage storage;

  AuthRepository({required this.dio, required this.storage});

  Future<UserModel> login(String email, String password) async {
    final res = await dio.post('/auth/login', data: {'email': email, 'password': password});
    await storage.write(key: 'jwt_token', value: res.data['token']);
    return UserModel.fromJson(res.data['user']);
  }

  Future<UserModel> register(String name, String email, String password) async {
    final res = await dio.post('/auth/register', data: {'name': name, 'email': email, 'password': password});
    await storage.write(key: 'jwt_token', value: res.data['token']);
    return UserModel.fromJson(res.data['user']);
  }

  Future<UserModel?> getMe() async {
    final token = await storage.read(key: 'jwt_token');
    if (token == null) return null;
    final res = await dio.get('/auth/me');
    return UserModel.fromJson(res.data);
  }

  Future<void> logout() async {
    await storage.delete(key: 'jwt_token');
  }
}
```

### 6.3 `lib/features/auth/presentation/cubit/auth_state.dart`

```dart
import '../../data/models/user_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final UserModel user;
  AuthAuthenticated(this.user);
}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
```

### 6.4 `lib/features/auth/presentation/cubit/auth_cubit.dart`

```dart
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;

  AuthCubit(this.repository) : super(AuthInitial());

  Future<void> checkAuth() async {
    emit(AuthLoading());
    try {
      final user = await repository.getMe();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await repository.login(email, password);
      emit(AuthAuthenticated(user));
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'error_generic';
      emit(AuthError(msg));
    }
  }

  Future<void> register(String name, String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await repository.register(name, email, password);
      emit(AuthAuthenticated(user));
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'error_generic';
      emit(AuthError(msg));
    }
  }

  Future<void> logout() async {
    await repository.logout();
    emit(AuthUnauthenticated());
  }
}
```

---

## Part 7 — Projects Feature (Cubit)

### 7.1 `lib/features/projects/presentation/cubit/project_state.dart`

```dart
import '../../data/models/project_model.dart';

abstract class ProjectState {}

class ProjectInitial extends ProjectState {}
class ProjectLoading extends ProjectState {}
class ProjectLoaded extends ProjectState {
  final List<ProjectModel> projects;
  ProjectLoaded(this.projects);
}
class ProjectError extends ProjectState {
  final String message;
  ProjectError(this.message);
}
```

### 7.2 `lib/features/projects/presentation/cubit/project_cubit.dart`

```dart
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/project_repository.dart';
import 'project_state.dart';

class ProjectCubit extends Cubit<ProjectState> {
  final ProjectRepository repository;

  ProjectCubit(this.repository) : super(ProjectInitial());

  Future<void> loadProjects() async {
    emit(ProjectLoading());
    try {
      final projects = await repository.getProjects();
      emit(ProjectLoaded(projects));
    } on DioException catch (e) {
      emit(ProjectError(e.response?.data['message'] ?? 'error_generic'));
    }
  }

  Future<void> createProject(String title, String description) async {
    try {
      await repository.createProject(title, description);
      await loadProjects();
    } on DioException catch (e) {
      emit(ProjectError(e.response?.data['message'] ?? 'error_generic'));
    }
  }
}
```

---

## Part 8 — Tasks Feature (Cubit)

### 8.1 `lib/features/tasks/presentation/cubit/task_state.dart`

```dart
import '../../data/models/task_model.dart';

abstract class TaskState {}

class TaskInitial extends TaskState {}
class TaskLoading extends TaskState {}
class TaskLoaded extends TaskState {
  final List<TaskModel> tasks;
  TaskLoaded(this.tasks);
}
class TaskError extends TaskState {
  final String message;
  TaskError(this.message);
}
```

### 8.2 `lib/features/tasks/presentation/cubit/task_cubit.dart`

```dart
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/task_repository.dart';
import 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskRepository repository;
  final String projectId;

  TaskCubit(this.repository, this.projectId) : super(TaskInitial());

  Future<void> loadTasks() async {
    emit(TaskLoading());
    try {
      final tasks = await repository.getTasks(projectId);
      emit(TaskLoaded(tasks));
    } on DioException catch (e) {
      emit(TaskError(e.response?.data['message'] ?? 'error_generic'));
    }
  }

  Future<void> createTask(String title, String priority) async {
    try {
      await repository.createTask(title, projectId, priority);
      await loadTasks();
    } on DioException catch (e) {
      emit(TaskError(e.response?.data['message'] ?? 'error_generic'));
    }
  }

  Future<void> markDone(String taskId) async {
    try {
      await repository.updateTask(taskId, {'status': 'done'});
      await loadTasks();
    } on DioException catch (e) {
      emit(TaskError(e.response?.data['message'] ?? 'error_generic'));
    }
  }
}
```

---

## Part 9 — `main.dart` (Cubit + Themes + Localization)

```dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/network/dio_client.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/locale/locale_cubit.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const AppProviders(),
    ),
  );
}

class AppProviders extends StatelessWidget {
  const AppProviders({super.key});

  @override
  Widget build(BuildContext context) {
    final dio = DioClient.createDio();
    const storage = FlutterSecureStorage();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()..loadTheme()),
        BlocProvider(create: (_) => LocaleCubit()..loadLocale()),
        BlocProvider(
          create: (_) => AuthCubit(
            AuthRepository(dio: dio, storage: storage),
          )..checkAuth(),
        ),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp.router(
          title: 'app_name'.tr(),
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeState.themeMode,
          routerConfig: AppRouter.router(context.read<AuthCubit>()),
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
        );
      },
    );
  }
}
```

---

## Part 10 — Router (`lib/router/app_router.dart`)

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/cubit/auth_state.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/projects/presentation/screens/projects_screen.dart';
import '../features/projects/presentation/screens/project_detail_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';

class AppRouter {
  static GoRouter router(AuthCubit authCubit) {
    return GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        final authState = authCubit.state;
        final isOnAuth = state.matchedLocation == '/login' || state.matchedLocation == '/register';

        if (authState is AuthAuthenticated && isOnAuth) return '/projects';
        if (authState is AuthUnauthenticated && !isOnAuth) return '/login';
        return null;
      },
      refreshListenable: GoRouterRefreshStream(authCubit.stream),
      routes: [
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
        GoRoute(path: '/projects', builder: (_, __) => const ProjectsScreen()),
        GoRoute(
          path: '/projects/:id',
          builder: (_, state) => ProjectDetailScreen(
            projectId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      ],
    );
  }
}

// Helper to bridge BLoC stream with GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream stream) {
    stream.listen((_) => notifyListeners());
  }
}
```

---

## Part 11 — Profile Screen (Theme Toggle + Language Switch)

```dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../core/theme/theme_state.dart';
import '../../../core/locale/locale_cubit.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../auth/presentation/cubit/auth_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('profile'.tr())),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final user = state is AuthAuthenticated ? state.user : null;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // User info
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(user?.name ?? ''),
                  subtitle: Text(user?.email ?? ''),
                ),
              ),
              const SizedBox(height: 16),

              // Dark mode toggle
              Card(
                child: BlocBuilder<ThemeCubit, ThemeState>(
                  builder: (context, themeState) {
                    return SwitchListTile(
                      secondary: const Icon(Icons.dark_mode),
                      title: Text('dark_mode'.tr()),
                      value: themeState.themeMode == ThemeMode.dark,
                      onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Language selector
              Card(
                child: ListTile(
                  leading: const Icon(Icons.language),
                  title: Text('language'.tr()),
                  trailing: DropdownButton<String>(
                    value: context.locale.languageCode,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'ar', child: Text('العربية')),
                    ],
                    onChanged: (code) {
                      if (code != null) {
                        context.read<LocaleCubit>().changeLocale(context, code);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Logout
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                icon: const Icon(Icons.logout),
                label: Text('logout'.tr()),
                onPressed: () => context.read<AuthCubit>().logout(),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

---

## Part 12 — Using Translations in Screens

In every screen, use `.tr()` for all user-facing strings:

```dart
// Instead of hardcoded strings:
Text('Login')          // ❌ Wrong
AppBar(title: Text('Projects'))  // ❌ Wrong

// Use translation keys:
Text('login'.tr())     // ✅ Correct
AppBar(title: Text('projects'.tr()))  // ✅ Correct

// In validators:
if (value == null || value.isEmpty) return 'field_required'.tr();
if (!value.contains('@')) return 'invalid_email'.tr();

// In SnackBars (error messages from API):
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('error_generic'.tr())),
);
```

### RTL Support

`easy_localization` + Flutter's built-in RTL engine handle Arabic layout automatically. The app will flip to RTL when Arabic is selected — **do not manually set `textDirection`** unless overriding a specific widget.

---

## Part 13 — Cubit Usage Pattern (UI Side)

In every screen, use `BlocBuilder` for state and `BlocListener` for side effects:

```dart
// Reading state + rebuilding UI
BlocBuilder<ProjectCubit, ProjectState>(
  builder: (context, state) {
    if (state is ProjectLoading) return const Center(child: CircularProgressIndicator());
    if (state is ProjectError) return AppErrorWidget(message: state.message.tr(), onRetry: () => context.read<ProjectCubit>().loadProjects());
    if (state is ProjectLoaded) {
      if (state.projects.isEmpty) return EmptyStateWidget(message: 'no_projects'.tr());
      return ListView.builder(
        itemCount: state.projects.length,
        itemBuilder: (_, i) => ProjectCard(project: state.projects[i]),
      );
    }
    return const SizedBox();
  },
)

// Listening for navigation/snackbar side effects
BlocListener<AuthCubit, AuthState>(
  listener: (context, state) {
    if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message.tr())));
    }
  },
  child: ...,
)

// Combine both with BlocConsumer:
BlocConsumer<AuthCubit, AuthState>(
  listener: (context, state) { /* side effects */ },
  builder: (context, state) { /* UI */ },
)
```

---

## Part 14 — Reusable Widgets to Build

| Widget | Description |
|---|---|
| `AppTextField` | Styled input with label, validator, uses `.tr()` for hint/label |
| `AppButton` | Primary button with `isLoading` bool to show spinner |
| `AppErrorWidget` | Error message + retry button, text via `.tr()` |
| `EmptyStateWidget` | Icon + translated message for empty lists |
| `StatusChip` | Colored chip, label from translation key |
| `LoadingOverlay` | Full-screen semi-transparent loading blocker |

---

## Part 15 — README.md Template

```markdown
# Task Manager App

A Flutter mobile app for managing projects and tasks, built for the Electro Pi technical assessment.

## Screenshots
[Add screenshots here — light mode, dark mode, Arabic locale]

## Tech Stack
- Flutter + Dart
- BLoC / Cubit (state management)
- Dio (HTTP client)
- Go Router (navigation)
- Flutter Secure Storage (JWT)
- easy_localization (AR + EN)
- Shared Preferences (theme + locale persistence)
- Custom Node.js/Express REST API hosted on Render

## API
Base URL: https://your-app-name.onrender.com/api

## Localization
Supports English and Arabic (RTL). Switch language from Profile screen.

## Theming
Supports Light and Dark mode. Toggle from Profile screen. Persisted across sessions.

## How to Run
1. Clone the repo
2. Run `flutter pub get`
3. Run `flutter run`

## Architecture
Clean Architecture with feature-based folder structure and Cubit for state management.

## Dependencies
See pubspec.yaml
```

---

## Part 16 — Submission Checklist

- [ ] Backend deployed on Render with all endpoints working
- [ ] Flutter app connects to the custom Render API
- [ ] Login and Register screens working with validation
- [ ] Projects list with pull-to-refresh and empty state
- [ ] Project detail screen with task list
- [ ] Mark task as done (PATCH endpoint)
- [ ] Add new task via bottom sheet
- [ ] Profile screen with logout
- [ ] **Dark / Light mode toggle — persisted with SharedPreferences**
- [ ] **Language toggle AR / EN — persisted, RTL works in Arabic**
- [ ] **All strings use `.tr()` — zero hardcoded English/Arabic text in widgets**
- [ ] Cubit used for all state (no setState except trivial form fields)
- [ ] BlocListener used for navigation and SnackBar side effects
- [ ] Loading states on all async operations
- [ ] Error handling with user-facing translated messages
- [ ] Named routes with Go Router + auth redirect guard
- [ ] JWT stored securely and auto-login on launch
- [ ] Public GitHub repo with clear README
- [ ] (Bonus) APK or screen recording showing both themes and both languages

---

## Evaluation Criteria Weights

| Criteria | Weight | Notes |
|---|---|---|
| App functionality & UI quality | 30% | All screens + theme + language must work end-to-end |
| Code structure & architecture | 25% | Strict layer separation: data / cubit / UI |
| State management usage | 20% | Cubit used consistently — no business logic in widgets |
| Error handling & loading states | 15% | All errors shown in translated user-facing messages |
| README & documentation | 10% | Screenshots of both themes and both locales |
