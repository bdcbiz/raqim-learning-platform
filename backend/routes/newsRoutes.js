const express = require('express');
const {
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
} = require('../controllers/newsController');

const { protect, authorize } = require('../middleware/auth');

const router = express.Router();

// Public routes
router.route('/').get(getAllNews);
router.route('/featured').get(getFeaturedNews);
router.route('/category/:category').get(getNewsByCategory);
router.route('/:id').get(getNewsById);

// Protected routes - require authentication
router.route('/').post(protect, authorize('admin', 'instructor'), createNews);
router.route('/:id').put(protect, authorize('admin', 'instructor'), updateNews);
router.route('/:id').delete(protect, authorize('admin', 'instructor'), deleteNews);

// News interaction routes - require authentication
router.route('/:id/like').put(protect, toggleNewsLike);
router.route('/:id/comments').post(protect, addNewsComment);
router.route('/:id/comments/:commentId').put(protect, updateNewsComment);
router.route('/:id/comments/:commentId').delete(protect, deleteNewsComment);

module.exports = router;