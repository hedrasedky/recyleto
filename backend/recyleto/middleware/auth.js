// middleware/upload.js
const multer = require('multer');
const path = require('path');
const fs = require('fs').promises;
const jwt = require('jsonwebtoken');
const User = require('../models/User');

// Ensure upload directories exist
const ensureUploadDirs = async () => {
    const dirs = [
        path.join(__dirname, '../uploads/licenses'),
        path.join(__dirname, '../uploads/logos')
    ];
    
    for (const dir of dirs) {
        try {
            await fs.access(dir);
        } catch {
            await fs.mkdir(dir, { recursive: true });
        }
    }
};

ensureUploadDirs().catch(console.error);

// Configure storage
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        if (file.fieldname === 'licenseImage') {
            cb(null, 'uploads/licenses/');
        } else if (file.fieldname === 'logo') {
            cb(null, 'uploads/logos/');
        } else {
            cb(new Error('Invalid fieldname'), false);
        }
    },
    filename: function (req, file, cb) {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
    }
});

// File filter
const fileFilter = (req, file, cb) => {
    if (file.fieldname === 'licenseImage' || file.fieldname === 'logo') {
        if (file.mimetype.startsWith('image/')) {
            cb(null, true);
        } else {
            cb(new Error('Only image files are allowed'), false);
        }
    } else {
        cb(new Error('Invalid fieldname'), false);
    }
};

// Create the upload instance
const upload = multer({
    storage: storage,
    fileFilter: fileFilter,
    limits: {
        fileSize: 5 * 1024 * 1024, // 5MB limit
        files: 2 // Maximum 2 files
    }
});

// AUTHENTICATION MIDDLEWARE
const authenticate = async (req, res, next) => {
    try {
        let token;

        // Check for token in Authorization header
        if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
            token = req.headers.authorization.split(' ')[1];
        }
        // Check for token in cookies (optional)
        else if (req.cookies && req.cookies.token) {
            token = req.cookies.token;
        }

        if (!token) {
            return res.status(401).json({
                success: false,
                message: 'Not authorized to access this route. No token provided.'
            });
        }

        // Verify token
        let decoded;
        try {
            decoded = jwt.verify(token, process.env.JWT_SECRET);
        } catch (jwtError) {
            return res.status(401).json({
                success: false,
                message: 'Not authorized to access this route. Invalid token.'
            });
        }

        // Fetch user - select necessary fields including twoFactorEnabled
        const currentUser = await User.findById(decoded.id).select('_id role pharmacyName email username twoFactorEnabled');
        if (!currentUser) {
            return res.status(401).json({
                success: false,
                message: 'The user belonging to this token no longer exists.'
            });
        }

        // Check if user has 2FA enabled
        if (currentUser.twoFactorEnabled) {
            if (!req.session || !req.session.twoFactorVerified) {
                return res.status(401).json({
                    success: false,
                    message: '2FA verification required',
                    requires2FA: true
                });
            }
        }

        // Attach user info to request
        req.user = currentUser;
        req.userId = currentUser._id;
        req.pharmacyName = currentUser.pharmacyName;

        next();
    } catch (error) {
        console.error('Auth middleware error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error in authentication'
        });
    }
};

// Role-based authorization
const authorize = (...roles) => {
    return (req, res, next) => {
        // Debug logging
        console.log('=== AUTHORIZE MIDDLEWARE DEBUG ===');
        console.log('Request URL:', req.originalUrl);
        console.log('User ID:', req.user ? req.user._id : 'No user');
        console.log('User Role:', req.user ? req.user.role : 'No role');
        console.log('Allowed Roles (raw):', roles);
        
        // Handle nested array case (if someone passes authorize([['role1', 'role2']]))
        let allowedRoles = roles;
        if (Array.isArray(roles[0]) && roles.length === 1) {
            allowedRoles = roles[0];
            console.log('Fixed nested array issue. New allowed roles:', allowedRoles);
        }
        
        // Flatten the roles array in case of multiple arrays
        allowedRoles = allowedRoles.flat();
        
        console.log('Allowed Roles (processed):', allowedRoles);
        console.log('Is Authorized:', req.user && allowedRoles.includes(req.user.role));
        console.log('==================================');
        
        if (!req.user || !allowedRoles.includes(req.user.role)) {
            return res.status(403).json({
                success: false,
                message: `User role ${req.user ? req.user.role : 'unknown'} is not authorized to access this route`
            });
        }
        next();
    };
};

// Optional authentication
const optionalAuth = async (req, res, next) => {
    try {
        let token;

        if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
            token = req.headers.authorization.split(' ')[1];
        } else if (req.cookies && req.cookies.token) {
            token = req.cookies.token;
        }

        if (token) {
            try {
                const decoded = jwt.verify(token, process.env.JWT_SECRET);
                const currentUser = await User.findById(decoded.id).select('_id role pharmacyName email twoFactorEnabled');
                if (currentUser) {
                    req.user = currentUser;
                    req.userId = currentUser._id;
                    req.pharmacyName = currentUser.pharmacyName;
                }
            } catch (jwtError) {
                console.log('Optional auth: Invalid token, continuing without user');
            }
        }

        next();
    } catch (error) {
        console.error('Optional auth error:', error);
        next();
    }
};

// Alias for backward compatibility
const protect = authenticate;

// Export both the upload instance and a fields configuration
module.exports = { 
    upload,
    pharmacyUpload: upload.fields([
        { name: 'licenseImage', maxCount: 1 },
        { name: 'logo', maxCount: 1 }
    ]),
    authenticate,
    authorize,
    optionalAuth,
    protect
};