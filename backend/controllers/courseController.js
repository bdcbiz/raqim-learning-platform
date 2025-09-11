const Course = require('../models/Course');
const User = require('../models/User');
const Progress = require('../models/Progress');

exports.getCourses = async (req, res, next) => {
  try {
    const {
      category,
      level,
      language,
      search,
      isFree,
      sort = '-createdAt',
      page = 1,
      limit = 10
    } = req.query;

    // First, let's check if we have any courses at all
    const allCourses = await Course.find({});
    console.log('Total courses in database:', allCourses.length);

    const query = {}; // Temporarily removed isPublished filter for testing

    if (category) query.category = category;
    if (level) query.level = level;
    if (language) query.language = language;
    if (isFree !== undefined) query.isFree = isFree === 'true';

    if (search) {
      // Temporarily disable text search
      // query.$text = { $search: search };
      // Use regex search instead
      query.$or = [
        { title: { $regex: search, $options: 'i' } },
        { titleAr: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } },
        { descriptionAr: { $regex: search, $options: 'i' } }
      ];
    }

    const courses = await Course.find(query)
      .populate('instructor', 'name avatar')
      .sort(sort)
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const count = await Course.countDocuments(query);

    res.status(200).json({
      success: true,
      count,
      totalPages: Math.ceil(count / limit),
      currentPage: page,
      data: courses
    });
  } catch (err) {
    next(err);
  }
};

exports.getCourse = async (req, res, next) => {
  try {
    const course = await Course.findById(req.params.id)
      .populate('instructor', 'name avatar bio')
      .populate('sections.lessons', 'title titleAr type duration isFree')
      .populate('reviews.user', 'name avatar');

    if (!course) {
      return res.status(404).json({
        success: false,
        error: 'Course not found'
      });
    }

    res.status(200).json({
      success: true,
      data: course
    });
  } catch (err) {
    next(err);
  }
};

exports.createCourse = async (req, res, next) => {
  try {
    req.body.instructor = req.user.id;

    const course = await Course.create(req.body);

    await User.findByIdAndUpdate(req.user.id, {
      $push: { teachingCourses: course._id }
    });

    res.status(201).json({
      success: true,
      data: course
    });
  } catch (err) {
    next(err);
  }
};

exports.updateCourse = async (req, res, next) => {
  try {
    let course = await Course.findById(req.params.id);

    if (!course) {
      return res.status(404).json({
        success: false,
        error: 'Course not found'
      });
    }

    if (course.instructor.toString() !== req.user.id && req.user.role !== 'admin') {
      return res.status(401).json({
        success: false,
        error: 'Not authorized to update this course'
      });
    }

    course = await Course.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true
    });

    res.status(200).json({
      success: true,
      data: course
    });
  } catch (err) {
    next(err);
  }
};

exports.deleteCourse = async (req, res, next) => {
  try {
    const course = await Course.findById(req.params.id);

    if (!course) {
      return res.status(404).json({
        success: false,
        error: 'Course not found'
      });
    }

    if (course.instructor.toString() !== req.user.id && req.user.role !== 'admin') {
      return res.status(401).json({
        success: false,
        error: 'Not authorized to delete this course'
      });
    }

    await course.remove();

    res.status(200).json({
      success: true,
      data: {}
    });
  } catch (err) {
    next(err);
  }
};

exports.enrollInCourse = async (req, res, next) => {
  try {
    const course = await Course.findById(req.params.id);

    if (!course) {
      return res.status(404).json({
        success: false,
        error: 'Course not found'
      });
    }

    const user = await User.findById(req.user.id);
    
    const alreadyEnrolled = user.enrolledCourses.some(
      enrollment => enrollment.course.toString() === req.params.id
    );

    if (alreadyEnrolled) {
      return res.status(400).json({
        success: false,
        error: 'Already enrolled in this course'
      });
    }

    // Check if course is free or paid
    if (course.price > 0) {
      // This is a paid course - should not enroll directly
      return res.status(402).json({
        success: false,
        error: 'This is a paid course. Please proceed to payment.',
        courseId: course._id,
        price: course.price,
        currency: course.currency || 'SAR'
      });
    }

    // Free course - enroll directly
    user.enrolledCourses.push({
      course: course._id,
      enrolledAt: Date.now()
    });

    await user.save();

    course.enrolledStudents.push(user._id);
    course.numberOfEnrollments += 1;
    await course.save();

    await Progress.create({
      user: user._id,
      course: course._id
    });

    res.status(200).json({
      success: true,
      message: 'Successfully enrolled in the course',
      course: {
        id: course._id,
        title: course.title,
        thumbnail: course.thumbnail
      }
    });
  } catch (err) {
    next(err);
  }
};

exports.addReview = async (req, res, next) => {
  try {
    const { rating, comment } = req.body;

    const course = await Course.findById(req.params.id);

    if (!course) {
      return res.status(404).json({
        success: false,
        error: 'Course not found'
      });
    }

    const alreadyReviewed = course.reviews.find(
      review => review.user.toString() === req.user.id
    );

    if (alreadyReviewed) {
      return res.status(400).json({
        success: false,
        error: 'Course already reviewed'
      });
    }

    const review = {
      user: req.user.id,
      rating,
      comment
    };

    course.reviews.push(review);
    course.calculateAverageRating();
    await course.save();

    res.status(201).json({
      success: true,
      data: review
    });
  } catch (err) {
    next(err);
  }
};

exports.getMyTeachingCourses = async (req, res, next) => {
  try {
    const courses = await Course.find({ instructor: req.user.id })
      .populate('enrolledStudents', 'name email')
      .sort('-createdAt');

    res.status(200).json({
      success: true,
      count: courses.length,
      data: courses
    });
  } catch (err) {
    next(err);
  }
};

exports.getEnrolledCourses = async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id)
      .populate({
        path: 'enrolledCourses.course',
        select: 'title titleAr thumbnail instructor category level',
        populate: {
          path: 'instructor',
          select: 'name'
        }
      });

    res.status(200).json({
      success: true,
      data: user.enrolledCourses
    });
  } catch (err) {
    next(err);
  }
};