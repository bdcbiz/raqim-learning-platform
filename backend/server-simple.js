const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = 5000;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cors({
  origin: ['http://localhost:3000', 'http://localhost:3001', 'http://localhost:8080', 'http://localhost:4200'],
  credentials: true
}));

// Static files
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// In-memory persistent storage (in production, use a real database)
const userDatabase = new Map(); // Map of email -> user data
const tokenToUser = new Map(); // Map of token -> userId
const userEnrollments = new Map(); // Map of userId -> Set of courseIds
let userIdCounter = 1;

const mockCourses = [
  {
    _id: '1',
    title: 'Introduction to Programming',
    titleAr: 'مقدمة في البرمجة',
    description: 'Learn the basics of programming with Python',
    descriptionAr: 'تعلم أساسيات البرمجة باستخدام بايثون',
    thumbnail: '/images/course1.jpg',
    instructor: { _id: '1', name: 'أحمد محمد' },
    category: 'programming',
    level: 'beginner',
    price: 0,
    isFree: true,
    totalLessons: 12,
    rating: 4.5,
    numberOfRatings: 234,
    language: 'both'
  },
  {
    _id: '2',
    title: 'Advanced Mathematics',
    titleAr: 'الرياضيات المتقدمة',
    description: 'Master calculus and linear algebra',
    descriptionAr: 'أتقن التفاضل والتكامل والجبر الخطي',
    thumbnail: '/images/course2.jpg',
    instructor: { _id: '2', name: 'فاطمة علي' },
    category: 'mathematics',
    level: 'advanced',
    price: 199,
    isFree: false,
    totalLessons: 24,
    rating: 4.8,
    numberOfRatings: 156,
    language: 'ar'
  },
  {
    _id: '3',
    title: 'Web Development Bootcamp',
    titleAr: 'معسكر تطوير الويب',
    description: 'Build modern web applications from scratch',
    descriptionAr: 'بناء تطبيقات ويب حديثة من الصفر',
    thumbnail: '/images/course3.jpg',
    instructor: { _id: '3', name: 'خالد عبدالله' },
    category: 'technology',
    level: 'intermediate',
    price: 299,
    isFree: false,
    totalLessons: 48,
    rating: 4.9,
    numberOfRatings: 512,
    language: 'both'
  }
];

const mockUser = {
  _id: '1',
  name: 'Test User',
  email: 'test@example.com',
  role: 'student',
  avatar: null
};

// Helper function to get user from token
function getUserFromToken(authHeader) {
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return null;
  }
  const token = authHeader.replace('Bearer ', '');
  const userId = tokenToUser.get(token);
  if (!userId) return null;
  
  // Find user by ID in the database
  for (const [email, user] of userDatabase) {
    if (user.id === userId) {
      return user;
    }
  }
  return null;
}

// Routes

// Health check
app.get('/api/v1/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Raqim Learning Platform API is running (Test Mode)',
    timestamp: new Date().toISOString()
  });
});

// Auth routes
app.post('/api/v1/auth/register', (req, res) => {
  const { name, email, password } = req.body;
  
  // Check if user already exists
  if (userDatabase.has(email)) {
    return res.status(400).json({
      success: false,
      error: 'User already exists with this email'
    });
  }
  
  const userId = 'user_' + userIdCounter++;
  const token = 'mock-jwt-token-' + Date.now();
  
  const user = {
    id: userId,
    name,
    email,
    password, // In production, hash this!
    role: 'student',
    avatar: null,
    createdAt: new Date().toISOString()
  };
  
  // Store user in database
  userDatabase.set(email, user);
  tokenToUser.set(token, userId);
  userEnrollments.set(userId, new Set());
  
  res.status(201).json({
    success: true,
    token,
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      avatar: user.avatar
    }
  });
});

app.post('/api/v1/auth/login', (req, res) => {
  const { email, password } = req.body;
  
  // Check if user exists
  const user = userDatabase.get(email);
  
  if (!user) {
    return res.status(401).json({
      success: false,
      error: 'Invalid email or password'
    });
  }
  
  // Check password (in production, compare hashed passwords)
  if (user.password !== password) {
    return res.status(401).json({
      success: false,
      error: 'Invalid email or password'
    });
  }
  
  // Generate new token for this session
  const token = 'mock-jwt-token-' + Date.now();
  tokenToUser.set(token, user.id);
  
  // Ensure user has enrollments set
  if (!userEnrollments.has(user.id)) {
    userEnrollments.set(user.id, new Set());
  }
  
  res.status(200).json({
    success: true,
    token,
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      avatar: user.avatar
    }
  });
});

