const News = require('../models/News');
const User = require('../models/User');

// @desc    Get all news articles
// @route   GET /api/v1/news
// @access  Public
const getAllNews = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page, 10) || 1;
    const limit = parseInt(req.query.limit, 10) || 10;
    const startIndex = (page - 1) * limit;
    
    let query = { isPublished: true };
    
    // Filter by category if provided
    if (req.query.category) {
      query.category = req.query.category;
    }
    
    // Search functionality
    if (req.query.search) {
      query.$text = { $search: req.query.search };
    }

    const news = await News.find(query)
      .populate('likes', 'name avatar')
      .populate('comments.user', 'name avatar')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip(startIndex)
      .exec();

    const total = await News.countDocuments(query);

    res.status(200).json({
      success: true,
      count: news.length,
      total,
      pagination: {
        current: page,
        pages: Math.ceil(total / limit),
        hasNext: page < Math.ceil(total / limit),
        hasPrev: page > 1
      },
      data: news
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Get single news article
// @route   GET /api/v1/news/:id
// @access  Public
const getNewsById = async (req, res, next) => {
  try {
    const news = await News.findById(req.params.id)
      .populate('likes', 'name avatar')
      .populate('comments.user', 'name avatar');

    if (!news) {
      return res.status(404).json({
        success: false,
        error: 'News article not found'
      });
    }

    // Increment view count
    await News.findByIdAndUpdate(req.params.id, { $inc: { viewCount: 1 } });

    res.status(200).json({
      success: true,
      data: news
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Create news article
// @route   POST /api/v1/news
// @access  Private (Admin only)
const createNews = async (req, res, next) => {
  try {
    const news = await News.create({
      ...req.body,
      publishedAt: req.body.isPublished ? new Date() : null
    });

    res.status(201).json({
      success: true,
      data: news
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Update news article
// @route   PUT /api/v1/news/:id
// @access  Private (Admin only)
const updateNews = async (req, res, next) => {
  try {
    let news = await News.findById(req.params.id);

    if (!news) {
      return res.status(404).json({
        success: false,
        error: 'News article not found'
      });
    }

    // If changing to published and no publishedAt date, set it
    if (req.body.isPublished && !news.publishedAt) {
      req.body.publishedAt = new Date();
    }

    news = await News.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true
    });

    res.status(200).json({
      success: true,
      data: news
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Delete news article
// @route   DELETE /api/v1/news/:id
// @access  Private (Admin only)
const deleteNews = async (req, res, next) => {
  try {
    const news = await News.findById(req.params.id);

    if (!news) {
      return res.status(404).json({
        success: false,
        error: 'News article not found'
      });
    }

    await news.deleteOne();

    res.status(200).json({
      success: true,
      message: 'News article deleted successfully'
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Like/Unlike news article
// @route   PUT /api/v1/news/:id/like
// @access  Private
const toggleNewsLike = async (req, res, next) => {
  try {
    const news = await News.findById(req.params.id);

    if (!news) {
      return res.status(404).json({
        success: false,
        error: 'News article not found'
      });
    }

    const userId = req.user.id;
    const isLiked = news.likes.includes(userId);

    if (isLiked) {
      // Unlike: Remove user from likes array
      news.likes = news.likes.filter(like => like.toString() !== userId);
    } else {
      // Like: Add user to likes array
      news.likes.push(userId);
    }

    await news.save();

    // Populate likes for response
    await news.populate('likes', 'name avatar');

    res.status(200).json({
      success: true,
      message: isLiked ? 'News article unliked' : 'News article liked',
      data: {
        likes: news.likes,
        likesCount: news.likes.length,
        isLiked: !isLiked
      }
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Add comment to news article
// @route   POST /api/v1/news/:id/comments
// @access  Private
const addNewsComment = async (req, res, next) => {
  try {
    const news = await News.findById(req.params.id);

    if (!news) {
      return res.status(404).json({
        success: false,
        error: 'News article not found'
      });
    }

    const { content } = req.body;

    if (!content || content.trim() === '') {
      return res.status(400).json({
        success: false,
        error: 'Comment content is required'
      });
    }

    const newComment = {
      user: req.user.id,
      content: content.trim(),
      createdAt: new Date()
    };

    news.comments.push(newComment);
    await news.save();

    // Populate the new comment with user data
    await news.populate('comments.user', 'name avatar');

    const addedComment = news.comments[news.comments.length - 1];

    res.status(201).json({
      success: true,
      message: 'Comment added successfully',
      data: addedComment
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Update comment on news article
// @route   PUT /api/v1/news/:id/comments/:commentId
// @access  Private
const updateNewsComment = async (req, res, next) => {
  try {
    const news = await News.findById(req.params.id);

    if (!news) {
      return res.status(404).json({
        success: false,
        error: 'News article not found'
      });
    }

    const comment = news.comments.id(req.params.commentId);

    if (!comment) {
      return res.status(404).json({
        success: false,
        error: 'Comment not found'
      });
    }

    // Check if user owns the comment
    if (comment.user.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        error: 'Not authorized to update this comment'
      });
    }

    const { content } = req.body;

    if (!content || content.trim() === '') {
      return res.status(400).json({
        success: false,
        error: 'Comment content is required'
      });
    }

    comment.content = content.trim();
    await news.save();

    // Populate user data
    await news.populate('comments.user', 'name avatar');

    res.status(200).json({
      success: true,
      message: 'Comment updated successfully',
      data: comment
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Delete comment from news article
// @route   DELETE /api/v1/news/:id/comments/:commentId
// @access  Private
const deleteNewsComment = async (req, res, next) => {
  try {
    const news = await News.findById(req.params.id);

    if (!news) {
      return res.status(404).json({
        success: false,
        error: 'News article not found'
      });
    }

    const comment = news.comments.id(req.params.commentId);

    if (!comment) {
      return res.status(404).json({
        success: false,
        error: 'Comment not found'
      });
    }

    // Check if user owns the comment or is admin
    if (comment.user.toString() !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        error: 'Not authorized to delete this comment'
      });
    }

    comment.remove();
    await news.save();

    res.status(200).json({
      success: true,
      message: 'Comment deleted successfully'
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Get featured news
// @route   GET /api/v1/news/featured
// @access  Public
const getFeaturedNews = async (req, res, next) => {
  try {
    const limit = parseInt(req.query.limit, 10) || 5;

    const news = await News.find({ 
      isPublished: true, 
      isFeatured: true 
    })
      .populate('likes', 'name avatar')
      .sort({ createdAt: -1 })
      .limit(limit);

    res.status(200).json({
      success: true,
      count: news.length,
      data: news
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Get news by category
// @route   GET /api/v1/news/category/:category
// @access  Public
const getNewsByCategory = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page, 10) || 1;
    const limit = parseInt(req.query.limit, 10) || 10;
    const startIndex = (page - 1) * limit;

    const news = await News.find({ 
      isPublished: true, 
      category: req.params.category 
    })
      .populate('likes', 'name avatar')
      .populate('comments.user', 'name avatar')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip(startIndex)
      .exec();

    const total = await News.countDocuments({ 
      isPublished: true, 
      category: req.params.category 
    });

    res.status(200).json({
      success: true,
      count: news.length,
      total,
      pagination: {
        current: page,
        pages: Math.ceil(total / limit),
        hasNext: page < Math.ceil(total / limit),
        hasPrev: page > 1
      },
      data: news
    });
  } catch (err) {
    next(err);
  }
};

module.exports = {
  getAllNews,
  getNewsById,
  createNews,
  updateNews,
  deleteNews,
  toggleNewsLike,
  addNewsComment,
  updateNewsComment,
  deleteNewsComment,
  getFeaturedNews,
  getNewsByCategory
};