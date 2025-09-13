# Raqim Learning Platform - Project Structure

## 📁 Project Overview
A comprehensive Flutter-based e-learning platform for AI and Machine Learning courses with mock data support.

## 📂 Directory Structure

### 🎯 Root Files
```
├── pubspec.yaml                # Flutter project configuration
├── pubspec.lock               # Dependency lock file
├── analysis_options.yaml      # Dart analyzer configuration
├── README.md                  # Project documentation
├── README_BACKEND.md          # Backend documentation
├── PROJECT_STRUCTURE.md       # This file
├── .gitignore                 # Git ignore configuration
├── devtools_options.yaml      # DevTools configuration
└── nul                        # Null device file
```

### 📱 Flutter Application (`/lib`)

#### Core Structure
```
lib/
├── main.dart                  # Application entry point
├── firebase_options.dart      # Firebase configuration
└── router.dart               # App routing configuration
```

#### Core Module (`/lib/core`)
```
lib/core/
├── constants/
│   └── app_constants.dart    # Application constants
├── theme/
│   └── app_theme.dart        # Application theming
└── utils/
    ├── helpers.dart           # Utility functions
    └── validators.dart        # Form validators
```

#### Data Layer (`/lib/data`)
```
lib/data/
├── models/
│   ├── certificate_model.dart # Certificate data model
│   ├── course_model.dart      # Course data model
│   ├── news_model.dart        # News data model
│   └── user_model.dart        # User data model
└── repositories/
    └── [Repository files]
```

#### Services (`/lib/services`)
```
lib/services/
├── api_service.dart           # API service (deprecated)
├── mock_data_service.dart     # Mock data provider (NEW)
├── cache_service.dart         # Local caching service
├── analytics/
│   └── analytics_service.dart # Analytics tracking
└── auth/
    ├── auth_service.dart      # Authentication service
    └── firebase_auth_service.dart # Firebase auth
```

#### Features (`/lib/features`)
```
lib/features/
├── auth/
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── forgot_password_screen.dart
│   │   ├── otp_verification_screen.dart
│   │   └── email_verification_screen.dart
│   ├── widgets/
│   │   └── responsive_auth_layout.dart
│   └── providers/
│       └── auth_provider.dart
│
├── courses/
│   ├── screens/
│   │   └── courses_list_screen.dart
│   ├── widgets/
│   │   └── [Course widgets]
│   └── providers/
│       └── courses_provider.dart
│
├── dashboard/
│   ├── screens/
│   │   ├── dashboard_screen.dart
│   │   └── modern_home_screen.dart
│   └── widgets/
│       └── [Dashboard widgets]
│
├── profile/
│   ├── screens/
│   │   └── profile_screen.dart
│   └── widgets/
│       └── [Profile widgets]
│
├── certificates/
│   ├── screens/
│   │   └── [Certificate screens]
│   └── providers/
│       └── certificates_provider.dart
│
├── community/
│   ├── screens/
│   │   └── community_feed_screen.dart
│   └── widgets/
│       └── [Community widgets]
│
├── news/
│   ├── screens/
│   │   └── [News screens]
│   └── providers/
│       └── news_provider.dart
│
├── payment/
│   ├── screens/
│   │   └── payment_methods_screen.dart
│   └── widgets/
│       └── [Payment widgets]
│
└── settings/
    ├── screens/
    │   └── settings_screen.dart
    └── widgets/
        └── [Settings widgets]
```

#### Legacy Screens (`/lib/screens`)
```
lib/screens/
├── course_detail_screen.dart
├── courses_screen.dart
├── my_courses_screen.dart
└── simple_course_detail_screen.dart
```

#### Models (`/lib/models`)
```
lib/models/
├── course.dart               # Legacy course model
└── user.dart                 # Legacy user model
```

#### Providers (`/lib/providers`)
```
lib/providers/
├── course_provider.dart      # Course state management
└── user_provider.dart        # User state management
```

#### Widgets (`/lib/widgets`)
```
lib/widgets/
├── common/
│   ├── modern_button.dart
│   ├── modern_card.dart
│   ├── modern_course_card.dart
│   ├── modern_search_field.dart
│   ├── pill_button.dart
│   └── welcome_header.dart
├── course_card.dart          # Course card widget
└── [Other widgets]
```

