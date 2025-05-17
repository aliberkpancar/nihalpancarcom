import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../main.dart';

class OrderFormPage extends StatefulWidget {
  const OrderFormPage({super.key});

  @override
  State<OrderFormPage> createState() => _OrderFormPageState();
}

class _OrderFormPageState extends State<OrderFormPage> {
  final _formKey = GlobalKey<FormState>();

  final orderNoController = TextEditingController();
  final orderDateController = TextEditingController();
  final nameController = TextEditingController();
  final profileController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final productController = TextEditingController();
  final colorController = TextEditingController();
  final unitPriceController = TextEditingController();
  final quantityController = TextEditingController(); 
  final totalPriceController = TextEditingController();
  final shippingDateController = TextEditingController();
  final shippingCodeController = TextEditingController();
  final noteController = TextEditingController();

  String paymentStatus = 'Alınmadı';
  String shippingStatus = 'Verilmedi';

  @override
  void initState() {
    super.initState();
    prepareOrderNoAndDate();
  }

  Future<void> prepareOrderNoAndDate() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery('SELECT MAX(order_no) as max_no FROM orders');
    final lastNo = result.first['max_no'] as int?;
    final newOrderNo = (lastNo ?? 1000) + 1;
    final now = DateTime.now();
    final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    setState(() {
      orderNoController.text = newOrderNo.toString();
      final now = DateTime.now();
      orderDateController.text = today;
    });
  }

  void calculateTotal() {
    final unitPrice = double.tryParse(unitPriceController.text) ?? 0;
    final quantity = int.tryParse(quantityController.text) ?? 0;
    final total = unitPrice * quantity;
    totalPriceController.text = total.toStringAsFixed(2);
  }

  Future<void> saveOrder() async {
  if (_formKey.currentState!.validate()) {
    final order = {
      'order_no': int.tryParse(orderNoController.text),
      'order_date': orderDateController.text,
      'name': nameController.text,
      'profile_name': profileController.text,
      'phone': phoneController.text,
      'address': addressController.text,
      'city': cityController.text,
      'product_info': productController.text,
      'color': colorController.text,
      'unit_price': double.tryParse(unitPriceController.text) ?? 0,
      'quantity': int.tryParse(quantityController.text) ?? 0,
      'total_price': double.tryParse(totalPriceController.text) ?? 0,
      'payment_status': paymentStatus,
      'shipping_status': shippingStatus,
      'shipping_date': shippingDateController.text,
      'shipping_code': shippingCodeController.text,
      'note': noteController.text.trim(),
    };

    // Lokal veritabanına ekle
    await DatabaseHelper.instance.insertOrder(order);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "siparis_no": int.tryParse(orderNoController.text) ?? 0,
          "siparis_tarihi": DateFormat('yyyy-MM-dd')
              .format(DateFormat('dd-MM-yyyy').parse(orderDateController.text)),
          "adi_soyadi": nameController.text,
          "kullanici_adi": profileController.text,
          "telefon": phoneController.text,
          "adres": addressController.text,
          "sehir": cityController.text,
          "urun_bilgisi": productController.text,
          "eni_boyu": "-",
          "renk": colorController.text,
          "birim_fiyati": double.tryParse(unitPriceController.text) ?? 0,
          "adet": int.tryParse(quantityController.text) ?? 0,
          "toplam_fiyat": double.tryParse(totalPriceController.text) ?? 0,
          "odeme": paymentStatus,
          "kargoya": shippingStatus,
          "kargo_tarihi": shippingDateController.text.isEmpty
              ? "-"
              : DateFormat('yyyy-MM-dd')
                  .format(DateFormat('dd-MM-yyyy').parse(shippingDateController.text)),
          "kargo_no": shippingCodeController.text.trim().isEmpty
              ? "-"
              : shippingCodeController.text.trim(),
          "notlar": noteController.text.trim(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ Sipariş sunucuya da gönderildi.");
      } else {
        debugPrint("❌ Sunucuya gönderme hatası: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ HTTP bağlantı hatası: $e");
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sipariş başarıyla kaydedildi.')),
    );
    Navigator.pop(context);
  }
}



  Widget buildTextField(String label, TextEditingController controller,
      {TextInputType? keyboardType, bool readOnly = false, bool isOptional = false}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (!isOptional && (value == null || value.isEmpty)) {
          return 'Boş bırakılamaz';
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    orderNoController.dispose();
    orderDateController.dispose();
    nameController.dispose();
    profileController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    productController.dispose();
    colorController.dispose();
    unitPriceController.dispose();
    quantityController.dispose();
    totalPriceController.dispose();
    shippingDateController.dispose();
    shippingCodeController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/logo.png',
          height: 90,
          width: 300,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildTextField('Sipariş No', orderNoController, readOnly: true),
              buildTextField('Sipariş Tarihi', orderDateController, readOnly: true),
              buildTextField('Adı Soyadı', nameController),
              buildTextField('Kullanıcı Adı', profileController, isOptional: true),
              buildTextField('Telefon Numarası', phoneController),
              buildTextField('Adres', addressController),
              buildTextField('Şehir', cityController),
              buildTextField('Ürün Bilgisi', productController),
              buildTextField('Renk', colorController, isOptional: true),
              buildTextField('Birim Fiyatı', unitPriceController, keyboardType: TextInputType.number, isOptional: true),
              buildTextField('Adet', quantityController, keyboardType: TextInputType.number, isOptional: true),
              Row(
                children: [
                  Expanded(
                    child: buildTextField('Toplam Fiyat', totalPriceController, readOnly: true),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calculate),
                    onPressed: calculateTotal,
                  ),
                ],
              ),
              DropdownButtonFormField<String>(
                value: paymentStatus,
                decoration: const InputDecoration(labelText: 'Ödeme Durumu'),
                items: ['Alınmadı', 'Alındı']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => paymentStatus = value!),
              ),
              DropdownButtonFormField<String>(
                value: shippingStatus,
                decoration: const InputDecoration(labelText: 'Kargoya Verildi mi?'),
                items: ['Verilmedi', 'Verildi']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => shippingStatus = value!),
              ),
              buildTextField('Kargo Tarihi', shippingDateController, isOptional: true),
              buildTextField('Kargo Takip No', shippingCodeController, isOptional: true),
              buildTextField('Not', noteController, isOptional: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveOrder,
                child: const Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
