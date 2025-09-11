const express = require('express');
const router = express.Router();
const {
  getCourseProgress,
  getAllProgress,
  updateCurrentLesson,
  addNote,
  addBookmark,
  removeBookmark,
  getStatistics,
  getCertificate
} = require('../controllers/progressController');
const { protect } = require('../middleware/auth');

router.use(protect);

router.route('/')
  .get(getAllProgress);

router.route('/statistics')
  .get(getStatistics);

router.route('/course/:courseId')
  .get(getCourseProgress)
  .put(updateCurrentLesson);

router.route('/course/:courseId/notes')
  .post(addNote);

router.route('/course/:courseId/bookmarks')
  .post(addBookmark);

router.route('/course/:courseId/bookmarks/:bookmarkId')
  .delete(removeBookmark);

router.route('/course/:courseId/certificate')
  .get(getCertificate);

module.exports = router;