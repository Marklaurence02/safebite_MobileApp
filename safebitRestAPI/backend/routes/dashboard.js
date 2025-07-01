const express = require('express');
const router = express.Router();
const db = require('../../db/db');

// Recent Food Detections
router.get('/dashboard/recent-food', async (req, res) => {
    try {
        const { date } = req.query;
        let query = 'SELECT name, expiration_date FROM food_items';
        let params = [];
        if (date) {
            query += ' WHERE expiration_date = ?';
            params.push(date);
        }
        query += ' ORDER BY expiration_date DESC LIMIT 10';
        const [foods] = await db.query(query, params);
        const today = new Date();
        const result = foods.map(food => {
            const expDate = new Date(food.expiration_date);
            let status = 'Good';
            if (expDate < today) status = 'Spoilt';
            else if ((expDate - today) / (1000*60*60*24) <= 3) status = 'Spoilt warning';
            return {
                food: food.name,
                date: expDate.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }),
                status
            };
        });
        res.json({ success: true, data: result });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

router.get('/dashboard/sensor-activity', async (req, res) => {
    try {
        const { date, start, end } = req.query;
        let query = 'SELECT COUNT(*) as count FROM readings';
        let params = [];
        if (date) {
            query += ' WHERE DATE(timestamp) = ?';
            params.push(date);
        } else if (start && end) {
            query += ' WHERE DATE(timestamp) BETWEEN ? AND ?';
            params.push(start, end);
        }
        const [[result]] = await db.query(query, params);
        res.json({
            success: true,
            usage_count: result.count
        });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

module.exports = router;