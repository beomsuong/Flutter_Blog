import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class ScreenShoot extends StatefulWidget {
  const ScreenShoot({super.key});

  @override
  _ScreenShootState createState() => _ScreenShootState();
}

class _ScreenShootState extends State<ScreenShoot> {
  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ScreenShoot'),
      ),
      body: Column(
        children: [
          TextButton(
            child: const Text('캡쳐!'),
            onPressed: () async {
              try {
                final directory =
                    (await getApplicationDocumentsDirectory()).path;
                String fileName =
                    '캡쳐본_${DateTime.now().microsecondsSinceEpoch}.png'
                        .toString();
                String path = directory;

                var result = await screenshotController.captureAndSave(path,
                    fileName: fileName);
                await GallerySaver.saveImage(result.toString());

                debugPrint('저장 완료 $result');
                Size size = MediaQuery.of(context).size;
                double screenWidth = size.width;
                double screenHeight = size.height;
                await Share.shareXFiles([XFile(result.toString())],
                    sharePositionOrigin: Rect.fromLTWH(
                        0, 0, screenWidth - 100, screenHeight - 100));
              } catch (e) {
                debugPrint('저장 실패 $e');
              }
            },
          ),
          Screenshot(
            controller: screenshotController,
            child: Container(
              padding: const EdgeInsets.all(30.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 5.0),
                color: Colors.amberAccent,
              ),
              child: const Text("캡쳐 할 위젯"),
            ),
          ),
        ],
      ),
    );
  }
}
