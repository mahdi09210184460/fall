import 'package:flutter/material.dart';
import '../data/horoscope_data.dart';
import 'horoscope_detail_screen.dart';

class HoroscopeListScreen extends StatelessWidget {
  final String? initialFilter;
  const HoroscopeListScreen({super.key, this.initialFilter});

  @override
  Widget build(BuildContext context) {
    final filteredTypes = initialFilter != null
        ? horoscopeTypes.where((type) => type.id == initialFilter).toList()
        : horoscopeTypes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('انواع فال'),
        backgroundColor: const Color(0xFFb21f1f),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.network(
              'https://i.pinimg.com/736x/ed/e6/8c/ede68c983d3e6d2c49c71c8430a21051.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Dark Overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          // Content
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredTypes.length,
            itemBuilder: (context, index) {
              final type = filteredTypes[index];
              return Card(
                color: Colors.white.withOpacity(0.9),
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Text(type.icon, style: const TextStyle(fontSize: 40)),
                  title: Text(
                    type.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFFb21f1f)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HoroscopeDetailScreen(type: type),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
