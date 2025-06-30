const express = require('express');
const cors = require('cors');
const db = require('../db/db');
const path = require('path');
const usersRouter = require('./routes/user');
const PORT = process.env.PORT || 3000;

const app = express();

app.use(cors());
app.use(express.json());

// check DB connection
app.get('/api/test-db', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT 1 + 1 AS solution');
        res.json({ success: true, result: rows[0].solution });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

app.use('/api', usersRouter);

app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});