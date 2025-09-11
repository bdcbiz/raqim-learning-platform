const mongoose = require('mongoose');
const dotenv = require('dotenv');
const Course = require('../models/Course');
const User = require('../models/User');

dotenv.config({ path: '../.env' });

// First, we'll create a dummy instructor
const createInstructor = async () => {
  const instructor = await User.findOne({ email: 'instructor@raqim.com' });
  if (instructor) return instructor._id;
  
  const newInstructor = await User.create({
    name: 'المدرب الافتراضي',
    email: 'instructor@raqim.com',
    password: 'password123',
    role: 'teacher'
  });
  return newInstructor._id;
};

const createCourses = (instructorId) => [
  {
    title: 'Programming Basics',
    titleAr: 'أساسيات البرمجة',
    description: 'Learn programming fundamentals from scratch',
    descriptionAr: 'تعلم أساسيات البرمجة من الصفر',
    category: 'programming',
    instructor: instructorId,
    price: 0,
    level: 'beginner',
    duration: 30,
    thumbnail: 'https://via.placeholder.com/400x300/4A90E2/FFFFFF?text=Programming+Basics',
    rating: 4.5,
    numberOfRatings: 150,
    isPublished: true,
    whatYouWillLearn: ['أساسيات البرمجة', 'المنطق البرمجي', 'حل المشكلات'],
    requirements: ['جهاز كمبيوتر', 'رغبة في التعلم']
  },
  {
    title: 'Web Development',
    titleAr: 'تطوير تطبيقات الويب',
    description: 'Master web development with React and Node.js',
    descriptionAr: 'احترف تطوير تطبيقات الويب باستخدام React و Node.js',
    category: 'technology',
    instructor: instructorId,
    price: 199,
    level: 'intermediate',
    duration: 60,
    thumbnail: 'https://via.placeholder.com/400x300/E74C3C/FFFFFF?text=Web+Development',
    rating: 4.8,
    numberOfRatings: 230,
    isPublished: true,
    whatYouWillLearn: ['React.js', 'Node.js', 'تطوير APIs', 'قواعد البيانات'],
    requirements: ['معرفة أساسيات البرمجة', 'HTML و CSS']
  },
  {
    title: 'Data Science and AI',
    titleAr: 'علم البيانات والذكاء الاصطناعي',
    description: 'Comprehensive introduction to Data Science and AI',
    descriptionAr: 'مقدمة شاملة في علم البيانات والذكاء الاصطناعي',
    category: 'technology',
    instructor: instructorId,
    price: 299,
    level: 'advanced',
    duration: 90,
    thumbnail: 'https://via.placeholder.com/400x300/2ECC71/FFFFFF?text=Data+Science',
    rating: 4.9,
    numberOfRatings: 180,
    isPublished: true,
    whatYouWillLearn: ['Python للعلوم', 'Machine Learning', 'Deep Learning', 'تحليل البيانات'],
    requirements: ['معرفة بالبرمجة', 'أساسيات الرياضيات']
  },
  {
    title: 'Graphic Design',
    titleAr: 'تصميم الجرافيك',
    description: 'Learn graphic design fundamentals with Adobe Creative Suite',
    descriptionAr: 'تعلم أساسيات التصميم الجرافيكي باستخدام Adobe Creative Suite',
    category: 'arts',
    instructor: instructorId,
    price: 149,
    level: 'beginner',
    duration: 45,
    thumbnail: 'https://via.placeholder.com/400x300/F39C12/FFFFFF?text=Graphic+Design',
    rating: 4.6,
    numberOfRatings: 120,
    isPublished: true,
    whatYouWillLearn: ['Photoshop', 'Illustrator', 'أساسيات التصميم', 'نظرية الألوان'],
    requirements: ['جهاز كمبيوتر', 'برامج Adobe']
  },
  {
    title: 'Digital Marketing',
    titleAr: 'التسويق الرقمي',
    description: 'Modern digital marketing strategies',
    descriptionAr: 'استراتيجيات التسويق الرقمي الحديثة',
    category: 'business',
    instructor: instructorId,
    price: 99,
    level: 'beginner',
    duration: 25,
    thumbnail: 'https://via.placeholder.com/400x300/9B59B6/FFFFFF?text=Digital+Marketing',
    rating: 4.4,
    numberOfRatings: 200,
    isPublished: true,
    whatYouWillLearn: ['SEO', 'Social Media Marketing', 'Content Marketing', 'Email Marketing'],
    requirements: ['لا يوجد متطلبات مسبقة']
  },
  {
    title: 'Mobile App Development',
    titleAr: 'تطوير تطبيقات الموبايل',
    description: 'Build professional mobile apps with Flutter',
    descriptionAr: 'بناء تطبيقات موبايل احترافية باستخدام Flutter',
    category: 'technology',
    instructor: instructorId,
    price: 249,
    level: 'intermediate',
    duration: 70,
    thumbnail: 'https://via.placeholder.com/400x300/3498DB/FFFFFF?text=Mobile+Apps',
    rating: 4.7,
    numberOfRatings: 165,
    isPublished: true,
    whatYouWillLearn: ['Flutter', 'Dart', 'تصميم UI/UX', 'نشر التطبيقات'],
    requirements: ['معرفة أساسية بالبرمجة']
  }
];

const seedDatabase = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/raqim', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log('Connected to MongoDB');

    // Create or get instructor
    const instructorId = await createInstructor();
    console.log('Instructor ready:', instructorId);

    // Clear existing courses
    await Course.deleteMany({});
    console.log('Cleared existing courses');

    // Create courses with instructor ID
    const coursesToInsert = createCourses(instructorId);

    // Insert new courses
    const insertedCourses = await Course.insertMany(coursesToInsert);
    console.log(`Inserted ${insertedCourses.length} courses`);

    console.log('Database seeded successfully!');
    process.exit(0);
  } catch (error) {
    console.error('Error seeding database:', error);
    process.exit(1);
  }
};

seedDatabase();