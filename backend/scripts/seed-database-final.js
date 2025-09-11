const mongoose = require('mongoose');
const dotenv = require('dotenv');
const User = require('../models/User');
const Course = require('../models/Course');
const Lesson = require('../models/Lesson');

dotenv.config({ path: '../.env' });

// YouTube video IDs for real educational content
const youtubeVideos = [
  'BWf-eARnf6U', // Python Tutorial
  'rfscVS0vtbw', // Learn Python - Full Course
  'PkZNo7MFNFg', // JavaScript Tutorial
  'W6NZfCO5SIk', // JavaScript Course
  'pQN-pnXPaVg', // HTML Full Course
  'yfoY53QXEnI', // CSS Tutorial
  '1Rs2ND1ryYc', // CSS Zero to Hero
  'fgdpvwEWJ9M', // React Tutorial
];

async function seedDatabase() {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/raqim_learning');
    console.log('✅ Connected to MongoDB');
    
    // Clear existing data
    await User.deleteMany({});
    await Course.deleteMany({});
    await Lesson.deleteMany({});
    console.log('✅ Database cleared');
    
    // Create teachers
    const teacher1 = await User.create({
      name: 'Dr. Ahmed Mohamed',
      email: 'ahmed.teacher@raqim.com',
      password: 'teacher123',
      role: 'teacher'
    });
    
    const teacher2 = await User.create({
      name: 'Dr. Sara Ali',
      email: 'sara.teacher@raqim.com',
      password: 'teacher123',
      role: 'teacher'
    });
    
    // Create students
    const student1 = await User.create({
      name: 'Mohamed Hassan',
      email: 'student1@raqim.com',
      password: 'student123',
      role: 'student'
    });
    
    const student2 = await User.create({
      name: 'Fatima Ahmed',
      email: 'student2@raqim.com',
      password: 'student123',
      role: 'student'
    });
    
    console.log('✅ Created users');
    
    // Create Courses with detailed content
    const courses = [];
    
    // Course 1: Python Programming
    const pythonCourse = await Course.create({
      title: 'Complete Python Programming',
      titleAr: 'برمجة Python الشاملة',
      description: 'Learn Python from zero to hero. This comprehensive course covers everything from basics to advanced topics including web development, data science, and automation.',
      descriptionAr: 'تعلم Python من الصفر إلى الاحتراف. هذه الدورة الشاملة تغطي كل شيء من الأساسيات إلى المواضيع المتقدمة بما في ذلك تطوير الويب وعلم البيانات والأتمتة.',
      instructor: teacher1._id,
      category: 'programming',
      level: 'beginner',
      price: 0,
      duration: 180,
      thumbnail: 'https://images.unsplash.com/photo-1526379095098-d400fd0bf935?w=800&q=80',
      isPublished: true,
      whatYouWillLearn: [
        'Python syntax and basics',
        'Object-Oriented Programming',
        'Web development with Django',
        'Data analysis with Pandas',
        'Building real projects'
      ],
      requirements: ['Computer with internet', 'No programming experience needed'],
      tags: ['Python', 'Programming', 'Web Development', 'Data Science']
    });
    
    // Create lessons for Python course
    const pythonLessons = [];
    for (let i = 1; i <= 10; i++) {
      const lesson = await Lesson.create({
        title: `Python Lesson ${i}`,
        titleAr: `درس Python رقم ${i}`,
        description: `Learn important Python concepts in lesson ${i}`,
        descriptionAr: `تعلم مفاهيم Python المهمة في الدرس ${i}`,
        course: pythonCourse._id,
        section: pythonCourse._id,
        type: 'video',
        order: i,
        duration: 15 + Math.floor(Math.random() * 30),
        videoUrl: `https://www.youtube.com/embed/${youtubeVideos[i % youtubeVideos.length]}`,
        content: `# Lesson ${i} Content\n\nThis lesson covers important Python concepts.\n\n## Topics Covered:\n- Topic 1\n- Topic 2\n- Topic 3`,
        resources: [{
          title: `Lesson ${i} PDF`,
          type: 'pdf',
          url: `https://example.com/lesson${i}.pdf`
        }]
      });
      pythonLessons.push(lesson);
    }
    
    pythonCourse.totalLessons = pythonLessons.length;
    await pythonCourse.save();
    courses.push(pythonCourse);
    
    // Course 2: Web Development
    const webCourse = await Course.create({
      title: 'Full Stack Web Development',
      titleAr: 'تطوير الويب الشامل',
      description: 'Master modern web development with HTML, CSS, JavaScript, React, and Node.js. Build real-world applications from scratch.',
      descriptionAr: 'احترف تطوير الويب الحديث مع HTML وCSS وJavaScript وReact وNode.js. قم ببناء تطبيقات حقيقية من الصفر.',
      instructor: teacher1._id,
      category: 'technology',
      level: 'intermediate',
      price: 299,
      duration: 240,
      thumbnail: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=800&q=80',
      isPublished: true,
      whatYouWillLearn: [
        'HTML5 & CSS3',
        'JavaScript ES6+',
        'React.js',
        'Node.js & Express',
        'MongoDB & Database Design'
      ],
      requirements: ['Basic computer skills', 'Enthusiasm to learn'],
      tags: ['Web Development', 'React', 'Node.js', 'JavaScript']
    });
    
    // Create lessons for Web course
    const webLessons = [];
    for (let i = 1; i <= 12; i++) {
      const lesson = await Lesson.create({
        title: `Web Development Lesson ${i}`,
        titleAr: `درس تطوير الويب رقم ${i}`,
        description: `Master web development concepts in lesson ${i}`,
        descriptionAr: `احترف مفاهيم تطوير الويب في الدرس ${i}`,
        course: webCourse._id,
        section: webCourse._id,
        type: 'video',
        order: i,
        duration: 20 + Math.floor(Math.random() * 40),
        videoUrl: `https://www.youtube.com/embed/${youtubeVideos[i % youtubeVideos.length]}`,
        content: `# Lesson ${i} - Web Development\n\nThis lesson focuses on essential web development skills.\n\n## What You'll Learn:\n- Concept 1\n- Concept 2\n- Practical examples`,
        resources: [{
          title: `Source Code ${i}`,
          type: 'code',
          url: `https://github.com/example/lesson${i}`
        }]
      });
      webLessons.push(lesson);
    }
    
    webCourse.totalLessons = webLessons.length;
    await webCourse.save();
    courses.push(webCourse);
    
    // Course 3: Data Science
    const dataCourse = await Course.create({
      title: 'Data Science & Machine Learning',
      titleAr: 'علم البيانات والتعلم الآلي',
      description: 'Dive deep into data science, machine learning, and artificial intelligence using Python and modern tools.',
      descriptionAr: 'تعمق في علم البيانات والتعلم الآلي والذكاء الاصطناعي باستخدام Python والأدوات الحديثة.',
      instructor: teacher2._id,
      category: 'technology',
      level: 'advanced',
      price: 499,
      duration: 300,
      thumbnail: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800&q=80',
      isPublished: true,
      whatYouWillLearn: [
        'Data Analysis with Python',
        'Machine Learning Algorithms',
        'Deep Learning with TensorFlow',
        'Natural Language Processing',
        'Computer Vision'
      ],
      requirements: ['Python knowledge', 'Basic mathematics', 'Statistics fundamentals'],
      tags: ['Data Science', 'Machine Learning', 'AI', 'Python']
    });
    
    // Create lessons for Data Science course
    const dataLessons = [];
    for (let i = 1; i <= 15; i++) {
      const lesson = await Lesson.create({
        title: `Data Science Lesson ${i}`,
        titleAr: `درس علم البيانات رقم ${i}`,
        description: `Explore data science and ML in lesson ${i}`,
        descriptionAr: `استكشف علم البيانات والتعلم الآلي في الدرس ${i}`,
        course: dataCourse._id,
        section: dataCourse._id,
        type: 'video',
        order: i,
        duration: 25 + Math.floor(Math.random() * 35),
        videoUrl: `https://www.youtube.com/embed/${youtubeVideos[i % youtubeVideos.length]}`,
        content: `# Data Science - Lesson ${i}\n\n## Today's Topics:\n- Data manipulation\n- Statistical analysis\n- Machine learning concepts\n\n## Practical Exercise:\nImplement what you learned with real datasets.`,
        resources: [{
          title: `Jupyter Notebook ${i}`,
          type: 'code',
          url: `https://github.com/example/notebook${i}.ipynb`
        }]
      });
      dataLessons.push(lesson);
    }
    
    dataCourse.totalLessons = dataLessons.length;
    await dataCourse.save();
    courses.push(dataCourse);
    
    // Course 4: Mobile Development
    const mobileCourse = await Course.create({
      title: 'Flutter Mobile Development',
      titleAr: 'تطوير تطبيقات الموبايل بـ Flutter',
      description: 'Build beautiful native mobile apps for iOS and Android using Flutter and Dart.',
      descriptionAr: 'قم ببناء تطبيقات موبايل أصلية جميلة لـ iOS و Android باستخدام Flutter و Dart.',
      instructor: teacher2._id,
      category: 'technology',
      level: 'intermediate',
      price: 349,
      duration: 200,
      thumbnail: 'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=800&q=80',
      isPublished: true,
      whatYouWillLearn: [
        'Dart Programming Language',
        'Flutter Widgets',
        'State Management',
        'API Integration',
        'Publishing to App Stores'
      ],
      requirements: ['Basic programming knowledge', 'Computer with 8GB RAM'],
      tags: ['Flutter', 'Mobile', 'Dart', 'iOS', 'Android']
    });
    
    // Create lessons for Mobile course
    const mobileLessons = [];
    for (let i = 1; i <= 8; i++) {
      const lesson = await Lesson.create({
        title: `Flutter Lesson ${i}`,
        titleAr: `درس Flutter رقم ${i}`,
        description: `Build mobile apps with Flutter - Lesson ${i}`,
        descriptionAr: `بناء تطبيقات الموبايل مع Flutter - الدرس ${i}`,
        course: mobileCourse._id,
        section: mobileCourse._id,
        type: 'video',
        order: i,
        duration: 30 + Math.floor(Math.random() * 30),
        videoUrl: `https://www.youtube.com/embed/${youtubeVideos[i % youtubeVideos.length]}`,
        content: `# Flutter Development - Lesson ${i}\n\n## Building Mobile Apps\n- UI Design\n- State Management\n- Backend Integration`,
        resources: [{
          title: `Flutter Project ${i}`,
          type: 'code',
          url: `https://github.com/flutter/samples`
        }]
      });
      mobileLessons.push(lesson);
    }
    
    mobileCourse.totalLessons = mobileLessons.length;
    await mobileCourse.save();
    courses.push(mobileCourse);
    
    // Course 5: Graphic Design
    const designCourse = await Course.create({
      title: 'Professional Graphic Design',
      titleAr: 'التصميم الجرافيكي الاحترافي',
      description: 'Master Adobe Creative Suite and become a professional graphic designer.',
      descriptionAr: 'احترف Adobe Creative Suite وكن مصمم جرافيك محترف.',
      instructor: teacher1._id,
      category: 'arts',
      level: 'beginner',
      price: 199,
      duration: 120,
      thumbnail: 'https://images.unsplash.com/photo-1561070791-2526d30994b5?w=800&q=80',
      isPublished: true,
      whatYouWillLearn: [
        'Adobe Photoshop',
        'Adobe Illustrator',
        'Logo Design',
        'Typography',
        'Color Theory'
      ],
      requirements: ['Adobe Creative Suite installed', 'Creative mindset'],
      tags: ['Design', 'Photoshop', 'Illustrator', 'Graphics']
    });
    
    // Create lessons for Design course
    const designLessons = [];
    for (let i = 1; i <= 6; i++) {
      const lesson = await Lesson.create({
        title: `Design Lesson ${i}`,
        titleAr: `درس التصميم رقم ${i}`,
        description: `Master design principles - Lesson ${i}`,
        descriptionAr: `احترف مبادئ التصميم - الدرس ${i}`,
        course: designCourse._id,
        section: designCourse._id,
        type: 'video',
        order: i,
        duration: 25 + Math.floor(Math.random() * 25),
        videoUrl: `https://www.youtube.com/embed/${youtubeVideos[i % youtubeVideos.length]}`,
        content: `# Graphic Design - Lesson ${i}\n\n## Design Fundamentals\n- Composition\n- Color harmony\n- Typography basics`,
        resources: [{
          title: `Design Assets ${i}`,
          type: 'pdf',
          url: `https://example.com/assets${i}.zip`
        }]
      });
      designLessons.push(lesson);
    }
    
    designCourse.totalLessons = designLessons.length;
    await designCourse.save();
    courses.push(designCourse);
    
    // Add enrollments and reviews
    for (const course of courses) {
      // Enroll students
      course.enrolledStudents.push(student1._id, student2._id);
      course.numberOfEnrollments = 2;
      
      // Add reviews
      course.reviews.push({
        user: student1._id,
        rating: 5,
        comment: 'Excellent course! Highly recommended.'
      });
      course.reviews.push({
        user: student2._id,
        rating: 4,
        comment: 'Very good content and explanations.'
      });
      
      course.calculateAverageRating();
      await course.save();
    }
    
    console.log('\n========================================');
    console.log('✅ DATABASE SEEDED SUCCESSFULLY!');
    console.log('========================================\n');
    
    console.log('📊 Database Summary:');
    console.log('------------------------');
    console.log(`Users: ${await User.countDocuments()}`);
    console.log(`Courses: ${await Course.countDocuments()}`);
    console.log(`Lessons: ${await Lesson.countDocuments()}`);
    console.log('------------------------\n');
    
    console.log('🔑 Login Credentials:');
    console.log('------------------------');
    console.log('Teacher: ahmed.teacher@raqim.com / teacher123');
    console.log('Student: student1@raqim.com / student123');
    console.log('------------------------\n');
    
    console.log('🎬 Sample YouTube Videos Added');
    console.log('📚 5 Complete Courses with Lessons');
    console.log('👥 Users with Enrollments and Reviews');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

seedDatabase();