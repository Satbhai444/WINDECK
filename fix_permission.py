import os

filepath = r"D:\WINDECK\android\lib\main.dart"

with open(filepath, "r", encoding="utf-8") as f:
    code = f.read()

# Replace the _requestNotificationPermission function
old_func = """  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isGranted || status.isPermanentlyDenied) return;

    final ctx = navigatorKey.currentContext;
    if (ctx == null || !mounted) return;

    await showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (dialogCtx) => Dialog(
        backgroundColor: const Color(0xFF161622),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0078d4).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_active_rounded, size: 40, color: Color(0xFF0078d4)),
              ),
              const SizedBox(height: 20),
              const Text(
                'Stay Connected',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Allow notifications to see your PC connection status directly in your notification drawer.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(dialogCtx);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Not Now', style: TextStyle(color: Colors.white60, fontSize: 15)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(dialogCtx);
                        await Permission.notification.request();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0078d4),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text('Enable Notifications', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }"""

new_func = """  Future<void> _requestNotificationPermission() async {
    final prefs = await SharedPreferences.getInstance();
    bool hasSeenPrompt = prefs.getBool('has_seen_notification_prompt') ?? false;
    
    // Check our shared preference AND the OS permission status
    final status = await Permission.notification.status;
    if (status.isGranted || status.isPermanentlyDenied || hasSeenPrompt) return;

    final ctx = navigatorKey.currentContext;
    if (ctx == null || !mounted) return;

    await showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (dialogCtx) => Dialog(
        backgroundColor: const Color(0xFF161622),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0078d4).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_active_rounded, size: 40, color: Color(0xFF0078d4)),
              ),
              const SizedBox(height: 20),
              const Text(
                'Stay Connected',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Allow notifications to see your PC connection status directly in your notification drawer.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        await prefs.setBool('has_seen_notification_prompt', true);
                        if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Not Now', style: TextStyle(color: Colors.white60, fontSize: 15)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await prefs.setBool('has_seen_notification_prompt', true);
                        if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                        await Permission.notification.request();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0078d4),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text('Enable', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }"""

code = code.replace(old_func, new_func)

# Also fix the withOpacity to withValues(alpha: x) since it's Flutter 3.12+ (which we did in new_func)
with open(filepath, "w", encoding="utf-8") as f:
    f.write(code)
