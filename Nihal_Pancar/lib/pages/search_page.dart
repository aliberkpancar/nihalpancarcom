import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import 'edit_order_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];

  Future<void> performSearch(String query) async {
  final db = await DatabaseHelper.instance.database;

  final results = await db.query(
    'orders',
    where: '''
      LOWER(name) LIKE ? OR
      LOWER(profile_name) LIKE ? OR
      LOWER(phone) LIKE ? OR
      LOWER(address) LIKE ? OR
      LOWER(city) LIKE ? OR
      LOWER(product_info) LIKE ? OR
      LOWER(color) LIKE ? OR
      LOWER(unit_price) LIKE ? OR
      LOWER(quantity) LIKE ? OR
      LOWER(total_price) LIKE ? OR
      LOWER(payment_status) LIKE ? OR
      LOWER(shipping_status) LIKE ? OR
      LOWER(shipping_date) LIKE ? OR
      LOWER(shipping_code) LIKE ? OR
      LOWER(note) LIKE ? OR
      LOWER(order_no) LIKE ?
    ''',
    whereArgs: List.filled(16, '%${query.toLowerCase()}%'),
    orderBy: 'order_date DESC',
  );

  setState(() {
    searchResults = results;
  });
}

  Future<void> fetchAllOrdersFromServer() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.101:3000/api/orders'), // kendi IP adresinle aynı olduğundan emin ol
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          searchResults = jsonData.cast<Map<String, dynamic>>();
        });
      } else {
        debugPrint("❌ Sunucudan veri alınamadı: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Bağlantı hatası: $e");
    }
  }

  Future<void> deleteOrder(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('orders', where: 'id = ?', whereArgs: [id]);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sipariş silindi')),
    );
    performSearch(searchController.text);
  }

  Widget buildResultCard(Map<String, dynamic> record) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sipariş No: ${record['siparis_no'] ?? record['order_no']}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditOrderPage(order: record),
                          ),
                        ).then((_) => performSearch(searchController.text));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteOrder(record['id'] as int? ?? -1),
                    ),
                  ],
                )
              ],
            ),
            Text('Sipariş Tarihi: ${record['siparis_tarihi'] ?? record['order_date']}'),
            Text('Adı Soyadı: ${record['adi_soyadi'] ?? record['name']}'),
            Text('Kullanıcı Adı: ${record['kullanici_adi'] ?? record['profile_name'] ?? ''}'),
            Text('Telefon: ${record['telefon'] ?? record['phone']}'),
            Text('Adres: ${record['adres'] ?? record['address']}'),
            Text('Şehir: ${record['sehir'] ?? record['city']}'),
            Text('Ürün Bilgisi: ${record['urun_bilgisi'] ?? record['product_info']}'),
            Text('Renk: ${record['renk'] ?? record['color'] ?? ''}'),
            Text('Birim Fiyatı: ₺${record['birim_fiyati'] ?? record['unit_price']}'),
            Text('Adet: ${record['adet'] ?? record['quantity']}'),
            Text('Toplam Fiyat: ₺${record['toplam_fiyat'] ?? record['total_price']}'),
            Text('Ödeme: ${record['odeme'] ?? record['payment_status']}'),
            Text('Kargo Durumu: ${record['kargoya'] ?? record['shipping_status']}'),
            Text('Kargo Tarihi: ${record['kargo_tarihi'] ?? record['shipping_date'] ?? ''}'),
            Text('Kargo Takip No: ${record['kargo_no'] ?? record['shipping_code'] ?? ''}'),
            Text('Not: ${record['notlar'] ?? record['note'] ?? ''}'),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
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
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: SizedBox(
                width: 300,
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Aranacak kelime',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: fetchAllOrdersFromServer,
                    ),
                  ),
                  onSubmitted: performSearch,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.list),
                label: const Text('Tüm Siparişleri Göster'),
                onPressed: fetchAllOrdersFromServer,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: searchResults.isEmpty
                  ? const Center(child: Text('Sonuç bulunamadı'))
                  : ListView(
                      children: searchResults.map(buildResultCard).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
