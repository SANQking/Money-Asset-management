import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../../core/constants/asset_limits.dart';

abstract interface class AssetImagePickerService {
  Future<String?> pickCompressedImageDataUrl();
}

class ImagePickerAssetImagePickerService implements AssetImagePickerService {
  ImagePickerAssetImagePickerService({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;
  static const _maxDimension = 1600;
  static const _jpegQuality = 82;

  @override
  Future<String?> pickCompressedImageDataUrl() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: _jpegQuality,
      maxWidth: _maxDimension.toDouble(),
      maxHeight: _maxDimension.toDouble(),
    );
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    final mime = _mimeFromPath(file.name);
    return compressImageBytesToDataUrl(
      bytes,
      sourceMimeType: mime,
      maxDimension: _maxDimension,
      jpegQuality: _jpegQuality,
    );
  }

  String _mimeFromPath(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }
}

String imageBytesToDataUrl(List<int> bytes, String mimeType) {
  if (bytes.length > AssetLimits.maxImageBytes) {
    throw const FormatException('image too large');
  }
  return 'data:$mimeType;base64,${base64Encode(bytes)}';
}

Future<String> compressImageBytesToDataUrl(
  List<int> bytes, {
  required String sourceMimeType,
  int maxDimension = 1600,
  int jpegQuality = 82,
}) async {
  if (bytes.length > AssetLimits.maxImageBytes) {
    throw const FormatException('image too large');
  }
  final compressed = await compute(
    _compressImageBytes,
    _ImageCompressionRequest(
      bytes: Uint8List.fromList(bytes),
      maxDimension: maxDimension,
      jpegQuality: jpegQuality,
    ),
  );
  if (compressed == null) {
    return imageBytesToDataUrl(bytes, sourceMimeType);
  }
  return imageBytesToDataUrl(compressed, 'image/jpeg');
}

Uint8List? _compressImageBytes(_ImageCompressionRequest request) {
  final decoded = img.decodeImage(request.bytes);
  if (decoded == null) return null;

  var output = decoded;
  final longestSide = decoded.width > decoded.height
      ? decoded.width
      : decoded.height;
  if (longestSide > request.maxDimension) {
    if (decoded.width >= decoded.height) {
      output = img.copyResize(decoded, width: request.maxDimension);
    } else {
      output = img.copyResize(decoded, height: request.maxDimension);
    }
  }

  final encoded = img.encodeJpg(output, quality: request.jpegQuality);
  return Uint8List.fromList(encoded);
}

class _ImageCompressionRequest {
  const _ImageCompressionRequest({
    required this.bytes,
    required this.maxDimension,
    required this.jpegQuality,
  });

  final Uint8List bytes;
  final int maxDimension;
  final int jpegQuality;
}
