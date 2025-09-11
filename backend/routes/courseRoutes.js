const express = require('express');
const router = express.Router();
const {
  getCourses,
  getCourse,
  createCourse,
  updateCourse,
  deleteCourse,
  enrollInCourse,
  addReview,
  getMyTeachingCourses,
  getEnrolledCourses
} = require('../controllers/courseController');
const { protect, authorize } = require('../middleware/auth');

router.route('/')
  .get(getCourses)
  .post(protect, authorize('teacher', 'admin'), createCourse);

router.route('/enrolled')
  .get(protect, getEnrolledCourses);

router.route('/teaching')
  .get(protect, authorize('teacher', 'admin'), getMyTeachingCourses);

router.route('/:id')
  .get(getCourse)
  .put(protect, authorize('teacher', 'admin'), updateCourse)
  .delete(protect, authorize('teacher', 'admin'), deleteCourse);

router.route('/:id/enroll')
  .post(protect, enrollInCourse);

router.route('/:id/reviews')
  .post(protect, addReview);

module.exports = router;