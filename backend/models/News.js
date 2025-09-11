const mongoose = require('mongoose');

const CommentSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  content: { type: String, required: true },
  createdAt: { type: Date, default: Date.now }
});

const NewsSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Please add a title'],
    trim: true,
    maxlength: [200, 'Title cannot be more than 200 characters']
  },
  titleAr: {
    type: String,
    required: [true, 'Please add an Arabic title'],
    trim: true,
    maxlength: [200, 'Title cannot be more than 200 characters']
  },
  content: {
    type: String,
    required: [true, 'Please add content'],
    maxlength: [10000, 'Content cannot be more than 10000 characters']
  },
  contentAr: {
    type: String,
    required: [true, 'Please add Arabic content'],
    maxlength: [10000, 'Content cannot be more than 10000 characters']
  },
  excerpt: {
    type: String,
    maxlength: [500, 'Excerpt cannot be more than 500 characters']
  },
  excerptAr: {
    type: String,
    maxlength: [500, 'Excerpt cannot be more than 500 characters']
  },
  thumbnail: {
    type: String,
    default: 'https://placehold.co/600x300/2ECC71/FFFFFF?text=News'
  },
  imageUrl: {
    type: String,
    default: 'https://placehold.co/600x300/2ECC71/FFFFFF?text=News'
  },
  category: {
    type: String,
    required: [true, 'Please add a category'],
    enum: [
      'announcement',
      'technology',
      'education',
      'success-stories',
      'events',
      'updates',
      'tips',
      'industry'
    ]
  },
  author: {
    type: String,
    default: 'Raqim Team'
  },
  tags: [{
    type: String
  }],
  viewCount: {
    type: Number,
    default: 0
  },
  likes: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }],
  comments: [CommentSchema],
  isPublished: {
    type: Boolean,
    default: false
  },
  isFeatured: {
    type: Boolean,
    default: false
  },
  publishedAt: {
    type: Date
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

// Create excerpt from content if not provided
NewsSchema.pre('save', function(next) {
  if (!this.excerpt && this.content) {
    this.excerpt = this.content.substring(0, 200) + '...';
  }
  if (!this.excerptAr && this.contentAr) {
    this.excerptAr = this.contentAr.substring(0, 200) + '...';
  }
  this.updatedAt = Date.now();
  next();
});

// Index for search
NewsSchema.index({ title: 'text', titleAr: 'text', content: 'text', contentAr: 'text' });

module.exports = mongoose.model('News', NewsSchema);