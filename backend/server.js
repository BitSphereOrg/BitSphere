const express = require('express');
const admin = require('firebase-admin');
const Razorpay = require('razorpay');
const axios = require('axios');
const cors = require('cors');
const winston = require('winston');
require('dotenv').config();

// Initialize Logger
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' }),
    new winston.transports.Console(),
  ],
});

// Initialize Firebase Admin SDK
const serviceAccount = require('./serviceAccountKey.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// Initialize Razorpay (with error handling for missing keys)
let razorpay;
let isRazorpayEnabled = true;
try {
  if (!process.env.RAZORPAY_KEY_ID || !process.env.RAZORPAY_KEY_SECRET) {
    throw new Error('Razorpay API keys not provided');
  }
  razorpay = new Razorpay({
    key_id: process.env.RAZORPAY_KEY_ID,
    key_secret: process.env.RAZORPAY_KEY_SECRET,
  });
  logger.info('Razorpay initialized successfully');
} catch (error) {
  logger.warn('Razorpay initialization failed', { error: error.message });
  isRazorpayEnabled = false;
}

const app = express();
app.use(cors());
app.use(express.json());

// Middleware to verify Firebase ID token
const authenticateToken = async (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    logger.warn('Unauthorized request: No token provided', { path: req.path });
    return res.status(401).json({
      success: false,
      error: 'Unauthorized: No token provided',
    });
  }

  const idToken = authHeader.split('Bearer ')[1];
  try {
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    req.user = decodedToken;
    logger.info('User authenticated', { userId: decodedToken.uid, path: req.path });
    next();
  } catch (error) {
    logger.error('Error verifying token', { error: error.message, path: req.path });
    res.status(401).json({
      success: false,
      error: 'Unauthorized: Invalid token',
    });
  }
};

// Helper function for input validation
const validateInput = (data, requiredFields) => {
  for (const field of requiredFields) {
    if (!data[field]) {
      return `Missing required field: ${field}`;
    }
  }
  return null;
};

// API Endpoints

// 1. Create Razorpay Order
app.post('/create-razorpay-order', authenticateToken, async (req, res) => {
  try {
    if (!isRazorpayEnabled) {
      logger.warn('Razorpay API not added', { path: req.path });
      return res.status(503).json({
        success: false,
        error: 'API not added',
      });
    }

    const { amount, currency = 'INR' } = req.body;

    // Validate input
    const validationError = validateInput({ amount }, ['amount']);
    if (validationError) {
      logger.warn('Invalid input', { error: validationError, path: req.path });
      return res.status(400).json({
        success: false,
        error: validationError,
      });
    }

    if (amount <= 0) {
      logger.warn('Invalid amount', { amount, path: req.path });
      return res.status(400).json({
        success: false,
        error: 'Amount must be greater than 0',
      });
    }

    const options = {
      amount: amount * 100, // Amount in paise
      currency,
      receipt: `receipt_${Date.now()}`,
    };

    const order = await razorpay.orders.create(options);
    logger.info('Razorpay order created', { orderId: order.id, userId: req.user.uid });

    res.status(200).json({
      success: true,
      data: {
        orderId: order.id,
        amount: order.amount,
        currency: order.currency,
        keyId: process.env.RAZORPAY_KEY_ID,
      },
    });
  } catch (error) {
    logger.error('Error creating Razorpay order', { error: error.message, path: req.path });
    res.status(500).json({
      success: false,
      error: 'Failed to create Razorpay order',
    });
  }
});

// 2. Verify Razorpay Payment
app.post('/verify-razorpay-payment', authenticateToken, async (req, res) => {
  try {
    if (!isRazorpayEnabled) {
      logger.warn('Razorpay API not added', { path: req.path });
      return res.status(503).json({
        success: false,
        error: 'API not added',
      });
    }

    const { razorpay_order_id, razorpay_payment_id, razorpay_signature } = req.body;

    // Validate input
    const validationError = validateInput(
      { razorpay_order_id, razorpay_payment_id, razorpay_signature },
      ['razorpay_order_id', 'razorpay_payment_id', 'razorpay_signature']
    );
    if (validationError) {
      logger.warn('Invalid input', { error: validationError, path: req.path });
      return res.status(400).json({
        success: false,
        error: validationError,
      });
    }

    const crypto = require('crypto');
    const generatedSignature = crypto
      .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
      .update(`${razorpay_order_id}|${razorpay_payment_id}`)
      .digest('hex');

    if (generatedSignature === razorpay_signature) {
      logger.info('Payment verified', { paymentId: razorpay_payment_id, userId: req.user.uid });
      res.status(200).json({
        success: true,
        message: 'Payment verified successfully',
      });
    } else {
      logger.warn('Payment verification failed', { paymentId: razorpay_payment_id, userId: req.user.uid });
      res.status(400).json({
        success: false,
        error: 'Payment verification failed',
      });
    }
  } catch (error) {
    logger.error('Error verifying payment', { error: error.message, path: req.path });
    res.status(500).json({
      success: false,
      error: 'Failed to verify payment',
    });
  }
});

