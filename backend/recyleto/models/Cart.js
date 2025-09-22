const mongoose = require('mongoose');

const cartSchema = new mongoose.Schema({
    pharmacyId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: false
    },
    transactionType: {
        type: String,
        required: true,
        enum: ['sale', 'purchase', 'return', 'adjustment'],
        default: 'sale'
    },
    items: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'CartItem'
    }],
    totalAmount: {
        type: Number,
        default: 0
    },
    totalItems: {
        type: Number,
        default: 0
    },
    totalQuantity: {
        type: Number,
        default: 0
    },
    description: {
        type: String,
        trim: true,
        maxlength: 500
    },
    customerName: {
        type: String,
        trim: true
    },
    customerPhone: {
        type: String,
        trim: true
    },
    paymentMethod: {
        type: String,
        enum: ['cash', 'card', 'mobile_money', 'bank_transfer', 'credit'],
        default: 'cash'
    },
    status: {
        type: String,
        enum: ['active', 'completed', 'abandoned'],
        default: 'active'
    },
    expiresAt: {
        type: Date,
        default: () => new Date(Date.now() + 24 * 60 * 60 * 1000) // 24 hours
    }
}, {
    timestamps: true
});

// Update cart totals
cartSchema.methods.updateTotals = async function() {
    const CartItem = mongoose.model('CartItem');
    const totals = await CartItem.calculateCartTotal(this._id);

    this.totalAmount = totals.totalAmount;
    this.totalItems = totals.totalItems;
    this.totalQuantity = totals.totalQuantity;

    await this.save();
};

// Add item to cart
cartSchema.methods.addItem = async function(itemData) {
    const CartItem = mongoose.model('CartItem');

    // Check if item already exists
    let existingItem = await CartItem.findOne({
        cartId: this._id,
        medicineId: itemData.medicineId
    });

    if (existingItem) {
        existingItem.quantity += itemData.quantity;
        existingItem.totalPrice = existingItem.quantity * existingItem.unitPrice;
        await existingItem.save();
    } else {
        existingItem = new CartItem({
            ...itemData,
            totalPrice: itemData.quantity * itemData.unitPrice,
            cartId: this._id,
            pharmacyId: this.pharmacyId || null
        });
        await existingItem.save();

        // Add reference to cart items
        this.items.push(existingItem._id);
        await this.save(); // ✅ ensure Cart is saved
    }

    // Update totals after adding
    await this.updateTotals();

    return existingItem;
};

// Remove item from cart
cartSchema.methods.removeItem = async function(itemId) {
    const CartItem = mongoose.model('CartItem');

    await CartItem.findByIdAndDelete(itemId);
    this.items.pull(itemId);
    await this.updateTotals();
};

// Clear all items from cart
cartSchema.methods.clearCart = async function() {
    const CartItem = mongoose.model('CartItem');

    await CartItem.deleteMany({ cartId: this._id });
    this.items = [];
    this.totalAmount = 0;
    this.totalItems = 0;
    this.totalQuantity = 0;

    await this.save();
};

// Get cart with populated items
cartSchema.methods.getPopulatedCart = async function() {
    await this.populate({
        path: 'items',
        select: 'medicineName genericName form packSize quantity unitPrice totalPrice expiryDate batchNumber manufacturer',
        options: { sort: { addedAt: -1 } }
    });

    return this.toObject(); // ✅ return plain object for easier use in controller
};

// TTL index for automatic expiration
cartSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });
cartSchema.index({ pharmacyId: 1, status: 1 });
cartSchema.index({ createdAt: 1 });

module.exports = mongoose.model('Cart', cartSchema);
