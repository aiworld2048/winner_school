# Winner School Project Structure

## Overview
This is a full-stack educational platform with:
- **Backend**: Laravel 10 (PHP 8.1+)
- **Frontend Web**: Laravel Blade Templates (Admin Panel)
- **Mobile App**: Flutter 3.8.1+ (Dart)

---

## Laravel Backend Structure

### Directory Structure
```
winner_school/
├── app/
│   ├── Console/              # Artisan commands
│   ├── Enums/                # PHP Enums (UserType, TransactionStatus, etc.)
│   ├── Exceptions/           # Exception handlers
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── Admin/        # Admin panel controllers (25 files)
│   │   │   ├── Api/V1/       # API controllers (23 files)
│   │   │   │   ├── Auth/
│   │   │   │   ├── Student/  # Student API endpoints
│   │   │   │   └── Teacher/  # Teacher API endpoints
│   │   │   └── Teacher/      # Web teacher controllers
│   │   ├── Middleware/       # Custom middleware (14 files)
│   │   ├── Requests/         # Form request validation (18 files)
│   │   └── Resources/        # API resources (29 files)
│   ├── Models/               # Eloquent models
│   │   ├── Admin/            # Admin-related models (10 files)
│   │   └── [Core Models]     # User, Lesson, Exam, Essay, VideoLesson, etc.
│   ├── Notifications/        # Laravel notifications
│   ├── Providers/           # Service providers
│   ├── Services/            # Business logic services
│   └── Traits/              # Reusable traits
├── database/
│   ├── migrations/          # 53 migration files
│   └── seeders/             # Database seeders (19 files)
├── resources/
│   ├── views/               # Blade templates (95 files)
│   │   ├── admin/           # Admin panel views
│   │   └── layouts/         # Layout templates
│   ├── css/                 # Stylesheets
│   └── js/                  # JavaScript files
├── routes/
│   ├── api.php              # API routes
│   ├── admin.php            # Admin panel routes
│   ├── web.php              # Web routes
│   └── channels.php         # Broadcasting channels
└── public/                  # Public assets
```

### Key Models
- **User**: Core user model with roles (Admin, Teacher, HeadTeacher, Student)
- **SchoolClass**: Classes/Grades
- **Subject**: Academic subjects
- **AcademicYear**: Academic year management
- **Lesson**: Text-based lessons
- **VideoLesson**: Video-based lessons
- **Exam**: Examinations with questions
- **Essay**: Essay assignments
- **StudentNote**: Student personal notes
- **DictionaryEntry**: Dictionary entries

### API Structure
**Base URL**: `/api/v1`

**Authentication**: Laravel Sanctum (`auth:sanctum` middleware)

**Main API Endpoints**:
- `/login`, `/register`, `/logout`
- `/teacher/*` - Teacher endpoints (dashboard, classes, subjects, students, lessons, exams, essays, video-lessons)
- `/student/*` - Student endpoints (lessons, notes, exams, essays, video-lessons)
- Public endpoints: `/banner`, `/dictionary`, `/public/highlights`

### Admin Panel Structure
**Base URL**: `/admin`

**Key Features**:
- Dashboard
- Staff Management (Teachers, Classes, Subjects)
- Academic Management (Academic Years, Classes, Subjects, Dictionary, Lesson Views)
- Content Management (Exams, Essays, Video Lessons)
- Financial Management (Banks, Payment Types, Deposit/Withdraw Requests)
- Marketing (Banners, Promotions, Ads Video)
- Contact Management

**Middleware**:
- `auth` - Authentication required
- `checkBanned` - Check if user is banned
- `preventPlayerAccess` - Prevent player role access
- `permission:*` - Permission-based access control

### Database Relationships
- **User ↔ SchoolClass**: Many-to-Many (via `class_teacher` pivot table)
- **User ↔ Subject**: Many-to-Many (via `teacher_subject` pivot table)
- **User (Teacher) ↔ User (Student)**: One-to-Many (via `teacher_id`)
- **Lesson ↔ User**: BelongsTo (teacher)
- **VideoLesson ↔ User**: BelongsTo (teacher)
- **Exam ↔ User**: BelongsTo (teacher)
- **Essay ↔ User**: BelongsTo (teacher)

---

## Flutter Mobile App Structure

### Directory Structure
```
school_apk/
├── lib/
│   ├── main.dart            # App entry point
│   ├── app.dart             # Root widget
│   ├── core/
│   │   ├── constants/       # API constants, app constants
│   │   ├── network/         # API client, exceptions
│   │   ├── providers/       # Core providers (session)
│   │   ├── services/        # Core services (session manager)
│   │   └── theme/           # App theme (colors, typography, spacing)
│   ├── features/
│   │   ├── auth/            # Authentication feature
│   │   │   ├── data/        # Auth repository
│   │   │   ├── models/      # Auth models (AuthUser)
│   │   │   ├── presentation/ # Login, Register screens
│   │   │   └── providers/   # Auth providers/controllers
│   │   ├── student/         # Student feature
│   │   │   ├── data/        # Repositories (lesson, exam, essay, video_lesson, wallet)
│   │   │   ├── models/      # Student models
│   │   │   ├── presentation/ # Student screens (11 screens)
│   │   │   └── providers/   # Student providers
│   │   ├── teacher/         # Teacher feature
│   │   │   ├── data/        # Repositories (essay, exam, teacher)
│   │   │   ├── models/      # Teacher models
│   │   │   ├── presentation/ # Teacher screens (8 screens)
│   │   │   └── providers/   # Teacher providers
│   │   ├── dictionary/      # Dictionary feature
│   │   ├── media/           # Media hub feature
│   │   ├── marketing/       # Marketing/promotions
│   │   ├── student_notes/   # Student notes feature
│   │   └── shared/          # Shared widgets
│   └── common/
│       └── widgets/         # Reusable widgets
├── android/                 # Android-specific files
├── ios/                     # iOS-specific files
├── pubspec.yaml             # Dependencies
└── analysis_options.yaml    # Linting rules
```

