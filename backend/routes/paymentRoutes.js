const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const {
  processCoursePayment,
  getPaymentHistory,
  verifyPayment
} = require('../controllers/paymentController');

// All payment routes require authentication
router.use(protect);

// Process payment for a course
router.post('/process', processCoursePayment);

// Get user's payment history
router.get('/history', getPaymentHistory);

// Verify a specific payment
router.get('/verify/:transactionId', verifyPayment);

module.exports = router;