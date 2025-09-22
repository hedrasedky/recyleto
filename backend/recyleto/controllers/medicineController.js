const Medicine = require('../models/Medicine');

exports.addMedicine = async (req, res) => {
    try {
        const pharmacyId = req.user._id;
        const {
            name,
            genericName,
            form,
            packSize,
            quantity,
            price,
            expiryDate,
            manufacturer,
            batchNumber,
            category,
            requiresPrescription
        } = req.body;

        const medicine = new Medicine({
            pharmacyId,
            name,
            genericName,
            form,
            packSize,
            quantity: parseInt(quantity),
            price: parseFloat(price),
            expiryDate: new Date(expiryDate),
            manufacturer,
            batchNumber,
            category,
            requiresPrescription: requiresPrescription === 'true'
        });

        await medicine.save();

        res.status(201).json({
            success: true,
            message: 'Medicine added successfully',
            data: medicine
        });

    } catch (error) {
        console.error('Add medicine error:', error);
        res.status(500).json({
            success: false,
            message: 'Error adding medicine'
        });
    }
};

exports.searchMedicines = async (req, res) => {
    try {
        const pharmacyId = req.user._id;
        const { search, page = 1, limit = 10 } = req.query;

        const query = { pharmacyId, status: 'active' };

        if (search) {
            query.$text = { $search: search };
        }

        const options = {
            page: parseInt(page),
            limit: parseInt(limit),
            sort: { name: 1 }
        };

        const medicines = await Medicine.find(query)
            .select('name genericName form packSize price quantity expiryDate')
            .limit(limit * 1)
            .skip((page - 1) * limit)
            .sort({ name: 1 });

        const total = await Medicine.countDocuments(query);

        res.status(200).json({
            success: true,
            data: {
                medicines,
                totalPages: Math.ceil(total / limit),
                currentPage: page,
                total
            }
        });

    } catch (error) {
        console.error('Search medicines error:', error);
        res.status(500).json({
            success: false,
            message: 'Error searching medicines'
        });
    }
};

exports.getMedicineById = async (req, res) => {
    try {
        const pharmacyId = req.user._id;
        const { id } = req.params;

        const medicine = await Medicine.findOne({ _id: id, pharmacyId });

        if (!medicine) {
            return res.status(404).json({
                success: false,
                message: 'Medicine not found'
            });
        }

        res.status(200).json({
            success: true,
            data: medicine
        });

    } catch (error) {
        console.error('Get medicine error:', error);
        res.status(500).json({
            success: false,
            message: 'Error fetching medicine'
        });
    }
};

exports.updateMedicine = async (req, res) => {
    try {
        const pharmacyId = req.user._id;
        const { id } = req.params;
        const updateData = req.body;

        const medicine = await Medicine.findOneAndUpdate(
            { _id: id, pharmacyId },
            updateData,
            { new: true, runValidators: true }
        );

        if (!medicine) {
            return res.status(404).json({
                success: false,
                message: 'Medicine not found'
            });
        }

        res.status(200).json({
            success: true,
            message: 'Medicine updated successfully',
            data: medicine
        });

    } catch (error) {
        console.error('Update medicine error:', error);
        res.status(500).json({
            success: false,
            message: 'Error updating medicine'
        });
    }
};