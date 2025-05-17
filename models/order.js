const mongoose = require("mongoose");

const orderSchema = new mongoose.Schema({
  siparis_tarihi: { type: String, required: true },
  adi_soyadi: { type: String, required: true },
  kullanici_adi: { type: String, required: true },
  telefon: { type: String, required: true },
  adres: { type: String, required: true },
  sehir: { type: String, required: true },
  urun_bilgisi: { type: String, required: true },
  renk: { type: String, required: true },
  birim_fiyati: { type: Number, required: true },
  adet: { type: Number, required: true },
  toplam_fiyat: { type: Number, required: true },
  odeme: { type: String, required: true },
  kargoya: { type: String, required: true },
  kargo_tarihi: { type: String, required: true },
  kargo_no: { type: String, required: true },
  notlar: { type: String, default: "" },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model("Order", orderSchema);
