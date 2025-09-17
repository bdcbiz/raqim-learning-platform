const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin
admin.initializeApp();

// Cloud Function to assign admin role to a user
exports.setAdminRole = functions.https.onCall(async (data, context) => {
  // Check if request is made by an admin
  if (!context.auth || !context.auth.token.admin === true) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Only admins can assign admin roles.'
    );
  }

  // Get user and add custom claim (admin)
  const { uid, role } = data;

  if (!uid || !role) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Missing uid or role parameter.'
    );
  }

  try {
    // Set custom user claims
    await admin.auth().setCustomUserClaims(uid, {
      admin: role === 'admin',
      moderator: role === 'moderator',
      instructor: role === 'instructor'
    });

    // Update user document in Firestore
    await admin.firestore().collection('users').doc(uid).update({
      role: role,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    return {
      message: `Successfully set ${role} role for user ${uid}`
    };
  } catch (error) {
    throw new functions.https.HttpsError(
      'internal',
      `Error setting admin role: ${error.message}`
    );
  }
});

// Cloud Function to create initial admin user
exports.createInitialAdmin = functions.https.onRequest(async (req, res) => {
  // This should only be run once during initial setup
  // Check if any admin exists
  const adminsSnapshot = await admin.firestore()
    .collection('users')
    .where('role', '==', 'admin')
    .limit(1)
    .get();

  if (!adminsSnapshot.empty) {
    res.status(400).json({
      error: 'Admin user already exists'
    });
    return;
  }

  // Create the initial admin user
  const adminEmail = req.body.email || 'admin@raqim.com';
  const adminPassword = req.body.password || 'Admin@123456';

  try {
    // Create user in Firebase Auth
    const userRecord = await admin.auth().createUser({
      email: adminEmail,
      password: adminPassword,
      emailVerified: true,
      displayName: 'مدير النظام'
    });

    // Set admin custom claims
    await admin.auth().setCustomUserClaims(userRecord.uid, {
      admin: true
    });

    // Create user document in Firestore
    await admin.firestore().collection('users').doc(userRecord.uid).set({
      uid: userRecord.uid,
      email: adminEmail,
      displayName: 'مدير النظام',
      role: 'admin',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      emailVerified: true,
      isActive: true
    });

    res.status(200).json({
      message: 'Initial admin user created successfully',
      uid: userRecord.uid,
      email: adminEmail
    });
  } catch (error) {
    res.status(500).json({
      error: `Failed to create admin user: ${error.message}`
    });
  }
});

// Cloud Function to verify manual payment
exports.verifyManualPayment = functions.https.onCall(async (data, context) => {
  // Check if request is made by an admin
  if (!context.auth || !context.auth.token.admin === true) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Only admins can verify payments.'
    );
  }

  const { transactionId, userId, courseId, amount, paymentMethod } = data;

  if (!transactionId || !userId || !courseId || !amount) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Missing required payment verification data.'
    );
  }

  try {
    // Create payment record
    const paymentRef = await admin.firestore().collection('payments').add({
      transactionId,
      userId,
      courseId,
      amount,
      paymentMethod: paymentMethod || 'bank_transfer',
      status: 'verified',
      verifiedBy: context.auth.uid,
      verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });

    // Enroll user in course
    await admin.firestore().collection('enrollments').add({
      userId,
      courseId,
      enrolledAt: admin.firestore.FieldValue.serverTimestamp(),
      paymentId: paymentRef.id,
      progress: 0,
      status: 'active'
    });

    // Update user's enrolled courses
    const userRef = admin.firestore().collection('users').doc(userId);
    await userRef.update({
      enrolledCourses: admin.firestore.FieldValue.arrayUnion(courseId),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    // Send notification to user (optional)
    // You can implement FCM notification here

    return {
      success: true,
      message: 'Payment verified and user enrolled successfully',
      paymentId: paymentRef.id
    };
  } catch (error) {
    throw new functions.https.HttpsError(
      'internal',
      `Error verifying payment: ${error.message}`
    );
  }
});

