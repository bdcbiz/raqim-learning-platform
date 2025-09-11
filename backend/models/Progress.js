const mongoose = require('mongoose');

const ProgressSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  course: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Course',
    required: true
  },
  completedLessons: [{
    lesson: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Lesson'
    },
    completedAt: {
      type: Date,
      default: Date.now
    },
    score: Number,
    timeSpent: Number,
    attempts: Number
  }],
  currentLesson: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Lesson'
  },
  overallProgress: {
    type: Number,
    default: 0,
    min: 0,
    max: 100
  },
  quizScores: [{
    lesson: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Lesson'
    },
    score: Number,
    maxScore: Number,
    attempts: Number,
    lastAttempt: Date,
    passed: Boolean
  }],
  assignmentSubmissions: [{
    lesson: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Lesson'
    },
    submittedAt: Date,
    content: String,
    fileUrl: String,
    score: Number,
    feedback: String,
    graded: {
      type: Boolean,
      default: false
    }
  }],
  totalTimeSpent: {
    type: Number,
    default: 0
  },
  lastAccessedAt: {
    type: Date,
    default: Date.now
  },
  streakDays: {
    type: Number,
    default: 0
  },
  lastStreakDate: Date,
  notes: [{
    lesson: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Lesson'
    },
    content: String,
    createdAt: {
      type: Date,
      default: Date.now
    },
    updatedAt: Date
  }],
  bookmarks: [{
    lesson: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Lesson'
    },
    timestamp: Number,
    note: String,
    createdAt: {
      type: Date,
      default: Date.now
    }
  }],
  achievements: [{
    type: {
      type: String,
      enum: ['first-lesson', 'quiz-master', 'streak-7', 'streak-30', 'course-complete', 'perfect-score']
    },
    earnedAt: {
      type: Date,
      default: Date.now
    }
  }],
  certificateIssued: {
    type: Boolean,
    default: false
  },
  certificateIssuedAt: Date,
  certificateUrl: String,
  startedAt: {
    type: Date,
    default: Date.now
  },
  completedAt: Date,
  isPaused: {
    type: Boolean,
    default: false
  },
  pausedAt: Date,
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

ProgressSchema.index({ user: 1, course: 1 }, { unique: true });

ProgressSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  this.lastAccessedAt = Date.now();
  
  const totalLessons = this.completedLessons.length;
  if (totalLessons > 0) {
    const courseModel = mongoose.model('Course');
    courseModel.findById(this.course).then(course => {
      if (course && course.totalLessons > 0) {
        this.overallProgress = Math.round((totalLessons / course.totalLessons) * 100);
      }
    });
  }
  
  next();
});

ProgressSchema.methods.updateStreak = function() {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  
  if (!this.lastStreakDate) {
    this.streakDays = 1;
    this.lastStreakDate = today;
  } else {
    const lastStreak = new Date(this.lastStreakDate);
    lastStreak.setHours(0, 0, 0, 0);
    
    const daysDiff = Math.floor((today - lastStreak) / (1000 * 60 * 60 * 24));
    
    if (daysDiff === 1) {
      this.streakDays += 1;
      this.lastStreakDate = today;
    } else if (daysDiff > 1) {
      this.streakDays = 1;
      this.lastStreakDate = today;
    }
  }
  
  return this.save();
};

module.exports = mongoose.model('Progress', ProgressSchema);