const mongoose = require('mongoose');

const LessonSchema = new mongoose.Schema({
  title: { type: String, required: true },
  videoUrl: { type: String, required: true },
  duration: { type: Number, required: true } // in minutes
});

const CourseSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Please add a course title'],
    trim: true,
    maxlength: [100, 'Title cannot be more than 100 characters']
  },
  titleAr: {
    type: String,
    required: [true, 'Please add an Arabic course title'],
    trim: true,
    maxlength: [100, 'Title cannot be more than 100 characters']
  },
  description: {
    type: String,
    required: [true, 'Please add a description'],
    maxlength: [1000, 'Description cannot be more than 1000 characters']
  },
  descriptionAr: {
    type: String,
    required: [true, 'Please add an Arabic description'],
    maxlength: [1000, 'Description cannot be more than 1000 characters']
  },
  thumbnail: {
    type: String,
    default: 'https://placehold.co/600x400/6A5AE0/FFFFFF?text=AI+Course'
  },
  imageUrl: {
    type: String,
    default: 'https://placehold.co/600x400/6A5AE0/FFFFFF?text=AI+Course'
  },
  instructor: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  category: {
    type: String,
    required: [true, 'Please add a category'],
    enum: [
      'Machine Learning',
      'NLP',
      'Computer Vision',
      'Deep Learning',
      'Data Science',
      'programming',
      'mathematics',
      'science',
      'languages',
      'arts',
      'business',
      'technology',
      'other'
    ]
  },
  level: {
    type: String,
    required: [true, 'Please add a difficulty level'],
    enum: ['Beginner', 'Intermediate', 'Advanced', 'beginner', 'intermediate', 'advanced']
  },
  price: {
    type: Number,
    default: 0,
    min: 0
  },
  currency: {
    type: String,
    default: 'SAR',
    enum: ['SAR', 'USD', 'EUR']
  },
  isFree: {
    type: Boolean,
    default: false
  },
  duration: {
    type: Number,
    default: 0
  },
  totalLessons: {
    type: Number,
    default: 0
  },
  language: {
    type: String,
    enum: ['ar', 'en', 'both']
  },
  requirements: [{
    type: String
  }],
  whatYouWillLearn: [{
    type: String
  }],
  tags: [{
    type: String
  }],
  rating: {
    type: Number,
    default: 0,
    min: 0,
    max: 5
  },
  numberOfRatings: {
    type: Number,
    default: 0
  },
  reviews: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    rating: {
      type: Number,
      min: 1,
      max: 5,
      required: true
    },
    comment: String,
    createdAt: {
      type: Date,
      default: Date.now
    }
  }],
  enrolledStudents: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }],
  numberOfEnrollments: {
    type: Number,
    default: 0
  },
  lessons: [LessonSchema],
  sections: [{
    title: String,
    titleAr: String,
    description: String,
    descriptionAr: String,
    order: Number,
    lessons: [{
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Lesson'
    }]
  }],
  isPublished: {
    type: Boolean,
    default: false
  },
  publishedAt: Date,
  lastUpdated: {
    type: Date,
    default: Date.now
  },
  certificate: {
    isAvailable: {
      type: Boolean,
      default: true
    },
    minimumScore: {
      type: Number,
      default: 70,
      min: 0,
      max: 100
    }
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

CourseSchema.pre('save', function(next) {
  if (this.price === 0) {
    this.isFree = true;
  }
  this.lastUpdated = Date.now();
  next();
});

CourseSchema.methods.calculateAverageRating = function() {
  if (this.reviews.length === 0) {
    this.rating = 0;
    this.numberOfRatings = 0;
  } else {
    const sum = this.reviews.reduce((acc, review) => acc + review.rating, 0);
    this.rating = Math.round((sum / this.reviews.length) * 10) / 10;
    this.numberOfRatings = this.reviews.length;
  }
};

// CourseSchema.index({ title: 'text', titleAr: 'text', description: 'text', descriptionAr: 'text' });

module.exports = mongoose.model('Course', CourseSchema);