### 🌐 Web Assets (`/web`)
```
web/
├── index.html                # Web app entry point
├── manifest.json             # PWA manifest
├── favicon.png              # Website favicon
├── icons/                   # Web app icons
│   ├── Icon-192.png
│   ├── Icon-512.png
│   └── Icon-maskable-512.png
└── js/
    ├── api.js               # JavaScript API utilities
    └── main.js              # Main JavaScript file
```

### 🖥️ Backend (`/backend`)
```
backend/
├── server.js                # Express server entry point
├── package.json             # Node.js dependencies
├── package-lock.json        # Dependency lock file
├── seedData.js             # Database seeding script
├── .env                    # Environment variables
│
├── config/
│   └── db.js               # Database configuration
│
├── controllers/
│   ├── authController.js   # Authentication logic
│   ├── courseController.js # Course management
│   ├── lessonController.js # Lesson management
│   ├── newsController.js   # News management
│   ├── paymentController.js # Payment processing
│   └── progressController.js # Progress tracking
│
├── middleware/
│   ├── auth.js             # Authentication middleware
│   └── error.js            # Error handling middleware
│
├── models/
│   ├── Course.js           # Course schema
│   ├── Lesson.js           # Lesson schema
│   ├── News.js             # News schema
│   ├── Progress.js         # Progress schema
│   └── User.js             # User schema
│
├── routes/
│   ├── auth.js             # Auth routes
│   ├── courses.js          # Course routes
│   ├── lessons.js          # Lesson routes
│   └── [Other routes]
│
├── seeds/
│   └── seedCourses.js      # Course seeding data
│
└── uploads/                # File upload directory
    ├── avatars/
    ├── thumbnails/
    └── materials/
```

### 📱 Platform Specific
```
├── android/                # Android configuration
├── ios/                    # iOS configuration
├── linux/                  # Linux configuration
├── macos/                  # macOS configuration
└── windows/                # Windows configuration
```

### 🛠️ Development & Build
```
├── .dart_tool/             # Dart tooling
├── build/                  # Build output
├── .claude/                # Claude AI settings
│   └── settings.local.json
└── test/                   # Test files
```

## 🔑 Key Files

### Critical Application Files
1. **`lib/main.dart`** - Application entry point
2. **`lib/router.dart`** - Navigation configuration
3. **`lib/services/mock_data_service.dart`** - Mock data provider
4. **`lib/features/courses/providers/courses_provider.dart`** - Course state management
5. **`lib/features/auth/providers/auth_provider.dart`** - Authentication state

### Configuration Files
1. **`pubspec.yaml`** - Flutter dependencies and assets
2. **`.env`** - Environment variables (backend)
3. **`firebase_options.dart`** - Firebase configuration

### Data Models
1. **`lib/data/models/course_model.dart`** - Course data structure
2. **`lib/data/models/user_model.dart`** - User data structure
3. **`lib/models/course.dart`** - Legacy course model

## 📦 Key Dependencies

### Flutter Dependencies
- `flutter` - Core framework
- `provider` - State management
- `go_router` - Navigation
- `http` - HTTP client
- `shared_preferences` - Local storage
- `firebase_core` - Firebase core
- `firebase_analytics` - Analytics
- `chewie` - Video player
- `image_picker` - Image selection
- `fl_chart` - Charts

### Backend Dependencies
- `express` - Web framework
- `mongoose` - MongoDB ODM
- `jsonwebtoken` - JWT authentication
- `bcrypt` - Password hashing
- `multer` - File uploads
- `cors` - CORS handling
- `dotenv` - Environment variables

## 🚀 Current State

### ✅ Implemented Features
- Mock data service for offline functionality
- Local authentication system
- Course browsing and enrollment
- Profile management
- Settings screen
- Responsive design
- Arabic language support

### 🔧 Recent Changes
- Replaced API calls with mock data service
- Fixed instructor field type mismatches
- Updated image URLs to use picsum.photos
- Removed backend API dependencies

### 📝 Notes
- Application runs completely offline with mock data
- Firebase is configured but not required
- Backend server exists but is not currently used
- All course data is generated from `MockDataService`

## 🎯 File Count Summary
- **Dart Files**: ~150+
- **JavaScript Files**: ~20+
- **Configuration Files**: ~15
- **Asset Files**: Various images and icons
- **Total Project Files**: 500+

---
*Last Updated: January 2025*
*Platform: Raqim Learning Platform v1.0*