import 'package:flutter/material.dart';
import 'horoscope_list_screen.dart';
import 'dream_interpretation_screen.dart';
import 'support_screen.dart';
import 'subscription_screen.dart';
import 'history_screen.dart';
import 'about_screen.dart';
import '../services/app_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _subStatus = '...';

  @override
  void initState() {
    super.initState();
    _loadSubStatus();
  }

  Future<void> _loadSubStatus() async {
    final status = await AppService.getSubscriptionRemainingDays();
    if (mounted) {
      setState(() {
        _subStatus = status;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('فال مانورا'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      drawer: _buildDrawer(context),
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
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          // Content
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
            child: Column(
              children: [
                _buildMenuCard(
                  context,
                  title: 'فال روزانه',
                  icon: Icons.wb_sunny,
                  color: const Color(0xFFF9D423),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HoroscopeListScreen(initialFilter: 'daily_horoscope'),
                      ),
                    ).then((_) => _loadSubStatus());
                  },
                ),
                const SizedBox(height: 20),
                _buildMenuCard(
                  context,
                  title: 'فال‌های هوشمند',
                  icon: Icons.auto_awesome,
                  color: const Color(0xFFb21f1f),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HoroscopeListScreen()),
                    ).then((_) => _loadSubStatus());
                  },
                ),
                const SizedBox(height: 20),
                _buildMenuCard(
                  context,
                  title: 'تعبیر خواب جامع',
                  icon: Icons.nightlight_round,
                  color: const Color(0xFF1a2a6c),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DreamInterpretationScreen()),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildMenuCard(
                  context,
                  title: 'فال اختصاصی',
                  icon: Icons.stars,
                  color: const Color(0xFFD4AF37),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SupportScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1a1a2e),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFFD4AF37),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_circle, size: 60, color: Color(0xFF1a1a2e)),
                const SizedBox(height: 10),
                const Text(
                  'کاربر فال مانورا',
                  style: TextStyle(color: Color(0xFF1a1a2e), fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'اشتراک: $_subStatus',
                  style: const TextStyle(color: Color(0xFF1a1a2e), fontSize: 14),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.payment,
            title: 'وضعیت و خرید اشتراک',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
              ).then((_) => _loadSubStatus());
            },
          ),
          _buildDrawerItem(
            icon: Icons.history,
            title: 'تاریخچه فال‌های من',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.info_outline,
            title: 'درباره برنامه',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
          const Divider(color: Colors.white24),
          _buildDrawerItem(
            icon: Icons.support_agent,
            title: 'ارتباط با ما',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SupportScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFD4AF37)),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
      onTap: onTap,
    );
  }

  Widget _buildMenuCard(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
