filepath = r"D:\WINDECK\android\lib\screens\discovery_screen.dart"

with open(filepath, "r", encoding="utf-8") as f:
    code = f.read()

# Add import for qr scanner
code = code.replace("import '../providers/connection_provider.dart';", "import '../providers/connection_provider.dart';\nimport 'qr_scanner_screen.dart';")

# Add the button to the UI above the manual button
old_manual_btn_ui = """                                    child: Column(
                                      children: [
                                        TextButton.icon(
                                          onPressed: _showManualButton ? _showManualConnectDialog : null,"""

new_manual_btn_ui = """                                    child: Column(
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => const QrScannerScreen()),
                                            );
                                            if (result != null && result is Map<String, dynamic>) {
                                              // Perform pairing with QR data
                                              _showPairingDialog(
                                                {'name': result['name'] ?? 'PC via QR', 'ip': result['ip'], 'port': result['port'] ?? 3000},
                                                autoOtp: result['otp'].toString()
                                              );
                                            }
                                          },
                                          icon: const Icon(Icons.qr_code_scanner_rounded, size: 20, color: Colors.white),
                                          label: const Text('Scan QR to Connect', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF0078d4),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                            elevation: 8,
                                            shadowColor: const Color(0xFF0078d4).withOpacity(0.5),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        TextButton.icon(
                                          onPressed: _showManualButton ? _showManualConnectDialog : null,"""

code = code.replace(old_manual_btn_ui, new_manual_btn_ui)

# And if there ARE discovered servers, we should still show the QR scan button at the bottom!
old_list_ui = """                          },
                        ),
                ),
                const SizedBox(height: 16),"""

new_list_ui = """                          },
                        ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const QrScannerScreen()),
                      );
                      if (result != null && result is Map<String, dynamic>) {
                        _showPairingDialog(
                          {'name': result['name'] ?? 'PC via QR', 'ip': result['ip'], 'port': result['port'] ?? 3000},
                          autoOtp: result['otp'].toString()
                        );
                      }
                    },
                    icon: const Icon(Icons.qr_code_scanner_rounded, size: 18, color: Colors.white),
                    label: const Text('Scan QR instead', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0078d4).withOpacity(0.2),
                      foregroundColor: const Color(0xFF0078d4),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),"""

code = code.replace(old_list_ui, new_list_ui)


# Modify _showPairingDialog to accept autoOtp
old_dialog = """  void _showPairingDialog(Map<String, dynamic> server) {"""
new_dialog = """  void _showPairingDialog(Map<String, dynamic> server, {String? autoOtp}) {"""
code = code.replace(old_dialog, new_dialog)

# Set the initial text of the pin controller
old_controller = """    final TextEditingController pinController = TextEditingController();"""
new_controller = """    final TextEditingController pinController = TextEditingController(text: autoOtp ?? '');"""
code = code.replace(old_controller, new_controller)

with open(filepath, "w", encoding="utf-8") as f:
    f.write(code)
