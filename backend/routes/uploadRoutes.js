const express = require('express');
const router = express.Router();
const upload = require('../utils/fileUpload');
const { protect, authorize } = require('../middleware/auth');
const path = require('path');

router.post('/avatar', protect, upload.single('avatar'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({
      success: false,
      error: 'Please upload a file'
    });
  }

  res.status(200).json({
    success: true,
    data: {
      filename: req.file.filename,
      url: `/uploads/avatars/${req.file.filename}`
    }
  });
});

router.post('/thumbnail', protect, authorize('teacher', 'admin'), upload.single('thumbnail'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({
      success: false,
      error: 'Please upload a file'
    });
  }

  res.status(200).json({
    success: true,
    data: {
      filename: req.file.filename,
      url: `/uploads/thumbnails/${req.file.filename}`
    }
  });
});

router.post('/video', protect, authorize('teacher', 'admin'), upload.single('video'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({
      success: false,
      error: 'Please upload a file'
    });
  }

  res.status(200).json({
    success: true,
    data: {
      filename: req.file.filename,
      url: `/uploads/videos/${req.file.filename}`,
      size: req.file.size
    }
  });
});

router.post('/material', protect, authorize('teacher', 'admin'), upload.single('material'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({
      success: false,
      error: 'Please upload a file'
    });
  }

  res.status(200).json({
    success: true,
    data: {
      filename: req.file.filename,
      originalName: req.file.originalname,
      url: `/uploads/materials/${req.file.filename}`,
      size: req.file.size,
      type: path.extname(req.file.originalname)
    }
  });
});

router.post('/multiple', protect, authorize('teacher', 'admin'), upload.array('files', 10), (req, res) => {
  if (!req.files || req.files.length === 0) {
    return res.status(400).json({
      success: false,
      error: 'Please upload files'
    });
  }

  const uploadedFiles = req.files.map(file => ({
    filename: file.filename,
    originalName: file.originalname,
    url: `/uploads/materials/${file.filename}`,
    size: file.size,
    type: path.extname(file.originalname)
  }));

  res.status(200).json({
    success: true,
    data: uploadedFiles
  });
});

module.exports = router;