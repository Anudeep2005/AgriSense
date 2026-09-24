const mongoose = require('mongoose');

const alertSchema = new mongoose.Schema(
  {
    userId: {
      type: String,
      default: 'default_user',
      index: true,
    },
    type: {
      type: String,
      enum: ['SOIL_MOISTURE', 'TEMPERATURE', 'HUMIDITY', 'WEATHER'],
      required: true,
    },
    severity: {
      type: String,
      enum: ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'],
      required: true,
    },
    metric: {
      type: String,
      required: true,
    },
    currentValue: {
      type: Number,
      required: true,
    },
    predictedValue: {
      type: Number,
      required: true,
    },
    threshold: {
      type: Number,
      required: true,
    },
    forecastHorizon: {
      type: String,
      enum: ['6h', '10h', '24h'],
      required: true,
    },
    message: {
      type: String,
      required: true,
    },
    read: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Alert', alertSchema);
