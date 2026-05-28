import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('plugins.flutter.io/image_picker');
  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    log.clear();
    // Register mock implementation for the image_picker platform channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      log.add(methodCall);
      if (methodCall.method == 'pickImage' || methodCall.method == 'pickVideo') {
        return 'mock_path/image.png';
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('ImagePicker Platform Channel Self-Testing', () {
    test('pickImage mock channel call test', () async {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      expect(image, isNotNull);
      expect(image!.path, equals('mock_path/image.png'));
      expect(log, hasLength(1));
      expect(log.single.method, equals('pickImage'));
    });

    test('pickVideo mock channel call test', () async {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(source: ImageSource.gallery);

      expect(video, isNotNull);
      expect(video!.path, equals('mock_path/image.png'));
      expect(log, hasLength(1));
      expect(log.single.method, equals('pickVideo'));
    });
  });
}
