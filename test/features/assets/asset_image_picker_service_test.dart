import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:mobile/core/constants/asset_limits.dart';
import 'package:mobile/features/assets/asset_image_picker_service.dart';

void main() {
  test('encodes compressed image bytes as data url', () {
    final dataUrl = imageBytesToDataUrl([1, 2, 3], 'image/jpeg');

    expect(dataUrl, 'data:image/jpeg;base64,AQID');
  });

  test('rejects images above size limit', () {
    final bytes = List<int>.filled(AssetLimits.maxImageBytes + 1, 0);

    expect(
      () => imageBytesToDataUrl(bytes, 'image/jpeg'),
      throwsFormatException,
    );
  });

  test('compresses decoded gallery images to jpeg data url', () async {
    final original = img.Image(width: 8, height: 4);
    img.fill(original, color: img.ColorRgb8(255, 0, 0));
    final pngBytes = img.encodePng(original);

    final dataUrl = await compressImageBytesToDataUrl(
      pngBytes,
      sourceMimeType: 'image/png',
      maxDimension: 4,
      jpegQuality: 75,
    );

    expect(dataUrl.startsWith('data:image/jpeg;base64,'), isTrue);
    final decoded = img.decodeJpg(UriData.parse(dataUrl).contentAsBytes());
    expect(decoded?.width, 4);
    expect(decoded?.height, 2);
  });

  test('fake picker can model cancellation', () async {
    final picker = _FakePicker(null);

    expect(await picker.pickCompressedImageDataUrl(), isNull);
  });
}

class _FakePicker implements AssetImagePickerService {
  const _FakePicker(this.result);

  final String? result;

  @override
  Future<String?> pickCompressedImageDataUrl() async => result;
}
