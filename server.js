const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const orderRoutes = require('./routes/orderRoutes.js');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api', orderRoutes);

// MongoDB bağlantısı
mongoose.connect('mongodb://127.0.0.1:27017/nihalpancar', )
  .then(() => console.log('MongoDB bağlantısı başarılı.'))
  .catch(err => console.log('MongoDB bağlantısı hatası:', err));


// Server başlat
app.listen(PORT, () => {
  console.log(`Sunucu ${PORT} portunda çalışıyor.`);
});

app.get('/', (req, res) => {
  res.send('Sunucu Çalışıyor!');
});
