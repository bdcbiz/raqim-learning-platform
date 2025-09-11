const mongoose = require('mongoose');
const dotenv = require('dotenv');
const News = require('../models/News');

dotenv.config({ path: '../.env' });

const newsArticles = [
  {
    title: 'New Python Course Launched - Learn Programming from Scratch',
    titleAr: 'إطلاق دورة Python جديدة - تعلم البرمجة من الصفر',
    content: 'We are excited to announce the launch of our comprehensive Python programming course. This course is designed for absolute beginners and will take you from zero to hero in Python programming. The course covers everything from basic syntax to advanced topics like web development with Django and data science with Pandas. With over 180 minutes of content and 10 structured lessons, you will master Python through hands-on projects and real-world examples.',
    contentAr: 'يسعدنا أن نعلن عن إطلاق دورة Python البرمجية الشاملة. هذه الدورة مصممة للمبتدئين تماماً وستأخذك من الصفر إلى الاحتراف في برمجة Python. تغطي الدورة كل شيء من الصياغة الأساسية إلى المواضيع المتقدمة مثل تطوير الويب باستخدام Django وعلم البيانات باستخدام Pandas. مع أكثر من 180 دقيقة من المحتوى و10 دروس منظمة، ستتقن Python من خلال المشاريع العملية والأمثلة الواقعية.',
    category: 'announcement',
    author: 'Raqim Team',
    tags: ['Python', 'Programming', 'New Course', 'Beginner'],
    thumbnail: 'https://images.unsplash.com/photo-1526379095098-d400fd0bf935?w=800&q=80',
    isPublished: true,
    isFeatured: true,
    publishedAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000)
  },
  {
    title: 'Success Story: From Student to Full Stack Developer in 6 Months',
    titleAr: 'قصة نجاح: من طالب إلى مطور Full Stack في 6 أشهر',
    content: 'Meet Ahmed Hassan, one of our star students who transformed his career in just 6 months. Starting with no prior programming experience, Ahmed enrolled in our Full Stack Web Development course. Through dedication and hard work, he mastered HTML, CSS, JavaScript, React, and Node.js. Today, Ahmed works as a Full Stack Developer at a leading tech company. His journey is an inspiration to all our students. Ahmed says: "The structured curriculum and hands-on projects at Raqim made all the difference in my learning journey."',
    contentAr: 'تعرف على أحمد حسن، أحد طلابنا المتميزين الذي غير مسار حياته المهنية في 6 أشهر فقط. بدأ أحمد بدون أي خبرة برمجية سابقة، والتحق بدورة تطوير الويب الشاملة. من خلال التفاني والعمل الجاد، أتقن HTML وCSS وJavaScript وReact وNode.js. اليوم، يعمل أحمد كمطور Full Stack في شركة تقنية رائدة. رحلته ملهمة لجميع طلابنا. يقول أحمد: "المنهج المنظم والمشاريع العملية في رقيم صنعت كل الفرق في رحلة تعلمي."',
    category: 'success-stories',
    author: 'Sara Mohamed',
    tags: ['Success Story', 'Web Development', 'Career Change'],
    thumbnail: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&q=80',
    isPublished: true,
    publishedAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000)
  },
  {
    title: '10 Tips to Master Programming Faster',
    titleAr: '10 نصائح لإتقان البرمجة بشكل أسرع',
    content: '1. Practice coding every day, even if just for 30 minutes. 2. Build real projects, not just follow tutorials. 3. Read other peoples code on GitHub. 4. Join a coding community for support. 5. Learn debugging techniques early. 6. Focus on understanding concepts, not memorizing syntax. 7. Take breaks to avoid burnout. 8. Teach what you learn to others. 9. Use version control from day one. 10. Never stop learning and stay curious. These tips have helped thousands of our students accelerate their learning journey.',
    contentAr: '1. مارس البرمجة كل يوم، حتى لو لمدة 30 دقيقة فقط. 2. ابنِ مشاريع حقيقية، لا تكتفي بمتابعة الدروس. 3. اقرأ أكواد الآخرين على GitHub. 4. انضم لمجتمع برمجي للحصول على الدعم. 5. تعلم تقنيات تصحيح الأخطاء مبكراً. 6. ركز على فهم المفاهيم، وليس حفظ الصياغة. 7. خذ فترات راحة لتجنب الإرهاق. 8. علّم ما تتعلمه للآخرين. 9. استخدم التحكم بالإصدارات من اليوم الأول. 10. لا تتوقف عن التعلم وابقَ فضولياً. هذه النصائح ساعدت آلاف طلابنا على تسريع رحلة تعلمهم.',
    category: 'tips',
    author: 'Dr. Ahmed Mohamed',
    tags: ['Programming Tips', 'Learning', 'Best Practices'],
    thumbnail: 'https://images.unsplash.com/photo-1461749280684-dccba630e2f6?w=800&q=80',
    isPublished: true,
    publishedAt: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)
  },
  {
    title: 'Upcoming Workshop: Introduction to AI and Machine Learning',
    titleAr: 'ورشة عمل قادمة: مقدمة في الذكاء الاصطناعي والتعلم الآلي',
    content: 'Join us for an exclusive online workshop on Introduction to AI and Machine Learning. This free workshop will be held next Saturday at 6 PM and will cover the basics of AI, machine learning algorithms, and practical applications. Dr. Sara Ali, our expert instructor, will guide you through hands-on examples using Python and popular ML libraries. Whether you are a beginner or have some programming experience, this workshop will provide valuable insights into the world of AI. Limited seats available - register now!',
    contentAr: 'انضم إلينا في ورشة عمل حصرية عبر الإنترنت حول مقدمة في الذكاء الاصطناعي والتعلم الآلي. ستُعقد هذه الورشة المجانية يوم السبت القادم في الساعة 6 مساءً وستغطي أساسيات الذكاء الاصطناعي وخوارزميات التعلم الآلي والتطبيقات العملية. ستقود د. سارة علي، مدربتنا الخبيرة، من خلال أمثلة عملية باستخدام Python ومكتبات ML الشائعة. سواء كنت مبتدئاً أو لديك بعض الخبرة البرمجية، ستوفر هذه الورشة رؤى قيمة في عالم الذكاء الاصطناعي. المقاعد محدودة - سجل الآن!',
    category: 'events',
    author: 'Raqim Events Team',
    tags: ['Workshop', 'AI', 'Machine Learning', 'Free Event'],
    thumbnail: 'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=800&q=80',
    isPublished: true,
    isFeatured: true,
    publishedAt: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000)
  },
  {
    title: 'Mobile App Development Trends in 2024',
    titleAr: 'اتجاهات تطوير تطبيقات الموبايل في 2024',
    content: 'The mobile app development landscape continues to evolve rapidly. In 2024, we are seeing major trends including: Cross-platform development with Flutter and React Native gaining more adoption, AI integration becoming standard in mobile apps, 5G technology enabling richer experiences, Augmented Reality (AR) features becoming mainstream, and increased focus on app security and privacy. Our Flutter Mobile Development course has been updated to include these latest trends, ensuring our students stay ahead of the curve.',
    contentAr: 'يستمر مشهد تطوير تطبيقات الموبايل في التطور بسرعة. في عام 2024، نشهد اتجاهات رئيسية تشمل: التطوير عبر المنصات مع Flutter وReact Native يكتسب المزيد من الاعتماد، دمج الذكاء الاصطناعي يصبح معياراً في تطبيقات الموبايل، تقنية 5G تمكن من تجارب أغنى، ميزات الواقع المعزز (AR) تصبح سائدة، والتركيز المتزايد على أمان التطبيق والخصوصية. تم تحديث دورة تطوير Flutter للموبايل لدينا لتشمل هذه الاتجاهات الأحدث، مما يضمن بقاء طلابنا في المقدمة.',
    category: 'technology',
    author: 'Tech Analysis Team',
    tags: ['Mobile Development', 'Flutter', 'Tech Trends', '2024'],
    thumbnail: 'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=800&q=80',
    isPublished: true,
    publishedAt: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000)
  },
  {
    title: 'Platform Update: New Features for Better Learning Experience',
    titleAr: 'تحديث المنصة: ميزات جديدة لتجربة تعلم أفضل',
    content: 'We are thrilled to announce major updates to the Raqim Learning Platform! New features include: Interactive coding exercises within lessons, Real-time collaboration tools for group projects, AI-powered personalized learning paths, Offline mode for downloading courses, Advanced progress tracking with detailed analytics, and Gamification elements with badges and achievements. These updates are designed to make your learning journey more engaging and effective. All features are now live and available to all users.',
    contentAr: 'يسعدنا أن نعلن عن تحديثات رئيسية لمنصة رقيم التعليمية! الميزات الجديدة تشمل: تمارين برمجة تفاعلية داخل الدروس، أدوات تعاون في الوقت الفعلي للمشاريع الجماعية، مسارات تعلم مخصصة مدعومة بالذكاء الاصطناعي، وضع غير متصل لتحميل الدورات، تتبع تقدم متقدم مع تحليلات مفصلة، وعناصر اللعبة مع الشارات والإنجازات. تم تصميم هذه التحديثات لجعل رحلة تعلمك أكثر تفاعلاً وفعالية. جميع الميزات متاحة الآن لجميع المستخدمين.',
    category: 'updates',
    author: 'Product Team',
    tags: ['Platform Update', 'New Features', 'Learning Experience'],
    thumbnail: 'https://images.unsplash.com/photo-1551434678-e076c223a692?w=800&q=80',
    isPublished: true,
    isFeatured: true,
    publishedAt: new Date()
  },
  {
    title: 'The Future of Education: How Technology is Transforming Learning',
    titleAr: 'مستقبل التعليم: كيف تحول التكنولوجيا التعلم',
    content: 'Education is undergoing a revolutionary transformation. Virtual Reality (VR) classrooms are creating immersive learning experiences, AI tutors provide personalized assistance 24/7, Blockchain technology is securing and verifying credentials, Microlearning is making education more accessible, and Adaptive learning systems adjust to individual student needs. At Raqim, we embrace these technologies to provide cutting-edge education. Our platform integrates the latest educational technologies to ensure our students receive the best possible learning experience.',
    contentAr: 'يخضع التعليم لتحول ثوري. فصول الواقع الافتراضي (VR) تخلق تجارب تعلم غامرة، معلمو الذكاء الاصطناعي يوفرون مساعدة مخصصة على مدار الساعة، تقنية البلوكشين تؤمن وتتحقق من الشهادات، التعلم المصغر يجعل التعليم أكثر سهولة، وأنظمة التعلم التكيفية تتكيف مع احتياجات الطلاب الفردية. في رقيم، نتبنى هذه التقنيات لتوفير تعليم متطور. تدمج منصتنا أحدث التقنيات التعليمية لضمان حصول طلابنا على أفضل تجربة تعلم ممكنة.',
    category: 'education',
    author: 'Dr. Mohamed Ibrahim',
    tags: ['Education', 'Technology', 'Future', 'Innovation'],
    thumbnail: 'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=800&q=80',
    isPublished: true,
    publishedAt: new Date(Date.now() - 4 * 24 * 60 * 60 * 1000)
  },
  {
    title: 'Industry Partnership: Raqim Collaborates with Tech Giants',
    titleAr: 'شراكة صناعية: رقيم تتعاون مع عمالقة التكنولوجيا',
    content: 'We are proud to announce strategic partnerships with leading technology companies. These partnerships will bring exclusive benefits to our students including: Internship opportunities at partner companies, Industry-recognized certifications, Access to enterprise tools and platforms, Guest lectures from industry experts, and Real-world project collaborations. This initiative bridges the gap between education and industry, ensuring our graduates are job-ready and highly sought after by employers.',
    contentAr: 'نفخر بالإعلان عن شراكات استراتيجية مع شركات التكنولوجيا الرائدة. ستجلب هذه الشراكات فوائد حصرية لطلابنا بما في ذلك: فرص تدريب في الشركات الشريكة، شهادات معترف بها في الصناعة، الوصول إلى أدوات ومنصات المؤسسات، محاضرات ضيوف من خبراء الصناعة، وتعاون في مشاريع حقيقية. تسد هذه المبادرة الفجوة بين التعليم والصناعة، مما يضمن أن خريجينا جاهزون للعمل ومطلوبون بشدة من قبل أصحاب العمل.',
    category: 'industry',
    author: 'Partnership Team',
    tags: ['Partnership', 'Industry', 'Career', 'Opportunities'],
    thumbnail: 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=800&q=80',
    isPublished: true,
    publishedAt: new Date(Date.now() - 6 * 24 * 60 * 60 * 1000)
  }
];

async function seedNews() {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/raqim_learning');
    console.log('✅ Connected to MongoDB');
    
    // Clear existing news
    await News.deleteMany({});
    console.log('✅ News collection cleared');
    
    // Create news articles
    const createdNews = await News.create(newsArticles);
    console.log(`✅ Created ${createdNews.length} news articles`);
    
    console.log('\n========================================');
    console.log('✅ NEWS SEEDED SUCCESSFULLY!');
    console.log('========================================\n');
    
    console.log('📰 News Summary:');
    console.log('------------------------');
    console.log(`Total Articles: ${createdNews.length}`);
    console.log(`Featured Articles: ${createdNews.filter(n => n.isFeatured).length}`);
    console.log(`Categories: ${[...new Set(createdNews.map(n => n.category))].join(', ')}`);
    console.log('------------------------\n');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

seedNews();