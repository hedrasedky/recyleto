const express = require('express');
const router = express.Router();
const checkoutController = require('../controllers/checkoutController');
const { authenticate } = require('../middleware/auth'); // ensure this is a function

router.use(authenticate); // apply auth middleware

// Get cart summary
router.get('/summary', checkoutController.getCartSummary); // must match exported name

// Process checkout
router.post('/process', checkoutController.processCheckout); // must match exported name

module.exports = router;
