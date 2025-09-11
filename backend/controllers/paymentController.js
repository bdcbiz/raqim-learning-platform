const Course = require('../models/Course');
const User = require('../models/User');
const Progress = require('../models/Progress');

// Process payment for a course
exports.processCoursePayment = async (req, res, next) => {
  try {
    const { courseId, paymentMethod, paymentDetails } = req.body;
    
    const course = await Course.findById(courseId);
    
    if (!course) {
      return res.status(404).json({
        success: false,
        error: 'Course not found'
      });
    }
    
    // Check if course is free
    if (course.price === 0) {
      return res.status(400).json({
        success: false,
        error: 'This is a free course, no payment required'
      });
    }
    
    const user = await User.findById(req.user.id);
    
    // Check if already enrolled
    const alreadyEnrolled = user.enrolledCourses.some(
      enrollment => enrollment.course.toString() === courseId
    );
    
    if (alreadyEnrolled) {
      return res.status(400).json({
        success: false,
        error: 'Already enrolled in this course'
      });
    }
    
    // Process payment based on method
    let paymentSuccess = false;
    let transactionId = '';
    
    switch (paymentMethod) {
      case 'credit_card':
        // In production, integrate with payment gateway (Stripe, PayPal, etc.)
        // For now, simulate successful payment
        paymentSuccess = true;
        transactionId = 'TXN_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
        break;
        
      case 'apple_pay':
      case 'google_pay':
      case 'paypal':
        // Simulate payment processing
        paymentSuccess = true;
        transactionId = 'TXN_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
        break;
        
      default:
        return res.status(400).json({
          success: false,
          error: 'Invalid payment method'
        });
    }
    
    if (!paymentSuccess) {
      return res.status(402).json({
        success: false,
        error: 'Payment failed. Please try again.'
      });
    }
    
    // Payment successful - enroll user in course
    user.enrolledCourses.push({
      course: course._id,
      enrolledAt: Date.now(),
      paymentInfo: {
        amount: course.price,
        currency: course.currency || 'SAR',
        method: paymentMethod,
        transactionId: transactionId,
        paidAt: Date.now()
      }
    });
    
    await user.save();
    
    // Update course enrollment count
    course.enrolledStudents.push(user._id);
    course.numberOfEnrollments += 1;
    await course.save();
    
    // Create progress tracking
    await Progress.create({
      user: user._id,
      course: course._id
    });
    
    res.status(200).json({
      success: true,
      message: 'Payment successful. You are now enrolled in the course.',
      data: {
        transactionId,
        courseId: course._id,
        courseTitle: course.title,
        amount: course.price,
        currency: course.currency || 'SAR'
      }
    });
    
  } catch (err) {
    next(err);
  }
};

// Get payment history for user
exports.getPaymentHistory = async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id)
      .populate('enrolledCourses.course', 'title thumbnail price');
    
    const paidCourses = user.enrolledCourses.filter(
      enrollment => enrollment.paymentInfo && enrollment.paymentInfo.amount > 0
    );
    
    const paymentHistory = paidCourses.map(enrollment => ({
      courseId: enrollment.course._id,
      courseTitle: enrollment.course.title,
      courseThumbnail: enrollment.course.thumbnail,
      amount: enrollment.paymentInfo.amount,
      currency: enrollment.paymentInfo.currency,
      method: enrollment.paymentInfo.method,
      transactionId: enrollment.paymentInfo.transactionId,
      paidAt: enrollment.paymentInfo.paidAt
    }));
    
    res.status(200).json({
      success: true,
      count: paymentHistory.length,
      data: paymentHistory
    });
    
  } catch (err) {
    next(err);
  }
};

// Verify payment status
exports.verifyPayment = async (req, res, next) => {
  try {
    const { transactionId } = req.params;
    
    const user = await User.findById(req.user.id);
    
    const payment = user.enrolledCourses.find(
      enrollment => enrollment.paymentInfo && 
      enrollment.paymentInfo.transactionId === transactionId
    );
    
    if (!payment) {
      return res.status(404).json({
        success: false,
        error: 'Payment not found'
      });
    }
    
    res.status(200).json({
      success: true,
      data: {
        status: 'completed',
        transactionId: payment.paymentInfo.transactionId,
        amount: payment.paymentInfo.amount,
        currency: payment.paymentInfo.currency,
        paidAt: payment.paymentInfo.paidAt
      }
    });
    
  } catch (err) {
    next(err);
  }
};