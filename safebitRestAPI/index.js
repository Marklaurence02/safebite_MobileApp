require('dotenv').config();
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

const userRoutes = require('./routes/userRoutes');
const miscRoutes = require('./routes/miscRoutes');

app.use('/api/users', userRoutes);
app.use('/api', miscRoutes);

app.get('/', (req, res) => {
  res.send('Welcome to the SafeBit REST API!');
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
