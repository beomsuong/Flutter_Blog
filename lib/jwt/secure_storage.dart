
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage storage;

  SecureStorage({required this.storage});

  /// 리프레시 토큰 저장
  Future<void> saveRefreshToken(String refreshToken) async {
    try {
      await storage.write(key: 'REFRESH_TOKEN', value: refreshToken);
      debugPrint('RefreshToken 저장 성공: $refreshToken');
    } catch (e) {
      debugPrint("RefreshToken 저장 실패: $e");
    }
  }

  /// 리프레시 토큰 불러오기
  Future<String?> readRefreshToken() async {
    try {
      final refreshToken = await storage.read(key: 'REFRESH_TOKEN');
      debugPrint('RefreshToken 불러오기 성공: $refreshToken');
      return refreshToken;
    } catch (e) {
      debugPrint("RefreshToken 불러오기 실패: $e");
      return null;
    }
  }

  /// 에세스 토큰 저장
  Future<void> saveAccessToken(String accessToken) async {
    try {
      await storage.write(key: 'ACCESS_TOKEN', value: accessToken);
      debugPrint('AccessToken 저장 성공: $accessToken');
    } catch (e) {
      debugPrint("AccessToken 저장 실패: $e");
    }
  }

  /// 에세스 토큰 불러오기
  Future<String?> readAccessToken() async {
    try {
      final accessToken = await storage.read(key: 'ACCESS_TOKEN');
      debugPrint('AccessToken 불러오기 성공: $accessToken');
      return accessToken;
    } catch (e) {
      debugPrint('AccessToken 불러오기 실패: $e');
      return null;
    }
  }

  /// 토큰 삭제하기
  Future<void> deleteToken() async {
    try {
      await Future.wait([
        storage.delete(key: 'ACCESS_TOKEN'),
        storage.delete(key: 'REFRESH_TOKEN')
      ]);
    } catch (e) {
      debugPrint('토큰 삭제 실패 $e');
      return;
    }
  }
}