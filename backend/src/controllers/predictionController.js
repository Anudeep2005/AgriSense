const { getPredictions } = require('../services/mlService');
const { evaluateAndGenerateAlerts } = require('../services/alertEngine');
const Alert = require('../models/Alert');

const getEnvironmentalPrediction = async (req, res) => {
  try {
    const { history, current } = req.body;

    let telemetryHistory = history;

    // If only a single current reading is sent, construct history buffer
    if (!telemetryHistory || !Array.isArray(telemetryHistory) || telemetryHistory.length === 0) {
      if (!current) {
        return res.status(400).json({ message: 'Payload must contain history or current telemetry reading' });
      }
      telemetryHistory = [current];
    }

    const latestReading = telemetryHistory[telemetryHistory.length - 1];

    // Request XGBoost predictions from FastAPI ML service
    const predictions = await getPredictions(telemetryHistory);

    // Run deterministic threshold engine to trigger alerts
    const userId = req.user ? req.user.id : 'default_user';
    const newAlerts = await evaluateAndGenerateAlerts(latestReading, predictions, userId);

    res.json({
      success: true,
      predictions,
      newAlerts,
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    console.error('Prediction controller error:', error.message);
    res.status(500).json({
      success: false,
      message: 'Failed to generate prediction',
      error: error.message,
    });
  }
};

const getUserAlerts = async (req, res) => {
  try {
    const userId = req.user ? req.user.id : 'default_user';
    const alerts = await Alert.find({ $or: [{ userId }, { userId: 'default_user' }] })
      .sort({ createdAt: -1 })
      .limit(20);
    res.json(alerts);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const markAlertAsRead = async (req, res) => {
  try {
    const alert = await Alert.findByIdAndUpdate(req.params.id, { read: true }, { new: true });
    if (!alert) return res.status(404).json({ message: 'Alert not found' });
    res.json(alert);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  getEnvironmentalPrediction,
  getUserAlerts,
  markAlertAsRead,
};
