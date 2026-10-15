import 'package:flutter/material.dart';
import '../dialogs/achievements_dialog.dart';
import '../dialogs/shop_dialog.dart';
import '../dialogs/themes_dialog.dart';
import '../models/game_theme.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import 'game_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedTabIndex = 0;
  final StorageService _storage = StorageService();
  final AudioService _audio = AudioService();
  GameTheme _currentTheme = GameTheme.classicPorcelain;

  void _openGame(int level) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          initialLevel: level,
          theme: _currentTheme,
        ),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedTabIndex,
          children: [
            _buildMainTab(),
            _buildDailyTab(),
            _buildMeTab(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedTabIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedTabIndex = index;
            });
          },
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFEFF6FF),
          elevation: 0,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: Color(0xFF64748B)),
              selectedIcon: Icon(Icons.home_rounded, color: Color(0xFF2563EB)),
              label: 'Main',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined, color: Color(0xFF64748B)),
              selectedIcon: Icon(Icons.calendar_month_rounded, color: Color(0xFF2563EB)),
              label: 'Daily',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded, color: Color(0xFF64748B)),
              selectedIcon: Icon(Icons.person_rounded, color: Color(0xFF2563EB)),
              label: 'Me',
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // TAB 1: MAIN (HOME) - Matching Video 00:32 & 01:06
  // ----------------------------------------------------
  Widget _buildMainTab() {
    return Stack(
      children: [
        // Subtle diagonal watermark arrows in background
        Positioned.fill(
          child: CustomPaint(
            painter: _BackgroundWatermarkPainter(),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Top Bar: Coins & Themes button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => ShopDialog(
                          theme: _currentTheme,
                          onUpdated: () => setState(() {}),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.monetization_on_rounded, color: Color(0xFFFFB800), size: 18),
                          const SizedBox(width: 6),
                          Text(
                            '${_storage.coins}',
                            style: const TextStyle(
                              color: Color(0xFF1E293B),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => ThemesDialog(
                          currentTheme: _currentTheme,
                          onSelectTheme: (t) {
                            setState(() {
                              _currentTheme = t;
                            });
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.palette_outlined, color: Color(0xFF64748B)),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Top Banner: Daily Challenge Card (as seen in video 00:33, 01:06)
              Container(
                width: 170,
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF389BFF), Color(0xFF1E75EB)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E75EB).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.calendar_today_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'DAILY CHALLENGE',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'October 15',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () => _openGame(15),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1E75EB),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        child: const Text('Play', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Big Center Title: "Arrow Puzzle" (matching video 00:32)
              const Text(
                'Arrow Puzzle',
                style: TextStyle(
                  color: Color(0xFF1B243B),
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),

              const Spacer(),

              // Bottom Button: "New Game" with "Level X"
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => _openGame(_storage.currentLevel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 4,
                    shadowColor: const Color(0xFF2563EB).withOpacity(0.4),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'New Game',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Level ${_storage.currentLevel}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------
  // TAB 2: DAILY CHALLENGES - Matching Video 00:36
  // ----------------------------------------------------
  Widget _buildDailyTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Column(
        children: [
          // Header Card with Trophy
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
                    ),
                    const Text(
                      'Daily Challenges',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Icon(
                  Icons.emoji_events_rounded,
                  size: 72,
                  color: Color(0xFFFFD700),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Month and Stars
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'October 2026',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: const [
                  Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 20),
                  SizedBox(width: 4),
                  Text(
                    '0/31',
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Days of Week Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((d) => SizedBox(
                      width: 32,
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),

          const SizedBox(height: 8),

          // Calendar Grid
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: 31,
              itemBuilder: (context, index) {
                final day = index + 1;
                final isCurrentDay = day == 15;

                return Center(
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isCurrentDay ? const Color(0xFF2563EB) : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$day',
                        style: TextStyle(
                          color: isCurrentDay ? Colors.white : const Color(0xFF64748B),
                          fontWeight: isCurrentDay ? FontWeight.bold : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Play Daily Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => _openGame(15),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Play', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // TAB 3: ME (PROFILE & SETTINGS) - Matching Video 00:39
  // ----------------------------------------------------
  Widget _buildMeTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      children: [
        _buildMeTile(
          icon: Icons.emoji_events_rounded,
          iconBgColor: const Color(0xFFFFFBEB),
          iconColor: const Color(0xFFF59E0B),
          title: 'Awards',
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => AchievementsDialog(theme: _currentTheme),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildMeTile(
          icon: Icons.sports_esports_rounded,
          iconBgColor: const Color(0xFFF0FDF4),
          iconColor: const Color(0xFF16A34A),
          title: 'Achievements',
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => AchievementsDialog(theme: _currentTheme),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildMeTile(
          icon: Icons.settings_rounded,
          iconBgColor: const Color(0xFFEFF6FF),
          iconColor: const Color(0xFF2563EB),
          title: 'Settings',
          onTap: _showSettingsSheet,
        ),
        const SizedBox(height: 12),
        _buildMeTile(
          icon: Icons.help_outline_rounded,
          iconBgColor: const Color(0xFFF0FDF4),
          iconColor: const Color(0xFF22C55E),
          title: 'Help',
          onTap: () => _showSimpleDialog('Help & Support', 'How to Play:\nTap free arrows to slide them off the board.\nAvoid tapping blocked arrows!\nUse hints or erasers if you get stuck.'),
        ),
        const SizedBox(height: 12),
        _buildMeTile(
          icon: Icons.info_outline_rounded,
          iconBgColor: const Color(0xFFF8FAFC),
          iconColor: const Color(0xFF64748B),
          title: 'About Game',
          onTap: () => _showSimpleDialog('About Game', 'ArrowFlow v1.0.0\nPure Flutter native puzzle game.\nFollows official PRD specifications.'),
        ),
        const SizedBox(height: 12),
        _buildMeTile(
          icon: Icons.description_outlined,
          iconBgColor: const Color(0xFFFAF5FF),
          iconColor: const Color(0xFF9333EA),
          title: 'Privacy Rights',
          onTap: () => _showSimpleDialog('Privacy Rights', 'ArrowFlow respects your privacy. Offline first with no personal tracking.'),
        ),
        const SizedBox(height: 12),
        _buildMeTile(
          icon: Icons.shield_outlined,
          iconBgColor: const Color(0xFFECFEFF),
          iconColor: const Color(0xFF0891B2),
          title: 'Privacy Preferences',
          onTap: () => _showSimpleDialog('Privacy Preferences', 'Manage your advertising and analytics preferences at any time.'),
        ),
        const SizedBox(height: 12),
        _buildMeTile(
          icon: Icons.block_rounded,
          iconBgColor: const Color(0xFFFEF2F2),
          iconColor: const Color(0xFFDC2626),
          title: 'Remove Ads',
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => ShopDialog(
                theme: _currentTheme,
                onUpdated: () => setState(() {}),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMeTile({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
      ),
    );
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Settings',
                          style: TextStyle(
                            color: Color(0xFF1E293B),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Sounds', style: TextStyle(fontWeight: FontWeight.w600)),
                      value: _audio.soundEnabled,
                      activeColor: const Color(0xFF2563EB),
                      onChanged: (val) {
                        setSheetState(() => _audio.soundEnabled = val);
                        setState(() {});
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Vibration', style: TextStyle(fontWeight: FontWeight.w600)),
                      value: _audio.vibrationEnabled,
                      activeColor: const Color(0xFF2563EB),
                      onChanged: (val) {
                        setSheetState(() => _audio.vibrationEnabled = val);
                        setState(() {});
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Auto-Lock', style: TextStyle(fontWeight: FontWeight.w600)),
                      value: false,
                      activeColor: const Color(0xFF2563EB),
                      onChanged: (val) {},
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSimpleDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
          ),
        ],
      ),
    );
  }
}

class _BackgroundWatermarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final arrowPaint = Paint()
      ..color = const Color(0xFFF1F5F9).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path1 = Path();
    path1.moveTo(-size.width * 0.2, size.height * 0.3);
    path1.lineTo(size.width * 0.6, size.height * 0.1);
    canvas.drawPath(path1, arrowPaint);

    final path2 = Path();
    path2.moveTo(size.width * 0.3, size.height * 0.85);
    path2.lineTo(size.width * 1.2, size.height * 0.6);
    canvas.drawPath(path2, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
