const multer = require('multer');
const path = require('path');

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    let uploadPath = './uploads';
    
    if (file.fieldname === 'avatar') {
      uploadPath = './uploads/avatars';
    } else if (file.fieldname === 'thumbnail') {
      uploadPath = './uploads/thumbnails';
    } else if (file.fieldname === 'video') {
      uploadPath = './uploads/videos';
    } else if (file.fieldname === 'material') {
      uploadPath = './uploads/materials';
    }
    
    cb(null, uploadPath);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const fileFilter = (req, file, cb) => {
  const allowedImageTypes = /jpeg|jpg|png|gif/;
  const allowedVideoTypes = /mp4|avi|mkv|mov/;
  const allowedDocTypes = /pdf|doc|docx|ppt|pptx|xls|xlsx/;
  
  const extname = path.extname(file.originalname).toLowerCase();
  
  if (file.fieldname === 'avatar' || file.fieldname === 'thumbnail') {
    if (allowedImageTypes.test(extname)) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed'), false);
    }
  } else if (file.fieldname === 'video') {
    if (allowedVideoTypes.test(extname)) {
      cb(null, true);
    } else {
      cb(new Error('Only video files are allowed'), false);
    }
  } else if (file.fieldname === 'material') {
    if (allowedDocTypes.test(extname) || allowedImageTypes.test(extname)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type'), false);
    }
  } else {
    cb(null, true);
  }
};

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 100 * 1024 * 1024
  },
  fileFilter: fileFilter
});

module.exports = upload;