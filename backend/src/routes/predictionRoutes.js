const express = require('express');
const router = express.Router();
const {
  getEnvironmentalPrediction,
  getUserAlerts,
  markAlertAsRead,
} = require('../controllers/predictionController');
const { protect } = require('../middleware/authMiddleware');

// Optional protect middleware for testing convenience
router.post('/predict', getEnvironmentalPrediction);
router.get('/alerts', getUserAlerts);
router.patch('/alerts/:id/read', markAlertAsRead);

module.exports = router;
