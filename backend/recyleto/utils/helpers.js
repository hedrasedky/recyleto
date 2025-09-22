const Counter = require('../models/Counter');

// Generate transaction number dynamically using Counter collection
exports.generateTransactionNumber = async (type = 'sale') => {
    const counter = await Counter.findOneAndUpdate(
        { name: type },
        { $inc: { seq: 1 } },
        { new: true, upsert: true }
    );

    const padded = String(counter.seq).padStart(6, '0'); // 000001
    return `${type.toUpperCase().slice(0,3)}-${padded}`;
};

// Format currency
exports.formatCurrency = (amount) => {
    return new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD'
    }).format(amount);
};

// Calculate expiry status
exports.calculateExpiryStatus = (expiryDate) => {
    const today = new Date();
    const expiry = new Date(expiryDate);
    const diffTime = expiry - today;
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    
    if (diffDays <= 0) return 'expired';
    if (diffDays <= 7) return 'critical';
    if (diffDays <= 30) return 'warning';
    return 'good';
};

// Generate stock alerts
exports.generateStockAlerts = async (pharmacyId) => {
    const Inventory = require('../models/Inventory');
    
    const alerts = await Inventory.find({
        pharmacyId: pharmacyId,
        $or: [
            { status: 'low_stock' },
            { 
                expiryDate: { 
                    $lte: new Date(new Date().setDate(new Date().getDate() + 30))
                }
            }
        ]
    }).populate('productId', 'name category');
    
    return alerts;
};

// Offline support - generate unique IDs for client-side
exports.generateClientId = () => {
    return Date.now().toString(36) + Math.random().toString(36).substr(2);
};
