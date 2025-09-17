# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Raqim (رقيم) is a comprehensive Arabic learning management system built with Flutter, designed for both web and mobile platforms. It features a complete educational ecosystem with course management, user authentication, admin dashboards, payment processing, and community features.

## Development Commands

### Running the Application
```bash
# Web development (recommended for admin features)
flutter run -d web-server --web-hostname localhost --web-port 9000

# General web run
flutter run -d web

# Mobile development
flutter run -d android
flutter run -d ios
```

### Code Quality
```bash
# Analyze code for issues
flutter analyze

# Format code
dart format .

# Run tests
flutter test

# Run specific test file
flutter test test/widget_test.dart
```

### Build Commands
```bash
# Build for web
flutter build web

# Build for Android
flutter build apk
flutter build appbundle

# Build for iOS
flutter build ios
```

## Architecture Overview

### Core Architecture Patterns

**Feature-Based Organization**: The codebase follows a feature-based folder structure with shared core components:
- `lib/features/` - Feature modules (auth, courses, admin, payment, etc.)
- `lib/core/` - Shared utilities, themes, constants
- `lib/services/` - Business logic and data services
- `lib/models/` and `lib/data/models/` - Data models (note: duplicated structure)

**State Management**: Uses Provider pattern extensively:
- Each feature has its own provider (e.g., `AdminProvider`, `CoursesProvider`)
- Global providers registered in `main.dart`
- `SyncService` acts as a central data synchronization layer

**Service Layer Architecture**:
- `AuthServiceFactory` - Creates platform-specific auth implementations
- `SyncService` - Singleton service for real-time data synchronization
- `UnifiedDataService` - Centralizes data operations
- `DatabaseService` - Abstracts database operations with fallbacks

### Data Flow

1. **Authentication Flow**: `AuthServiceFactory` → Platform-specific auth service → `AuthProvider` state updates
2. **Data Synchronization**: `SyncService` (singleton) ↔ `UnifiedDataService` ↔ `DatabaseService` layers
3. **Admin Operations**: Admin screens → `AdminProvider` → `SyncService` → Database layers
4. **Course Management**: Multiple providers (`CoursesProvider`, `CourseProvider`) handle different course views

### Key Architectural Components

**Router Configuration**: Centralized in `main.dart` using GoRouter with:
- Feature-based route organization
- Admin route protection
- Redirect logic for authentication states

**Localization**: Arabic-first with RTL support:
- `AppLocalizations` custom implementation
- RTL direction handling in root `Directionality` widget
- Arabic constants in `AppConstants`

**Theme System**: Consistent design system in `core/theme/`:
- `AppColors`, `AppTextStyles`, `AppTheme`
- Material Design 3 components with Arabic typography

## Admin System

The admin system is a complete management dashboard accessible at `/admin-login`:

**Authentication**: Separate admin auth system with demo credentials:
- Email: `admin@raqim.com`, Password: `admin123`
- Additional roles: `super@raqim.com`, `manager@raqim.com`

**Admin Features**:
- Dashboard with analytics and charts (using fl_chart)
- Course management (CRUD operations)
- User management
- Content management (news, categories)
- Financial management and transactions

**Admin Navigation**:
- Desktop: Sidebar navigation
- Mobile: Drawer navigation
- Protected routes with authentication checks

## Data Models

**Important**: The codebase has duplicate model structures:
- `lib/models/` - Legacy models (Course, UserModel)
- `lib/data/models/` - New models (CourseModel, UserModel)
- When working with courses, use `CourseModel` from `data/models/`

**CourseModel Structure**:
- Rich model with instructor details, modules, lessons, reviews
- Includes enrollment tracking and progress
- Supports both free and paid courses

## Firebase Integration

Firebase is configured but partially implemented:
- `firebase_options.dart` contains configuration
- Firestore integration available but with fallbacks
- Analytics service with factory pattern for web/mobile

## Key Development Notes

**Multi-Language Support**:
- Primary language is Arabic with RTL layout
- English translations available in localization files
- UI components designed for Arabic-first experience

**Responsive Design**:
- Adaptive layouts for desktop, tablet, and mobile
- Admin dashboard optimized for desktop use
- Course catalog works across all screen sizes

**Development Workflow**:
- Use hot reload for faster development
- Admin features require web platform for full functionality
- Mock data services provide fallbacks when backend is unavailable

**Error Handling**:
- Services implement graceful fallbacks (real data → mock data)
- User-friendly error messages in Arabic
- Comprehensive logging with `Logger` utility

## Testing

Currently minimal test coverage with default widget test. When adding tests:
- Place tests in `test/` directory
- Follow the existing naming convention
- Focus on critical user flows and data models