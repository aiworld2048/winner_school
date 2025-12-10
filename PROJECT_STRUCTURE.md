# Winner School Project Structure

## Overview
This project consists of two main components:
1. **Laravel Backend** - API and Admin Panel (root directory: `winner_school`)
2. **Flutter Mobile App** - Student/Teacher mobile application (`school_apk/`)

---

## 📱 Laravel Backend Structure

### Framework & Version
- **Laravel**: 10.10
- **PHP**: ^8.1
- **Authentication**: Laravel Sanctum
- **Key Packages**: 
  - Guzzle HTTP
  - Elephant.io (WebSocket)

### Directory Structure

```
winner_school/
├── app/
│   ├── Console/              # Artisan commands
│   ├── Enums/                # Enum classes (UserType, TransactionType, etc.)
│   ├── Exceptions/           # Exception handlers
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── Admin/        # Admin panel controllers (18 files)
│   │   │   ├── Api/V1/       # API controllers organized by feature
│   │   │   │   ├── Auth/
│   │   │   │   ├── Bank/
│   │   │   │   ├── Game/
│   │   │   │   ├── Student/
│   │   │   │   └── Teacher/
│   │   │   └── Teacher/      # Teacher web controllers
│   │   ├── Middleware/       # Custom middleware (14 files)
│   │   ├── Requests/         # Form request validation (17 files)
│   │   └── Resources/        # API resources (24 files)
│   ├── Models/               # Eloquent models
│   │   ├── Admin/            # Admin-related models (10 files)
│   │   └── [Other models]    # User, Lesson, Subject, etc.
│   ├── Notifications/        # Notification classes
│   ├── Providers/            # Service providers
│   ├── Services/             # Business logic services
│   │   ├── Notification/     # Socket notification service
│   │   └── Slot/             # Game slot service
│   └── Traits/               # Reusable traits
├── config/                   # Configuration files
├── database/
│   ├── migrations/           # Database migrations (46 files)
│   └── seeders/              # Database seeders
├── public/                   # Public assets (images, CSS, JS)
├── resources/
│   ├── views/
│   │   ├── admin/            # Admin panel views (59 files)
│   │   ├── teacher/          # Teacher panel views (7 files)
│   │   └── auth/             # Authentication views
│   ├── css/
│   └── js/
├── routes/
│   ├── api.php               # API routes (for Flutter app)
│   ├── web.php               # Web routes (admin/teacher panels)
│   ├── admin.php             # Admin-specific routes
│   └── channels.php          # Broadcasting channels
└── storage/                  # Logs, cache, uploads

```

### Key Features

#### API Routes (`routes/api.php`)
- **Authentication**: `/login`, `/register`, `/logout`, `/player-change-password`
- **User**: `/user` (get current user)
- **Teacher Endpoints** (requires `teacher` middleware):
  - `/teacher/dashboard`
  - `/teacher/classes`
  - `/teacher/subjects`
  - `/teacher/students` (GET, POST)
  - `/teacher/lessons` (GET, POST)
- **Student Endpoints**:
  - `/student/lessons` (GET, show)
  - `/student/notes` (CRUD operations)
- **Public Endpoints**:
  - `/banner`, `/banner_Text`, `/popup-ads-banner`
  - `/public/highlights`
  - `/dictionary`
- **Financial**:
  - `/depositfinicial`, `/withdrawfinicial`
  - Deposit/Withdraw logs

#### Web Routes
- **Admin Panel** (`routes/admin.php`):
  - Dashboard, Profile Management
  - Teacher, Class, Subject Management
  - Banner, Promotion, Contact Management
  - Dictionary Management
  - Deposit/Withdraw Request Management
  - Lesson View Analytics
- **Teacher Panel** (`routes/web.php`):
  - Student Class Assignment
  - Lesson Management

#### Models
- **User Management**: `User`, `UserTree`, `UserPayment`
- **Academic**: `AcademicYear`, `SchoolClass`, `Subject`, `Lesson`, `LessonView`, `Exam`
- **Student**: `StudentNote`
- **Admin**: `Role`, `Permission`, `PermissionUser`, `UserLog`
- **Financial**: `DepositRequest`, `WithDrawRequest`, `TransactionLog`, `WithdrawLog`
- **Content**: `Banner`, `BannerAds`, `BannerText`, `Promotion`, `DictionaryEntry`, `Contact`

---

## 📱 Flutter App Structure (`school_apk/`)

### Framework & Version
- **Flutter SDK**: ^3.8.1
- **State Management**: Flutter Riverpod (^2.5.1)
- **Key Packages**:
  - `dio` (^5.7.0) - HTTP client
  - `shared_preferences` (^2.3.2) - Local storage
  - `intl` (^0.19.0) - Internationalization
  - `flutter_html` - HTML rendering
  - `flutter_tts` - Text-to-speech
  - `google_fonts` - Custom fonts

### Directory Structure

