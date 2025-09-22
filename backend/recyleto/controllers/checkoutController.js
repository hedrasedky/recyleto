const Transaction = require('../models/Transaction');
const Cart = require('../models/Cart');
const Medicine = require('../models/Medicine');
const { generateTransactionNumber } = require('../utils/helpers'); // ✅ Counter helper

// Generate unique transaction reference (optional)
const generateTransactionRef = () => {
  const timestamp = Date.now().toString(36);
  const randomStr = Math.random().toString(36).substring(2, 8);
  return `TXN-${timestamp}-${randomStr}`.toUpperCase();
};

// Checkout cart
exports.processCheckout = async (req, res) => {
  try {
    const pharmacyId = req.user?.pharmacyId || req.user?._id;
    if (!pharmacyId) return res.status(401).json({ success: false, message: 'Unauthorized: user not found' });

    const { 
      transactionType = 'sale', 
      description, 
      customerName, 
      customerPhone, 
      paymentMethod,
      saveAsDraft = false 
    } = req.body;

    // Find active cart
    const cart = await Cart.findOne({ pharmacyId, transactionType, status: 'active' }).populate('items');
    if (!cart || !cart.items?.length) return res.status(400).json({ success: false, message: 'Cart is empty' });

    // Prepare transaction items
    let totalAmount = 0;
    const transactionItems = [];

    for (const item of cart.items) {
      const med = await Medicine.findById(item.medicineId);
      if (!med) continue;

      const lineTotal = item.quantity * item.unitPrice;
      totalAmount += lineTotal;

      transactionItems.push({
        medicineId: med._id,
        medicineName: med.name,
        packSize: med.packSize,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        totalPrice: lineTotal,
        expiryDate: item.expiryDate,
        batchNumber: item.batchNumber
      });
    }

    // ✅ Generate unique transaction number **atomically**
    let transactionNumber;
    let saved = false;
    let attempts = 0;

    while (!saved && attempts < 5) {
      transactionNumber = await generateTransactionNumber(transactionType);

      try {
        const transactionData = {
          pharmacyId,
          transactionType,
          transactionNumber, // ✅ unique transaction number
          description,
          items: transactionItems,
          customerName,
          customerPhone,
          paymentMethod,
          totalAmount,
          subtotal: totalAmount,
          transactionRef: generateTransactionRef(),
          status: saveAsDraft ? 'draft' : 'completed'
        };

        const transaction = new Transaction(transactionData);
        await transaction.save();
        saved = true;

        // If not a draft, update stock and clear cart
        if (!saveAsDraft) {
          // Update stock if sale
          if (transactionType === 'sale') {
            for (const item of cart.items) {
              await Medicine.findByIdAndUpdate(item.medicineId, { $inc: { quantity: -item.quantity } });
            }
          }
          
          // Clear cart
          cart.items = [];
          cart.totalAmount = 0;
          cart.totalItems = 0;
          cart.totalQuantity = 0;
          cart.status = 'completed';
          await cart.save();
        }

        return res.status(201).json({ 
          success: true, 
          message: saveAsDraft ? 'Transaction saved as draft' : 'Transaction completed', 
          data: transaction,
          transactionId: transaction._id
        });

      } catch (err) {
        if (err.code === 11000) {
          // duplicate transactionNumber, retry
          attempts++;
        } else {
          throw err;
        }
      }
    }

    if (!saved) {
      return res.status(500).json({ success: false, message: 'Could not generate unique transaction number. Please try again.' });
    }

  } catch (error) {
    console.error('Checkout cart error:', error);
    res.status(500).json({ success: false, message: 'Error during checkout', error: error.message });
  }
};

// Get cart summary
exports.getCartSummary = async (req, res) => {
  try {
    const pharmacyId = req.user?.pharmacyId || req.user?._id;
    const { transactionType = 'sale' } = req.query;

    const cart = await Cart.findOne({ pharmacyId, transactionType, status: 'active' }).populate('items');
    if (!cart || !cart.items?.length) {
      return res.status(200).json({ success: true, data: { items: [], totalAmount: 0, totalItems: 0, totalQuantity: 0 } });
    }

    let totalAmount = 0;
    const itemsData = cart.items.map(item => {
      totalAmount += item.totalPrice;
      return {
        id: item._id,
        medicineId: item.medicineId,
        medicineName: item.medicineName,
        genericName: item.genericName,
        form: item.form,
        packSize: item.packSize,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        totalPrice: item.totalPrice,
        expiryDate: item.expiryDate,
        batchNumber: item.batchNumber,
        manufacturer: item.manufacturer
      };
    });

    res.status(200).json({
      success: true,
      data: {
        items: itemsData,
        totalAmount,
        totalItems: cart.items.length,
        totalQuantity: cart.items.reduce((sum, i) => sum + i.quantity, 0)
      }
    });

  } catch (error) {
    console.error('Cart summary error:', error);
    res.status(500).json({ success: false, message: 'Error fetching cart summary', error: error.message });
  }
};