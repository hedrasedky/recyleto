const mongoose = require('mongoose');
const Counter = require('./Counter');

const transactionItemSchema = new mongoose.Schema({
    medicineId: { type: mongoose.Schema.Types.ObjectId, ref: 'Medicine', required: true },
    medicineName: { type: String, required: true },
    genericName: { type: String, required: true }, 
    packSize: { type: String, required: true },
    quantity: { type: Number, required: true, min: 1 },
    unitPrice: { type: Number, required: true, min: 0 },
    totalPrice: { type: Number, required: true, min: 0 },
    expiryDate: { type: Date },
    batchNumber: { type: String }
});

const transactionSchema = new mongoose.Schema({
    pharmacyId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    transactionType: {
        type: String,
        required: true,
        enum: ['sale', 'purchase', 'return', 'adjustment', 'transfer'],
        default: 'sale'
    },
    transactionId: { type: String, unique: true, sparse: true }, // Will be generated
    transactionNumber: { type: String, unique: true, sparse: true }, // Will be generated
    transactionRef: { type: String, unique: true, sparse: true }, // Will be generated
    description: { type: String, trim: true, maxlength: 500 },
    items: [transactionItemSchema],
    subtotal: { type: Number, required: true, default: 0 },
    tax: { type: Number, default: 0 },
    discount: { type: Number, default: 0 },
    totalAmount: { type: Number, required: true, min: 0, default: 0 },
    customerInfo: {
        name: { type: String, trim: true },
        phone: { type: String, trim: true }
    },
    paymentMethod: {
        type: String,
        enum: ['cash', 'card', 'mobile_money', 'bank_transfer', 'credit', 'digital_wallet'],
        default: 'cash'
    },
    status: {
        type: String,
        enum: ['draft', 'pending', 'completed', 'cancelled', 'refunded', 'partially_refunded'],
        default: 'draft'
    },
    transactionDate: { type: Date, default: Date.now },
    refunds: [{
        refundId: { type: mongoose.Schema.Types.ObjectId, ref: 'Refund' },
        amount: { type: Number, required: true, min: 0 },
        date: { type: Date, default: Date.now },
        reason: { type: String, trim: true }
    }]
}, { timestamps: true });

// Method to generate unique transaction ID with retry logic
transactionSchema.methods.generateUniqueTransactionId = async function() {
    let attempts = 0;
    const maxAttempts = 5;
    
    while (attempts < maxAttempts) {
        try {
            const now = new Date();
            const dateStr = now.toISOString().slice(0, 10).replace(/-/g, '');
            const timeStr = now.getTime().toString().slice(-4); // Last 4 digits of timestamp
            const randomStr = Math.random().toString(36).substring(2, 5).toUpperCase();
            
            const transactionId = `TXN-${dateStr}-${timeStr}${randomStr}`;
            
            // Check if this ID already exists
            const existing = await mongoose.model('Transaction').findOne({ transactionId });
            if (!existing) {
                return transactionId;
            }
            
            attempts++;
        } catch (error) {
            attempts++;
        }
    }
    
    // If all attempts fail, use ObjectId as fallback
    return `TXN-${new mongoose.Types.ObjectId().toString().toUpperCase()}`;
};

// Method to generate unique transaction number
transactionSchema.methods.generateUniqueTransactionNumber = async function() {
    let attempts = 0;
    const maxAttempts = 5;
    
    while (attempts < maxAttempts) {
        try {
            // Get counter for this transaction type
            const counter = await Counter.findOneAndUpdate(
                { name: `${this.transactionType}_txn_number` },
                { $inc: { seq: 1 } },
                { new: true, upsert: true }
            );
            
            const transactionNumber = `${this.transactionType.toUpperCase().slice(0,3)}-${String(counter.seq).padStart(6, '0')}`;
            
            // Check if this number already exists
            const existing = await mongoose.model('Transaction').findOne({ transactionNumber });
            if (!existing) {
                return transactionNumber;
            }
            
            attempts++;
        } catch (error) {
            attempts++;
        }
    }
    
    // Fallback with timestamp
    const timestamp = Date.now().toString().slice(-6);
    return `${this.transactionType.toUpperCase().slice(0,3)}-${timestamp}`;
};

// Method to generate unique transaction reference
transactionSchema.methods.generateUniqueTransactionRef = async function() {
    let attempts = 0;
    const maxAttempts = 5;
    
    while (attempts < maxAttempts) {
        try {
            const randomStr = Math.random().toString(36).substring(2, 9).toUpperCase();
            const transactionRef = `REF-${randomStr}`;
            
            // Check if this ref already exists
            const existing = await mongoose.model('Transaction').findOne({ transactionRef });
            if (!existing) {
                return transactionRef;
            }
            
            attempts++;
        } catch (error) {
            attempts++;
        }
    }
    
    // Fallback with timestamp
    const timestamp = Date.now().toString().slice(-6);
    return `REF-${timestamp}${Math.random().toString(36).substring(2, 3).toUpperCase()}`;
};

// Pre-save middleware to generate unique IDs and calculate totals
transactionSchema.pre('save', async function(next) {
    try {
        // Generate unique IDs only for new documents
        if (this.isNew) {
            // Generate transactionId
            if (!this.transactionId) {
                this.transactionId = await this.generateUniqueTransactionId();
            }
            
            // Generate transactionNumber
            if (!this.transactionNumber) {
                this.transactionNumber = await this.generateUniqueTransactionNumber();
            }
            
            // Generate transactionRef
            if (!this.transactionRef) {
                this.transactionRef = await this.generateUniqueTransactionRef();
            }
        }

        // Calculate totals
        this.subtotal = this.items.reduce((total, item) => total + (item.totalPrice || 0), 0);
        this.totalAmount = Math.max(0, this.subtotal + (this.tax || 0) - (this.discount || 0));

        // Update status based on refunds (only if transaction is completed)
        if (this.status === 'completed') {
            const totalRefunded = this.refunds.reduce((total, refund) => total + (refund.amount || 0), 0);
            if (totalRefunded >= this.totalAmount && totalRefunded > 0) {
                this.status = 'refunded';
            } else if (totalRefunded > 0) {
                this.status = 'partially_refunded';
            }
        }

        next();
    } catch (error) {
        next(error);
    }
});

// Static method to create transaction with guaranteed unique IDs
transactionSchema.statics.createWithUniqueIds = async function(transactionData) {
    const transaction = new this(transactionData);
    
    // Ensure unique IDs are generated
    transaction.transactionId = await transaction.generateUniqueTransactionId();
    transaction.transactionNumber = await transaction.generateUniqueTransactionNumber();
    transaction.transactionRef = await transaction.generateUniqueTransactionRef();
    
    return transaction;
};

// Virtual for total refund amount
transactionSchema.virtual('totalRefunded').get(function() {
    return this.refunds.reduce((total, refund) => total + (refund.amount || 0), 0);
});

// Method to check if transaction can be refunded
transactionSchema.methods.canRefund = function() {
    return this.status === 'completed' && this.totalRefunded < this.totalAmount;
};

// Index for better query performance
transactionSchema.index({ pharmacyId: 1, status: 1 });
transactionSchema.index({ transactionDate: -1 });
transactionSchema.index({ transactionType: 1, pharmacyId: 1 });

// Compound index for finding pending transactions by pharmacy and type
transactionSchema.index({ pharmacyId: 1, transactionType: 1, status: 1 }, { unique: false });

module.exports = mongoose.model('Transaction', transactionSchema);