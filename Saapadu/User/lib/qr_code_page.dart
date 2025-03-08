import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodePage extends StatelessWidget {
  final List<Map<String, dynamic>> orderedItems;
  final double totalAmount;
  final String uniqueKey;

  const QrCodePage({super.key, required this.orderedItems, required this.totalAmount, required this.uniqueKey});

  @override
  Widget build(BuildContext context) {
    // Generate unique key

    // Create QR code data
    final qrData = orderedItems.map((item) {
      return '${item['name']}:${item['quantity']}:${(item['price'] * item['quantity']).toInt()}';
    }).join(';');

    final qr = orderedItems.map((item){
      return """
      ${item['name']}: ${item['quantity']} X ${item['price']}
      """;
    }).join(';\n');

    final qrCodeData = 'UniqueKey:$uniqueKey;Items:$qrData';
    final qrCode = """
    Unique Key: $uniqueKey;
    Items: $qr
    """;

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code'),
        backgroundColor: Colors.white,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: Divider(
            height: 4.0,
            thickness: 1,
            color: Color(0x61693BB8),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: QrImageView(
                data: qrCode,
                version: QrVersions.auto,
                size: 300.0,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ...orderedItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['name'],
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          '${item['quantity']} x ₹${item['price']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(
                  height: 20,
                  thickness: 1,
                  color: Colors.grey,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₹${totalAmount.toInt()}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
