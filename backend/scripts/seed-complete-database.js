const mongoose = require('mongoose');
const dotenv = require('dotenv');

// Load models
const User = require('../models/User');
const Course = require('../models/Course');
const Lesson = require('../models/Lesson');
const News = require('../models/News');

dotenv.config({ path: '../.env' });

// Sample video URLs (you can replace with real YouTube/Vimeo URLs)
const videoUrls = [
  'https://www.youtube.com/embed/dQw4w9WgXcQ',
  'https://www.youtube.com/embed/3JZ_D3ELwOQ',
  'https://www.youtube.com/embed/2Vv-BfVoq4g',
  'https://www.youtube.com/embed/kJQP7kiw5Fk',
  'https://www.youtube.com/embed/RgKAFK5djSk'
];

async function clearDatabase() {
  await User.deleteMany({});
  await Course.deleteMany({});
  await Lesson.deleteMany({});
  await News.deleteMany({});
  console.log('✅ Database cleared');
}

async function createUsers() {
  const users = [];
  
  // Create admin
  const admin = await User.create({
    name: 'مدير النظام',
    email: 'admin@raqim.com',
    password: 'admin123',
    role: 'admin'
  });
  users.push(admin);
  
  // Create teachers
  const teacher1 = await User.create({
    name: 'د. أحمد محمد',
    email: 'ahmed@raqim.com',
    password: 'teacher123',
    role: 'teacher',
    bio: 'خبير في البرمجة وعلوم الحاسوب مع خبرة 15 سنة'
  });
  users.push(teacher1);
  
  const teacher2 = await User.create({
    name: 'د. فاطمة علي',
    email: 'fatima@raqim.com',
    password: 'teacher123',
    role: 'teacher',
    bio: 'متخصصة في الذكاء الاصطناعي وتعلم الآلة'
  });
  users.push(teacher2);
  
  const teacher3 = await User.create({
    name: 'أ. سارة أحمد',
    email: 'sara@raqim.com',
    password: 'teacher123',
    role: 'teacher',
    bio: 'مصممة جرافيك ومدربة معتمدة من Adobe'
  });
  users.push(teacher3);
  
  // Create students
  for (let i = 1; i <= 5; i++) {
    const student = await User.create({
      name: `طالب ${i}`,
      email: `student${i}@raqim.com`,
      password: 'student123',
      role: 'student'
    });
    users.push(student);
  }
  
  console.log(`✅ Created ${users.length} users`);
  return { admin, teacher1, teacher2, teacher3, students: users.slice(4) };
}

async function createLessons(courseId, count = 5) {
  const lessons = [];
  
  for (let i = 1; i <= count; i++) {
    const lesson = await Lesson.create({
      title: `الدرس ${i}`,
      titleAr: `الدرس ${i}`,
      description: `محتوى الدرس ${i} - شرح مفصل للموضوع`,
      descriptionAr: `محتوى الدرس ${i} - شرح مفصل للموضوع`,
      course: courseId,
      order: i,
      duration: Math.floor(Math.random() * 30) + 10, // 10-40 minutes
      videoUrl: videoUrls[Math.floor(Math.random() * videoUrls.length)],
      content: `
# محتوى الدرس ${i}

## المقدمة
هذا هو محتوى الدرس التعليمي رقم ${i}. سنتعلم في هذا الدرس مفاهيم مهمة ومفيدة.

## الأهداف التعليمية
1. فهم المفاهيم الأساسية
2. التطبيق العملي
3. حل المشكلات

## المحتوى الرئيسي
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

## التمارين
- تمرين 1: تطبيق ما تعلمته
- تمرين 2: حل مسألة متقدمة
- تمرين 3: مشروع صغير

## الخلاصة
في هذا الدرس تعلمنا المفاهيم الأساسية وطبقناها عملياً.
      `,
      resources: [
        {
          title: `ملف PDF - الدرس ${i}`,
          type: 'pdf',
          url: `https://example.com/lesson${i}.pdf`
        },
        {
          title: `عرض تقديمي - الدرس ${i}`,
          type: 'presentation',
          url: `https://example.com/lesson${i}.pptx`
        }
      ],
      quiz: {
        questions: [
          {
            question: `ما هو الموضوع الرئيسي للدرس ${i}؟`,
            options: ['الخيار أ', 'الخيار ب', 'الخيار ج', 'الخيار د'],
            correctAnswer: 0
          },
          {
            question: `أي من التالي صحيح؟`,
            options: ['الإجابة 1', 'الإجابة 2', 'الإجابة 3', 'الإجابة 4'],
            correctAnswer: 1
          }
        ],
        passingScore: 60
      }
    });
    lessons.push(lesson);
  }
  
  return lessons;
}

