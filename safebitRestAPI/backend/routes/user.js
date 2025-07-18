const express = require('express');
const router = express.Router();
const db = require('../../db/db');
const bcrypt = require('bcrypt');
const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'dinewatchph@gmail.com',
    pass: 'aoox zrsp ugcq jpun'
  },
  tls: {
    rejectUnauthorized: false
  }
});

// Create a new user
router.post('/newuser', async (req, res) => {
  try {
    const { 
      email, 
      password, 
      firstName, 
      lastName, 
      username, 
      contact_number, 
      acceptTerms, 
      acceptPrivacy 
    } = req.body;

    console.log(req.body)

    if (!email || !password || !firstName || !lastName || !username || !contact_number) {
      return res.status(400).json({ 
        success: false, 
        error: 'Email, password, first name, last name, username, and contact number are required' 
      });
    }

    if (!acceptTerms || !acceptPrivacy) {
      return res.status(400).json({ 
        success: false, 
        error: 'You must accept both Terms and Conditions and Data Privacy Policy' 
      });
    }

    // Check if email or username already exists
    const [existingUsers] = await db.query('SELECT * FROM users WHERE email = ? OR username = ?', [email, username]);
    if (existingUsers.length > 0) {
      return res.status(409).json({ success: false, error: 'Username or email already exists.' });
    }

    const saltRounds = 10;
    const password_hash = await bcrypt.hash(password, saltRounds);

    const newUser = {
      first_name: firstName,
      last_name: lastName,
      username,
      email,
      contact_number,
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

// Forgot Password - Send OTP
router.post('/forgot-password', async (req, res) => {
  const { email } = req.body;
  if (!email) return res.status(400).json({ success: false, error: 'Email required' });

  // Check if user exists
  const [users] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
  if (users.length === 0) return res.status(404).json({ success: false, error: 'Email not found' });

  // Generate OTP
  const otp = Math.floor(100000 + Math.random() * 900000).toString();
  const expiry = new Date(Date.now() + 10 * 60000); // 10 minutes from now

  // Store OTP and expiry
  await db.query('UPDATE users SET reset_otp = ?, otp_expiry = ? WHERE email = ?', [otp, expiry, email]);

  // Send OTP via email
  transporter.sendMail({
    from: 'dinewatchph@gmail.com',
    to: email,
    subject: 'Your SafeBite OTP Code',
    text: `Your OTP code is: ${otp}`
  }, (err, info) => {
    if (err) {
      return res.status(500).json({ success: false, error: 'Failed to send OTP email' });
    }
    res.json({ success: true, message: 'OTP sent to email' });
  });
});

// Verify OTP
router.post('/verify-otp', async (req, res) => {
  const { email, otp } = req.body;
  if (!email || !otp) return res.status(400).json({ success: false, error: 'Email and OTP required' });

  const [users] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
  if (users.length === 0) return res.status(404).json({ success: false, error: 'Email not found' });

  const user = users[0];
  if (user.reset_otp !== otp) return res.status(400).json({ success: false, error: 'Invalid OTP' });
  if (!user.otp_expiry || new Date(user.otp_expiry) < new Date()) {
    return res.status(400).json({ success: false, error: 'OTP expired' });
  }

  // Optionally clear OTP after successful verification
  await db.query('UPDATE users SET reset_otp = NULL, otp_expiry = NULL WHERE email = ?', [email]);

  res.json({ success: true, message: 'OTP verified' });
});

// Reset Password
router.post('/reset-password', async (req, res) => {
  const { email, newPassword } = req.body;
  if (!email || !newPassword) {
    return res.status(400).json({ success: false, error: 'Email and new password required' });
  }

  try {
    const saltRounds = 10;
    const password_hash = await bcrypt.hash(newPassword, saltRounds);

    await db.query('UPDATE users SET password_hash = ? WHERE email = ?', [password_hash, email]);
    res.json({ success: true, message: 'Password updated successfully' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;