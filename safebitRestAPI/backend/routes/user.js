const express = require('express');
const router = express.Router();
const db = require('../../db/db');

// Create a new user
router.post('/newuser', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validate required fields
    if (!email || !password) {
      return res.status(400).json({ 
        success: false, 
        error: 'Email and password are required' 
      });
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({ 
        success: false, 
        error: 'Please enter a valid email address' 
      });
    }

    // Validate password length
    if (password.length < 6) {
      return res.status(400).json({ 
        success: false, 
        error: 'Password must be at least 6 characters long' 
      });
    }

    // Check if user already exists (by email)
    const [existingUsers] = await db.query(
      'SELECT user_id FROM users WHERE email = ?', 
      [email]
    );

    if (existingUsers.length > 0) {
      return res.status(400).json({ 
        success: false, 
        error: 'User with this email already exists' 
      });
    }

    // Generate default values for required fields
    const emailParts = email.split('@');
    const username = emailParts[0] + '_' + Math.random().toString(36).substr(2, 5);
    const firstName = emailParts[0].charAt(0).toUpperCase() + emailParts[0].slice(1);
    const lastName = 'User';

    // Insert new user
    const [result] = await db.query(
      'INSERT INTO users (first_name, last_name, username, email, password_hash) VALUES (?, ?, ?, ?, ?)',
      [firstName, lastName, username, email, password]
    );

    res.status(201).json({ 
      success: true, 
      message: 'User created successfully',
      userId: result.insertId
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Login user
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    
    if (!email || !password) {
      return res.status(400).json({ 
        success: false, 
        error: 'Email and password are required' 
      });
    }
    
    // Find user by email
    const [users] = await db.query(
      'SELECT * FROM users WHERE email = ?', 
      [email]
    );
    
    if (users.length === 0) {
      return res.status(401).json({ 
        success: false, 
        error: 'Invalid email or password' 
      });
    }
    
    const user = users[0];
    
    // Check if account is active
    if (user.account_status !== 'active') {
      return res.status(401).json({ 
        success: false, 
        error: 'Account is inactive. Please contact administrator.' 
      });
    }
    
    // Check password (in production, use bcrypt to compare hashed passwords)
    if (user.password_hash !== password) {
      return res.status(401).json({ 
        success: false, 
        error: 'Invalid email or password' 
      });
    }
    
    // Return user data (without password)
    res.json({ 
      success: true, 
      message: 'Login successful',
      user: {
        userId: user.user_id,
        firstName: user.first_name,
        lastName: user.last_name,
        username: user.username,
        email: user.email,
        contactNumber: user.contact_number,
        role: user.role,
        accountStatus: user.account_status,
        createdAt: user.created_at
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get all users
router.get('/users', async (req, res) => {
  try {
    const [rows] = await db.query(
      'SELECT user_id, first_name, last_name, username, email, contact_number, role, account_status, created_at, updated_at FROM users'
    );
    res.json({ success: true, users: rows });
  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get user by ID
router.get('/user/:id', async (req, res) => {
  try {
    const userId = req.params.id;
    const [users] = await db.query(
      'SELECT user_id, first_name, last_name, username, email, contact_number, role, account_status, created_at, updated_at FROM users WHERE user_id = ?',
      [userId]
    );
    
    if (users.length === 0) {
      return res.status(404).json({ 
        success: false, 
        error: 'User not found' 
      });
    }
    
    res.json({ success: true, user: users[0] });
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;