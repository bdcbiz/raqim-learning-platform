const mongoose = require('mongoose');
const Course = require('../models/Course');
const User = require('../models/User');
const dotenv = require('dotenv');

dotenv.config();

const courses = [
  {
    title: 'Introduction to Machine Learning',
    titleAr: 'مقدمة في تعلم الآلة',
    description: 'Learn the fundamentals of machine learning and build intelligent models using Python and TensorFlow. This course is designed for beginners who want to enter the world of artificial intelligence.',
    descriptionAr: 'تعلم أساسيات تعلم الآلة وكيفية بناء نماذج ذكية باستخدام Python وTensorFlow. هذا الكورس مصمم للمبتدئين الذين يريدون دخول عالم الذكاء الاصطناعي.',
    thumbnail: 'https://placehold.co/400x300/3B82F6/FFFFFF?text=ML+Course',
    imageUrl: 'https://placehold.co/400x300/3B82F6/FFFFFF?text=ML+Course',
    categories: ['الذكاء الاصطناعي', 'تعلم الآلة', 'البرمجة', 'Python', 'علم البيانات'],
    category: 'Machine Learning', // for backward compatibility
    level: 'Beginner',
    price: 299,
    currency: 'SAR',
    duration: 480, // 8 hours in minutes
    totalLessons: 15,
    requirements: [
      'Basic programming knowledge',
      'Understanding of basic mathematics and statistics',
      'Computer with Python installed'
    ],
    whatYouWillLearn: [
      'Understand the basics of machine learning and AI',
      'Build simple classification and prediction models',
      'Use Python libraries for machine learning',
      'Apply algorithms to real projects'
    ],
    rating: 4.8,
    numberOfRatings: 125,
    numberOfEnrollments: 500,
    isPublished: true,
    publishedAt: new Date('2024-01-01'),
    lessons: [
      { title: 'Introduction to ML', videoUrl: 'https://example.com/lesson1', duration: 30 },
      { title: 'Python Basics for ML', videoUrl: 'https://example.com/lesson2', duration: 45 },
      { title: 'Understanding Data', videoUrl: 'https://example.com/lesson3', duration: 35 }
    ]
  },
  {
    title: 'Natural Language Processing Fundamentals',
    titleAr: 'أساسيات معالجة اللغة الطبيعية',
    description: 'Discover the world of NLP and learn how to build applications that understand and analyze text in Arabic and English.',
    descriptionAr: 'اكتشف عالم معالجة اللغة الطبيعية وتعلم كيفية بناء تطبيقات تفهم وتحلل النصوص العربية والإنجليزية.',
    thumbnail: 'https://placehold.co/400x300/EF4444/FFFFFF?text=NLP+Course',
    imageUrl: 'https://placehold.co/400x300/EF4444/FFFFFF?text=NLP+Course',
    categories: ['الذكاء الاصطناعي', 'معالجة اللغات', 'التعلم العميق', 'Python', 'التطبيقات العملية'],
    category: 'NLP', // for backward compatibility
    level: 'Intermediate',
    price: 599,
    currency: 'SAR',
    duration: 720, // 12 hours
    totalLessons: 20,
    requirements: [
      'Knowledge of Python',
      'Basic understanding of machine learning',
      'Experience with data handling'
    ],
    whatYouWillLearn: [
      'Understand NLP fundamentals',
      'Build sentiment analysis models',
      'Develop smart chatbots',
      'Process Arabic text'
    ],
    rating: 4.9,
    numberOfRatings: 98,
    numberOfEnrollments: 450,
    isPublished: true,
    publishedAt: new Date('2024-01-15'),
    lessons: [
      { title: 'Introduction to NLP', videoUrl: 'https://example.com/nlp1', duration: 40 },
      { title: 'Text Preprocessing', videoUrl: 'https://example.com/nlp2', duration: 35 },
      { title: 'Tokenization and Embeddings', videoUrl: 'https://example.com/nlp3', duration: 45 }
    ]
  },
  {
    title: 'Computer Vision and Deep Learning',
    titleAr: 'الرؤية الحاسوبية والتعلم العميق',
    description: 'Learn how to build advanced computer vision systems using deep learning and neural networks.',
    descriptionAr: 'تعلم كيفية بناء أنظمة رؤية حاسوبية متقدمة باستخدام التعلم العميق والشبكات العصبية.',
    thumbnail: 'https://placehold.co/400x300/10B981/FFFFFF?text=CV+Course',
    imageUrl: 'https://placehold.co/400x300/10B981/FFFFFF?text=CV+Course',
    categories: ['الذكاء الاصطناعي', 'رؤية الحاسوب', 'التعلم العميق', 'Python', 'البحث العلمي'],
    category: 'Computer Vision', // for backward compatibility
    level: 'Advanced',
    price: 799,
    currency: 'SAR',
    duration: 900, // 15 hours
    totalLessons: 25,
    requirements: [
      'Experience with Python',
      'Knowledge of deep learning basics',
      'GPU-enabled computer (recommended)'
    ],
    whatYouWillLearn: [
      'Understand computer vision fundamentals',
      'Build object detection models',
      'Develop face recognition systems',
      'Process and analyze images'
    ],
    rating: 4.7,
    numberOfRatings: 76,
    numberOfEnrollments: 350,
    isPublished: true,
    publishedAt: new Date('2024-02-01'),
    lessons: [
      { title: 'Introduction to Computer Vision', videoUrl: 'https://example.com/cv1', duration: 35 },
      { title: 'Image Processing Basics', videoUrl: 'https://example.com/cv2', duration: 40 },
      { title: 'Convolutional Neural Networks', videoUrl: 'https://example.com/cv3', duration: 50 }
    ]
  },
  {
    title: 'Deep Learning Foundations',
    titleAr: 'أسس التعلم العميق',
    description: 'A comprehensive free course on deep learning and artificial neural networks.',
    descriptionAr: 'دورة مجانية شاملة في التعلم العميق والشبكات العصبية الاصطناعية.',
    thumbnail: 'https://placehold.co/400x300/8B5CF6/FFFFFF?text=DL+Course',
    imageUrl: 'https://placehold.co/400x300/8B5CF6/FFFFFF?text=DL+Course',
    categories: ['الذكاء الاصطناعي', 'التعلم العميق', 'تعلم الآلة', 'Python', 'البحث العلمي'],
    category: 'Deep Learning', // for backward compatibility
    level: 'Intermediate',
    price: 0,
    isFree: true,
    currency: 'SAR',
    duration: 600, // 10 hours
    totalLessons: 18,
    requirements: [
      'Knowledge of machine learning',
      'Programming experience',
      'Understanding of linear algebra'
    ],
    whatYouWillLearn: [
      'Understand neural networks',
      'Build deep learning models',
      'Use TensorFlow and Keras',
      'Apply to various domains'
    ],
    rating: 4.6,
    numberOfRatings: 210,
    numberOfEnrollments: 800,
    isPublished: true,
    publishedAt: new Date('2024-02-15'),
    lessons: [
      { title: 'Neural Network Basics', videoUrl: 'https://example.com/dl1', duration: 30 },
      { title: 'Backpropagation', videoUrl: 'https://example.com/dl2', duration: 35 },
      { title: 'Deep Networks', videoUrl: 'https://example.com/dl3', duration: 40 }
    ]
  }
];

async function seedCourses() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/raqim_db', {
      useNewUrlParser: true,
      useUnifiedTopology: true
    });

    console.log('Connected to MongoDB');

    // Find or create a default instructor
    let instructor = await User.findOne({ email: 'instructor@raqim.com' });

    if (!instructor) {
      instructor = await User.create({
        name: 'Dr. Ahmed Al-Rashid',
        nameAr: 'د. أحمد الرشيد',
        email: 'instructor@raqim.com',
        password: 'password123', // This will be hashed by the User model
        role: 'teacher',
        isVerified: true
      });
      console.log('Created default instructor');
    }

    // Delete existing courses
    await Course.deleteMany({});
    console.log('Cleared existing courses');

    // Add instructor ID to each course
    const coursesWithInstructor = courses.map(course => ({
      ...course,
      instructor: instructor._id
    }));

    // Insert courses
    const insertedCourses = await Course.insertMany(coursesWithInstructor);
    console.log(`Inserted ${insertedCourses.length} courses`);

    // Log course IDs for reference
    insertedCourses.forEach(course => {
      console.log(`Course: ${course.titleAr} - ID: ${course._id}`);
    });

    console.log('Seeding completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('Error seeding courses:', error);
    process.exit(1);
  }
}

seedCourses();