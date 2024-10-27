import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tapioca/tapioca.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';

void main() {
  runApp(const MaterialApp(
    home: VideoEditor(),
  ));
}

class VideoEditor extends StatefulWidget {
  const VideoEditor({super.key});

  @override
  _VideoEditorState createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> {
  final ImagePicker _picker = ImagePicker();
  String? _videoPath;

  Future<void> _pickVideo() async {
    var status = await Permission.storage.status;

    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    if (await Permission.storage.request().isGranted) {
      print("저장소 접근 권한 허용됨");
    } else {
      print("저장소 접근 권한이 필요합니다.");
    }
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _videoPath = video.path;
      });
    }
  }

  Future<void> _editAndSaveVideo() async {
    if (_videoPath == null) return;

    // 오버레이 요소 정의
    final tapiocaBalls = [
      //TapiocaBall.filter(Filters.pink, 0),
      TapiocaBall.textOverlay("Test Overlay", 100, 100, 100, Colors.black),
    ];
    // 임시 저장 위치 설정
    final Directory tempDir = await getTemporaryDirectory();
    final String outputPath = join(tempDir.path, 'edited_video.mp4');

    // 비디오 편집 실행
    try {
      final tapiocaBalls = [
        TapiocaBall.filter(Filters.grey),
        // TapiocaBall.textOverlay("text", 100, 10, 100, const Color(0xffffc0cb)),
      ];
      var tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/result.mp4';
      final cup = Cup(Content(_videoPath!), tapiocaBalls);
      await cup.suckUp(path).then((_) {
        print("finish processing");
      });
      // print('시작 $_videoPath');
      // final cup = Cup(Content(_videoPath!), tapiocaBalls);
      // print('끝0');
      // await cup.suckUp('${tempDir.path}/result.mp4');
      // print('끝1');
      // // 갤러리에 수정된 비디오 저장

      await GallerySaver.saveVideo('${tempDir.path}/result.mp4');
      print('끝2');
    } catch (e) {
      print("비디오 편집 오류: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('비디오 편집기'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickVideo,
              child: const Text('갤러리에서 비디오 선택'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _editAndSaveVideo,
              child: const Text('비디오 편집 후 저장'),
            ),
          ],
        ),
      ),
    );
  }
}
