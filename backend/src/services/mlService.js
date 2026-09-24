const http = require('http');

const ML_SERVICE_URL = process.env.ML_SERVICE_URL || 'http://localhost:8000';

const getPredictions = async (telemetryHistory) => {
  return new Promise((resolve, reject) => {
    const url = new URL('/predict', ML_SERVICE_URL);
    const data = JSON.stringify({ history: telemetryHistory });

    const options = {
      hostname: url.hostname,
      port: url.port || 8000,
      path: url.pathname,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(data),
      },
      timeout: 10000,
    };

    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => (body += chunk));
      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          try {
            resolve(JSON.parse(body));
          } catch (e) {
            reject(new Error(`Failed to parse ML response: ${e.message}`));
          }
        } else {
          reject(new Error(`ML Service error ${res.statusCode}: ${body}`));
        }
      });
    });

    req.on('error', (err) => {
      reject(new Error(`ML Service unreachable: ${err.message}`));
    });

    req.on('timeout', () => {
      req.destroy();
      reject(new Error('ML Service request timed out'));
    });

    req.write(data);
    req.end();
  });
};

module.exports = { getPredictions };
