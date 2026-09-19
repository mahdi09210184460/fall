import 'dart:math';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/horoscope.dart';
import '../models/horoscope_history.dart';
import '../data/horoscope_data.dart';
import '../services/app_service.dart';
import 'subscription_screen.dart';

class HoroscopeDetailScreen extends StatefulWidget {
  final HoroscopeType type;

  const HoroscopeDetailScreen({super.key, required this.type});

  @override
  State<HoroscopeDetailScreen> createState() => _HoroscopeDetailScreenState();
}

class _HoroscopeDetailScreenState extends State<HoroscopeDetailScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _motherNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _calculateAbjad(String text) {
    const abjadMap = {
      'ا': 1, 'آ': 1, 'ب': 2, 'پ': 2, 'ج': 3, 'چ': 3, 'د': 4, 'ه': 5, 'و': 6, 'ز': 7, 'ژ': 7, 'ح': 8,
      'ط': 9, 'ی': 10, 'ک': 20, 'گ': 20, 'ل': 30, 'م': 40, 'ن': 50, 'س': 60, 'ع': 70, 'ف': 80,
      'ص': 90, 'ق': 100, 'ر': 200, 'ش': 300, 'ت': 400, 'ث': 500, 'خ': 600, 'ذ': 700, 'ض': 800,
      'ظ': 900, 'غ': 1000,
    };

    int sum = 0;
    for (int i = 0; i < text.length; i++) {
      String char = text[i];
      sum += abjadMap[char] ?? 0;
    }
    return sum;
  }

  Future<void> _showResult(BuildContext context) async {
    try {
      debugPrint('Processing horoscope for: ${widget.type.id}');
      
      // Check subscription / free use
      final canUse = await AppService.canUseHoroscope(widget.type.id);
      if (!canUse) {
        if (!context.mounted) return;
        _showSubscriptionPrompt(context);
        return;
      }

      if (widget.type.id == 'person_name' || widget.type.id == 'parent_names') {
        if (!_formKey.currentState!.validate()) return;
      }

      final results = horoscopeResults[widget.type.id] ?? [];
      if (results.isEmpty) {
        throw Exception("دیتای فال برای این بخش یافت نشد.");
      }

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.indigo.shade900.withOpacity(0.9),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFFD4AF37)),
              SizedBox(height: 20),
              Text('در حال تفأل و تفسیر...', style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
        ),
      );

      // Simulate thinking/searching
      await Future.delayed(const Duration(seconds: 2));
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading

      // For name-based horoscopes, use Abjad to pick a result
      int index;
      if (widget.type.id == 'person_name') {
        int abjad = _calculateAbjad(_nameController.text);
        index = abjad % results.length;
      } else if (widget.type.id == 'parent_names') {
        int abjad = _calculateAbjad(_nameController.text) + _calculateAbjad(_motherNameController.text);
        index = abjad % results.length;
      } else {
        index = Random().nextInt(results.length);
      }

      final result = results[index];

      // Mark as used if not subscribed
      if (!(await AppService.isSubscribed())) {
        await AppService.markAsUsed(widget.type.id);
      }

      // Save to history
      await AppService.addToHistory(HoroscopeHistoryEntry(
        typeId: widget.type.id,
        typeTitle: widget.type.title,
        resultTitle: result.title,
        resultContent: result.content,
        resultAdvice: result.advice,
        resultPoem: result.poem,
        timestamp: DateTime.now(),
      ));

      if (!context.mounted) return;
      _showResultDialog(context, result);
    } catch (e) {
      debugPrint("Error in _showResult: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در دریافت فال: $e'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    }
  }

  void _showSubscriptionPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 2),
        ),
        title: const Text('پایان استفاده رایگان', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFD4AF37))),
        content: const Text(
          'شما یکبار به صورت رایگان از این فال استفاده کرده‌اید. برای استفاده مجدد و دسترسی نامحدود به تمام فال‌ها، لطفاً اشتراک ویژه تهیه کنید.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('بعداً', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionScreen()));
            },
            child: const Text('خرید اشتراک', style: TextStyle(color: Color(0xFF1a1a2e))),
          ),
        ],
      ),
    );
  }

  void _showResultDialog(BuildContext context, HoroscopeResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 2),
        ),
        title: Text(
          result.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFD4AF37),
            fontSize: 24,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (result.poem != null) ...[
                Text(
                  result.poem!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    color: Colors.white70,
                    height: 1.8,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Divider(color: Color(0xFFD4AF37), thickness: 1),
                ),
              ],
              Text(
                result.content,
                textAlign: TextAlign.justify,
                style: const TextStyle(fontSize: 18, color: Colors.white, height: 1.5),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'توصیه: ${result.advice}',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Color(0xFFF9D423),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final String resultText = '${result.title}\n\n'
                  '${result.poem != null ? "${result.poem}\n\n" : ""}'
                  '${result.content}\n\n'
                  'توصیه: ${result.advice}';
              final String shareMessage = 'فال من در اپلیکیشن فال مانورا:\n'
                  '$resultText\n\n'
                  'آیدی ما: @manora_astrology';
              Share.share(shareMessage);
            },
            child: const Text('اشتراک‌گذاری', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 18)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('بستن', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 18)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isNameBased = widget.type.id == 'person_name' || widget.type.id == 'parent_names';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type.title),
        backgroundColor: const Color(0xFF1a1a2e),
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
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          // Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(widget.type.icon, style: const TextStyle(fontSize: 100)),
                  const SizedBox(height: 20),
                  Text(
                    widget.type.title,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD4AF37),
                      shadows: [Shadow(color: Colors.black, blurRadius: 5)],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      widget.type.description,
                      textAlign: TextAlign.justify,
                      style: const TextStyle(
                        fontSize: 19,
                        height: 1.8,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (isNameBased) ...[
                    _buildNameField(_nameController, 'نام شما'),
                    if (widget.type.id == 'parent_names') ...[
                      const SizedBox(height: 15),
                      _buildNameField(_motherNameController, 'نام مادر شما'),
                    ],
                  ],
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: () => _showResult(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD4AF37), Color(0xFFF9D423)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4AF37).withOpacity(0.5),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Text(
                        'دریافت فال',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1a1a2e),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white, fontSize: 18),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFD4AF37)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white38),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFD4AF37)),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
      validator: (value) => value == null || value.isEmpty ? 'لطفاً $label را وارد کنید' : null,
    );
  }
}
