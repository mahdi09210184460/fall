import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('درباره برنامه'),
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
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: Color(0xFFD4AF37),
                    child: Icon(Icons.stars, size: 80, color: Color(0xFF1a1a2e)),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'فال مانورا',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
                  ),
                  const Text(
                    'نسخه ۱.۵.۰',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Text(
                      'اپلیکیشن فال مانورا، مرجع کامل و هوشمند انواع فال‌های باستانی و معاصر است. هدف ما ارائه لحظاتی سرشار از آرامش، خودشناسی و آگاهی به شماست. تمامی تفاسیر با دقت و ظرافت از معتبرترین منابع گردآوری شده‌اند.\n\nبا اشتراک ویژه مانورا، می‌توانید بدون هیچ محدودیتی به تمامی بخش‌های برنامه دسترسی داشته باشید و از خدمات اختصاصی ما بهره‌مند شوید.',
                      textAlign: TextAlign.justify,
                      style: TextStyle(color: Colors.white, fontSize: 18, height: 1.8),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'طراحی و توسعه توسط تیم مانورا',
                    style: TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
