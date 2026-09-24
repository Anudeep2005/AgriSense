const Alert = require('../models/Alert');
const thresholds = require('../config/thresholds');

const evaluateAndGenerateAlerts = async (currentTelemetry, predictions, userId = 'default_user') => {
  const alertsToSave = [];

  if (!predictions || !currentTelemetry) return [];

  const currentSoil = currentTelemetry.soil_moisture;
  const currentTemp = currentTelemetry.temperature;
  const currentHum = currentTelemetry.humidity;

  // 1. Evaluate Soil Moisture Predictions (6h, 10h, 24h)
  const soilPreds = predictions.soilMoisture || {};
  for (const horizon of ['6h', '10h', '24h']) {
    const predVal = soilPreds[horizon];
    if (predVal !== undefined) {
      if (predVal <= thresholds.SOIL_MOISTURE.CRITICAL) {
        alertsToSave.push({
          userId,
          type: 'SOIL_MOISTURE',
          severity: 'CRITICAL',
          metric: 'soilMoisture',
          currentValue: currentSoil,
          predictedValue: predVal,
          threshold: thresholds.SOIL_MOISTURE.CRITICAL,
          forecastHorizon: horizon,
          message: `🚨 Critical Alert: Soil moisture is expected to fall to ${predVal}% within the next ${horizon}. Immediate irrigation required!`,
        });
      } else if (predVal <= thresholds.SOIL_MOISTURE.WARNING) {
        alertsToSave.push({
          userId,
          type: 'SOIL_MOISTURE',
          severity: 'HIGH',
          metric: 'soilMoisture',
          currentValue: currentSoil,
          predictedValue: predVal,
          threshold: thresholds.SOIL_MOISTURE.WARNING,
          forecastHorizon: horizon,
          message: `⚠️ Warning: Soil moisture forecast to drop to ${predVal}% in ${horizon}. Plan irrigation soon.`,
        });
      }
    }
  }

  // 2. Evaluate Temperature Predictions (6h, 10h, 24h)
  const tempPreds = predictions.temperature || {};
  for (const horizon of ['6h', '10h', '24h']) {
    const predVal = tempPreds[horizon];
    if (predVal !== undefined) {
      if (predVal >= thresholds.TEMPERATURE.CRITICAL) {
        alertsToSave.push({
          userId,
          type: 'TEMPERATURE',
          severity: 'CRITICAL',
          metric: 'temperature',
          currentValue: currentTemp,
          predictedValue: predVal,
          threshold: thresholds.TEMPERATURE.CRITICAL,
          forecastHorizon: horizon,
          message: `🔥 Extreme Heat Alert: Temperature predicted to reach ${predVal}°C within ${horizon}. Protect sensitive crops.`,
        });
      } else if (predVal >= thresholds.TEMPERATURE.WARNING) {
        alertsToSave.push({
          userId,
          type: 'TEMPERATURE',
          severity: 'MEDIUM',
          metric: 'temperature',
          currentValue: currentTemp,
          predictedValue: predVal,
          threshold: thresholds.TEMPERATURE.WARNING,
          forecastHorizon: horizon,
          message: `☀️ High Temperature Alert: Temperature expected to rise to ${predVal}°C in ${horizon}.`,
        });
      }
    }
  }

  // Save generated alerts into MongoDB
  const createdAlerts = [];
  for (const alertData of alertsToSave) {
    try {
      const alert = await Alert.create(alertData);
      createdAlerts.push(alert);
    } catch (e) {
      console.error('Alert creation error:', e.message);
    }
  }

  return createdAlerts;
};

module.exports = { evaluateAndGenerateAlerts };