app.get('/api/v1/auth/me', (req, res) => {
  const user = getUserFromToken(req.headers.authorization);
  
  if (!user) {
    return res.status(401).json({
      success: false,
      error: 'Not authenticated'
    });
  }
  
  res.status(200).json({
    success: true,
    data: user
  });
});

// Course routes
app.get('/api/v1/courses', (req, res) => {
  const user = getUserFromToken(req.headers.authorization);
  let coursesWithEnrollment = [...mockCourses];
  
  if (user) {
    const enrollments = userEnrollments.get(user.id) || new Set();
    coursesWithEnrollment = mockCourses.map(course => ({
      ...course,
      isEnrolled: enrollments.has(course._id)
    }));
  }
  
  res.status(200).json({
    success: true,
    count: coursesWithEnrollment.length,
    totalPages: 1,
    currentPage: 1,
    data: coursesWithEnrollment
  });
});

app.get('/api/v1/courses/:id', (req, res) => {
  const user = getUserFromToken(req.headers.authorization);
  const course = mockCourses.find(c => c._id === req.params.id);
  
  if (course) {
    let courseWithEnrollment = { ...course };
    
    if (user) {
      const enrollments = userEnrollments.get(user.id) || new Set();
      courseWithEnrollment.isEnrolled = enrollments.has(course._id);
    }
    
    res.status(200).json({
      success: true,
      data: courseWithEnrollment
    });
  } else {
    res.status(404).json({
      success: false,
      error: 'Course not found'
    });
  }
});

app.post('/api/v1/courses/:id/enroll', (req, res) => {
  const user = getUserFromToken(req.headers.authorization);
  
  if (!user) {
    return res.status(401).json({
      success: false,
      error: 'Not authenticated'
    });
  }
  
  const courseId = req.params.id;
  const course = mockCourses.find(c => c._id === courseId);
  
  if (!course) {
    return res.status(404).json({
      success: false,
      error: 'Course not found'
    });
  }
  
  const enrollments = userEnrollments.get(user.id) || new Set();
  
  if (enrollments.has(courseId)) {
    return res.status(400).json({
      success: false,
      error: 'Already enrolled in this course'
    });
  }
  
  enrollments.add(courseId);
  userEnrollments.set(user.id, enrollments);
  
  res.status(200).json({
    success: true,
    message: 'Successfully enrolled in course',
    data: {
      courseId,
      enrolledAt: new Date().toISOString()
    }
  });
});

app.get('/api/v1/courses/enrolled', (req, res) => {
  const user = getUserFromToken(req.headers.authorization);
  
  if (!user) {
    return res.status(401).json({
      success: false,
      error: 'Not authenticated'
    });
  }
  
  const enrollments = userEnrollments.get(user.id) || new Set();
  const enrolledCourses = mockCourses.filter(course => 
    enrollments.has(course._id)
  ).map(course => ({
    ...course,
    isEnrolled: true,
    enrolledAt: new Date().toISOString()
  }));
  
  res.status(200).json({
    success: true,
    count: enrolledCourses.length,
    data: enrolledCourses
  });
});

// Lesson routes
app.get('/api/v1/lessons/course/:courseId', (req, res) => {
  const mockLessons = [
    {
      _id: '1',
      title: 'Getting Started',
      titleAr: 'البداية',
      type: 'video',
      duration: 15,
      isFree: true
    },
    {
      _id: '2',
      title: 'Variables and Data Types',
      titleAr: 'المتغيرات وأنواع البيانات',
      type: 'video',
      duration: 20,
      isFree: false
    }
  ];
  
  res.status(200).json({
    success: true,
    count: mockLessons.length,
    data: mockLessons
  });
});

// Progress routes
app.get('/api/v1/progress/statistics', (req, res) => {
  res.status(200).json({
    success: true,
    data: {
      totalCourses: 3,
      completedCourses: 1,
      inProgressCourses: 2,
      totalLessonsCompleted: 15,
      totalTimeSpent: 320,
      averageProgress: 45,
      currentStreak: 5
    }
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: 'Route not found'
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`
╔════════════════════════════════════════════╗
║                                            ║
║   🚀 Raqim Backend Server (Test Mode)     ║
║                                            ║
║   Server running on: http://localhost:${PORT} ║
║   API Base: http://localhost:${PORT}/api/v1 ║
║                                            ║
║   Ready to accept connections!            ║
║                                            ║
╚════════════════════════════════════════════╝
  `);
});