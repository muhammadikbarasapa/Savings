import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/notification_service.dart';
import '../services/auth_services.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _notificationService = NotificationService();
  final _authService = AuthService();
  Map<String, bool> _notificationSettings = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _notificationService.getNotificationSettings();
    setState(() {
      _notificationSettings = settings;
      _isLoading = false;
    });
  }

  Future<void> _updateNotificationSetting(String key, bool value) async {
    setState(() {
      _notificationSettings[key] = value;
    });
    
    await _notificationService.saveNotificationSettings(_notificationSettings);
    
    // Apply settings
    if (key == 'daily_reminders' && value) {
      await _notificationService.scheduleDailyReminder();
    } else if (key == 'daily_reminders' && !value) {
      await _notificationService.cancelNotification(1);
    }
    
    if (key == 'monthly_reports' && value) {
      await _notificationService.scheduleMonthlyReport();
    } else if (key == 'monthly_reports' && !value) {
      await _notificationService.cancelNotification(2);
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Profile Section
                  _buildSectionCard(
                    'Profil Pengguna',
                    [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Icon(Icons.person, color: Colors.blue.shade700),
                        ),
                        title: Text(user?.displayName ?? 'User'),
                        subtitle: Text(user?.email ?? ''),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // Navigate to profile edit screen
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Notification Settings Section
                  _buildSectionCard(
                    'Notifikasi',
                    [
                      _buildNotificationTile(
                        'Pengingat Harian',
                        'Mengingatkan untuk mencatat transaksi harian',
                        'daily_reminders',
                        Icons.schedule,
                      ),
                      _buildNotificationTile(
                        'Peringatan Budget',
                        'Memberitahu ketika budget hampir habis',
                        'budget_alerts',
                        Icons.account_balance_wallet,
                      ),
                      _buildNotificationTile(
                        'Pengingat Tujuan',
                        'Mengingatkan tentang tujuan tabungan',
                        'goal_reminders',
                        Icons.flag,
                      ),
                      _buildNotificationTile(
                        'Laporan Bulanan',
                        'Mengirim laporan keuangan bulanan',
                        'monthly_reports',
                        Icons.analytics,
                      ),
                      _buildNotificationTile(
                        'Pencapaian',
                        'Memberitahu tentang pencapaian finansial',
                        'achievements',
                        Icons.emoji_events,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // App Settings Section
                  _buildSectionCard(
                    'Pengaturan Aplikasi',
                    [
                      ListTile(
                        leading: Icon(Icons.palette, color: Colors.blue.shade700),
                        title: const Text('Tema'),
                        subtitle: const Text('Light Mode'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // Navigate to theme settings
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.language, color: Colors.blue.shade700),
                        title: const Text('Bahasa'),
                        subtitle: const Text('Bahasa Indonesia'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // Navigate to language settings
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.backup, color: Colors.blue.shade700),
                        title: const Text('Backup & Restore'),
                        subtitle: const Text('Cadangkan data Anda'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // Navigate to backup settings
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // About Section
                  _buildSectionCard(
                    'Tentang',
                    [
                      ListTile(
                        leading: Icon(Icons.info, color: Colors.blue.shade700),
                        title: const Text('Versi Aplikasi'),
                        subtitle: const Text('1.0.0'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // Show version info
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.help, color: Colors.blue.shade700),
                        title: const Text('Bantuan & FAQ'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // Navigate to help screen
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.privacy_tip, color: Colors.blue.shade700),
                        title: const Text('Kebijakan Privasi'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // Navigate to privacy policy
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Logout Section
                  _buildSectionCard(
                    'Akun',
                    [
                      ListTile(
                        leading: Icon(Icons.logout, color: Colors.red.shade700),
                        title: const Text('Keluar'),
                        subtitle: const Text('Keluar dari akun Anda'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          _showLogoutDialog();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile(String title, String subtitle, String key, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade700),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: _notificationSettings[key] ?? false,
        onChanged: (value) => _updateNotificationSetting(key, value),
        activeColor: Colors.blue,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Keluar'),
          content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }
}