// 3. Create Heroku App
app.post('/heroku/create-app', authenticateToken, async (req, res) => {
  try {
    const { appName } = req.body;

    // Validate input
    const validationError = validateInput({ appName }, ['appName']);
    if (validationError) {
      logger.warn('Invalid input', { error: validationError, path: req.path });
      return res.status(400).json({
        success: false,
        error: validationError,
      });
    }

    const response = await axios.post(
      'https://api.heroku.com/apps',
      { name: appName },
      {
        headers: {
          Authorization: `Bearer ${process.env.HEROKU_API_KEY}`,
          Accept: 'application/vnd.heroku+json; version=3',
        },
      }
    );

    logger.info('Heroku app created', { appId: response.data.id, userId: req.user.uid });
    res.status(200).json({
      success: true,
      data: { appId: response.data.id },
    });
  } catch (error) {
    logger.error('Error creating Heroku app', {
      error: error.response?.data || error.message,
      path: req.path,
    });
    res.status(500).json({
      success: false,
      error: 'Failed to create Heroku app',
    });
  }
});

// 4. Deploy to Heroku
app.post('/heroku/deploy-app', authenticateToken, async (req, res) => {
  try {
    const { appId, githubUrl } = req.body;

    // Validate input
    const validationError = validateInput({ appId, githubUrl }, ['appId', 'githubUrl']);
    if (validationError) {
      logger.warn('Invalid input', { error: validationError, path: req.path });
      return res.status(400).json({
        success: false,
        error: validationError,
      });
    }

    // Create a source for deployment
    const sourceResponse = await axios.post(
      `https://api.heroku.com/apps/${appId}/sources`,
      {},
      {
        headers: {
          Authorization: `Bearer ${process.env.HEROKU_API_KEY}`,
          Accept: 'application/vnd.heroku+json; version=3',
        },
      }
    );

    const sourceBlob = sourceResponse.data.source_blob;

    // Deploy the GitHub repo
    await axios.put(
      sourceBlob.put_url,
      { url: githubUrl },
      {
        headers: {
          'Content-Type': 'application/json',
        },
      }
    );

    logger.info('Deployment initiated', { appId, userId: req.user.uid });
    res.status(200).json({
      success: true,
      message: 'Deployment initiated',
    });
  } catch (error) {
    logger.error('Error deploying to Heroku', {
      error: error.response?.data || error.message,
      path: req.path,
    });
    res.status(500).json({
      success: false,
      error: 'Failed to deploy to Heroku',
    });
  }
});

// 5. Get Heroku App Status
app.get('/heroku/app-status/:appId', authenticateToken, async (req, res) => {
  try {
    const { appId } = req.params;

    const response = await axios.get(`https://api.heroku.com/apps/${appId}`, {
      headers: {
        Authorization: `Bearer ${process.env.HEROKU_API_KEY}`,
        Accept: 'application/vnd.heroku+json; version=3',
      },
    });

    const isRunning = response.data.status === 'running';
    logger.info('Fetched app status', { appId, isRunning, userId: req.user.uid });
    res.status(200).json({
      success: true,
      data: { isRunning },
    });
  } catch (error) {
    logger.error('Error getting app status', {
      error: error.response?.data || error.message,
      path: req.path,
    });
    res.status(500).json({
      success: false,
      error: 'Failed to get app status',
    });
  }
});

// 6. Toggle Heroku App
app.post('/heroku/toggle-app', authenticateToken, async (req, res) => {
  try {
    const { appId, enable } = req.body;

    // Validate input
    const validationError = validateInput({ appId, enable }, ['appId', 'enable']);
    if (validationError) {
      logger.warn('Invalid input', { error: validationError, path: req.path });
      return res.status(400).json({
        success: false,
        error: validationError,
      });
    }

    await axios.patch(
      `https://api.heroku.com/apps/${appId}/formation`,
      {
        quantity: enable ? 1 : 0,
        type: 'web',
      },
      {
        headers: {
          Authorization: `Bearer ${process.env.HEROKU_API_KEY}`,
          Accept: 'application/vnd.heroku+json; version=3',
        },
      }
    );

    logger.info('App toggled', { appId, enable, userId: req.user.uid });
    res.status(200).json({
      success: true,
      message: `App ${enable ? 'enabled' : 'disabled'}`,
    });
  } catch (error) {
    logger.error('Error toggling app', {
      error: error.response?.data || error.message,
      path: req.path,
    });
    res.status(500).json({
      success: false,
      error: 'Failed to toggle app',
    });
  }
});

// Error handling middleware
app.use((err, req, res, next) => {
  logger.error('Unhandled error', { error: err.message, path: req.path });
  res.status(500).json({
    success: false,
    error: 'Internal server error',
  });
});

// Start the server
const PORT = process.env.PORT || 50000;
app.listen(PORT, () => {
  logger.info(`Server running on port ${PORT}`);
});