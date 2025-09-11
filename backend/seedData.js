const mongoose = require('mongoose');
const User = require('./models/User');
const Course = require('./models/Course');
const Lesson = require('./models/Lesson');
const News = require('./models/News');
const dotenv = require('dotenv');

dotenv.config();

const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/raqim', {
      useUnifiedTopology: true,
      useNewUrlParser: true,
    });

    console.log(`MongoDB Connected: ${conn.connection.host}`);
  } catch (error) {
    console.error('Database connection error:', error);
    process.exit(1);
  }
};

const seedData = async () => {
  try {
    // Clear existing data
    await User.deleteMany({});
    await Course.deleteMany({});
    await Lesson.deleteMany({});
    await News.deleteMany({});

    console.log('Data cleared successfully');

    // Create admin user
    const adminUser = await User.create({
      name: 'Admin User',
      email: 'admin@raqim.com',
      password: 'password123',
      role: 'admin'
    });

    // Create instructor users
    const instructor1 = await User.create({
      name: 'Dr. Ahmed Al-Rashid',
      email: 'ahmed@raqim.com',
      password: 'password123',
      role: 'instructor',
      bio: 'AI Research Scientist with 10+ years experience in Machine Learning and Deep Learning',
      avatar: 'https://placehold.co/150x150/3B82F6/FFFFFF?text=AH'
    });

    const instructor2 = await User.create({
      name: 'Dr. Sarah Johnson',
      email: 'sarah@raqim.com',
      password: 'password123',
      role: 'instructor',
      bio: 'Natural Language Processing Expert and Data Science Consultant',
      avatar: 'https://placehold.co/150x150/EF4444/FFFFFF?text=SJ'
    });

    const instructor3 = await User.create({
      name: 'Prof. Omar Hassan',
      email: 'omar@raqim.com',
      password: 'password123',
      role: 'instructor',
      bio: 'Computer Vision Specialist and AI Ethics Researcher',
      avatar: 'https://placehold.co/150x150/10B981/FFFFFF?text=OH'
    });

    console.log('Users created successfully');

    // Create AI-focused courses
    const courses = [
      {
        title: 'Introduction to Machine Learning',
        titleAr: 'مقدمة في تعلم الآلة',
        description: 'Learn the fundamentals of machine learning, including supervised and unsupervised learning, feature engineering, and model evaluation. Perfect for beginners looking to enter the AI field.',
        descriptionAr: 'تعلم أساسيات تعلم الآلة، بما في ذلك التعلم المراقب وغير المراقب، وهندسة الخصائص، وتقييم النماذج. مثالي للمبتدئين الراغبين في دخول مجال الذكاء الاصطناعي.',
        instructor: instructor1._id,
        category: 'Machine Learning',
        level: 'Beginner',
        price: 299,
        currency: 'SAR',
        isFree: false,
        duration: 480, // 8 hours
        totalLessons: 5,
        language: 'both',
        thumbnail: 'https://placehold.co/600x400/3B82F6/FFFFFF?text=ML+Course',
        imageUrl: 'https://placehold.co/600x400/3B82F6/FFFFFF?text=ML+Course',
        requirements: [
          'Basic programming knowledge (Python recommended)',
          'High school level mathematics',
          'Eager to learn and practice'
        ],
        whatYouWillLearn: [
          'Understand different types of machine learning algorithms',
          'Implement linear and logistic regression',
          'Apply decision trees and random forests',
          'Evaluate model performance using various metrics',
          'Handle real-world datasets and preprocessing'
        ]
      },
      {
        title: 'Natural Language Processing Fundamentals',
        titleAr: 'أساسيات معالجة اللغة الطبيعية',
        description: 'Dive deep into NLP techniques, from text preprocessing to building chatbots. Learn tokenization, sentiment analysis, named entity recognition, and modern transformer models.',
        descriptionAr: 'اغوص بعمق في تقنيات معالجة اللغة الطبيعية، من معالجة النصوص إلى بناء الروبوتات المحادثة. تعلم التقطيع وتحليل المشاعر والتعرف على الكيانات المسماة ونماذج المحولات الحديثة.',
        instructor: instructor2._id,
        category: 'NLP',
        level: 'Intermediate',
        price: 599,
        currency: 'SAR',
        isFree: false,
        duration: 720, // 12 hours
        totalLessons: 4,
        language: 'both',
        thumbnail: 'https://placehold.co/600x400/EF4444/FFFFFF?text=NLP+Course',
        imageUrl: 'https://placehold.co/600x400/EF4444/FFFFFF?text=NLP+Course',
        requirements: [
          'Solid Python programming skills',
          'Basic machine learning knowledge',
          'Understanding of statistics and probability'
        ],
        whatYouWillLearn: [
          'Master text preprocessing and tokenization techniques',
          'Build sentiment analysis models',
          'Implement named entity recognition systems',
          'Understand and apply transformer architectures',
          'Create your own chatbot from scratch'
        ]
      },
      {
        title: 'Computer Vision with Deep Learning',
        titleAr: 'الرؤية الحاسوبية بالتعلم العميق',
        description: 'Master computer vision using convolutional neural networks. Learn image classification, object detection, segmentation, and work with popular frameworks like TensorFlow and PyTorch.',
        descriptionAr: 'اتقن الرؤية الحاسوبية باستخدام الشبكات العصبية التحويلية. تعلم تصنيف الصور واكتشاف الكائنات والتقسيم والعمل مع الأطر الشائعة مثل TensorFlow و PyTorch.',
        instructor: instructor3._id,
        category: 'Computer Vision',
        level: 'Advanced',
        price: 799,
        currency: 'SAR',
        isFree: false,
        duration: 900, // 15 hours
        totalLessons: 5,
        language: 'both',
        thumbnail: 'https://placehold.co/600x400/10B981/FFFFFF?text=CV+Course',
        imageUrl: 'https://placehold.co/600x400/10B981/FFFFFF?text=CV+Course',
        requirements: [
          'Strong Python and machine learning background',
          'Linear algebra and calculus knowledge',
          'Experience with neural networks recommended'
        ],
        whatYouWillLearn: [
          'Build and train convolutional neural networks',
          'Implement image classification systems',
          'Develop object detection models',
          'Apply image segmentation techniques',
          'Work with real-world computer vision projects'
        ]
      },
      {
        title: 'Deep Learning Foundations',
        titleAr: 'أسس التعلم العميق',
        description: 'Comprehensive introduction to deep learning covering neural networks, backpropagation, optimization, and modern architectures. Includes hands-on projects and industry applications.',
        descriptionAr: 'مقدمة شاملة للتعلم العميق تغطي الشبكات العصبية والانتشار العكسي والتحسين والهياكل الحديثة. تشمل مشاريع عملية وتطبيقات صناعية.',
        instructor: instructor1._id,
        category: 'Deep Learning',
        level: 'Intermediate',
        price: 0,
        currency: 'SAR',
        isFree: true,
        duration: 600, // 10 hours
        totalLessons: 4,
        language: 'both',
        thumbnail: 'https://placehold.co/600x400/8B5CF6/FFFFFF?text=DL+Course',
        imageUrl: 'https://placehold.co/600x400/8B5CF6/FFFFFF?text=DL+Course',
        requirements: [
          'Basic machine learning knowledge',
          'Python programming proficiency',
          'Linear algebra fundamentals'
        ],
        whatYouWillLearn: [
          'Understand neural network architectures',
          'Master backpropagation and gradient descent',
          'Implement different activation functions',
          'Optimize deep learning models',
          'Build neural networks from scratch'
        ]
      },
      {
        title: 'Data Science for AI Applications',
        titleAr: 'علوم البيانات لتطبيقات الذكاء الاصطناعي',
        description: 'Learn essential data science skills for AI projects. Cover data collection, cleaning, analysis, visualization, and statistical modeling with Python and popular libraries.',
        descriptionAr: 'تعلم المهارات الأساسية في علوم البيانات لمشاريع الذكاء الاصطناعي. اغطِ جمع البيانات وتنظيفها وتحليلها وتصورها والنمذجة الإحصائية باستخدام Python والمكتبات الشائعة.',
        instructor: instructor2._id,
        category: 'Data Science',
        level: 'Beginner',
        price: 0,
        currency: 'SAR',
        isFree: true,
        duration: 540, // 9 hours
        totalLessons: 3,
        language: 'both',
        thumbnail: 'https://placehold.co/600x400/F59E0B/FFFFFF?text=DS+Course',
        imageUrl: 'https://placehold.co/600x400/F59E0B/FFFFFF?text=DS+Course',
        requirements: [
          'Basic programming knowledge',
          'High school mathematics',
          'Curiosity about data and statistics'
        ],
        whatYouWillLearn: [
          'Master Python for data analysis',
          'Use pandas, numpy, and matplotlib effectively',
          'Apply statistical methods to real datasets',
          'Create compelling data visualizations',
          'Prepare data for machine learning models'
        ]
      }
    ];

    const createdCourses = await Course.insertMany(courses);
    console.log('Courses created successfully');

    // Create lessons for each course
    const lessons = [];

    // Machine Learning Course Lessons
    const mlCourse = createdCourses[0];
    const mlLessons = [
      {
        title: 'What is Machine Learning?',
        titleAr: 'ما هو تعلم الآلة؟',
        description: 'Introduction to machine learning concepts and applications',
        descriptionAr: 'مقدمة في مفاهيم وتطبيقات تعلم الآلة',
        course: mlCourse._id,
        section: 'Introduction',
        order: 1,
        type: 'video',
        content: {
          videoUrl: 'https://www.youtube.com/watch?v=ukzFI9rgwfU',
          videoDuration: 95
        }
      },
      {
        title: 'Types of Machine Learning',
        titleAr: 'أنواع تعلم الآلة',
        description: 'Understanding supervised, unsupervised, and reinforcement learning',
        descriptionAr: 'فهم التعلم المراقب وغير المراقب والتعلم المعزز',
        course: mlCourse._id,
        section: 'Fundamentals',
        order: 2,
        type: 'video',
        content: {
          videoUrl: 'https://www.youtube.com/watch?v=f_uwKZIAeM0',
          videoDuration: 120
        }
      },
      {
        title: 'Linear Regression Explained',
        titleAr: 'شرح الانحدار الخطي',
        description: 'Deep dive into linear regression algorithm and implementation',
        descriptionAr: 'غوص عميق في خوارزمية الانحدار الخطي والتنفيذ',
        course: mlCourse._id,
        section: 'Algorithms',
        order: 3,
        type: 'video',
        content: {
          videoUrl: 'https://www.youtube.com/watch?v=nk2CQITm_eo',
          videoDuration: 150
        }
      },
      {
        title: 'Decision Trees and Random Forests',
        titleAr: 'أشجار القرار والغابات العشوائية',
        description: 'Learn tree-based algorithms for classification and regression',
        descriptionAr: 'تعلم الخوارزميات القائمة على الأشجار للتصنيف والانحدار',
        course: mlCourse._id,
        section: 'Algorithms',
        order: 4,
        type: 'video',
        content: {
          videoUrl: 'https://www.youtube.com/watch?v=7VeUPuFGJHk',
          videoDuration: 180
        }
      },
      {
        title: 'Model Evaluation and Metrics',
        titleAr: 'تقييم النماذج والمقاييس',
        description: 'Understanding different evaluation metrics and cross-validation',
        descriptionAr: 'فهم مقاييس التقييم المختلفة والتحقق المتقاطع',
        course: mlCourse._id,
        section: 'Evaluation',
        order: 5,
        type: 'video',
        content: {
          videoUrl: 'https://www.youtube.com/watch?v=LbX4X71-TFI',
          videoDuration: 135
        }
      }
    ];

    // NLP Course Lessons
    const nlpCourse = createdCourses[1];
    const nlpLessons = [
      {
        title: 'Text Preprocessing and Tokenization',
        titleAr: 'معالجة النص والتقطيع',
        description: 'Learn essential text preprocessing techniques',
        descriptionAr: 'تعلم تقنيات معالجة النصوص الأساسية',
        course: nlpCourse._id,
        section: 'Preprocessing',
        order: 1,
        type: 'video',
        content: {
          videoUrl: 'https://www.youtube.com/watch?v=fNxaJsNG3-s',
          videoDuration: 180
        }
      },
      {
        title: 'Sentiment Analysis with Python',
        titleAr: 'تحليل المشاعر باستخدام Python',
        description: 'Build sentiment analysis models from scratch',
        descriptionAr: 'بناء نماذج تحليل المشاعر من الصفر',
        course: nlpCourse._id,
        section: 'Applications',
        order: 2,
        type: 'video',
        content: {
          videoUrl: 'https://www.youtube.com/watch?v=QpzMWQvxXWk',
          videoDuration: 200
        }
      },
      {
        title: 'Named Entity Recognition',
        titleAr: 'التعرف على الكيانات المسماة',
        description: 'Extract and classify named entities from text',
        descriptionAr: 'استخراج وتصنيف الكيانات المسماة من النص',
        course: nlpCourse._id,
        section: 'Advanced',
        order: 3,
        type: 'video',
        content: {
          videoUrl: 'https://www.youtube.com/watch?v=Ljzz-tLjFYE',
          videoDuration: 170
        }
      },
      {
        title: 'Building Chatbots with Transformers',
        titleAr: 'بناء روبوتات المحادثة بالمحولات',
        description: 'Create intelligent chatbots using modern NLP techniques',
        descriptionAr: 'إنشاء روبوتات محادثة ذكية باستخدام تقنيات معالجة اللغة الطبيعية الحديثة',
        course: nlpCourse._id,
        section: 'Projects',
        order: 4,
        type: 'video',
        content: {
          videoUrl: 'https://www.youtube.com/watch?v=kCc8FmEb1nY',
          videoDuration: 220
        }
      }
    ];

    // Computer Vision Course Lessons
    const cvCourse = createdCourses[2];
    const cvLessons = [
      {
        title: 'Introduction to Convolutional Neural Networks',
        titleAr: 'مقدمة في الشبكات العصبية التحويلية',
        description: 'Understanding CNNs architecture and components',
        descriptionAr: 'فهم بنية ومكونات الشبكات العصبية التحويلية',
        course: cvCourse._id,
        section: 'Fundamentals',
        order: 1,
        type: 'video',
        content: {
          videoUrl: 'https://www.youtube.com/watch?v=YRhxdVk_sIs',
          videoDuration: 190
        }
      },
      {
        title: 'Image Classification with CNN',
        titleAr: 'تصنيف الصور باستخدام CNN',
        description: 'Build and train image classification models',
        descriptionAr: 'بناء وتدريب نماذج تصنيف الصور',
        course: cvCourse._id,
        section: 'Classification',
        order: 2,
        type: 'video',
        content: {
          videoUrl: 'https://www.youtube.com/watch?v=pDdP0TFzsoQ',
          videoDuration: 210
        }
      },
      {
        title: 'Object Detection with YOLO',
        titleAr: 'اكتشاف الكائنات باستخدام YOLO',
        description: 'Implement real-time object detection systems',
        descriptionAr: 'تنفيذ أنظمة اكتشاف الكائنات في الوقت الفعلي',
        course: cvCourse._id,
        section: 'Detection',
        order: 3,
        type: 'video',
        content: {
          videoUrl: 'https://www.youtube.com/watch?v=Grir6TZbc1M',
          videoDuration: 240
        }
      },
      {
        title: 'Image Segmentation Techniques',
        titleAr: 'تقنيات تقسيم الصور',
        description: 'Learn semantic and instance segmentation',
        descriptionAr: 'تعلم التقسيم الدلالي وتقسيم الكائنات',
        course: cvCourse._id,
        section: 'Segmentation',
        order: 4,
        type: 'video',
        content: {
          videoUrl: 'https://www.youtube.com/watch?v=nDPWywWRIRo',
          videoDuration: 200
        }
      },
      {
        title: 'Computer Vision Applications Project',
        titleAr: 'مشروع تطبيقات الرؤية الحاسوبية',
        description: 'Complete end-to-end computer vision project',
        descriptionAr: 'مشروع كامل للرؤية الحاسوبية من البداية للنهاية',
        course: cvCourse._id,
        section: 'Project',
        order: 5,
        type: 'video',
        content: {
          videoUrl: 'https://www.youtube.com/watch?v=9s_FpMpdYW8',
          videoDuration: 270
        }
      }
    ];

    // Deep Learning Course Lessons
    const dlCourse = createdCourses[3];
    const dlLessons = [
      {
        title: 'Neural Networks Fundamentals',
        titleAr: 'أساسيات الشبكات العصبية',
        description: 'Understanding how neural networks work',
        descriptionAr: 'فهم كيفية عمل الشبكات العصبية',
        course: dlCourse._id,
        section: 'Basics',
        order: 1,
        type: 'video',
        content: {
          videoUrl: 'https://www.youtube.com/watch?v=aircAruvnKk',
          videoDuration: 160
        }
      },
      {
        title: 'Backpropagation Algorithm',
        titleAr: 'خوارزمية الانتشار العكسي',
        description: 'Deep dive into backpropagation and gradient descent',
        descriptionAr: 'غوص عميق في الانتشار العكسي وانحدار الانحدار',
        course: dlCourse._id,
        section: 'Training',
        order: 2,
        type: 'video',
        content: {
          videoUrl: 'https://www.youtube.com/watch?v=Ilg3gGewQ5U',
          videoDuration: 180
        }
      },
      {
        title: 'Optimization Techniques',
        titleAr: 'تقنيات التحسين',
        description: 'Advanced optimization methods for deep learning',
        descriptionAr: 'طرق التحسين المتقدمة للتعلم العميق',
        course: dlCourse._id,
        section: 'Optimization',
        order: 3,
        type: 'video',
        content: {
          videoUrl: 'https://www.youtube.com/watch?v=TEB2z7ZlRAw',
          videoDuration: 150
        }
      },
      {
        title: 'Building Neural Networks from Scratch',
        titleAr: 'بناء الشبكات العصبية من الصفر',
        description: 'Implement neural networks using only Python and NumPy',
        descriptionAr: 'تنفيذ الشبكات العصبية باستخدام Python و NumPy فقط',
        course: dlCourse._id,
        section: 'Implementation',
        order: 4,
        type: 'video',
        content: {
          videoUrl: 'https://www.youtube.com/watch?v=w8yWXqWQYmU',
          videoDuration: 210
        }
      }
    ];

    // Data Science Course Lessons
    const dsCourse = createdCourses[4];
    const dsLessons = [
      {
        title: 'Python for Data Analysis',
        titleAr: 'Python لتحليل البيانات',
        description: 'Master Python libraries for data science',
        descriptionAr: 'إتقان مكتبات Python لعلوم البيانات',
        course: dsCourse._id,
        section: 'Python Basics',
        order: 1,
        type: 'video',
        content: {
          videoUrl: 'https://www.youtube.com/watch?v=r-uOLxNrNk8',
          videoDuration: 200
        }
      },
      {
        title: 'Data Visualization with Matplotlib and Seaborn',
        titleAr: 'تصور البيانات باستخدام Matplotlib و Seaborn',
        description: 'Create compelling visualizations for data insights',
        descriptionAr: 'إنشاء تصورات مقنعة لفهم البيانات',
        course: dsCourse._id,
        section: 'Visualization',
        order: 2,
        type: 'video',
        content: {
          videoUrl: 'https://www.youtube.com/watch?v=a9UrKTVEeZA',
          videoDuration: 180
        }
      },
      {
        title: 'Statistical Analysis and Hypothesis Testing',
        titleAr: 'التحليل الإحصائي واختبار الفرضيات',
        description: 'Apply statistical methods to real-world problems',
        descriptionAr: 'تطبيق الأساليب الإحصائية على المشاكل الواقعية',
        course: dsCourse._id,
        section: 'Statistics',
        order: 3,
        type: 'video',
        content: {
          videoUrl: 'https://www.youtube.com/watch?v=tFWsuO9f74o',
          videoDuration: 160
        }
      }
    ];

    // Combine all lessons
    lessons.push(...mlLessons, ...nlpLessons, ...cvLessons, ...dlLessons, ...dsLessons);
    await Lesson.insertMany(lessons);
    console.log('Lessons created successfully');

    // Create AI-focused news articles
    const newsArticles = [
      {
        title: 'The Future of AI in Education: Transforming Learning Experiences',
        titleAr: 'مستقبل الذكاء الاصطناعي في التعليم: تحويل تجارب التعلم',
        content: `Artificial Intelligence is revolutionizing the education sector in unprecedented ways. From personalized learning paths to intelligent tutoring systems, AI is making education more accessible, engaging, and effective.

Key areas where AI is making an impact:

1. **Personalized Learning**: AI algorithms analyze student performance and learning patterns to create customized learning experiences. This ensures that each student receives content at their optimal difficulty level and pace.

2. **Intelligent Tutoring Systems**: AI-powered tutors provide 24/7 support, answering questions and providing feedback in real-time. These systems can identify knowledge gaps and suggest additional resources.

3. **Automated Assessment**: AI can grade assignments, provide instant feedback, and even detect plagiarism, freeing up instructors to focus on more valuable activities.

4. **Predictive Analytics**: Educational institutions use AI to predict student outcomes, identify at-risk students, and implement early intervention strategies.

5. **Virtual Classrooms**: AI enhances virtual learning environments with features like real-time translation, emotion recognition, and adaptive interfaces.

The integration of AI in education is not just a trend; it's the future of how we learn and teach. At Raqim, we're committed to preparing learners for this AI-driven future.`,
        contentAr: `يحدث الذكاء الاصطناعي ثورة في قطاع التعليم بطرق غير مسبوقة. من مسارات التعلم الشخصية إلى أنظمة التدريس الذكية، يجعل الذكاء الاصطناعي التعليم أكثر سهولة وتشويقاً وفعالية.

المجالات الرئيسية التي يؤثر فيها الذكاء الاصطناعي:

1. **التعلم الشخصي**: تحلل خوارزميات الذكاء الاصطناعي أداء الطلاب وأنماط التعلم لإنشاء تجارب تعلم مخصصة. هذا يضمن حصول كل طالب على محتوى بمستوى الصعوبة والوتيرة المثلى.

2. **أنظمة التدريس الذكية**: توفر المدرسون المدعومون بالذكاء الاصطناعي دعماً على مدار الساعة، والإجابة على الأسئلة وتقديم التغذية الراجعة في الوقت الفعلي.

3. **التقييم الآلي**: يمكن للذكاء الاصطناعي تصحيح المهام وتقديم تغذية راجعة فورية واكتشاف الانتحال.

4. **التحليلات التنبؤية**: تستخدم المؤسسات التعليمية الذكاء الاصطناعي للتنبؤ بنتائج الطلاب وتحديد الطلاب المعرضين للخطر.

5. **الفصول الافتراضية**: يعزز الذكاء الاصطناعي بيئات التعلم الافتراضية بميزات مثل الترجمة الفورية والتعرف على المشاعر.

إن دمج الذكاء الاصطناعي في التعليم ليس مجرد اتجاه؛ إنه مستقبل كيف نتعلم وندرّس. في رقيم، نحن ملتزمون بإعداد المتعلمين لهذا المستقبل المدفوع بالذكاء الاصطناعي.`,
        category: 'technology',
        author: 'Dr. Ahmed Al-Rashid',
        tags: ['AI', 'Education', 'Machine Learning', 'EdTech'],
        isPublished: true,
        isFeatured: true,
        publishedAt: new Date('2024-09-10'),
        thumbnail: 'https://placehold.co/600x300/3B82F6/FFFFFF?text=AI+Education',
        imageUrl: 'https://placehold.co/600x300/3B82F6/FFFFFF?text=AI+Education'
      },
      {
        title: 'Breaking Down Large Language Models: How ChatGPT and GPT-4 Work',
        titleAr: 'تفكيك نماذج اللغة الكبيرة: كيف يعمل ChatGPT و GPT-4',
        content: `Large Language Models (LLMs) like ChatGPT and GPT-4 have captured the world's attention with their remarkable ability to understand and generate human-like text. But how do they actually work?

## The Architecture Behind LLMs

**Transformer Architecture**: At the heart of modern LLMs lies the transformer architecture, introduced in the paper "Attention is All You Need." This architecture revolutionized natural language processing by introducing the attention mechanism.

**Self-Attention Mechanism**: This allows the model to weigh the importance of different words in a sentence when processing each word. It's like having a spotlight that can focus on multiple parts of a sentence simultaneously.

**Pre-training and Fine-tuning**: LLMs are first pre-trained on massive amounts of text data to learn language patterns, then fine-tuned for specific tasks.

## Key Capabilities

1. **Text Generation**: Creating coherent, contextually relevant text
2. **Language Translation**: Converting text between different languages
3. **Question Answering**: Providing accurate answers to complex questions
4. **Code Generation**: Writing functional code in various programming languages
5. **Creative Writing**: Producing stories, poems, and other creative content

## Challenges and Limitations

- **Hallucinations**: Sometimes generating plausible but incorrect information
- **Bias**: Reflecting biases present in training data
- **Context Length**: Limited ability to maintain coherence over very long conversations
- **Computational Requirements**: Requiring significant computing resources

Understanding these models is crucial for anyone working in AI and NLP. They represent a significant milestone in artificial intelligence and continue to evolve rapidly.`,
        contentAr: `نماذج اللغة الكبيرة مثل ChatGPT و GPT-4 لفتت انتباه العالم بقدرتها الرائعة على فهم وتوليد نص شبيه بالإنسان. لكن كيف تعمل فعلاً؟

## البنية وراء نماذج اللغة الكبيرة

**بنية المحول**: في قلب نماذج اللغة الحديثة تكمن بنية المحول، والتي قدمت في ورقة "الانتباه هو كل ما تحتاجه."

**آلية الانتباه الذاتي**: هذا يسمح للنموذج بترجيح أهمية الكلمات المختلفة في الجملة عند معالجة كل كلمة.

**التدريب المسبق والضبط الدقيق**: يتم أولاً تدريب نماذج اللغة الكبيرة مسبقاً على كميات ضخمة من البيانات النصية لتعلم أنماط اللغة.

## القدرات الرئيسية

1. **توليد النص**: إنشاء نص متماسك وذو صلة بالسياق
2. **ترجمة اللغة**: تحويل النص بين لغات مختلفة
3. **الإجابة على الأسئلة**: تقديم إجابات دقيقة لأسئلة معقدة
4. **توليد الكود**: كتابة كود وظيفي بلغات برمجة مختلفة
5. **الكتابة الإبداعية**: إنتاج قصص وقصائد ومحتوى إبداعي آخر

## التحديات والقيود

- **الهلوسات**: أحياناً توليد معلومات معقولة لكن غير صحيحة
- **التحيز**: عكس التحيزات الموجودة في بيانات التدريب
- **طول السياق**: قدرة محدودة على الحفاظ على التماسك
- **متطلبات الحوسبة**: الحاجة إلى موارد حاسوبية كبيرة

فهم هذه النماذج أمر بالغ الأهمية لأي شخص يعمل في مجال الذكاء الاصطناعي ومعالجة اللغة الطبيعية.`,
        category: 'technology',
        author: 'Dr. Sarah Johnson',
        tags: ['LLM', 'NLP', 'ChatGPT', 'Transformers', 'AI'],
        isPublished: true,
        isFeatured: true,
        publishedAt: new Date('2024-09-08'),
        thumbnail: 'https://placehold.co/600x300/EF4444/FFFFFF?text=LLM+Models',
        imageUrl: 'https://placehold.co/600x300/EF4444/FFFFFF?text=LLM+Models'
      },
      {
        title: 'Computer Vision Breakthroughs: From Object Detection to Autonomous Vehicles',
        titleAr: 'اختراقات الرؤية الحاسوبية: من اكتشاف الكائنات إلى المركبات ذاتية القيادة',
        content: `Computer vision has experienced remarkable breakthroughs in recent years, transforming from academic research into practical applications that touch our daily lives. From smartphones that can recognize faces to cars that can drive themselves, computer vision is everywhere.

## Major Breakthroughs in Computer Vision

**Convolutional Neural Networks (CNNs)**: The foundation of modern computer vision, CNNs have revolutionized image recognition tasks. AlexNet's victory in the 2012 ImageNet competition marked the beginning of the deep learning era in computer vision.

**Object Detection Evolution**: From R-CNN to YOLO (You Only Look Once) to modern transformer-based detectors, object detection has become faster and more accurate.

**Generative Adversarial Networks (GANs)**: These networks can generate incredibly realistic images, leading to applications in art, entertainment, and data augmentation.

## Real-World Applications

1. **Autonomous Vehicles**: Self-driving cars rely heavily on computer vision to navigate roads, detect obstacles, and make driving decisions.

2. **Medical Imaging**: AI can now detect diseases in medical scans with accuracy matching or exceeding human radiologists.

3. **Augmented Reality**: Computer vision enables AR applications to understand and interact with the real world.

4. **Security and Surveillance**: Advanced facial recognition and behavior analysis systems enhance security.

5. **Manufacturing**: Quality control systems using computer vision can detect defects at superhuman speeds.

## Current Challenges

- **Robustness**: Ensuring systems work reliably in diverse conditions
- **Privacy Concerns**: Balancing functionality with user privacy
- **Computational Efficiency**: Making systems faster and more energy-efficient
- **Interpretability**: Understanding how models make decisions

## The Future

The future of computer vision lies in:
- **3D Understanding**: Better spatial reasoning capabilities
- **Video Analysis**: Real-time processing of video streams
- **Multimodal AI**: Combining vision with other senses
- **Edge Computing**: Running sophisticated models on mobile devices

Computer vision continues to push the boundaries of what's possible with AI, creating new opportunities across industries.`,
        contentAr: `شهدت الرؤية الحاسوبية اختراقات ملحوظة في السنوات الأخيرة، تحولت من البحث الأكاديمي إلى تطبيقات عملية تلامس حياتنا اليومية.

## الاختراقات الرئيسية في الرؤية الحاسوبية

**الشبكات العصبية التحويلية**: أساس الرؤية الحاسوبية الحديثة، أحدثت الشبكات العصبية التحويلية ثورة في مهام التعرف على الصور.

**تطور اكتشاف الكائنات**: من R-CNN إلى YOLO إلى أجهزة الكشف الحديثة المعتمدة على المحولات.

**الشبكات التوليدية التنافسية**: يمكن لهذه الشبكات توليد صور واقعية بشكل لا يصدق.

## التطبيقات في العالم الحقيقي

1. **المركبات ذاتية القيادة**: تعتمد السيارات ذاتية القيادة بشكل كبير على الرؤية الحاسوبية.

2. **التصوير الطبي**: يمكن للذكاء الاصطناعي الآن اكتشاف الأمراض في الصور الطبية.

3. **الواقع المعزز**: تمكن الرؤية الحاسوبية تطبيقات الواقع المعزز من فهم العالم الحقيقي.

4. **الأمن والمراقبة**: أنظمة التعرف على الوجوه المتقدمة تعزز الأمن.

5. **التصنيع**: أنظمة مراقبة الجودة باستخدام الرؤية الحاسوبية يمكنها اكتشاف العيوب.

## التحديات الحالية

- **المتانة**: ضمان عمل الأنظمة بشكل موثوق في ظروف متنوعة
- **مخاوف الخصوصية**: موازنة الوظائف مع خصوصية المستخدم
- **الكفاءة الحاسوبية**: جعل الأنظمة أسرع وأكثر كفاءة
- **القابلية للتفسير**: فهم كيف تتخذ النماذج القرارات

مستقبل الرؤية الحاسوبية يكمن في الفهم ثلاثي الأبعاد وتحليل الفيديو والذكاء الاصطناعي متعدد الوسائط.`,
        category: 'technology',
        author: 'Prof. Omar Hassan',
        tags: ['Computer Vision', 'Deep Learning', 'CNNs', 'Autonomous Vehicles', 'AI'],
        isPublished: true,
        isFeatured: false,
        publishedAt: new Date('2024-09-05'),
        thumbnail: 'https://placehold.co/600x300/10B981/FFFFFF?text=Computer+Vision',
        imageUrl: 'https://placehold.co/600x300/10B981/FFFFFF?text=Computer+Vision'
      }
    ];

    await News.insertMany(newsArticles);
    console.log('News articles created successfully');

    console.log('✅ Seed data created successfully!');
    
    console.log('\n📊 Summary:');
    console.log(`👥 Users: ${await User.countDocuments()}`);
    console.log(`📚 Courses: ${await Course.countDocuments()}`);
    console.log(`📖 Lessons: ${await Lesson.countDocuments()}`);
    console.log(`📰 News Articles: ${await News.countDocuments()}`);

    console.log('\n🔑 Test Accounts:');
    console.log('Admin: admin@raqim.com / password123');
    console.log('Instructor 1: ahmed@raqim.com / password123');
    console.log('Instructor 2: sarah@raqim.com / password123');
    console.log('Instructor 3: omar@raqim.com / password123');

  } catch (error) {
    console.error('Error seeding data:', error);
    process.exit(1);
  }
};

// Run the seed script
const runSeed = async () => {
  await connectDB();
  await seedData();
  process.exit(0);
};

if (require.main === module) {
  runSeed();
}

module.exports = { seedData };