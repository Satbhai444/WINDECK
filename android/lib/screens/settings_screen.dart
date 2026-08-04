import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/connection_provider.dart';
import '../providers/pages_provider.dart';
import '../services/update_service.dart';

// ─── Main Settings Screen ─────────────────────────────────────────────────────
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '';
  bool _isCheckingForUpdate = false;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _version = info.version);
  }

  Future<void> _checkForUpdate() async {
    setState(() => _isCheckingForUpdate = true);
    final service = UpdateService();
    final update = await service.checkForUpdate();
    if (mounted) setState(() => _isCheckingForUpdate = false);

    if (update != null && mounted) {
      _showUpdateDialog(update);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You are on the latest version!')));
    }
  }

  void _showUpdateDialog(Map<String, dynamic> update) {
    bool isDownloading = false;
    double progress = 0.0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF161622),
          title: Text('Update Available: v${update['version']}', style: const TextStyle(color: Colors.white)),
          content: isDownloading
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Downloading update...', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(value: progress, backgroundColor: Colors.white12, color: const Color(0xFF0078d4)),
                  ],
                )
              : Text('A new version is available. Would you like to update now?\n\nChangelog:\n${update['changelog']}', style: const TextStyle(color: Colors.white70)),
          actions: [
            if (!isDownloading) TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Later', style: TextStyle(color: Colors.white54))),
            if (!isDownloading) ElevatedButton(
              onPressed: () async {
                setDialogState(() => isDownloading = true);
                try {
                  await UpdateService().downloadAndInstallUpdate(update['downloadUrl'], (p) {
                    setDialogState(() => progress = p);
                  });
                } catch (e) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Update failed.')));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0078d4)),
              child: const Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                  if (subtitle != null)
                    Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white.withValues(alpha: 0.25)),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 16, 0, 8),
    child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0078d4), letterSpacing: 1.5)),
  );

  @override
  Widget build(BuildContext context) {
    final conn = context.watch<ConnectionProvider>();
    final pages = context.watch<PagesProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0C0C14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Device name card
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 8, top: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF0078d4).withValues(alpha: 0.15), Colors.transparent],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF0078d4).withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: const Color(0xFF0078d4).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.phone_android_rounded, color: Color(0xFF0078d4), size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(conn.deviceName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('v$_version · ${conn.isConnected ? "Connected" : "Not Connected"}',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: Colors.white38, size: 18),
                    onPressed: () => _editDeviceName(context, conn),
                  ),
                ],
              ),
            ),

            if (conn.isConnected) ...[
              _sectionLabel('PREFERENCES'),
              _settingsTile(icon: Icons.tune_rounded, iconColor: Colors.orangeAccent, title: 'Preferences', subtitle: 'Haptics, sound, clipboard, auto-switch', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPreferencesScreen()))),

              _sectionLabel('PAGES'),
              _settingsTile(icon: Icons.layers_rounded, iconColor: Colors.purpleAccent, title: 'Manage Pages', subtitle: 'Rename, delete, or rearrange your deck pages', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsPagesScreen(pages: pages)))),
            ],

            _sectionLabel('PRIVACY & INFO'),
            _settingsTile(icon: Icons.shield_rounded, iconColor: Colors.greenAccent, title: 'Data & Privacy', subtitle: '100% local — no data leaves your network', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsDataPrivacyScreen()))),
            _settingsTile(icon: Icons.notifications_rounded, iconColor: const Color(0xFF0078d4), title: 'Notifications', subtitle: 'Connection and file alerts', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsNotificationsScreen()))),

            _sectionLabel('HELP & LEGAL'),
            _settingsTile(icon: Icons.help_rounded, iconColor: Colors.cyanAccent, title: 'How to Use', subtitle: 'Step-by-step guide to WinDeck', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsHelpScreen()))),
            _settingsTile(icon: Icons.gavel_rounded, iconColor: Colors.white54, title: 'Legal & Privacy Policy', subtitle: 'Terms, licenses, and policies', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsLegalScreen()))),

            _sectionLabel('ABOUT'),
            _settingsTile(icon: Icons.info_rounded, iconColor: const Color(0xFF0078d4), title: 'About & Credits', subtitle: 'Developer info, inspiration, tech used', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsAboutScreen()))),
            _settingsTile(
              icon: Icons.system_update_rounded, 
              iconColor: Colors.pinkAccent, 
              title: 'Check for Updates', 
              subtitle: _isCheckingForUpdate ? 'Checking...' : 'Check if a newer version is available', 
              onTap: _isCheckingForUpdate ? () {} : _checkForUpdate,
            ),

            const SizedBox(height: 24),
            Center(
              child: Text('WinDeck v$_version · Made with ❤️ for Windows', style: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }

  void _editDeviceName(BuildContext context, ConnectionProvider conn) {
    final ctrl = TextEditingController(text: conn.deviceName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161622),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Device Name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'e.g. My OnePlus',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true, fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () { conn.setDeviceName(ctrl.text.trim()); Navigator.pop(ctx); },
            child: const Text('Save', style: TextStyle(color: Color(0xFF0078d4), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ─── Preferences Sub-Screen ───────────────────────────────────────────────────
class SettingsPreferencesScreen extends StatelessWidget {
  const SettingsPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final conn = context.watch<ConnectionProvider>();
    return _SubScreen(
      title: 'Preferences',
      icon: Icons.tune_rounded,
      iconColor: Colors.orangeAccent,
      children: [
        _SubSection(label: 'FEEDBACK', children: [
          SwitchListTile(
            title: const Text('Haptic Feedback', style: TextStyle(color: Colors.white)),
            subtitle: Text('Vibrate on tile press', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
            value: conn.hapticsEnabled,
            activeThumbColor: Colors.orangeAccent,
            onChanged: (v) => conn.setHaptics(v),
          ),
          SwitchListTile(
            title: const Text('Sound Effects', style: TextStyle(color: Colors.white)),
            subtitle: Text('Play tap sounds', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
            value: conn.soundsEnabled,
            activeThumbColor: Colors.orangeAccent,
            onChanged: (v) => conn.setSounds(v),
          ),
        ]),
        _SubSection(label: 'SYNC', children: [
          SwitchListTile(
            title: const Text('Clipboard Auto-Sync', style: TextStyle(color: Colors.white)),
            subtitle: Text('Sync clipboard between phone and PC', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
            value: conn.clipboardSyncEnabled,
            activeThumbColor: Colors.orangeAccent,
            onChanged: (v) => conn.setClipboardSync(v),
          ),
          SwitchListTile(
            title: const Text('Context Auto-Switch', style: TextStyle(color: Colors.white)),
            subtitle: Text('Auto-switch pages based on active PC app', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
            value: conn.autoSwitchEnabled,
            activeThumbColor: Colors.orangeAccent,
            onChanged: (v) => conn.setAutoSwitch(v),
          ),
        ]),
      ],
    );
  }
}

// ─── Pages Sub-Screen ─────────────────────────────────────────────────────────
class SettingsPagesScreen extends StatefulWidget {
  final PagesProvider pages;
  const SettingsPagesScreen({super.key, required this.pages});

  @override
  State<SettingsPagesScreen> createState() => _SettingsPagesScreenState();
}

class _SettingsPagesScreenState extends State<SettingsPagesScreen> {
  @override
  Widget build(BuildContext context) {
    final pages = context.watch<PagesProvider>();
    return _SubScreen(
      title: 'Manage Pages',
      icon: Icons.layers_rounded,
      iconColor: Colors.purpleAccent,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: Text('Drag ≡ to reorder. Tap ✏️ to rename. Custom pages can be deleted.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
        ),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pages.pages.length,
          onReorder: (oldIndex, newIndex) {
            pages.reorderPage(oldIndex, newIndex);
          },
          itemBuilder: (context, index) {
            final page = pages.pages[index];
            final isCustom = page.type == 'custom';
            return Container(
              key: ValueKey(page.name + index.toString()),
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Row(
                children: [
                  ReorderableDragStartListener(
                    index: index,
                    child: Icon(Icons.drag_handle_rounded, color: Colors.white.withValues(alpha: 0.3), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      color: isCustom ? Colors.purpleAccent : const Color(0xFF0078d4),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(page.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
                        Text(page.type.toUpperCase(), style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 10, letterSpacing: 0.8)),
                      ],
                    ),
                  ),
                  if (isCustom) ...[
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, color: Colors.white38, size: 18),
                      onPressed: () => _renamePage(context, pages, index),
                      padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.delete_rounded, color: Colors.redAccent, size: 18),
                      onPressed: () => _deletePage(context, pages, index),
                      padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                    ),
                  ] else
                    Icon(Icons.lock_rounded, size: 14, color: Colors.white.withValues(alpha: 0.2)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _renamePage(BuildContext context, PagesProvider pages, int index) {
    final ctrl = TextEditingController(text: pages.pages[index].name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161622),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Rename Page', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl, autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'New page name', hintStyle: const TextStyle(color: Colors.white38),
            filled: true, fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () { if (ctrl.text.trim().isNotEmpty) pages.renamePage(index, ctrl.text.trim()); Navigator.pop(ctx); },
            child: const Text('Save', style: TextStyle(color: Color(0xFF0078d4), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _deletePage(BuildContext context, PagesProvider pages, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161622),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Page', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Delete "${pages.pages[index].name}"? This cannot be undone.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () { pages.deletePage(index); Navigator.pop(ctx); },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ─── Data & Privacy Sub-Screen ────────────────────────────────────────────────
class SettingsDataPrivacyScreen extends StatelessWidget {
  const SettingsDataPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _SubScreen(
      title: 'Data & Privacy',
      icon: Icons.shield_rounded,
      iconColor: Colors.greenAccent,
      children: [
        _PrivacyCard(icon: Icons.wifi_rounded, color: Colors.greenAccent, title: '100% Local & Offline', body: 'All communication happens directly between your PC and phone over your local Wi-Fi. WinDeck never uses the internet.'),
        _PrivacyCard(icon: Icons.analytics_outlined, color: Colors.greenAccent, title: 'No Data Collection', body: 'WinDeck collects zero analytics, usage data, crash reports, or personal information. Your layout and settings stay only on your device.'),
        _PrivacyCard(icon: Icons.share_outlined, color: Colors.greenAccent, title: 'No Third-Party Sharing', body: 'Your data is never shared with third parties. There are no ads, no tracking, and no telemetry services.'),
        _PrivacyCard(icon: Icons.folder_zip_outlined, color: const Color(0xFF0078d4), title: 'File Transfers Stay Local', body: 'Files sent via DropZone go directly over Wi-Fi — never through a cloud or external server.'),
      ],
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _PrivacyCard({required this.icon, required this.color, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 4),
                Text(body, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Notifications Sub-Screen ─────────────────────────────────────────────────
class SettingsNotificationsScreen extends StatefulWidget {
  const SettingsNotificationsScreen({super.key});

  @override
  State<SettingsNotificationsScreen> createState() => _SettingsNotificationsScreenState();
}

class _SettingsNotificationsScreenState extends State<SettingsNotificationsScreen> {
  bool _onConnect = true;
  bool _onDisconnect = true;
  bool _onFile = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
      _onConnect = prefs.getBool('notif_connect') ?? true;
      _onDisconnect = prefs.getBool('notif_disconnect') ?? true;
      _onFile = prefs.getBool('notif_file') ?? false;
    });
    }
  }

  Future<void> _save(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _handleToggle(String key, bool currentValue, Function(bool) updateState) async {
    if (currentValue) {
      // Trying to turn it ON
      var status = await Permission.notification.status;
      if (!status.isGranted) {
        status = await Permission.notification.request();
      }
      if (status.isGranted) {
        updateState(true);
        _save(key, true);
      } else {
        // Permission denied, can't turn on
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification permission is required.')));
        }
        updateState(false);
        _save(key, false);
      }
    } else {
      // Turning off
      updateState(false);
      _save(key, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SubScreen(
      title: 'Notifications',
      icon: Icons.notifications_rounded,
      iconColor: const Color(0xFF0078d4),
      children: [
        _SubSection(label: 'DEVICE EVENTS', children: [
          SwitchListTile(
            title: const Text('Device Connected', style: TextStyle(color: Colors.white)),
            subtitle: Text('Alert when a phone pairs successfully', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
            value: _onConnect,
            activeThumbColor: const Color(0xFF0078d4),
            onChanged: (v) => _handleToggle('notif_connect', v, (newVal) => setState(() => _onConnect = newVal)),
          ),
          SwitchListTile(
            title: const Text('Device Disconnected', style: TextStyle(color: Colors.white)),
            subtitle: Text('Alert when a paired phone disconnects', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
            value: _onDisconnect,
            activeThumbColor: const Color(0xFF0078d4),
            onChanged: (v) => _handleToggle('notif_disconnect', v, (newVal) => setState(() => _onDisconnect = newVal)),
          ),
        ]),
        _SubSection(label: 'FILE EVENTS', children: [
          SwitchListTile(
            title: const Text('File Received', style: TextStyle(color: Colors.white)),
            subtitle: Text('Alert when a file arrives from your phone', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
            value: _onFile,
            activeThumbColor: const Color(0xFF0078d4),
            onChanged: (v) => _handleToggle('notif_file', v, (newVal) => setState(() => _onFile = newVal)),
          ),
        ]),
      ],
    );
  }
}

// ─── Help Sub-Screen ──────────────────────────────────────────────────────────
class SettingsHelpScreen extends StatelessWidget {
  const SettingsHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _SubScreen(
      title: 'How to Use',
      icon: Icons.help_rounded,
      iconColor: Colors.cyanAccent,
      children: [
        _HelpStep(n: 1, title: 'Start the Server', body: 'Open WinDeck on your PC. Enter a room name and click "Start Server". A 6-digit Pairing Code will appear on the dashboard.'),
        _HelpStep(n: 2, title: 'Connect Your Phone', body: 'Open WinDeck on your Android phone. Both devices must be on the same Wi-Fi. The app will auto-discover your PC, or enter the Pairing Code manually.'),
        _HelpStep(n: 3, title: 'Build Your Layout', body: 'On the PC app, go to the Editor tab. Drag tiles (PC Apps, System Controls, Websites) onto the phone preview. Click "Save & Sync" — tiles appear on your phone instantly.'),
        _HelpStep(n: 4, title: 'Transfer Files (DropZone)', body: 'Phone → PC: Tap the DropZone tile, select a file — it lands in your PC\'s Downloads folder.\nPC → Phone: Click "Send to Phone" on the Dashboard, choose a file, and it opens on your phone.'),
        _HelpStep(n: 5, title: 'Use AirMouse', body: 'Tap the AirMouse tile on your phone. Drag anywhere on the touchpad to move the mouse. Tap to left-click, long press to right-click. Use the right strip to scroll.'),
        _HelpStep(n: 6, title: 'Rename Device', body: 'On the PC Dashboard, click the ✏️ icon next to your device name to give it a custom label. On the phone, go to Settings to change your phone\'s name.'),
        _HelpStep(n: 7, title: 'Features & Limitations', body: '• File Sharing: Supports all file types. Max size is virtually unlimited but relies on your local Wi-Fi speed and device RAM.\n• Connectivity: Requires a local network. Will not work on public Wi-Fi networks that block P2P connections.\n• Compatibility: PC app requires Windows 10/11. Phone app requires Android 5.0+.'),
      ],
    );
  }
}

class _HelpStep extends StatelessWidget {
  final int n;
  final String title;
  final String body;
  const _HelpStep({required this.n, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: const Color(0xFF0078d4), borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text('$n', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(body, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Legal Sub-Screen ─────────────────────────────────────────────────────────
class SettingsLegalScreen extends StatelessWidget {
  const SettingsLegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _SubScreen(
      title: 'Legal & Privacy',
      icon: Icons.gavel_rounded,
      iconColor: Colors.white54,
      children: [
        _LegalSection(title: 'Terms of Use', body: 'WinDeck is provided as-is for personal, non-commercial use. You agree not to reverse-engineer, redistribute, or use the software for any unlawful purpose. The developers are not liable for any damage, data loss, or security issues arising from use of this software.'),
        _LegalSection(title: 'Privacy Policy', body: 'WinDeck does not collect, store, or transmit any personal data to external parties. All data — including your device name, layout configuration, and transferred files — remains strictly on your local devices. WinDeck has no backend server, no database, and no user accounts.'),
        _LegalSection(title: 'Open Source Licenses', body: 'WinDeck is built using open-source technologies including Node.js, Electron, Flutter, Socket.IO, Express, and Tailwind CSS. Each carries its own respective open-source license. This product is not affiliated with or endorsed by any of these projects.'),
        _LegalSection(title: 'No Warranty', body: 'This software is provided without warranty of any kind, express or implied. Use at your own risk. Features may change, break, or be removed in future versions without notice.'),
      ],
    );
  }
}

class _LegalSection extends StatelessWidget {
  final String title;
  final String body;
  const _LegalSection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 6),
          Text(body, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12, height: 1.6)),
        ],
      ),
    );
  }
}

// ─── About & Credits Sub-Screen ───────────────────────────────────────────────
class SettingsAboutScreen extends StatelessWidget {
  const SettingsAboutScreen({super.key});

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return _SubScreen(
      title: 'About & Credits',
      icon: Icons.info_rounded,
      iconColor: const Color(0xFF0078d4),
      children: [
        // Developer Card
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF0078d4).withValues(alpha: 0.15), Colors.transparent],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF0078d4).withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('DEVELOPER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0078d4), letterSpacing: 1.5)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF0078d4), Color(0xFF2196F3)]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(child: Text('DS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16))),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Darshan Satbhai', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Flutter & React Developer\nPrompt Engineer & AI Specialist', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12, height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Social Links
              Wrap(
                spacing: 8, runSpacing: 8,
                children: [
                  _SocialBtn(icon: Icons.language_rounded, label: 'Portfolio', color: const Color(0xFF0078d4), onTap: () => _openUrl('https://www.daarshannexaa.in/')),
                  _SocialBtn(icon: Icons.code_rounded, label: 'GitHub', color: Colors.white70, onTap: () => _openUrl('https://github.com/satbhai444')),
                  _SocialBtn(icon: Icons.camera_alt_rounded, label: 'Instagram', color: Colors.pinkAccent, onTap: () => _openUrl('https://www.instagram.com/darshannn.0801')),
                  _SocialBtn(icon: Icons.work_rounded, label: 'LinkedIn', color: Colors.blueAccent, onTap: () => _openUrl('https://linkedin.com/in/darshan-satbhai')),
                ],
              ),
            ],
          ),
        ),

        // Inspiration
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('INSPIRATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Text(
                'WinDeck draws inspiration from PhoneDeck — a fantastic web-based tool that lets you use your phone as a stream deck. We love what they built.\n\nWinDeck takes a different approach: it runs fully offline, is open for customization, and targets Windows-native control rather than a browser-based experience.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 12, height: 1.6),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _openUrl('https://phonedeck.io'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.open_in_new_rounded, color: Color(0xFF0078d4), size: 14),
                    const SizedBox(width: 6),
                    Text('Visit phonedeck.io', style: const TextStyle(color: Color(0xFF0078d4), fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Built With
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('BUILT WITH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1.5)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: [
                  _TechChip(label: 'Flutter', icon: Icons.phone_android_rounded, color: Colors.cyanAccent),
                  _TechChip(label: 'Electron', icon: Icons.desktop_windows_rounded, color: Colors.blueAccent),
                  _TechChip(label: 'Socket.IO', icon: Icons.bolt_rounded, color: Colors.amberAccent),
                  _TechChip(label: 'Express.js', icon: Icons.cloud_rounded, color: Colors.greenAccent),
                  _TechChip(label: 'Tailwind CSS', icon: Icons.style_rounded, color: Colors.tealAccent),
                  _TechChip(label: 'Multer', icon: Icons.upload_rounded, color: Colors.orangeAccent),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        Center(child: Text('WinDeck v1.2.0 · © 2025 Darshan Satbhai', style: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 11))),
      ],
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _SocialBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _TechChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _TechChip({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: color.withValues(alpha: 0.85), fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─── Reusable Sub-Screen Shell ────────────────────────────────────────────────
class _SubScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;
  const _SubScreen({required this.title, required this.icon, required this.iconColor, required this.children});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0C14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      ),
    );
  }
}

class _SubSection extends StatelessWidget {
  final String label;
  final List<Widget> children;
  const _SubSection({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 0, 4),
          child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0078d4), letterSpacing: 1.5)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}
