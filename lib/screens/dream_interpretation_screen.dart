import 'package:flutter/material.dart';
import '../data/dream_data.dart';

class DreamInterpretationScreen extends StatefulWidget {
  const DreamInterpretationScreen({super.key});

  @override
  State<DreamInterpretationScreen> createState() => _DreamInterpretationScreenState();
}

class _DreamInterpretationScreenState extends State<DreamInterpretationScreen> {
  List<Map<String, String>> _filteredInterpretations = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredInterpretations = dreamInterpretations;
  }

  void _filterDreams(String query) {
    setState(() {
      _filteredInterpretations = dreamInterpretations
          .where((dream) => dream['title']!.contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعبیر خواب'),
        backgroundColor: const Color(0xFF1a2a6c),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.network(
              'https://i.pinimg.com/736x/16/e1/e1/16e1e1d24c0d0c3d9b6a9c7d4a5b6c7d.jpg',
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
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterDreams,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'جستجوی موضوع خواب...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredInterpretations.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.white.withOpacity(0.9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          _filteredInterpretations[index]['title']!,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Text(
                          _filteredInterpretations[index]['content']!,
                          style: const TextStyle(fontSize: 16),
                        ),
                        leading: const Icon(Icons.nightlight_round, color: Color(0xFF1a2a6c)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