// Cloud Function to get dashboard statistics (for admins only)
exports.getDashboardStats = functions.https.onCall(async (data, context) => {
  // Check if request is made by an admin
  if (!context.auth || !context.auth.token.admin !== true) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Only admins can access dashboard statistics.'
    );
  }

  try {
    // Get total users count
    const usersSnapshot = await admin.firestore().collection('users').get();
    const totalUsers = usersSnapshot.size;

    // Get active users (logged in within last 30 days)
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    const activeUsersSnapshot = await admin.firestore()
      .collection('users')
      .where('lastLoginAt', '>=', thirtyDaysAgo)
      .get();
    const activeUsers = activeUsersSnapshot.size;

    // Get total courses
    const coursesSnapshot = await admin.firestore().collection('courses').get();
    const totalCourses = coursesSnapshot.size;

    // Get total enrollments
    const enrollmentsSnapshot = await admin.firestore().collection('enrollments').get();
    const totalEnrollments = enrollmentsSnapshot.size;

    // Get total revenue
    const paymentsSnapshot = await admin.firestore()
      .collection('payments')
      .where('status', '==', 'verified')
      .get();

    let totalRevenue = 0;
    paymentsSnapshot.forEach(doc => {
      totalRevenue += doc.data().amount || 0;
    });

    // Get recent transactions
    const recentTransactionsSnapshot = await admin.firestore()
      .collection('payments')
      .orderBy('createdAt', 'desc')
      .limit(10)
      .get();

    const recentTransactions = [];
    recentTransactionsSnapshot.forEach(doc => {
      recentTransactions.push({
        id: doc.id,
        ...doc.data()
      });
    });

    return {
      totalUsers,
      activeUsers,
      totalCourses,
      totalEnrollments,
      totalRevenue,
      recentTransactions,
      timestamp: admin.firestore.FieldValue.serverTimestamp()
    };
  } catch (error) {
    throw new functions.https.HttpsError(
      'internal',
      `Error fetching dashboard stats: ${error.message}`
    );
  }
});

// Cloud Function to handle user registration with email verification
exports.onUserCreate = functions.auth.user().onCreate(async (user) => {
  // Create user document in Firestore
  try {
    await admin.firestore().collection('users').doc(user.uid).set({
      uid: user.uid,
      email: user.email,
      displayName: user.displayName || '',
      photoURL: user.photoURL || '',
      role: 'student', // Default role
      emailVerified: user.emailVerified,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      isActive: true,
      enrolledCourses: [],
      completedCourses: [],
      certificates: []
    });

    // Send welcome email (optional)
    // You can implement email sending here using SendGrid or similar

    console.log(`User document created for ${user.email}`);
  } catch (error) {
    console.error(`Error creating user document: ${error.message}`);
  }
});

// Cloud Function to clean up when user is deleted
exports.onUserDelete = functions.auth.user().onDelete(async (user) => {
  try {
    // Delete user document from Firestore
    await admin.firestore().collection('users').doc(user.uid).delete();

    // Delete user's enrollments
    const enrollmentsSnapshot = await admin.firestore()
      .collection('enrollments')
      .where('userId', '==', user.uid)
      .get();

    const batch = admin.firestore().batch();
    enrollmentsSnapshot.forEach(doc => {
      batch.delete(doc.ref);
    });
    await batch.commit();

    console.log(`User data cleaned up for ${user.email}`);
  } catch (error) {
    console.error(`Error cleaning up user data: ${error.message}`);
  }
});

// Cloud Function to validate and process course purchases
exports.processCoursePayment = functions.https.onCall(async (data, context) => {
  // Check if user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated to make a purchase.'
    );
  }

  const { courseId, paymentToken, amount } = data;

  if (!courseId || !paymentToken || !amount) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Missing required payment data.'
    );
  }

  try {
    // Verify course exists and price matches
    const courseDoc = await admin.firestore()
      .collection('courses')
      .doc(courseId)
      .get();

    if (!courseDoc.exists) {
      throw new functions.https.HttpsError(
        'not-found',
        'Course not found.'
      );
    }

    const course = courseDoc.data();
    if (course.price !== amount) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Payment amount does not match course price.'
      );
    }

    // Process payment (integrate with payment gateway)
    // This is a placeholder - integrate with Stripe, PayPal, etc.
    const paymentResult = {
      success: true,
      transactionId: `TXN_${Date.now()}`
    };

    if (paymentResult.success) {
      // Create payment record
      const paymentRef = await admin.firestore().collection('payments').add({
        userId: context.auth.uid,
        courseId,
        amount,
        transactionId: paymentResult.transactionId,
        status: 'completed',
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      });

      // Enroll user in course
      await admin.firestore().collection('enrollments').add({
        userId: context.auth.uid,
        courseId,
        enrolledAt: admin.firestore.FieldValue.serverTimestamp(),
        paymentId: paymentRef.id,
        progress: 0,
        status: 'active'
      });

      // Update user's enrolled courses
      await admin.firestore()
        .collection('users')
        .doc(context.auth.uid)
        .update({
          enrolledCourses: admin.firestore.FieldValue.arrayUnion(courseId)
        });

      return {
        success: true,
        message: 'Payment successful and enrolled in course',
        transactionId: paymentResult.transactionId
      };
    } else {
      throw new functions.https.HttpsError(
        'internal',
        'Payment processing failed.'
      );
    }
  } catch (error) {
    throw new functions.https.HttpsError(
      'internal',
      `Error processing payment: ${error.message}`
    );
  }
});