import 'package:flutter/material.dart';
import 'dart:ui';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Text with Blur")),
        body: const Center(
          child: MyTextWidget(),
        ),
      ),
    );
  }
}

class MyTextWidget extends StatelessWidget {
  const MyTextWidget({super.key});
  @override
  Widget build(BuildContext context) {
    TextSpan textSpan = const TextSpan(
      text: "첫 번째 줄입니다.\n두 번째 줄입니다.\n세 번째 줄입니다, 마지막 줄은 블러 처리됩니다.",
      style: TextStyle(fontWeight: FontWeight.w900),
    );
    final TextPainter textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: MediaQuery.of(context).size.width);
    final textHeight = textPainter.size.height;
    return Stack(
      children: [
        Text.rich(textSpan),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: textHeight / 3,
                color: Colors.black.withOpacity(0.2),
                child: const Text(
                  '추가 결제를',
                  style:
                      TextStyle(fontWeight: FontWeight.w900, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