### Architecture Pattern
**Feature-Based Architecture** with **Clean Architecture** principles:
- **Data Layer**: Repositories, Models
- **Presentation Layer**: Screens, Widgets
- **Provider Layer**: Riverpod providers for state management

### State Management
**Riverpod 2.5.1** - Used throughout the app:
- `StateNotifierProvider` for complex state
- `FutureProvider` for async data
- `StateProvider` for simple state
- `Provider` for dependencies

### Key Features

#### Authentication
- Login/Register screens
- Session management (SharedPreferences)
- Role-based routing (Student, Teacher, HeadTeacher)
- AuthGate widget for route protection

#### Student Features
- **Lessons**: View text-based lessons with HTML content
- **Video Lessons**: View video lessons (YouTube, Vimeo, direct URLs)
- **Exams**: List and take exams
- **Essays**: View and submit essays (with payment)
- **Notes**: Personal notes management
- **Wallet**: Balance, deposit, withdraw
- **Calculator**: Built-in calculator
- **Profile**: User profile management

#### Teacher Features
- **Dashboard**: Overview statistics
- **Classes**: Manage assigned classes
- **Subjects**: View assigned subjects
- **Students**: Manage students
- **Lessons**: Create/edit text lessons
- **Exams**: Create/edit exams with questions
- **Essays**: Create/edit essay assignments
- **Video Lessons**: Create/edit video lessons
- **Profile**: Teacher profile

### Key Dependencies
```yaml
flutter_riverpod: ^2.5.1      # State management
dio: ^5.7.0                    # HTTP client
shared_preferences: ^2.3.2      # Local storage
flutter_html: ^3.0.0-beta.2    # HTML rendering
flutter_tts: ^3.8.3            # Text-to-speech
video_player: ^2.8.2           # Video playback
chewie: ^1.7.4                 # Video player UI
url_launcher: ^6.2.5           # External URL launcher
google_fonts: ^6.2.1           # Custom fonts
intl: ^0.19.0                  # Internationalization
image_picker: ^1.0.7           # Image picking
```

### Navigation Structure
- **AuthGate** → Routes to Login or appropriate Shell
- **StudentShell** → Student navigation with drawer
- **TeacherShell** → Teacher navigation with drawer

### API Integration
- **ApiClient**: Centralized HTTP client using Dio
- **ApiException**: Custom exception handling
- **Session Management**: Token-based authentication
- **Error Handling**: Detailed error messages from API

---

## Key Relationships & Patterns

### Laravel Patterns
1. **Repository Pattern**: Services layer for business logic
2. **Resource Pattern**: API resources for data transformation
3. **Form Requests**: Validation in dedicated request classes
4. **Middleware**: Role and permission-based access control
5. **Eloquent Relationships**: HasMany, BelongsTo, BelongsToMany

### Flutter Patterns
1. **Repository Pattern**: Data layer abstraction
2. **Provider Pattern**: State management with Riverpod
3. **Feature Modules**: Self-contained feature modules
4. **Widget Composition**: Reusable widgets
5. **Error Handling**: Try-catch with user-friendly messages

---

## Database Schema Highlights

### Core Tables
- `users` - All user types (admin, teacher, student)
- `school_classes` - Classes/grades
- `subjects` - Academic subjects
- `academic_years` - Academic year management
- `lessons` - Text-based lessons
- `video_lessons` - Video lessons
- `exams` - Examinations
- `exam_questions` - Exam questions
- `exam_question_options` - Multiple choice options
- `essays` - Essay assignments
- `student_notes` - Student personal notes
- `dictionary_entries` - Dictionary entries

### Pivot Tables
- `class_teacher` - Many-to-many: Classes ↔ Teachers
- `teacher_subject` - Many-to-many: Teachers ↔ Subjects
- `class_subject` - Many-to-many: Classes ↔ Subjects

### View Tracking Tables
- `lesson_views` - Track lesson views
- `essay_views` - Track essay views
- `video_lesson_views` - Track video views (with payment)

---

## Deployment

### Laravel Deployment
1. Run `composer install --no-dev`
2. Run `php artisan migrate`
3. Clear caches: `php artisan cache:clear`, `config:clear`, `route:clear`, `view:clear`
4. Run `composer dump-autoload`
5. Set proper permissions on `storage/` and `bootstrap/cache/`

### Flutter Deployment
1. Run `flutter pub get`
2. Build APK: `flutter build apk --release`
3. Build iOS: `flutter build ios --release`

---

## Security Features

### Laravel
- Laravel Sanctum for API authentication
- CSRF protection
- Password hashing
- Role-based access control (RBAC)
- Permission middleware
- Input validation via Form Requests

### Flutter
- Token-based authentication
- Secure storage (SharedPreferences)
- API error handling
- Input validation
- Role-based UI routing

---

## Recent Features Added
1. **Multi-Teacher Class Assignment**: Classes can have multiple teachers
2. **Text-to-Speech**: TTS for essays and lessons
3. **Video Lessons**: Video lesson management and playback
4. **Payment Integration**: 100 MMK charge for essays and video lessons
5. **Improved Error Handling**: Better error messages in Flutter
6. **Banner Removal**: Removed banner section from Flutter app

---

## Notes
- The project uses a monorepo structure (Laravel + Flutter in same repo)
- Flutter app is in `school_apk/` directory
- Laravel admin panel uses AdminLTE theme
- Flutter app uses Material Design 3
- Both projects share the same database
- API versioning: `/api/v1/`