async function createCourses(teachers) {
  const courses = [];
  
  // Programming Courses
  const programmingCourse1 = await Course.create({
    title: 'Complete Python Programming',
    titleAr: 'البرمجة الشاملة بلغة Python',
    description: 'Learn Python from zero to hero with practical projects',
    descriptionAr: 'تعلم البرمجة بلغة Python من الصفر إلى الاحتراف مع مشاريع عملية',
    instructor: teachers.teacher1._id,
    category: 'programming',
    level: 'beginner',
    price: 0,
    duration: 120,
    thumbnail: 'https://images.unsplash.com/photo-1526379095098-d400fd0bf935?w=400',
    isPublished: true,
    whatYouWillLearn: [
      'أساسيات Python',
      'البرمجة الكائنية',
      'قواعد البيانات',
      'تطوير تطبيقات الويب',
      'مشاريع عملية'
    ],
    requirements: ['جهاز كمبيوتر', 'رغبة في التعلم'],
    tags: ['Python', 'Programming', 'Web Development']
  });
  
  const lessons1 = await createLessons(programmingCourse1._id, 8);
  programmingCourse1.sections = [{
    title: 'الأساسيات',
    titleAr: 'الأساسيات',
    order: 1,
    lessons: lessons1.slice(0, 4).map(l => l._id)
  }, {
    title: 'المستوى المتقدم',
    titleAr: 'المستوى المتقدم',
    order: 2,
    lessons: lessons1.slice(4).map(l => l._id)
  }];
  programmingCourse1.totalLessons = lessons1.length;
  await programmingCourse1.save();
  courses.push(programmingCourse1);
  
  // Web Development Course
  const webCourse = await Course.create({
    title: 'Full Stack Web Development',
    titleAr: 'تطوير الويب الشامل',
    description: 'Master React, Node.js, and MongoDB',
    descriptionAr: 'احترف React و Node.js و MongoDB',
    instructor: teachers.teacher1._id,
    category: 'technology',
    level: 'intermediate',
    price: 299,
    duration: 180,
    thumbnail: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=400',
    isPublished: true,
    whatYouWillLearn: [
      'HTML/CSS/JavaScript',
      'React.js المتقدم',
      'Node.js و Express',
      'MongoDB',
      'نشر التطبيقات'
    ],
    requirements: ['معرفة أساسية بالبرمجة', 'HTML و CSS'],
    tags: ['React', 'Node.js', 'MongoDB', 'Full Stack']
  });
  
  const lessons2 = await createLessons(webCourse._id, 10);
  webCourse.sections = [{
    title: 'Frontend Development',
    titleAr: 'تطوير الواجهات',
    order: 1,
    lessons: lessons2.slice(0, 5).map(l => l._id)
  }, {
    title: 'Backend Development',
    titleAr: 'تطوير الخوادم',
    order: 2,
    lessons: lessons2.slice(5).map(l => l._id)
  }];
  webCourse.totalLessons = lessons2.length;
  await webCourse.save();
  courses.push(webCourse);
  
  // AI Course
  const aiCourse = await Course.create({
    title: 'Artificial Intelligence & Machine Learning',
    titleAr: 'الذكاء الاصطناعي وتعلم الآلة',
    description: 'Deep dive into AI, ML, and Deep Learning',
    descriptionAr: 'تعمق في الذكاء الاصطناعي وتعلم الآلة والتعلم العميق',
    instructor: teachers.teacher2._id,
    category: 'technology',
    level: 'advanced',
    price: 499,
    duration: 240,
    thumbnail: 'https://images.unsplash.com/photo-1555255707-c07966088b7b?w=400',
    isPublished: true,
    whatYouWillLearn: [
      'أساسيات الذكاء الاصطناعي',
      'Machine Learning Algorithms',
      'Deep Learning',
      'Computer Vision',
      'Natural Language Processing'
    ],
    requirements: ['Python', 'رياضيات', 'إحصاء'],
    tags: ['AI', 'Machine Learning', 'Deep Learning', 'Python']
  });
  
  const lessons3 = await createLessons(aiCourse._id, 12);
  aiCourse.sections = [{
    title: 'Machine Learning Basics',
    titleAr: 'أساسيات تعلم الآلة',
    order: 1,
    lessons: lessons3.slice(0, 6).map(l => l._id)
  }, {
    title: 'Deep Learning',
    titleAr: 'التعلم العميق',
    order: 2,
    lessons: lessons3.slice(6).map(l => l._id)
  }];
  aiCourse.totalLessons = lessons3.length;
  await aiCourse.save();
  courses.push(aiCourse);
  
  // Design Course
  const designCourse = await Course.create({
    title: 'Professional Graphic Design',
    titleAr: 'التصميم الجرافيكي الاحترافي',
    description: 'Master Adobe Creative Suite and design principles',
    descriptionAr: 'احترف Adobe Creative Suite ومبادئ التصميم',
    instructor: teachers.teacher3._id,
    category: 'arts',
    level: 'beginner',
    price: 199,
    duration: 90,
    thumbnail: 'https://images.unsplash.com/photo-1561070791-2526d30994b5?w=400',
    isPublished: true,
    whatYouWillLearn: [
      'Photoshop الاحترافي',
      'Illustrator',
      'InDesign',
      'نظرية الألوان',
      'Typography'
    ],
    requirements: ['جهاز كمبيوتر', 'Adobe Creative Suite'],
    tags: ['Design', 'Photoshop', 'Illustrator', 'Graphics']
  });
  
  const lessons4 = await createLessons(designCourse._id, 6);
  designCourse.sections = [{
    title: 'Design Fundamentals',
    titleAr: 'أساسيات التصميم',
    order: 1,
    lessons: lessons4.map(l => l._id)
  }];
  designCourse.totalLessons = lessons4.length;
  await designCourse.save();
  courses.push(designCourse);
  
  // Mobile Development
  const mobileCourse = await Course.create({
    title: 'Flutter Mobile Development',
    titleAr: 'تطوير تطبيقات الموبايل بـ Flutter',
    description: 'Build iOS and Android apps with Flutter',
    descriptionAr: 'بناء تطبيقات iOS و Android باستخدام Flutter',
    instructor: teachers.teacher1._id,
    category: 'technology',
    level: 'intermediate',
    price: 349,
    duration: 150,
    thumbnail: 'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=400',
    isPublished: true,
    whatYouWillLearn: [
      'Dart Programming',
      'Flutter Widgets',
      'State Management',
      'Firebase Integration',
      'Publishing Apps'
    ],
    requirements: ['معرفة بالبرمجة', 'Android Studio أو Xcode'],
    tags: ['Flutter', 'Mobile', 'Dart', 'iOS', 'Android']
  });
  
  const lessons5 = await createLessons(mobileCourse._id, 8);
  mobileCourse.sections = [{
    title: 'Flutter Basics',
    titleAr: 'أساسيات Flutter',
    order: 1,
    lessons: lessons5.slice(0, 4).map(l => l._id)
  }, {
    title: 'Advanced Flutter',
    titleAr: 'Flutter المتقدم',
    order: 2,
    lessons: lessons5.slice(4).map(l => l._id)
  }];
  mobileCourse.totalLessons = lessons5.length;
  await mobileCourse.save();
  courses.push(mobileCourse);
  
  // Data Science
  const dataCourse = await Course.create({
    title: 'Data Science & Analytics',
    titleAr: 'علم البيانات والتحليلات',
    description: 'Master data analysis with Python and R',
    descriptionAr: 'احترف تحليل البيانات باستخدام Python و R',
    instructor: teachers.teacher2._id,
    category: 'technology',
    level: 'intermediate',
    price: 279,
    duration: 120,
    thumbnail: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400',
    isPublished: true,
    whatYouWillLearn: [
      'Python for Data Science',
      'Pandas & NumPy',
      'Data Visualization',
      'Statistical Analysis',
      'Machine Learning Basics'
    ],
    requirements: ['Python أساسيات', 'رياضيات'],
    tags: ['Data Science', 'Python', 'Analytics', 'Statistics']
  });
  
  const lessons6 = await createLessons(dataCourse._id, 7);
  dataCourse.sections = [{
    title: 'Data Analysis',
    titleAr: 'تحليل البيانات',
    order: 1,
    lessons: lessons6.map(l => l._id)
  }];
  dataCourse.totalLessons = lessons6.length;
  await dataCourse.save();
  courses.push(dataCourse);
  
  console.log(`✅ Created ${courses.length} courses with lessons`);
  return courses;
}

