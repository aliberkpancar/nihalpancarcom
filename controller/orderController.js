const Order = require("../models/order.js");

// Yeni sipariş ekle
exports.createOrder = async (req, res) => {
  try {
    const newOrder = new Order(req.body);
    await newOrder.save();
    res.status(201).json(newOrder);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Kullanıcının tüm siparişlerini getir
exports.getOrdersByUser = async (req, res) => {
  try {
    const { userId } = req.query;
    const orders = await Order.find({ userId }).sort({ createdAt: -1 });
    res.json(orders);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Siparişlerde arama yap
exports.searchOrders = async (req, res) => {
  try {
    const { q, userId } = req.query;
    const orders = await Order.find({
      userId,
      orderDetails: { $regex: q, $options: "i" }
    });
    res.json(orders);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
