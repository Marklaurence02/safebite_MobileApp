const express = require('express');
const router = express.Router();
const db = require('../../db/db');
const bcrypt = require('bcrypt');

// Create a new user
router.post('/newuser', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ success: false, error: 'Email and password are required' });
    }

    // Auto-generate username from email
    const username = email.split('@')[0];

    // Check if email or username already exists
    const [existingUsers] = await db.query('SELECT * FROM users WHERE email = ? OR username = ?', [email, username]);
    if (existingUsers.length > 0) {
      return res.status(409).json({ success: false, error: 'Username or email already exists.' });
    }

    const saltRounds = 10;
    const password_hash = await bcrypt.hash(password, saltRounds);

    const newUser = {
      first_name: username, // Default first_name to username
      last_name: 'User',    // Default last_name
      username,
      email,
      password_hash,
    };
    
    const result = await db.query('INSERT INTO users SET ?', newUser);
    res.status(201).json({ success: true, message: 'User created successfully', userId: result[0].insertId });

  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

router.post('/login', async (req, res) => {
  try {
    const { email: emailOrUsername, password } = req.body;
    
    if (!emailOrUsername || !password) {
        return res.status(400).json({ success: false, error: 'Email/Username and password are required' });
    }

    const [rows] = await db.query('SELECT * FROM users WHERE email = ? OR username = ?', [emailOrUsername, emailOrUsername]);
    
    if (rows.length === 0) {
      return res.status(401).json({ success: false, error: 'Invalid credentials' });
    }

    const user = rows[0];
    const passwordMatch = await bcrypt.compare(password, user.password_hash);
    
    if (!passwordMatch) {
      return res.status(401).json({ success: false, error: 'Invalid credentials' });
    }
    
    // Remove password hash from the user object before sending it
    delete user.password_hash;
    
    res.json({ success: true, message: 'Login successful', user: user });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

router.get('/users/:id', async (req, res) => {
  try {
    const id = req.params.id;
    const [rows] = await db.query('SELECT * FROM users WHERE user_id = ?', [id]);
    if (rows.length === 0) {
      res.status(404).json({ success: false, error: 'User not found' });
    } else {
      res.json({ success: true, user: rows[0] });
    }
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

router.get('/users', async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM users');
    res.json({ success: true, users: rows });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;