async function createNews() {
  const newsArticles = [
    {
      title: 'إطلاق منصة رقيم التعليمية الجديدة',
      titleAr: 'إطلاق منصة رقيم التعليمية الجديدة',
      content: `
تم اليوم إطلاق منصة رقيم التعليمية الجديدة التي تهدف إلى توفير تعليم عالي الجودة باللغة العربية.
المنصة تقدم مجموعة واسعة من الكورسات في مختلف المجالات التقنية والإبداعية.

## المميزات الرئيسية:
- دورات تفاعلية بالفيديو
- شهادات معتمدة
- مشاريع عملية
- دعم مباشر من المدربين

انضم إلينا اليوم وابدأ رحلتك التعليمية!
      `,
      contentAr: `
تم اليوم إطلاق منصة رقيم التعليمية الجديدة التي تهدف إلى توفير تعليم عالي الجودة باللغة العربية.
المنصة تقدم مجموعة واسعة من الكورسات في مختلف المجالات التقنية والإبداعية.

## المميزات الرئيسية:
- دورات تفاعلية بالفيديو
- شهادات معتمدة
- مشاريع عملية
- دعم مباشر من المدربين

انضم إلينا اليوم وابدأ رحلتك التعليمية!
      `,
      category: 'announcement',
      author: 'إدارة رقيم',
      thumbnail: 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=400',
      tags: ['منصة', 'إطلاق', 'تعليم'],
      isPublished: true,
      isFeatured: true,
      publishedAt: new Date()
    },
    {
      title: 'الذكاء الاصطناعي في التعليم: الفرص والتحديات',
      titleAr: 'الذكاء الاصطناعي في التعليم: الفرص والتحديات',
      content: `
يشهد قطاع التعليم ثورة حقيقية مع دخول تقنيات الذكاء الاصطناعي. 
من التعلم الشخصي إلى التقييم الذكي، الإمكانيات لا محدودة.

## التطبيقات الحالية:
1. أنظمة التوصية الذكية للمحتوى
2. المساعدات الافتراضية للطلاب
3. التقييم التلقائي للمهام
4. تحليل أداء الطلاب

## التحديات:
- الخصوصية وأمان البيانات
- الحاجة إلى تدريب المعلمين
- التكلفة العالية للتطبيق
- ضمان الجودة والدقة

المستقبل واعد، لكن يتطلب تخطيطاً دقيقاً وتنفيذاً حكيماً.
      `,
      contentAr: `
يشهد قطاع التعليم ثورة حقيقية مع دخول تقنيات الذكاء الاصطناعي. 
من التعلم الشخصي إلى التقييم الذكي، الإمكانيات لا محدودة.

## التطبيقات الحالية:
1. أنظمة التوصية الذكية للمحتوى
2. المساعدات الافتراضية للطلاب
3. التقييم التلقائي للمهام
4. تحليل أداء الطلاب

## التحديات:
- الخصوصية وأمان البيانات
- الحاجة إلى تدريب المعلمين
- التكلفة العالية للتطبيق
- ضمان الجودة والدقة

المستقبل واعد، لكن يتطلب تخطيطاً دقيقاً وتنفيذاً حكيماً.
      `,
      category: 'technology',
      author: 'د. أحمد محمد',
      thumbnail: 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=400',
      tags: ['AI', 'تعليم', 'تكنولوجيا'],
      isPublished: true,
      publishedAt: new Date(Date.now() - 24 * 60 * 60 * 1000)
    },
    {
      title: '10 نصائح للتعلم الفعال عن بُعد',
      titleAr: '10 نصائح للتعلم الفعال عن بُعد',
      content: `
التعلم عن بُعد أصبح جزءاً أساسياً من التعليم الحديث. إليك أهم النصائح للاستفادة القصوى:

## النصائح:
1. **خصص مكاناً للدراسة** - اختر مكاناً هادئاً ومريحاً
2. **ضع جدولاً زمنياً** - نظم وقتك بفعالية
3. **شارك بنشاط** - تفاعل مع المحتوى والمدربين
4. **خذ فترات راحة** - الراحة مهمة للتركيز
5. **استخدم تقنيات متنوعة** - فيديو، صوت، نص
6. **تواصل مع الزملاء** - التعلم الجماعي مفيد
7. **طبق ما تتعلمه** - المشاريع العملية أساسية
8. **اطلب المساعدة** - لا تتردد في السؤال
9. **راجع بانتظام** - المراجعة تثبت المعلومات
10. **احتفل بإنجازاتك** - كافئ نفسك على التقدم

النجاح في التعلم عن بُعد يتطلب الانضباط والتنظيم!
      `,
      contentAr: `
التعلم عن بُعد أصبح جزءاً أساسياً من التعليم الحديث. إليك أهم النصائح للاستفادة القصوى:

## النصائح:
1. **خصص مكاناً للدراسة** - اختر مكاناً هادئاً ومريحاً
2. **ضع جدولاً زمنياً** - نظم وقتك بفعالية
3. **شارك بنشاط** - تفاعل مع المحتوى والمدربين
4. **خذ فترات راحة** - الراحة مهمة للتركيز
5. **استخدم تقنيات متنوعة** - فيديو، صوت، نص
6. **تواصل مع الزملاء** - التعلم الجماعي مفيد
7. **طبق ما تتعلمه** - المشاريع العملية أساسية
8. **اطلب المساعدة** - لا تتردد في السؤال
9. **راجع بانتظام** - المراجعة تثبت المعلومات
10. **احتفل بإنجازاتك** - كافئ نفسك على التقدم

النجاح في التعلم عن بُعد يتطلب الانضباط والتنظيم!
      `,
      category: 'education',
      author: 'سارة أحمد',
      thumbnail: 'https://images.unsplash.com/photo-1588072432836-e10032774350?w=400',
      tags: ['تعلم', 'نصائح', 'online'],
      isPublished: true,
      publishedAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000)
    },
    {
      title: 'مستقبل البرمجة: اللغات الواعدة لعام 2025',
      titleAr: 'مستقبل البرمجة: اللغات الواعدة لعام 2025',
      content: `
مع التطور السريع في عالم التكنولوجيا، تبرز لغات برمجة جديدة وتتطور أخرى. 
إليك أهم اللغات التي يجب تعلمها في 2025:

## اللغات الأكثر طلباً:
### 1. Python
- الذكاء الاصطناعي وتعلم الآلة
- تحليل البيانات
- تطوير الويب

### 2. JavaScript/TypeScript
- تطوير الواجهات
- Node.js للخوادم
- React, Vue, Angular

### 3. Rust
- برمجة الأنظمة
- الأمان والأداء
- WebAssembly

### 4. Go
- الخدمات السحابية
- DevOps
- Microservices

### 5. Kotlin
- تطوير Android
- Multiplatform development

الاستثمار في تعلم هذه اللغات سيفتح أبواباً واسعة في سوق العمل!
      `,
      contentAr: `
مع التطور السريع في عالم التكنولوجيا، تبرز لغات برمجة جديدة وتتطور أخرى. 
إليك أهم اللغات التي يجب تعلمها في 2025:

## اللغات الأكثر طلباً:
### 1. Python
- الذكاء الاصطناعي وتعلم الآلة
- تحليل البيانات
- تطوير الويب

### 2. JavaScript/TypeScript
- تطوير الواجهات
- Node.js للخوادم
- React, Vue, Angular

### 3. Rust
- برمجة الأنظمة
- الأمان والأداء
- WebAssembly

### 4. Go
- الخدمات السحابية
- DevOps
- Microservices

### 5. Kotlin
- تطوير Android
- Multiplatform development

الاستثمار في تعلم هذه اللغات سيفتح أبواباً واسعة في سوق العمل!
      `,
      category: 'technology',
      author: 'د. أحمد محمد',
      thumbnail: 'https://images.unsplash.com/photo-1515879218367-8466d910aaa4?w=400',
      tags: ['برمجة', 'لغات', '2025'],
      isPublished: true,
      publishedAt: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000)
    },
    {
      title: 'قصص نجاح: من طلابنا إلى قادة في التقنية',
      titleAr: 'قصص نجاح: من طلابنا إلى قادة في التقنية',
      content: `
نفتخر بقصص نجاح طلابنا الذين تحولوا من مبتدئين إلى محترفين في مجالاتهم.

## قصة أحمد - من الصفر إلى Full Stack Developer
بدأ أحمد رحلته معنا قبل عام واحد فقط، واليوم يعمل في شركة تقنية رائدة.
"المنصة غيرت حياتي المهنية بالكامل" - أحمد

## قصة فاطمة - مصممة UI/UX محترفة
تحولت فاطمة من موظفة إدارية إلى مصممة محترفة خلال 8 أشهر.
"التعلم العملي والمشاريع الحقيقية كانت المفتاح" - فاطمة

## قصة محمد - رائد أعمال تقني
أسس محمد شركته الناشئة بعد إكمال دورة تطوير التطبيقات.
"المهارات التي اكتسبتها مكنتني من تحقيق حلمي" - محمد

كن القصة التالية للنجاح!
      `,
      contentAr: `
نفتخر بقصص نجاح طلابنا الذين تحولوا من مبتدئين إلى محترفين في مجالاتهم.

## قصة أحمد - من الصفر إلى Full Stack Developer
بدأ أحمد رحلته معنا قبل عام واحد فقط، واليوم يعمل في شركة تقنية رائدة.
"المنصة غيرت حياتي المهنية بالكامل" - أحمد

## قصة فاطمة - مصممة UI/UX محترفة
تحولت فاطمة من موظفة إدارية إلى مصممة محترفة خلال 8 أشهر.
"التعلم العملي والمشاريع الحقيقية كانت المفتاح" - فاطمة

## قصة محمد - رائد أعمال تقني
أسس محمد شركته الناشئة بعد إكمال دورة تطوير التطبيقات.
"المهارات التي اكتسبتها مكنتني من تحقيق حلمي" - محمد

كن القصة التالية للنجاح!
      `,
      category: 'success-stories',
      author: 'إدارة رقيم',
      thumbnail: 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=400',
      tags: ['نجاح', 'قصص', 'إلهام'],
      isPublished: true,
      isFeatured: true,
      publishedAt: new Date(Date.now() - 4 * 24 * 60 * 60 * 1000)
    }
  ];
  
  await News.insertMany(newsArticles);
  console.log(`✅ Created ${newsArticles.length} news articles`);
}