```
school_apk/
├── lib/
│   ├── main.dart             # App entry point
│   ├── app.dart              # Root widget with MaterialApp
│   ├── assets/               # Images, fonts, etc.
│   ├── common/               # Shared widgets
│   │   └── widgets/
│   │       ├── async_value_widget.dart
│   │       ├── banner_slider.dart
│   │       ├── empty_state.dart
│   │       ├── frosted_glass_card.dart
│   │       └── marquee_text.dart
│   ├── core/                 # Core functionality
│   │   ├── constants/
│   │   │   └── api_constants.dart    # API base URL
│   │   ├── network/
│   │   │   ├── api_client.dart       # HTTP client wrapper
│   │   │   └── api_exception.dart    # Error handling
│   │   ├── providers/
│   │   │   └── session_provider.dart  # Session state
│   │   ├── services/
│   │   │   └── session_manager.dart  # Session persistence
│   │   └── theme/            # App theming
│   │       ├── app_colors.dart
│   │       ├── app_gradients.dart
│   │       ├── app_spacing.dart
│   │       ├── app_theme.dart
│   │       └── app_typography.dart
│   └── features/             # Feature modules (Clean Architecture)
│       ├── auth/
│       │   ├── data/
│       │   │   └── auth_repository.dart
│       │   ├── models/
│       │   │   └── auth_user.dart
│       │   ├── presentation/
│       │   │   ├── auth_gate.dart        # Route guard
│       │   │   ├── login_screen.dart
│       │   │   ├── register_screen.dart
│       │   │   └── widgets/
│       │   └── providers/
│       │       └── auth_controller.dart
│       ├── dictionary/
│       │   ├── data/
│       │   ├── models/
│       │   ├── presentation/
│       │   └── providers/
│       ├── marketing/
│       │   ├── data/
│       │   ├── models/
│       │   └── providers/
│       ├── media/
│       │   ├── data/
│       │   ├── models/
│       │   ├── presentation/
│       │   └── providers/
│       ├── shared/
│       │   └── widgets/
│       │       └── app_navbar.dart
│       ├── student/
│       │   ├── data/
│       │   │   ├── lesson_repository.dart
│       │   │   └── wallet_repository.dart
│       │   ├── models/
│       │   │   └── lesson_models.dart
│       │   ├── presentation/
│       │   │   ├── screens/
│       │   │   │   ├── student_calculator_screen.dart
│       │   │   │   ├── student_lesson_detail_screen.dart
│       │   │   │   ├── student_lessons_screen.dart
│       │   │   │   ├── student_profile_screen.dart
│       │   │   │   └── student_wallet_screen.dart
│       │   │   └── student_shell.dart
│       │   └── providers/
│       ├── student_notes/
│       │   ├── data/
│       │   ├── models/
│       │   ├── presentation/
│       │   └── providers/
│       └── teacher/
│           ├── data/
│           ├── models/
│           ├── presentation/
│           │   ├── screens/
│           │   │   ├── teacher_dashboard_screen.dart
│           │   │   ├── teacher_lessons_screen.dart
│           │   │   ├── teacher_profile_screen.dart
│           │   │   └── teacher_students_screen.dart
│           │   ├── teacher_shell.dart
│           │   └── widgets/
│           └── providers/
├── android/                  # Android-specific files
├── ios/                      # iOS-specific files
├── test/                     # Unit tests
└── pubspec.yaml              # Dependencies

```

### Architecture Pattern
The Flutter app follows **Clean Architecture** with feature-based organization:
- **Data Layer**: Repositories, API calls
- **Domain Layer**: Models, business logic
- **Presentation Layer**: Screens, widgets, providers (Riverpod)

### Key Features

#### Authentication
- Login/Register screens
- Session management with `shared_preferences`
- Token-based authentication (Bearer token)
- Auth gate for route protection

#### Student Features
- Lessons list and detail view
- Student notes (CRUD)
- Wallet screen
- Calculator
- Profile management

#### Teacher Features
- Dashboard
- Lessons management
- Students management
- Profile management

#### Other Features
- Dictionary
- Media hub
- Marketing highlights
- Banner slider

### API Integration
- **Base URL**: Configurable via `API_ORIGIN` environment variable (default: `https://lion11.site`)
- **API Client**: Uses Dio with interceptors for:
  - Automatic token injection
  - Error handling
  - Timeout configuration (45 seconds)
- **Session Management**: Token stored in `shared_preferences`

---

## 🔗 Integration

### API Connection
- Flutter app connects to Laravel API via `/api/` endpoints
- Authentication uses Laravel Sanctum tokens
- All API requests include `Authorization: Bearer {token}` header

### Data Flow
1. User logs in via Flutter app → Laravel `/api/login`
2. Laravel returns token → Stored in Flutter `SessionManager`
3. Subsequent requests include token → Laravel validates via Sanctum
4. Admin/Teacher web panels use session-based auth

---

## 🗄️ Database
- **Migrations**: 46 migration files
- **Seeders**: Multiple seeders for initial data (Users, Classes, Subjects, Permissions, etc.)

---

## 📝 Notes
- The project uses **Laravel Sanctum** for API authentication
- Flutter app uses **Riverpod** for state management
- Both projects follow modern architectural patterns
- Admin panel uses blade templates (AdminLTE theme)
- Teacher panel has separate web interface

