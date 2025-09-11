const User = require('../models/User');
const { validationResult } = require('express-validator');
const { OAuth2Client } = require('google-auth-library');

exports.register = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { name, email, password, role } = req.body;

    const userExists = await User.findOne({ email });
    if (userExists) {
      return res.status(400).json({
        success: false,
        error: 'المستخدم موجود بالفعل',
        errorEn: 'User already exists'
      });
    }

    const user = await User.create({
      name,
      email,
      password,
      role: role || 'student'
    });

    sendTokenResponse(user, 201, res);
  } catch (err) {
    next(err);
  }
};

exports.googleSignIn = async (req, res, next) => {
  try {
    const { token } = req.body;
    
    if (!token) {
      return res.status(400).json({
        success: false,
        error: 'Google token is required'
      });
    }

    // Verify Google token
    const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);
    let ticket;
    try {
      ticket = await client.verifyIdToken({
        idToken: token,
        audience: process.env.GOOGLE_CLIENT_ID
      });
    } catch (error) {
      return res.status(401).json({
        success: false,
        error: 'Invalid Google token'
      });
    }

    const payload = ticket.getPayload();
    const googleId = payload.sub;
    const email = payload.email;
    const name = payload.name;
    const picture = payload.picture;

    // Check if user exists with this Google ID
    let user = await User.findOne({ googleId });

    if (!user) {
      // Check if user exists with this email
      user = await User.findOne({ email });
      
      if (user) {
        // Link Google account to existing email account
        user.googleId = googleId;
        user.provider = 'google';
        if (picture) user.avatar = picture;
        if (picture) user.avatarUrl = picture;
        await user.save();
      } else {
        // Create new user with Google account
        user = await User.create({
          name,
          email,
          googleId,
          provider: 'google',
          avatar: picture || 'https://placehold.co/150x150/6A5AE0/FFFFFF?text=R',
          avatarUrl: picture || 'https://placehold.co/150x150/6A5AE0/FFFFFF?text=R',
          emailVerified: true,
          role: 'student'
        });
      }
    }

    user.lastLogin = Date.now();
    await user.save();

    // TODO: Send welcome email if new user
    // if (isNewUser) {
    //   await sendWelcomeEmail(user.email, user.name);
    // }

    sendTokenResponse(user, user.createdAt === user.updatedAt ? 201 : 200, res);
  } catch (err) {
    next(err);
  }
};

exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        error: 'Please provide an email and password'
      });
    }

    const user = await User.findOne({ email }).select('+password');

    if (!user) {
      return res.status(401).json({
        success: false,
        error: 'Invalid credentials'
      });
    }

    const isMatch = await user.matchPassword(password);

    if (!isMatch) {
      return res.status(401).json({
        success: false,
        error: 'Invalid credentials'
      });
    }

    user.lastLogin = Date.now();
    await user.save();

    sendTokenResponse(user, 200, res);
  } catch (err) {
    next(err);
  }
};

exports.getMe = async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id)
      .populate('enrolledCourses.course', 'title titleAr thumbnail')
      .populate('teachingCourses', 'title titleAr thumbnail');

    res.status(200).json({
      success: true,
      data: user
    });
  } catch (err) {
    next(err);
  }
};

exports.updateProfile = async (req, res, next) => {
  try {
    const fieldsToUpdate = {
      name: req.body.name,
      phone: req.body.phone,
      bio: req.body.bio,
      preferences: req.body.preferences
    };

    const user = await User.findByIdAndUpdate(
      req.user.id,
      fieldsToUpdate,
      {
        new: true,
        runValidators: true
      }
    );

    res.status(200).json({
      success: true,
      data: user
    });
  } catch (err) {
    next(err);
  }
};

exports.updatePassword = async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id).select('+password');

    if (!(await user.matchPassword(req.body.currentPassword))) {
      return res.status(401).json({
        success: false,
        error: 'Password is incorrect'
      });
    }

    user.password = req.body.newPassword;
    await user.save();

    sendTokenResponse(user, 200, res);
  } catch (err) {
    next(err);
  }
};

exports.logout = (req, res, next) => {
  res.status(200).json({
    success: true,
    data: {}
  });
};

const sendTokenResponse = (user, statusCode, res) => {
  try {
    const token = user.getSignedJwtToken();

    // Send response without cookies
    res.status(statusCode).json({
      success: true,
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
        avatar: user.avatar
      }
    });
  } catch (error) {
    console.error('Error generating token:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};