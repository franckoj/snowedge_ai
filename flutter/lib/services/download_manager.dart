import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import '../models/model_info.dart';
import 'model_manager.dart';

final _logger = Logger();

/// Download progress information
class DownloadProgress {
  final int received;
  final int total;
  final double percentage;
  final String speed;

  DownloadProgress({
    required this.received,
    required this.total,
    required this.percentage,
    required this.speed,
  });
}

/// Handles model file downloads
class DownloadManager {
  static final DownloadManager _instance = DownloadManager._internal();
  factory DownloadManager() => _instance;
  DownloadManager._internal();

  final Dio _dio = Dio();
  final Map<String, CancelToken> _activeDownloads = {};

  /// Download a model
  Stream<DownloadProgress> downloadModel(ModelInfo model) {
    // Use a StreamController to bridge the callback-based progress to a stream
    final controller = StreamController<DownloadProgress>();
    
    // We need to run the download logic in a separate future so we can return the stream immediately
    _startDownload(model, controller);
    
    return controller.stream;
  }

  Future<void> _startDownload(ModelInfo model, StreamController<DownloadProgress> controller) async {
    try {
      _logger.i('Starting download: ${model.name}');

      // Get save path
      final savePath = await _getModelPath(model);
      final saveFile = File(savePath);

      // Create directory if needed
      await saveFile.parent.create(recursive: true);

      // Create cancel token
      final cancelToken = CancelToken();
      _activeDownloads[model.id] = cancelToken;

      int lastTime = DateTime.now().millisecondsSinceEpoch;
      int lastReceived = 0;
      String currentSpeed = '0 KB/s';

      try {
        await _dio.download(
          model.downloadUrl,
          savePath,
          cancelToken: cancelToken,
          onReceiveProgress: (received, total) {
            final now = DateTime.now().millisecondsSinceEpoch;
            final timeDiff = (now - lastTime) / 1000.0; // seconds
            
            // Update speed calculation every 500ms
            if (timeDiff > 0.5) {
              final receivedDiff = received - lastReceived;
              final speedBytes = receivedDiff / timeDiff;
              
              if (speedBytes < 1024 * 1024) {
                currentSpeed = '${(speedBytes / 1024).toStringAsFixed(1)} KB/s';
              } else {
                currentSpeed = '${(speedBytes / (1024 * 1024)).toStringAsFixed(2)} MB/s';
              }
              
              lastTime = now;
              lastReceived = received;
            }

            // Don't divide by zero
            final percentage = total > 0 ? (received / total * 100) : 0.0;
            
            // Add progress to stream
            if (!controller.isClosed) {
              controller.add(DownloadProgress(
                received: received,
                total: total,
                percentage: percentage,
                speed: currentSpeed,
              ));
            }
          },
        );

        // Verify download
        _logger.i('Download complete, verifying...');
        if (model.sha256 != null) {
          await _verifyChecksum(savePath, model.sha256!);
        }

        // Mark as downloaded in manager
        ModelManager().markAsDownloaded(model.id, saveFile);

        // Yield final progress
        if (!controller.isClosed) {
          controller.add(DownloadProgress(
            received: model.sizeBytes,
            total: model.sizeBytes,
            percentage: 100.0,
            speed: '0 KB/s',
          ));
          await controller.close();
        }

        _logger.i('Model downloaded successfully: ${model.name}');
      } catch (e) {
        if (!controller.isClosed) {
           // Don't treat cancellation as an error for the stream if possible, 
           // but traditionally we just throw/addError.
           // If 'e' is DioExceptionType.cancel, it might be cleaner to just close.
           if (e is DioException && e.type == DioExceptionType.cancel) {
             // Just close, maybe send a specific event if needed, but for now just close.
             // Actually, usually streams error on cancel.
           }
           controller.addError(e);
           await controller.close();
        }
        rethrow;
      } finally {
        _activeDownloads.remove(model.id);
      }
    } catch (e) {
      _logger.e('Download failed', error: e);
      _activeDownloads.remove(model.id);
      if (!controller.isClosed) {
        controller.addError(e);
        await controller.close();
      }
    }
  }

  /// Cancel a download
  void cancelDownload(String modelId) {
    final cancelToken = _activeDownloads[modelId];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel('User cancelled');
      _activeDownloads.remove(modelId);
      _logger.i('Download cancelled: $modelId');
    }
  }

  /// Check if a model is currently downloading
  bool isDownloading(String modelId) {
    return _activeDownloads.containsKey(modelId);
  }

  Future<String> _getModelPath(ModelInfo model) async {
    final dir = await getApplicationDocumentsDirectory();
    final runtimeDir = model.runtime == RuntimeType.onnx ? 'onnx' : 'llamacpp';
    return '${dir.path}/models/$runtimeDir/${model.filename}';
  }

  Future<void> _verifyChecksum(String filePath, String expectedSha256) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final digest = sha256.convert(bytes);
    final actualSha256 = digest.toString();

    if (actualSha256.toLowerCase() != expectedSha256.toLowerCase()) {
      throw Exception('Checksum verification failed');
    }

    _logger.i('Checksum verified successfully');
  }
}
