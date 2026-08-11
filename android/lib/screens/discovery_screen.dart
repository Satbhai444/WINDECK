import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../providers/connection_provider.dart';
import '../services/discovery_service.dart';
import '../globals.dart';
import 'settings_screen.dart';


class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class RadarAnimation extends StatelessWidget {
  const RadarAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Lottie.asset('assets/animations/radar.json'),
    );
  }
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  final DiscoveryService _discoveryService = DiscoveryService();
  final List<Map<String, dynamic>> _discoveredServers = [];
  bool _showManualButton = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startDiscovery();
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showManualButton = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _discoveryService.stopDiscovery();
    super.dispose();
  }

  Future<void> _startDiscovery() async {
    await _discoveryService.startDiscovery((ip, port, name) {
      if (mounted) {
        setState(() {
          if (!_discoveredServers.any((s) => s['ip'] == ip)) {
            _discoveredServers.add({
              'name': name,
              'ip': ip,
              'port': port,
              'type': 'windeck-server',
            });
          }
        });
      }
    });
  }

  String _decodeRoomIdToIp(String roomId) {
    final clean = roomId.replaceAll('-', '').trim().toUpperCase().replaceAll('O', '0').replaceAll('I', '1');
    if (clean.length != 8) return '';
    try {
      final p1 = int.parse(clean.substring(0, 2), radix: 16);
      final p2 = int.parse(clean.substring(2, 4), radix: 16);
      final p3 = int.parse(clean.substring(4, 6), radix: 16);
      final p4 = int.parse(clean.substring(6, 8), radix: 16);
      return '$p1.$p2.$p3.$p4';
    } catch (e) {
      return '';
    }
  }

  void _showManualConnectDialog() {
    final TextEditingController ipController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161622),
        title: const Text('Enter IP Manually', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the IP address of your PC.', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: ipController,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'e.g. 192.168.1.100',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
                filled: true,
                fillColor: Colors.black38,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              final ip = ipController.text.trim();
              Navigator.pop(context);
              if (ip.isNotEmpty) {
                _showPairingDialog({'name': 'Manual Connect', 'ip': ip, 'port': 3000});
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid IP Address.')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0078d4)),
            child: const Text('Connect', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPairingDialog(Map<String, dynamic> server) {
    final TextEditingController pinController = TextEditingController();
    final FocusNode pinFocusNode = FocusNode();
    _isLoading = false;
    _errorMessage = null;
    bool isSuccess = false;
    bool isError = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final String pinText = pinController.text;

            return GestureDetector(
              onTap: () => pinFocusNode.requestFocus(),
              child: Container(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 24,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF161622),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  border: Border(
                    top: BorderSide(color: Colors.white10, width: 1),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Connect to ${server['name']}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter the 6-digit pairing code shown on your PC screen.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),

                    // Hidden TextField for Keyboard Input
                    Stack(
                      children: [
                        Opacity(
                          opacity: 0.0,
                          child: TextField(
                            controller: pinController,
                            focusNode: pinFocusNode,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            autofocus: true,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            onChanged: (val) {
                              setModalState(() {
                                isError = false;
                                _errorMessage = null;
                              });
                              if (val.length == 6 && !_isLoading && !isSuccess) {
                                _attemptPairing(server, val, setModalState, (success) {
                                  setModalState(() {
                                    if (success) {
                                      isSuccess = true;
                                      isError = false;
                                    } else {
                                      isSuccess = false;
                                      isError = true;
                                    }
                                  });
                                });
                              }
                            },
                          ),
                        ),

                        // 6 PIN Input Boxes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (index) {
                            final char = index < pinText.length ? pinText[index] : '';
                            final isCurrent = index == pinText.length && pinFocusNode.hasFocus;

                            Color boxBgColor = Colors.black38;
                            Color borderColor = Colors.white10;
                            List<BoxShadow> glow = [];

                            if (isSuccess) {
                              boxBgColor = Colors.greenAccent.withValues(alpha: 0.15);
                              borderColor = Colors.greenAccent;
                              glow = [
                                BoxShadow(
                                  color: Colors.greenAccent.withValues(alpha: 0.6),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                )
                              ];
                            } else if (isError) {
                              boxBgColor = Colors.redAccent.withValues(alpha: 0.15);
                              borderColor = Colors.redAccent;
                              glow = [
                                BoxShadow(
                                  color: Colors.redAccent.withValues(alpha: 0.6),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                )
                              ];
                            } else if (isCurrent) {
                              boxBgColor = const Color(0xFF0078d4).withValues(alpha: 0.15);
                              borderColor = const Color(0xFF0078d4);
                              glow = [
                                BoxShadow(
                                  color: const Color(0xFF0078d4).withValues(alpha: 0.5),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                )
                              ];
                            } else if (char.isNotEmpty) {
                              borderColor = Colors.white38;
                            }

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 44,
                              height: 54,
                              decoration: BoxDecoration(
                                color: boxBgColor,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: borderColor, width: (isSuccess || isError || isCurrent) ? 2 : 1),
                                boxShadow: glow,
                              ),
                              child: Center(
                                child: Text(
                                  char,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: isSuccess
                                        ? Colors.greenAccent
                                        : isError
                                            ? Colors.redAccent
                                            : Colors.white,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Make sure both PC & Phone app versions match.',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading || pinController.text.length < 6 || isSuccess
                          ? null
                          : () => _attemptPairing(server, pinController.text, setModalState, (success) {
                                setModalState(() {
                                  if (success) {
                                    isSuccess = true;
                                    isError = false;
                                  } else {
                                    isSuccess = false;
                                    isError = true;
                                  }
                                });
                              }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSuccess ? Colors.greenAccent : const Color(0xFF0078d4),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.white10,
                        disabledForegroundColor: Colors.white30,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isSuccess ? 'Connected!' : 'Connect Device',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
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

  void _attemptPairing(
      Map<String, dynamic> server,
      String pin,
      StateSetter setModalState,
      Function(bool success) onStateResult) async {
    setModalState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    final conn = context.read<ConnectionProvider>();
    
    // Connect to the Socket server first
    final connected = await conn.connect(server['ip'], server['port'], autoAuth: false);
    
    if (!connected) {
      onStateResult(false);
      setModalState(() {
        _isLoading = false;
        _errorMessage = 'Connection timed out. Check Room ID, Wi-Fi, and that both app versions match.';
      });
      return;
    }
    
    conn.authenticate(pin, 'Android Phone', (success, error) async {
      onStateResult(success);
      if (success) {
        setModalState(() {
          _isLoading = false;
        });
        // Brief pause so user sees the Green Glow
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) {
          Navigator.pop(context); // Close bottom sheet
          _showSuccessAnimation();
        }
      } else {
        setModalState(() {
          _isLoading = false;
          _errorMessage = error ?? 'Pairing failed. Please try again.';
        });
      }
    });
  }

  void _showSuccessAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0xFF0A0A12).withValues(alpha: 0.95),
      builder: (ctx) {
        // Auto-navigate after animation plays
        Future.delayed(const Duration(milliseconds: 2500), () {
          if (mounted) {
            Navigator.of(ctx).pop();
            Navigator.pushReplacementNamed(context, '/home');
          }
        });
        
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/connected_success.json',
                width: 220,
                height: 220,
                repeat: false,
              ),
              const SizedBox(height: 24),
              const Text(
                'Connected!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your PC is now linked',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _connectDirectly(Map<String, dynamic> data) async {
    setState(() => _isLoading = true);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator(color: Color(0xFF0078d4))),
    );

    final conn = context.read<ConnectionProvider>();
    final connected = await conn.connect(data['ip'], data['port'], autoAuth: false);

    if (!connected) {
      if (mounted) {
        Navigator.pop(context); // close loading dialog
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connection failed. Please check Wi-Fi.')));
      }
      return;
    }

    conn.authenticate(data['otp'].toString(), 'Android Phone', (success, error) {
      if (mounted) {
        Navigator.pop(context); // close loading dialog
        setState(() => _isLoading = false);
        if (success) {
          _showSuccessAnimation();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Pairing failed')));
        }
      }
    });
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161622),
        title: const Text('Exit WinDeck?', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to exit the application?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No', style: TextStyle(color: Colors.cyan)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161622),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('How to Connect', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('1. Ensure your Phone and PC are on the same Wi-Fi network.', style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 12),
            const Text('2. Open the WinDeck app on your PC.', style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 12),
            const Text('3. Tap your PC name here to connect.', style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0078d4).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF0078d4).withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Don\'t have the PC app yet?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  const Text('Download it from our official website:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {},
                    child: const Text('https://www.daarshannexaa.in', style: TextStyle(color: Color(0xFF0078d4), fontSize: 13, decoration: TextDecoration.underline)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it', style: TextStyle(color: Color(0xFF0078d4), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFF0C0C14),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.info_outline_rounded, color: Colors.white54),
                      onPressed: _showInfoDialog,
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_rounded, color: Colors.white54),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'win',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  'deck',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0078d4),
                    height: 0.8,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Make sure your PC app is open and connected to the same Wi-Fi network.',
                  style: TextStyle(fontSize: 14, color: Colors.white54, height: 1.4),
                ),
                const SizedBox(height: 48),
                const Text(
                  'DISCOVERED COMPUTERS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white30,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _discoveredServers.isEmpty
                      ? Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Lottie.asset('assets/animations/radar.lottie', width: 200, height: 200, fit: BoxFit.contain),
                                const SizedBox(height: 20),
                                Text(
                                  'Searching for your PC...',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 15, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 24),
                                AnimatedOpacity(
                                  opacity: _showManualButton ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 500),
                                  child: Column(
                                    children: [
                                      TextButton.icon(
                                        onPressed: _showManualButton ? _showManualConnectDialog : null,
                                        icon: const Icon(Icons.edit_rounded, size: 18),
                                        label: const Text('Can\'t find your PC? Enter IP manually'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: const Color(0xFF0078d4),
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                          backgroundColor: const Color(0xFF0078d4).withValues(alpha: 0.1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _discoveredServers.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final server = _discoveredServers[index];
                            return Material(
                              color: Colors.transparent,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.02),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  leading: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0078d4).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(Icons.desktop_windows_rounded, color: Color(0xFF0078d4)),
                                  ),
                                  title: Text(
                                    server['name'] ?? 'Windows PC',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    'Tap to connect',
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white30),
                                  onTap: () => _showPairingDialog(server),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                Center(child: Text('v${Globals.appVersion}', style: const TextStyle(color: Colors.white30, fontSize: 10, letterSpacing: 1))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
