# Raqim Learning Platform - Complete Setup Guide

## Project Structure
```
raqim/
├── backend/           # Node.js + Express + MongoDB backend
├── lib/              # Flutter mobile/web app
├── web/              # Web frontend
└── README_BACKEND.md # This file
```

## Prerequisites
- Node.js (v14+)
- MongoDB (local or cloud)
- Flutter SDK
- Git

## Backend Setup

### 1. Install MongoDB
Download and install MongoDB from: https://www.mongodb.com/try/download/community

Or use MongoDB Atlas (cloud): https://www.mongodb.com/cloud/atlas

### 2. Configure Environment Variables
Edit `backend/.env` file:
```env
NODE_ENV=development
PORT=5000
MONGODB_URI=mongodb://localhost:27017/raqim_learning  # Update with your MongoDB URI
JWT_SECRET=your_super_secret_jwt_key_change_this_in_production
JWT_EXPIRE=30d
```

### 3. Install Dependencies & Run Backend
```bash
cd backend
npm install
npm run dev
```

The backend will run on http://localhost:5000

### 4. Test Backend
Open browser and go to: http://localhost:5000/api/v1/health

## Flutter App Setup

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run Flutter App
For web:
```bash
flutter run -d chrome
```

For Android:
```bash
flutter run -d android
```

For iOS:
```bash
flutter run -d ios
```

## Web Frontend Setup

### 1. Open Web App
Open `web/app.html` in a browser

Or use a local server:
```bash
cd web
python -m http.server 8080
```
Then open: http://localhost:8080/app.html

## API Endpoints

### Authentication
- POST `/api/v1/auth/register` - Register new user
- POST `/api/v1/auth/login` - Login
- GET `/api/v1/auth/me` - Get current user
- PUT `/api/v1/auth/updateprofile` - Update profile
- PUT `/api/v1/auth/updatepassword` - Update password

### Courses
- GET `/api/v1/courses` - Get all courses
- GET `/api/v1/courses/:id` - Get single course
- POST `/api/v1/courses` - Create course (teacher/admin)
- PUT `/api/v1/courses/:id` - Update course (teacher/admin)
- DELETE `/api/v1/courses/:id` - Delete course (teacher/admin)
- POST `/api/v1/courses/:id/enroll` - Enroll in course
- POST `/api/v1/courses/:id/reviews` - Add review

### Lessons
- GET `/api/v1/lessons/course/:courseId` - Get lessons for course
- GET `/api/v1/lessons/:id` - Get single lesson
- POST `/api/v1/lessons` - Create lesson (teacher/admin)
- PUT `/api/v1/lessons/:id` - Update lesson (teacher/admin)
- DELETE `/api/v1/lessons/:id` - Delete lesson (teacher/admin)
- POST `/api/v1/lessons/:id/complete` - Mark lesson complete
- POST `/api/v1/lessons/:id/comment` - Add comment
- POST `/api/v1/lessons/:id/quiz/submit` - Submit quiz

### Progress
- GET `/api/v1/progress` - Get all progress
- GET `/api/v1/progress/course/:courseId` - Get course progress
- GET `/api/v1/progress/statistics` - Get statistics
- POST `/api/v1/progress/course/:courseId/notes` - Add note
- POST `/api/v1/progress/course/:courseId/bookmarks` - Add bookmark
- GET `/api/v1/progress/course/:courseId/certificate` - Get certificate

### Uploads
- POST `/api/v1/upload/avatar` - Upload avatar
- POST `/api/v1/upload/thumbnail` - Upload course thumbnail
- POST `/api/v1/upload/video` - Upload video
- POST `/api/v1/upload/material` - Upload material

## Testing the Complete System

### 1. Create Test User
```bash
curl -X POST http://localhost:5000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "password123"
  }'
```

### 2. Login
```bash
curl -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

Save the returned token for authenticated requests.

### 3. Get Courses
```bash
curl http://localhost:5000/api/v1/courses
```

## Features Implemented

✅ **Backend API**
- User authentication with JWT
- Course management
- Lesson management with different types (video, text, quiz, assignment)
- Progress tracking
- File uploads
- Quiz system
- Review and rating system
- Certificate generation

✅ **Database Models**
- User (students, teachers, admins)
- Course
- Lesson
- Progress
- Reviews and ratings
- Achievements

✅ **Flutter App Integration**
- API service for all endpoints
- Authentication
- Course browsing
- Lesson viewing
- Progress tracking
- File uploads

✅ **Web Frontend Integration**
- API service
- Authentication
- Course display
- User dashboard
- Responsive design

## Production Deployment

### Backend Deployment
1. Update `.env` with production values
2. Set `NODE_ENV=production`
3. Use a process manager like PM2
4. Set up reverse proxy (Nginx/Apache)
5. Enable HTTPS

### Database
1. Use MongoDB Atlas for cloud hosting
2. Enable authentication
3. Set up backups
4. Configure replica sets

### Flutter Web Deployment
```bash
flutter build web
```
Deploy the `build/web` folder to your hosting service.

### Mobile App Deployment
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## Security Notes
- Change JWT_SECRET in production
- Enable CORS for specific domains only
- Use HTTPS in production
- Implement rate limiting
- Add input validation
- Sanitize user inputs
- Enable MongoDB authentication

## Support
For issues or questions, please create an issue in the repository.

## License
MIT License - See LICENSE file for details