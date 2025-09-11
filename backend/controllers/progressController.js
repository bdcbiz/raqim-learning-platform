const Progress = require('../models/Progress');
const Course = require('../models/Course');
const User = require('../models/User');

exports.getCourseProgress = async (req, res, next) => {
  try {
    const progress = await Progress.findOne({
      user: req.user.id,
      course: req.params.courseId
    })
      .populate('completedLessons.lesson', 'title type')
      .populate('currentLesson', 'title type')
      .populate('course', 'title totalLessons');

    if (!progress) {
      return res.status(404).json({
        success: false,
        error: 'Progress not found. Please enroll in the course first.'
      });
    }

    res.status(200).json({
      success: true,
      data: progress
    });
  } catch (err) {
    next(err);
  }
};

exports.getAllProgress = async (req, res, next) => {
  try {
    const progress = await Progress.find({ user: req.user.id })
      .populate('course', 'title titleAr thumbnail instructor')
      .populate('currentLesson', 'title');

    res.status(200).json({
      success: true,
      count: progress.length,
      data: progress
    });
  } catch (err) {
    next(err);
  }
};

exports.updateCurrentLesson = async (req, res, next) => {
  try {
    const { lessonId } = req.body;

    const progress = await Progress.findOne({
      user: req.user.id,
      course: req.params.courseId
    });

    if (!progress) {
      return res.status(404).json({
        success: false,
        error: 'Progress not found'
      });
    }

    progress.currentLesson = lessonId;
    progress.lastAccessedAt = Date.now();
    await progress.save();

    res.status(200).json({
      success: true,
      data: progress
    });
  } catch (err) {
    next(err);
  }
};

exports.addNote = async (req, res, next) => {
  try {
    const { lessonId, content } = req.body;

    const progress = await Progress.findOne({
      user: req.user.id,
      course: req.params.courseId
    });

    if (!progress) {
      return res.status(404).json({
        success: false,
        error: 'Progress not found'
      });
    }

    const existingNote = progress.notes.find(
      note => note.lesson.toString() === lessonId
    );

    if (existingNote) {
      existingNote.content = content;
      existingNote.updatedAt = Date.now();
    } else {
      progress.notes.push({
        lesson: lessonId,
        content,
        createdAt: Date.now()
      });
    }

    await progress.save();

    res.status(200).json({
      success: true,
      data: progress.notes
    });
  } catch (err) {
    next(err);
  }
};

exports.addBookmark = async (req, res, next) => {
  try {
    const { lessonId, timestamp, note } = req.body;

    const progress = await Progress.findOne({
      user: req.user.id,
      course: req.params.courseId
    });

    if (!progress) {
      return res.status(404).json({
        success: false,
        error: 'Progress not found'
      });
    }

    progress.bookmarks.push({
      lesson: lessonId,
      timestamp,
      note,
      createdAt: Date.now()
    });

    await progress.save();

    res.status(201).json({
      success: true,
      data: progress.bookmarks
    });
  } catch (err) {
    next(err);
  }
};

exports.removeBookmark = async (req, res, next) => {
  try {
    const progress = await Progress.findOne({
      user: req.user.id,
      course: req.params.courseId
    });

    if (!progress) {
      return res.status(404).json({
        success: false,
        error: 'Progress not found'
      });
    }

    progress.bookmarks = progress.bookmarks.filter(
      bookmark => bookmark._id.toString() !== req.params.bookmarkId
    );

    await progress.save();

    res.status(200).json({
      success: true,
      data: progress.bookmarks
    });
  } catch (err) {
    next(err);
  }
};

exports.getStatistics = async (req, res, next) => {
  try {
    const userId = req.user.id;

    const allProgress = await Progress.find({ user: userId })
      .populate('course', 'title totalLessons');

    const stats = {
      totalCourses: allProgress.length,
      completedCourses: 0,
      inProgressCourses: 0,
      totalLessonsCompleted: 0,
      totalTimeSpent: 0,
      averageProgress: 0,
      currentStreak: 0,
      achievements: []
    };

    allProgress.forEach(progress => {
      if (progress.overallProgress === 100) {
        stats.completedCourses++;
      } else if (progress.overallProgress > 0) {
        stats.inProgressCourses++;
      }

      stats.totalLessonsCompleted += progress.completedLessons.length;
      stats.totalTimeSpent += progress.totalTimeSpent;
      stats.averageProgress += progress.overallProgress;

      if (progress.streakDays > stats.currentStreak) {
        stats.currentStreak = progress.streakDays;
      }

      stats.achievements = [...stats.achievements, ...progress.achievements];
    });

    if (allProgress.length > 0) {
      stats.averageProgress = Math.round(stats.averageProgress / allProgress.length);
    }

    stats.achievements = [...new Set(stats.achievements.map(a => a.type))];

    res.status(200).json({
      success: true,
      data: stats
    });
  } catch (err) {
    next(err);
  }
};

exports.getCertificate = async (req, res, next) => {
  try {
    const progress = await Progress.findOne({
      user: req.user.id,
      course: req.params.courseId
    })
      .populate('course', 'title certificate')
      .populate('user', 'name email');

    if (!progress) {
      return res.status(404).json({
        success: false,
        error: 'Progress not found'
      });
    }

    if (progress.overallProgress < 100) {
      return res.status(400).json({
        success: false,
        error: 'Course not completed yet'
      });
    }

    const course = await Course.findById(req.params.courseId);
    
    if (!course.certificate.isAvailable) {
      return res.status(400).json({
        success: false,
        error: 'Certificate not available for this course'
      });
    }

    const averageQuizScore = progress.quizScores.reduce((acc, quiz) => {
      return acc + quiz.score;
    }, 0) / progress.quizScores.length;

    if (averageQuizScore < course.certificate.minimumScore) {
      return res.status(400).json({
        success: false,
        error: `Minimum score of ${course.certificate.minimumScore}% required for certificate`
      });
    }

    if (!progress.certificateIssued) {
      progress.certificateIssued = true;
      progress.certificateIssuedAt = Date.now();
      progress.certificateUrl = `/certificates/${progress._id}`;
      await progress.save();
    }

    res.status(200).json({
      success: true,
      data: {
        certificateUrl: progress.certificateUrl,
        issuedAt: progress.certificateIssuedAt,
        courseName: course.title,
        userName: progress.user.name,
        completedAt: progress.completedAt
      }
    });
  } catch (err) {
    next(err);
  }
};