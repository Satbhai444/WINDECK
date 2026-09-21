filepath = r"D:\WINDECK\android\lib\screens\discovery_screen.dart"
with open(filepath, "r", encoding="utf-8") as f:
    code = f.read()

old_post_frame = """      showModalBottomSheet(
        context: context,"""

new_post_frame = """      
      // Auto-trigger if OTP is provided
      if (autoOtp != null && autoOtp.length == 6) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _attemptPairing(server, autoOtp, (fn) {
            if (mounted) setState(fn);
          }, (success) {
            if (success) {
              if (mounted) setState(() { _showSuccessAnimation(); });
            } else {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('QR Pairing failed')));
            }
          });
        });
        return; // Don't show the dialog at all, just connect and navigate!
      }

      showModalBottomSheet(
        context: context,"""
code = code.replace(old_post_frame, new_post_frame)

with open(filepath, "w", encoding="utf-8") as f:
    f.write(code)
