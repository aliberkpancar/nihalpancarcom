import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';

class EditOrderPage extends StatefulWidget {
  final Map<String, dynamic> order;

  const EditOrderPage({super.key, required this.order});

  @override
  State<EditOrderPage> createState() => _EditOrderPageState();
}

class _EditOrderPageState extends State<EditOrderPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController orderNoController;
  late TextEditingController orderDateController;
  late TextEditingController nameController;
  late TextEditingController profileController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController cityController;
  late TextEditingController productController;
  late TextEditingController colorController;
  late TextEditingController unitPriceController;
  late TextEditingController quantityController;
  late TextEditingController totalPriceController;
  late TextEditingController shippingDateController;
  late TextEditingController shippingCodeController;
  late TextEditingController noteController;

  late String paymentStatus;
  late String shippingStatus;

  @override
  void initState() {
    super.initState();

    final o = widget.order;

    orderNoController = TextEditingController(text: o['order_no'].toString());
    orderDateController = TextEditingController(text: o['order_date']);
    nameController = TextEditingController(text: o['name']);
    profileController = TextEditingController(text: o['profile_name']);
    phoneController = TextEditingController(text: o['phone']);
    addressController = TextEditingController(text: o['address']);
    cityController = TextEditingController(text: o['city']);
    productController = TextEditingController(text: o['product_info']);
    colorController = TextEditingController(text: o['color']);
    unitPriceController = TextEditingController(text: o['unit_price'].toString());
    quantityController = TextEditingController(text: o['quantity'].toString());
    totalPriceController = TextEditingController(text: o['total_price'].toString());
    shippingDateController = TextEditingController(text: o['shipping_date']);
    shippingCodeController = TextEditingController(text: o['shipping_code']);
    noteController = TextEditingController(text: o['note']);
    paymentStatus = o['payment_status'];
    shippingStatus = o['shipping_status'];
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

  void updateOrder() async {
    if (_formKey.currentState!.validate()) {
      final db = await DatabaseHelper.instance.database;

      final updated = {
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
        'note': noteController.text,
      };

      await db.update(
        'orders',
        updated,
        where: 'id = ?',
        whereArgs: [widget.order['id']],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sipariş güncellendi')),
      );

      Navigator.pop(context); // geri dön
    }
  }

  Widget buildTextField(String label, TextEditingController controller,
      {TextInputType? keyboardType, bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
      validator: (value) => value == null || value.isEmpty ? 'Boş bırakılamaz' : null,
    );
  }

  void calculateTotal() {
    final unitPrice = double.tryParse(unitPriceController.text) ?? 0;
    final quantity = int.tryParse(quantityController.text) ?? 0;
    final total = unitPrice * quantity;
    totalPriceController.text = total.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Siparişi Düzenle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildTextField('Sipariş No', orderNoController, readOnly: true),
              buildTextField('Sipariş Tarihi', orderDateController),
              buildTextField('Adı Soyadı', nameController),
              buildTextField('Kullanıcı Adı', profileController),
              buildTextField('Telefon', phoneController),
              buildTextField('Adres', addressController),
              buildTextField('Şehir', cityController),
              buildTextField('Ürün Bilgisi', productController),
              buildTextField('Renk', colorController),
              buildTextField('Birim Fiyatı', unitPriceController),
              buildTextField('Adet', quantityController),
              Row(
                children: [
                  Expanded(
                    child: buildTextField('Toplam Fiyat', totalPriceController),
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
                items: ['Alındı', 'Alınmadı'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (value) => setState(() => paymentStatus = value!),
              ),
              DropdownButtonFormField<String>(
                value: shippingStatus,
                decoration: const InputDecoration(labelText: 'Kargo Durumu'),
                items: ['Verildi', 'Verilmedi'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (value) => setState(() => shippingStatus = value!),
              ),
              buildTextField('Kargo Tarihi', shippingDateController),
              buildTextField('Kargo No', shippingCodeController),
              buildTextField('Not', noteController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateOrder,
                child: const Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
