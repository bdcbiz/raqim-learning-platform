const express = require('express');
const router = express.Router();
const {
  getLessons,
  getLesson,
  createLesson,
  updateLesson,
  deleteLesson,
  completeLesson,
  addComment,
  submitQuiz
} = require('../controllers/lessonController');
const { protect, authorize } = require('../middleware/auth');

router.route('/course/:courseId')
  .get(protect, getLessons);

router.route('/')
  .post(protect, authorize('teacher', 'admin'), createLesson);

router.route('/:id')
  .get(protect, getLesson)
  .put(protect, authorize('teacher', 'admin'), updateLesson)
  .delete(protect, authorize('teacher', 'admin'), deleteLesson);

router.route('/:id/complete')
  .post(protect, completeLesson);

router.route('/:id/comment')
  .post(protect, addComment);

router.route('/:id/quiz/submit')
  .post(protect, submitQuiz);

module.exports = router;