import os

filepath = r"D:\WINDECK\android\lib\screens\discovery_screen.dart"

with open(filepath, "r", encoding="utf-8") as f:
    code = f.read()

# Add tutorial_coach_mark and shared_preferences imports
code = code.replace(
    "import 'package:lottie/lottie.dart';",
    "import 'package:lottie/lottie.dart';\nimport 'package:tutorial_coach_mark/tutorial_coach_mark.dart';\nimport 'package:shared_preferences/shared_preferences.dart';"
)

# Add GlobalKeys inside _DiscoveryScreenState
code = code.replace(
    "bool _isLoading = false;",
    "bool _isLoading = false;\n  final GlobalKey _headerKey = GlobalKey();\n  final GlobalKey _radarKey = GlobalKey();\n  TutorialCoachMark? _tutorialCoachMark;"
)

# Add showTutorial function and check in initState
init_state_replacement = """
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
    
    // Check for First Launch Tour
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowTutorial();
    });
  }
  
  Future<void> _checkAndShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    bool hasSeenSetupTour = prefs.getBool('windeck_setup_tour_done') ?? false;
    
    if (!hasSeenSetupTour && mounted) {
      _showTutorial();
      await prefs.setBool('windeck_setup_tour_done', true);
    }
  }

  void _showTutorial() {
    List<TargetFocus> targets = [
      TargetFocus(
        identify: "header",
        keyTarget: _headerKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Step 1: Open PC App",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Before continuing, make sure you have opened the WinDeck Server app on your Windows PC.\\n\\nCRITICAL: Both your PC and phone MUST be on the exact same Wi-Fi network. (Or connect your PC to your phone's Wi-Fi hotspot!).",
                    style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                  ),
                ],
              );
            },
          )
        ],
      ),
      TargetFocus(
        identify: "radar",
        keyTarget: _radarKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        shape: ShapeLightFocus.RRect,
        radius: 20,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Step 2: Connect via OTP",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Click 'Create Room' on your PC.\\nOnce your PC appears in this list below, tap it and enter the 6-digit OTP shown on your computer screen to pair securely.",
                    style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                  ),
                ],
              );
            },
          )
        ],
      ),
    ];

    _tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: const Color(0xFF0078d4),
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.85,
    )..show(context: context);
  }
"""

code = code.replace(
    """  @override
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
  }""",
    init_state_replacement
)

# Apply GlobalKeys to Widgets
# Header key to the column containing "win deck" and subtitle
code = code.replace(
    """const Text(
                  'win',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),""",
    """Container(
                  key: _headerKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                    ],
                  ),
                ),"""
)

# Remove the original "deck" text and subtitle since they are now in the Container
code = code.replace(
    """Text(
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
                ),""",
    ""
)

# Apply Radar key to the Expanded widget
code = code.replace(
    "Expanded(\n                  child: _discoveredServers.isEmpty",
    "Expanded(\n                  key: _radarKey,\n                  child: _discoveredServers.isEmpty"
)

with open(filepath, "w", encoding="utf-8") as f:
    f.write(code)