async function addEnrollments(courses, students) {
  for (const course of courses) {
    // Enroll random students
    const enrollCount = Math.floor(Math.random() * students.length) + 1;
    const enrolledStudents = students.slice(0, enrollCount);
    
    for (const student of enrolledStudents) {
      course.enrolledStudents.push(student._id);
      
      // Add random reviews
      if (Math.random() > 0.5) {
        course.reviews.push({
          user: student._id,
          rating: Math.floor(Math.random() * 2) + 4, // 4 or 5 stars
          comment: 'دورة ممتازة ومفيدة جداً!'
        });
      }
    }
    
    course.numberOfEnrollments = course.enrolledStudents.length;
    course.calculateAverageRating();
    await course.save();
  }
  
  console.log('✅ Added enrollments and reviews');
}

async function seedDatabase() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/raqim_learning');
    console.log('📊 Connected to MongoDB');
    
    // Clear existing data
    await clearDatabase();
    
    // Create users
    const { admin, teacher1, teacher2, teacher3, students } = await createUsers();
    
    // Create courses with lessons
    const courses = await createCourses({ teacher1, teacher2, teacher3 });
    
    // Create news articles
    await createNews();
    
    // Add enrollments and reviews
    await addEnrollments(courses, students);
    
    console.log('\n✅ ==========================================');
    console.log('✅ Database seeded successfully!');
    console.log('✅ ==========================================\n');
    
    console.log('📝 Login Credentials:');
    console.log('------------------------');
    console.log('Admin: admin@raqim.com / admin123');
    console.log('Teacher: ahmed@raqim.com / teacher123');
    console.log('Student: student1@raqim.com / student123');
    console.log('------------------------\n');
    
    console.log('📊 Database Summary:');
    console.log('------------------------');
    console.log(`Users: ${await User.countDocuments()}`);
    console.log(`Courses: ${await Course.countDocuments()}`);
    console.log(`Lessons: ${await Lesson.countDocuments()}`);
    console.log(`News Articles: ${await News.countDocuments()}`);
    console.log('------------------------');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding database:', error);
    process.exit(1);
  }
}

// Run the seeder
seedDatabase();