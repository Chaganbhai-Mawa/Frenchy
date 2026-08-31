import 'package:flutter_test/flutter_test.dart';
import 'package:frenchly/data/models/video_content.dart';

void main() {
  group('VideoUrlParser', () {
    test('parses watch URLs', () {
      final info = VideoUrlParser.parse(
        'https://www.youtube.com/watch?v=Mt00FUPzLPc',
      );
      expect(info.provider, VideoProvider.youtube);
      expect(info.videoId, 'Mt00FUPzLPc');
      expect(info.format, VideoFormat.video);
    });

    test('parses youtu.be short links', () {
      final info = VideoUrlParser.parse('https://youtu.be/abc123XYZ_-');
      expect(info.provider, VideoProvider.youtube);
      expect(info.videoId, 'abc123XYZ_-');
    });

    test('parses Shorts URLs as short format', () {
      final info = VideoUrlParser.parse(
        'https://www.youtube.com/shorts/xyz789',
      );
      expect(info.provider, VideoProvider.youtube);
      expect(info.videoId, 'xyz789');
      expect(info.format, VideoFormat.short);
    });

    test('non-YouTube URLs fall back to web provider', () {
      final info = VideoUrlParser.parse('https://example.com/video.mp4');
      expect(info.provider, VideoProvider.web);
      expect(info.videoId, isEmpty);
    });

    test('garbage input never throws', () {
      expect(VideoUrlParser.parse('').provider, VideoProvider.web);
      expect(VideoUrlParser.parse('not a url').provider, VideoProvider.web);
    });

    test('builds privacy-enhanced embed URLs', () {
      expect(
        VideoUrlParser.embedUrl('https://www.youtube.com/watch?v=Mt00FUPzLPc'),
        'https://www.youtube-nocookie.com/embed/Mt00FUPzLPc?rel=0&playsinline=1',
      );
      expect(VideoUrlParser.embedUrl('https://example.com/x'), isNull);
    });
  });
}
