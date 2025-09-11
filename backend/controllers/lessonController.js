const Lesson = require('../models/Lesson');
const Course = require('../models/Course');
const Progress = require('../models/Progress');

exports.getLessons = async (req, res, next) => {
  try {
    const { courseId } = req.params;
    
    const lessons = await Lesson.find({ course: courseId })
      .sort('section order')
      .select('-quiz.questions.correctAnswer');

    res.status(200).json({
      success: true,
      count: lessons.length,
      data: lessons
    });
  } catch (err) {
    next(err);
  }
};

exports.getLesson = async (req, res, next) => {
  try {
    const lesson = await Lesson.findById(req.params.id)
      .populate('course', 'title instructor')
      .populate('comments.user', 'name avatar')
      .populate('comments.replies.user', 'name avatar');

    if (!lesson) {
      return res.status(404).json({
        success: false,
        error: 'Lesson not found'
      });
    }

    const progress = await Progress.findOne({
      user: req.user.id,
      course: lesson.course._id
    });

    if (!progress) {
      return res.status(401).json({
        success: false,
        error: 'You must be enrolled in the course to access this lesson'
      });
    }

    await lesson.incrementViews();

    res.status(200).json({
      success: true,
      data: lesson
    });
  } catch (err) {
    next(err);
  }
};

exports.createLesson = async (req, res, next) => {
  try {
    const course = await Course.findById(req.body.course);

    if (!course) {
      return res.status(404).json({
        success: false,
        error: 'Course not found'
      });
    }

    if (course.instructor.toString() !== req.user.id && req.user.role !== 'admin') {
      return res.status(401).json({
        success: false,
        error: 'Not authorized to add lessons to this course'
      });
    }

    const lesson = await Lesson.create(req.body);

    const sectionIndex = course.sections.findIndex(
      section => section.title === req.body.section
    );

    if (sectionIndex === -1) {
      course.sections.push({
        title: req.body.section,
        titleAr: req.body.sectionAr || req.body.section,
        order: course.sections.length + 1,
        lessons: [lesson._id]
      });
    } else {
      course.sections[sectionIndex].lessons.push(lesson._id);
    }

    course.totalLessons += 1;
    await course.save();

    res.status(201).json({
      success: true,
      data: lesson
    });
  } catch (err) {
    next(err);
  }
};

exports.updateLesson = async (req, res, next) => {
  try {
    let lesson = await Lesson.findById(req.params.id).populate('course');

    if (!lesson) {
      return res.status(404).json({
        success: false,
        error: 'Lesson not found'
      });
    }

    if (lesson.course.instructor.toString() !== req.user.id && req.user.role !== 'admin') {
      return res.status(401).json({
        success: false,
        error: 'Not authorized to update this lesson'
      });
    }

    lesson = await Lesson.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true
    });

    res.status(200).json({
      success: true,
      data: lesson
    });
  } catch (err) {
    next(err);
  }
};

exports.deleteLesson = async (req, res, next) => {
  try {
    const lesson = await Lesson.findById(req.params.id).populate('course');

    if (!lesson) {
      return res.status(404).json({
        success: false,
        error: 'Lesson not found'
      });
    }

    if (lesson.course.instructor.toString() !== req.user.id && req.user.role !== 'admin') {
      return res.status(401).json({
        success: false,
        error: 'Not authorized to delete this lesson'
      });
    }

    await lesson.remove();

    const course = await Course.findById(lesson.course._id);
    course.totalLessons -= 1;
    
    for (let section of course.sections) {
      section.lessons = section.lessons.filter(
        lessonId => lessonId.toString() !== req.params.id
      );
    }
    
    await course.save();

    res.status(200).json({
      success: true,
      data: {}
    });
  } catch (err) {
    next(err);
  }
};

exports.completeLesson = async (req, res, next) => {
  try {
    const lesson = await Lesson.findById(req.params.id);

    if (!lesson) {
      return res.status(404).json({
        success: false,
        error: 'Lesson not found'
      });
    }

    let progress = await Progress.findOne({
      user: req.user.id,
      course: lesson.course
    });

    if (!progress) {
      return res.status(401).json({
        success: false,
        error: 'You must be enrolled in the course'
      });
    }

    const alreadyCompleted = progress.completedLessons.find(
      item => item.lesson.toString() === req.params.id
    );

    if (!alreadyCompleted) {
      progress.completedLessons.push({
        lesson: lesson._id,
        completedAt: Date.now(),
        score: req.body.score,
        timeSpent: req.body.timeSpent
      });

      const course = await Course.findById(lesson.course);
      progress.overallProgress = Math.round(
        (progress.completedLessons.length / course.totalLessons) * 100
      );

      await progress.updateStreak();
      await progress.save();
    }

    res.status(200).json({
      success: true,
      data: progress
    });
  } catch (err) {
    next(err);
  }
};

exports.addComment = async (req, res, next) => {
  try {
    const lesson = await Lesson.findById(req.params.id);

    if (!lesson) {
      return res.status(404).json({
        success: false,
        error: 'Lesson not found'
      });
    }

    const comment = {
      user: req.user.id,
      text: req.body.text,
      createdAt: Date.now()
    };

    lesson.comments.push(comment);
    await lesson.save();

    res.status(201).json({
      success: true,
      data: comment
    });
  } catch (err) {
    next(err);
  }
};

exports.submitQuiz = async (req, res, next) => {
  try {
    const lesson = await Lesson.findById(req.params.id);

    if (!lesson || lesson.type !== 'quiz') {
      return res.status(404).json({
        success: false,
        error: 'Quiz not found'
      });
    }

    const { answers } = req.body;
    let score = 0;
    let totalPoints = 0;
    const results = [];

    lesson.quiz.questions.forEach((question, index) => {
      totalPoints += question.points;
      const userAnswer = answers[index];
      let isCorrect = false;

      if (question.type === 'multiple-choice') {
        const correctOption = question.options.find(opt => opt.isCorrect);
        isCorrect = userAnswer === correctOption.text;
      } else {
        isCorrect = userAnswer === question.correctAnswer;
      }

      if (isCorrect) {
        score += question.points;
      }

      results.push({
        question: question.question,
        userAnswer,
        isCorrect,
        explanation: question.explanation
      });
    });

    const percentage = Math.round((score / totalPoints) * 100);
    const passed = percentage >= lesson.quiz.passingScore;

    const progress = await Progress.findOne({
      user: req.user.id,
      course: lesson.course
    });

    if (progress) {
      const quizRecord = progress.quizScores.find(
        q => q.lesson.toString() === req.params.id
      );

      if (quizRecord) {
        quizRecord.score = Math.max(quizRecord.score, percentage);
        quizRecord.attempts += 1;
        quizRecord.lastAttempt = Date.now();
        quizRecord.passed = passed || quizRecord.passed;
      } else {
        progress.quizScores.push({
          lesson: lesson._id,
          score: percentage,
          maxScore: 100,
          attempts: 1,
          lastAttempt: Date.now(),
          passed
        });
      }

      await progress.save();
    }

    res.status(200).json({
      success: true,
      data: {
        score,
        totalPoints,
        percentage,
        passed,
        results
      }
    });
  } catch (err) {
    next(err);
  }
};