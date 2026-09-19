import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../models/horoscope_history.dart';
import '../services/app_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HoroscopeHistoryEntry> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await AppService.getHistory();
    setState(() {
      _history = history;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('تاریخچه فال‌های من'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://i.pinimg.com/736x/ed/e6/8c/ede68c983d3e6d2c49c71c8430a21051.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.7))),
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
              : _history.isEmpty
                  ? const Center(
                      child: Text(
                        'هنوز فالی نگرفته‌اید.',
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 100, left: 16, right: 16, bottom: 20),
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        final entry = _history[index];
                        final dateStr = intl.DateFormat('yyyy/MM/dd HH:mm').format(entry.timestamp);
                        return Card(
                          color: Colors.white.withOpacity(0.1),
                          margin: const EdgeInsets.only(bottom: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: const BorderSide(color: Colors.white24),
                          ),
                          child: ExpansionTile(
                            leading: const Icon(Icons.auto_awesome, color: Color(0xFFD4AF37)),
                            title: Text(
                              entry.typeTitle,
                              style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(dateStr, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                            childrenPadding: const EdgeInsets.all(16),
                            iconColor: Colors.white,
                            collapsedIconColor: Colors.white,
                            children: [
                              Text(
                                entry.resultTitle,
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              if (entry.resultPoem != null) ...[
                                Text(
                                  entry.resultPoem!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                                ),
                                const Divider(color: Colors.white24),
                              ],
                              Text(
                                entry.resultContent,
                                textAlign: TextAlign.justify,
                                style: const TextStyle(color: Colors.white, height: 1.5),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'توصیه: ${entry.resultAdvice}',
                                style: const TextStyle(color: Color(0xFFF9D423), fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ],
      ),
    );
  }
}
