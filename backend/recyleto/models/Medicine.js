const mongoose = require('mongoose');

const medicineSchema = new mongoose.Schema({
    pharmacyId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    name: {
        type: String,
        required: true,
        trim: true
    },
    genericName: {
        type: String,
        required: true,
        trim: true
    },
    form: {
        type: String,
        required: true,
        enum: ['Tablet', 'Capsule', 'Syrup', 'Injection', 'Ointment', 'Cream', 'Drops', 'Inhaler', 'Other'],
        default: 'Tablet'
    },
    packSize: {
        type: String,
        required: true,
        trim: true
    },
    quantity: {
        type: Number,
        required: true,
        min: 0
    },
    price: {
        type: Number,
        required: true,
        min: 0
    },
    expiryDate: {
        type: Date,
        required: true
    },
    manufacturer: {
        type: String,
        trim: true
    },
    batchNumber: {
        type: String,
        trim: true
    },
    category: {
        type: String,
        required: true,
        trim: true
    },
    description: {
        type: String,
        trim: true
    },
    requiresPrescription: {
        type: Boolean,
        default: false
    },
    stockAlert: {
        type: Number,
        default: 10
    },
    lowStockThreshold: {
        type: Number,
        default: 10
    },
    status: {
        type: String,
        enum: ['active', 'inactive', 'discontinued'],
        default: 'active'
    },
    isActive: {
        type: Boolean,
        default: true
    }
}, {
    timestamps: true
});

// Index for search functionality (updated to include category)
medicineSchema.index({
    name: 'text',
    genericName: 'text',
    manufacturer: 'text',
    category: 'text'
});

// Virtual for stock status
medicineSchema.virtual('stockStatus').get(function() {
    if (this.quantity === 0) return 'out_of_stock';
    if (this.quantity <= this.lowStockThreshold) return 'low_stock';
    return 'in_stock';
});

// Check if medicine is expired
medicineSchema.virtual('isExpired').get(function() {
    return new Date() > this.expiryDate;
});

// Check if medicine will expire soon (within 30 days)
medicineSchema.virtual('expiresSoon').get(function() {
    const thirtyDaysFromNow = new Date();
    thirtyDaysFromNow.setDate(thirtyDaysFromNow.getDate() + 30);
    return this.expiryDate <= thirtyDaysFromNow && this.expiryDate > new Date();
});

module.exports = mongoose.model('Medicine', medicineSchema);