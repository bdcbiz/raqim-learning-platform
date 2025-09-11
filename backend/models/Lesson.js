const mongoose = require('mongoose');

const LessonSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Please add a lesson title'],
    trim: true,
    maxlength: [100, 'Title cannot be more than 100 characters']
  },
  titleAr: {
    type: String,
    required: [true, 'Please add an Arabic lesson title'],
    trim: true,
    maxlength: [100, 'Title cannot be more than 100 characters']
  },
  description: {
    type: String,
    maxlength: [500, 'Description cannot be more than 500 characters']
  },
  descriptionAr: {
    type: String,
    maxlength: [500, 'Description cannot be more than 500 characters']
  },
  course: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Course',
    required: true
  },
  section: {
    type: String,
    required: true
  },
  order: {
    type: Number,
    required: true
  },
  type: {
    type: String,
    enum: ['video', 'text', 'quiz', 'assignment', 'interactive'],
    required: true
  },
  content: {
    videoUrl: String,
    videoDuration: Number,
    text: String,
    textAr: String,
    attachments: [{
      name: String,
      url: String,
      type: String,
      size: Number
    }],
    externalLinks: [{
      title: String,
      url: String,
      description: String
    }]
  },
  quiz: {
    questions: [{
      question: String,
      questionAr: String,
      type: {
        type: String,
        enum: ['multiple-choice', 'true-false', 'short-answer', 'essay'],
        default: 'multiple-choice'
      },
      options: [{
        text: String,
        textAr: String,
        isCorrect: Boolean
      }],
      correctAnswer: String,
      explanation: String,
      explanationAr: String,
      points: {
        type: Number,
        default: 1
      }
    }],
    passingScore: {
      type: Number,
      default: 70,
      min: 0,
      max: 100
    },
    timeLimit: Number,
    attempts: {
      type: Number,
      default: 3
    }
  },
  assignment: {
    instructions: String,
    instructionsAr: String,
    dueDate: Date,
    maxScore: {
      type: Number,
      default: 100
    },
    submissionType: {
      type: String,
      enum: ['file', 'text', 'link'],
      default: 'file'
    },
    allowedFileTypes: [String]
  },
  interactive: {
    type: {
      type: String,
      enum: ['code-editor', 'simulation', 'game', 'calculator']
    },
    config: mongoose.Schema.Types.Mixed
  },
  duration: {
    type: Number,
    default: 0
  },
  isFree: {
    type: Boolean,
    default: false
  },
  isPublished: {
    type: Boolean,
    default: false
  },
  prerequisites: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Lesson'
  }],
  completions: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    completedAt: {
      type: Date,
      default: Date.now
    },
    score: Number,
    attempts: Number,
    timeSpent: Number
  }],
  resources: [{
    title: String,
    titleAr: String,
    type: {
      type: String,
      enum: ['pdf', 'doc', 'image', 'code', 'other']
    },
    url: String,
    size: Number
  }],
  comments: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    text: String,
    createdAt: {
      type: Date,
      default: Date.now
    },
    replies: [{
      user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
      },
      text: String,
      createdAt: {
        type: Date,
        default: Date.now
      }
    }]
  }],
  likes: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }],
  views: {
    type: Number,
    default: 0
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

LessonSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

LessonSchema.methods.incrementViews = function() {
  this.views += 1;
  return this.save();
};

LessonSchema.index({ title: 'text', titleAr: 'text' });

module.exports = mongoose.model('Lesson', LessonSchema);