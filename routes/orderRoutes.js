const express = require('express');
const router = express.Router();
const Order = require('../models/order.js');

router.post('/orders', async (req, res) => {
  try {
    const order = new Order(req.body);
    await order.save();
    res.status(201).json({ message: 'Sipariş kaydedildi.' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Sipariş kaydedilemedi.' });
  }
});

// GET: Tüm siparişleri getir
router.get('/orders', async (req, res) => {
  try {
    const orders = await Order.find().sort({ siparis_tarihi: -1 });
    res.status(200).json(orders);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Siparişler getirilemedi.' });
  }
});


module.exports = router;
