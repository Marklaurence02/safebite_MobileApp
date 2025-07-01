const express = require('express');
const router = express.Router();
const db = require('../../db/db');

// GET all alerts, ordered by most recent
router.get('/alerts', async (req, res) => {
    try {
        const [alerts] = await db.query('SELECT * FROM `alerts` ORDER BY `timestamp` DESC');
        res.json({ success: true, data: alerts });
    } catch (error) {
        console.error('Error fetching alerts:', error);
        res.status(500).json({ success: false, message: 'Failed to retrieve alerts', error: error.message });
    }
});

module.exports = router;