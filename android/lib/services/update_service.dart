import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/material.dart';

class UpdateService {
  final String _repoOwner = 'Satbhai444';
  final String _repoName = 'WINDECK';
  final Dio _dio = Dio();

  Future<Map<String, dynamic>?> checkForUpdate() async {
    try {
      final response = await _dio.get(
        'https://api.github.com/repos/$_repoOwner/$_repoName/releases/latest',
        options: Options(headers: {'Accept': 'application/vnd.github.v3+json'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final latestVersion = data['tag_name'].toString().replaceAll('v', '');
        
        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersion = packageInfo.version;

        if (_isNewerVersion(currentVersion, latestVersion)) {
          final assets = data['assets'] as List;
          final apkAsset = assets.firstWhere((asset) => asset['name'].toString().endsWith('.apk'), orElse: () => null);
          
          if (apkAsset != null) {
            return {
              'version': latestVersion,
              'downloadUrl': apkAsset['browser_download_url'],
              'changelog': data['body'] ?? 'New features and improvements.',
            };
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
    return null;
  }

  bool _isNewerVersion(String current, String latest) {
    try {
      final v1 = current.split('.').map(int.parse).toList();
      final v2 = latest.split('.').map(int.parse).toList();
      for (int i = 0; i < 3; i++) {
        final p1 = i < v1.length ? v1[i] : 0;
        final p2 = i < v2.length ? v2[i] : 0;
        if (p2 > p1) return true;
        if (p2 < p1) return false;
      }
    } catch (e) {
      // In case version tags are weird
    }
    return false;
  }

  Future<void> downloadAndInstallUpdate(String url, Function(double) onProgress) async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/update.apk';

      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );

      final appId = (await PackageInfo.fromPlatform()).packageName;
      await OpenFilex.open(filePath);
    } catch (e) {
      debugPrint('Failed to download/install update: $e');
      rethrow;
    }
  }
}
