const mongoose = require('mongoose');
const dotenv = require('dotenv');
const Course = require('../models/Course');
const User = require('../models/User');

dotenv.config({ path: '../.env' });

const seedDatabase = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/raqim_learning');
    console.log('Connected to MongoDB');

    // Clear existing courses
    await Course.deleteMany({});
    console.log('Cleared existing courses');

    // Create or get instructor
    let instructor = await User.findOne({ email: 'instructor@raqim.com' });
    if (!instructor) {
      instructor = await User.create({
        name: 'المدرب الافتراضي',
        email: 'instructor@raqim.com',
        password: 'password123',
        role: 'teacher'
      });
    }
    console.log('Instructor ready:', instructor._id);

    // Create courses one by one
    const course1 = await Course.create({
      title: 'Programming Basics',
      titleAr: 'أساسيات البرمجة',
      description: 'Learn programming fundamentals from scratch',
      descriptionAr: 'تعلم أساسيات البرمجة من الصفر',
      category: 'programming',
      instructor: instructor._id,
      price: 0,
      level: 'beginner',
      duration: 30,
      thumbnail: 'https://via.placeholder.com/400x300/4A90E2/FFFFFF?text=Programming',
      rating: 4.5,
      numberOfRatings: 150,
      isPublished: true
    });
    console.log('Created course:', course1.title);

    const course2 = await Course.create({
      title: 'Web Development',
      titleAr: 'تطوير تطبيقات الويب',
      description: 'Master web development with React and Node.js',
      descriptionAr: 'احترف تطوير تطبيقات الويب باستخدام React و Node.js',
      category: 'technology',
      instructor: instructor._id,
      price: 199,
      level: 'intermediate',
      duration: 60,
      thumbnail: 'https://via.placeholder.com/400x300/E74C3C/FFFFFF?text=Web+Dev',
      rating: 4.8,
      numberOfRatings: 230,
      isPublished: true
    });
    console.log('Created course:', course2.title);

    const course3 = await Course.create({
      title: 'Data Science',
      titleAr: 'علم البيانات',
      description: 'Introduction to Data Science and AI',
      descriptionAr: 'مقدمة في علم البيانات والذكاء الاصطناعي',
      category: 'technology',
      instructor: instructor._id,
      price: 299,
      level: 'advanced',
      duration: 90,
      thumbnail: 'https://via.placeholder.com/400x300/2ECC71/FFFFFF?text=Data+Science',
      rating: 4.9,
      numberOfRatings: 180,
      isPublished: true
    });
    console.log('Created course:', course3.title);

    const course4 = await Course.create({
      title: 'Mathematics Fundamentals',
      titleAr: 'أساسيات الرياضيات',
      description: 'Build a strong foundation in mathematics',
      descriptionAr: 'بناء أساس قوي في الرياضيات',
      category: 'mathematics',
      instructor: instructor._id,
      price: 99,
      level: 'beginner',
      duration: 45,
      thumbnail: 'https://via.placeholder.com/400x300/F39C12/FFFFFF?text=Mathematics',
      rating: 4.6,
      numberOfRatings: 120,
      isPublished: true
    });
    console.log('Created course:', course4.title);

    const course5 = await Course.create({
      title: 'Business Strategy',
      titleAr: 'استراتيجية الأعمال',
      description: 'Learn modern business strategies',
      descriptionAr: 'تعلم استراتيجيات الأعمال الحديثة',
      category: 'business',
      instructor: instructor._id,
      price: 149,
      level: 'intermediate',
      duration: 35,
      thumbnail: 'https://via.placeholder.com/400x300/9B59B6/FFFFFF?text=Business',
      rating: 4.4,
      numberOfRatings: 200,
      isPublished: true
    });
    console.log('Created course:', course5.title);

    const course6 = await Course.create({
      title: 'Arabic Language',
      titleAr: 'اللغة العربية',
      description: 'Master the Arabic language',
      descriptionAr: 'إتقان اللغة العربية',
      category: 'languages',
      instructor: instructor._id,
      price: 0,
      level: 'beginner',
      duration: 50,
      thumbnail: 'https://via.placeholder.com/400x300/3498DB/FFFFFF?text=Arabic',
      rating: 4.7,
      numberOfRatings: 165,
      isPublished: true
    });
    console.log('Created course:', course6.title);

    console.log('Database seeded successfully with 6 courses!');
    process.exit(0);
  } catch (error) {
    console.error('Error seeding database:', error.message);
    process.exit(1);
  }
};

seedDatabase();