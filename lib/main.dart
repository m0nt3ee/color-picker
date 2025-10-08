import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Window.initialize();

  await Window.setEffect(effect: WindowEffect.mica, dark: true);

  HotKey hotKey = HotKey(
    key: PhysicalKeyboardKey.keyQ,
    modifiers: [HotKeyModifier.alt],
    scope: HotKeyScope.system,
  );
  await hotKeyManager.register(
    hotKey,
    keyDownHandler: (hotKey) async {
      await windowManager.focus();
      print("keydown");
    },
  );

  runApp(const Homepage());
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => HomepageState();
}

class HomepageState extends State<Homepage> {
  static const platform = MethodChannel('com.example.colorpicker');
  bool inUse = false;

  Color pickedColor = Colors.white;
  Map<String, String>? rgbValue;

  Future<void> pickColor() async {
    setState(() {
      inUse = true;
    });
    try {
      final Map<dynamic, dynamic>? color = await platform.invokeMethod(
        'pickColor',
      );

      if (color != null) {
        int r = color['r'];
        int g = color['g'];
        int b = color['b'];
        rgbValue = {'r': r.toString(), 'g': g.toString(), 'b': b.toString()};

        pickedColor = Color.fromARGB(255, r, g, b);
      }
    } on PlatformException catch (e) {
      Exception(e);
    }
    setState(() {
      inUse = false;
    });
  }

  bool isHoveredPick = false;
  bool isHoveredCopyRGB = false;
  bool isHoveredCopyHex = false;
  bool isHoveredCopyHsl = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Colors.transparent),
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SizedBox(
            width: 450,
            height: 300,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "🎨 Color picker v1.0",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              "Author: m0nt3ee",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: MouseRegion(
                            onEnter: (event) => setState(() {
                              isHoveredPick = true;
                            }),
                            onExit: (event) => setState(() {
                              isHoveredPick = false;
                            }),
                            child: Container(
                              decoration: BoxDecoration(
                                color: inUse
                                    ? const Color.fromARGB(255, 15, 152, 206)
                                    : (isHoveredPick
                                          ? const Color.fromARGB(
                                              64,
                                              255,
                                              255,
                                              255,
                                            )
                                          : Colors.transparent),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5),
                                ),
                              ),
                              child: ElevatedButton(
                                onPressed: pickColor,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  overlayColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text("🖌️ Pick color     "),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 75,
                              width: 75,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: Colors.black,
                                  ),
                                  color: pickedColor,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    rgbValue == null
                                        ? "R: 255 G: 255 B: 255"
                                        : ("RGB: ${rgbValue!['r']}, ${rgbValue!['g']}, ${rgbValue!['b']}"),
                                    style: TextStyle(color: Colors.white),
                                    overflow: TextOverflow.clip,
                                    softWrap: false,
                                  ),
                                  SizedBox(width: 4),
                                  MouseRegion(
                                    onEnter: (event) => setState(() {
                                      isHoveredCopyRGB = true;
                                    }),
                                    onExit: (event) => setState(() {
                                      isHoveredCopyRGB = false;
                                    }),
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: isHoveredCopyRGB
                                            ? const Color.fromARGB(
                                                64,
                                                255,
                                                255,
                                                255,
                                              )
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5),
                                        ),
                                      ),
                                      child: IconButton(
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          overlayColor: Colors.transparent,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () {
                                          Clipboard.setData(
                                            ClipboardData(
                                              text:
                                                  "${rgbValue!['r']}, ${rgbValue!['g']}, ${rgbValue!['b']}",
                                            ),
                                          );
                                        },
                                        icon: Icon(
                                          Icons.copy,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "HEX: #${((pickedColor.r * 255).round() & 0xFF).toRadixString(16).padLeft(2, '0').toUpperCase()}"
                                    "${((pickedColor.g * 255).round() & 0xFF).toRadixString(16).padLeft(2, '0').toUpperCase()}"
                                    "${((pickedColor.b * 255).round() & 0xFF).toRadixString(16).padLeft(2, '0').toUpperCase()}",
                                    style: TextStyle(color: Colors.white),
                                    overflow: TextOverflow.clip,
                                    softWrap: false,
                                  ),
                                  SizedBox(width: 4),
                                  MouseRegion(
                                    onEnter: (event) => setState(() {
                                      isHoveredCopyHex = true;
                                    }),
                                    onExit: (event) => setState(() {
                                      isHoveredCopyHex = false;
                                    }),
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: isHoveredCopyHex
                                            ? const Color.fromARGB(
                                                64,
                                                255,
                                                255,
                                                255,
                                              )
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5),
                                        ),
                                      ),
                                      child: IconButton(
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          overlayColor: Colors.transparent,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () {
                                          final hex =
                                              '#'
                                              '${((pickedColor.r * 255).round() & 0xFF).toRadixString(16).padLeft(2, '0').toUpperCase()}'
                                              '${((pickedColor.g * 255).round() & 0xFF).toRadixString(16).padLeft(2, '0').toUpperCase()}'
                                              '${((pickedColor.b * 255).round() & 0xFF).toRadixString(16).padLeft(2, '0').toUpperCase()}';
                                          Clipboard.setData(
                                            ClipboardData(text: hex),
                                          );
                                        },
                                        icon: Icon(
                                          Icons.copy,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    // Convert Color to HSL and display as HSL(h, s%, l%)
                                    () {
                                      final hsl = HSLColor.fromColor(
                                        pickedColor,
                                      );
                                      final h = hsl.hue.round();
                                      final s = (hsl.saturation * 100).round();
                                      final l = (hsl.lightness * 100).round();
                                      return "HSL: $h, $s%, $l%";
                                    }(),
                                    style: TextStyle(color: Colors.white),
                                    overflow: TextOverflow.clip,
                                    softWrap: false,
                                  ),
                                  SizedBox(width: 4),
                                  MouseRegion(
                                    onEnter: (event) => setState(() {
                                      isHoveredCopyHsl = true;
                                    }),
                                    onExit: (event) => setState(() {
                                      isHoveredCopyHsl = false;
                                    }),
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: isHoveredCopyHsl
                                            ? const Color.fromARGB(
                                                64,
                                                255,
                                                255,
                                                255,
                                              )
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5),
                                        ),
                                      ),
                                      child: IconButton(
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          overlayColor: Colors.transparent,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () {
                                          final hsl = HSLColor.fromColor(
                                            pickedColor,
                                          );
                                          final h = hsl.hue.round();
                                          final s = (hsl.saturation * 100)
                                              .round();
                                          final l = (hsl.lightness * 100)
                                              .round();
                                          final hslString = "$h, $s%, $l%";
                                          Clipboard.setData(
                                            ClipboardData(text: hslString),
                                          );
                                        },
                                        icon: Icon(
                                          Icons.copy,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
