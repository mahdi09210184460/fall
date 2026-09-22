import 'package:flutter/material.dart';
import '../services/app_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String _status = '...';
  bool _isSubscribed = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final status = await AppService.getSubscriptionRemainingDays();
    final isSub = await AppService.isSubscribed();
    setState(() {
      _status = status;
      _isSubscribed = isSub;
    });
  }

  Future<void> _buySubscription() async {
    setState(() => _isProcessing = true);
    
    try {
      // Local subscription placeholder for Myket
      await AppService.subscribeLocally();
      await _checkStatus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('اشتراک شما با موفقیت فعال شد!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطا در برقراری اشتراک'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('اشتراک ماهانه'),
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
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.6))),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFD4AF37)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars, size: 80, color: Color(0xFFD4AF37)),
                    const SizedBox(height: 20),
                    const Text(
                      'اشتراک ویژه مانورا',
                      style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'وضعیت فعلی: $_status',
                      style: TextStyle(fontSize: 18, color: _isSubscribed ? Colors.greenAccent : Colors.redAccent),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'با خرید این اشتراک به مدت ۳۰ روز می‌توانید از تمامی فال‌ها (تاروت، حافظ، انبیا و...) بدون محدودیت و به صورت رایگان استفاده کنید.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 40),
                    if (!_isSubscribed)
                      _isProcessing 
                        ? const Column(
                            children: [
                              CircularProgressIndicator(color: Color(0xFFD4AF37)),
                              SizedBox(height: 10),
                              Text("در حال پردازش...", style: TextStyle(color: Colors.white)),
                            ],
                          )
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF37),
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            onPressed: _buySubscription,
                            child: const Text(
                              'خرید اشتراک (۷۵,۰۰۰ تومان)',
                              style: TextStyle(fontSize: 18, color: Color(0xFF1a1a2e), fontWeight: FontWeight.bold),
                            ),
                          )
                    else
                      const Text(
                        'اشتراک شما فعال است و می‌توانید از فال‌ها لذت ببرید.',
                        style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
