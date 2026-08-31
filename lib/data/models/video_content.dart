import 'exercise.dart';
import 'vocab_item.dart';

enum VideoProvider {
  youtube,
  web,
  local;

  static VideoProvider fromString(String? value) => VideoProvider.values
      .firstWhere((p) => p.name == value, orElse: () => VideoProvider.web);
}

enum VideoFormat {
  video,
  short;

  static VideoFormat fromString(String? value) => VideoFormat.values.firstWhere(
    (f) => f.name == value,
    orElse: () => VideoFormat.video,
  );
}

/// Parsed identity of a video URL.
class VideoInfo {
  const VideoInfo({
    required this.provider,
    required this.videoId,
    required this.format,
  });

  final VideoProvider provider;
  final String videoId;
  final VideoFormat format;
}

/// Recognizes YouTube watch/short/youtu.be URLs; anything else is [VideoProvider.web].
abstract final class VideoUrlParser {
  static VideoInfo parse(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) {
      return const VideoInfo(
        provider: VideoProvider.web,
        videoId: '',
        format: VideoFormat.video,
      );
    }
    final host = uri.host.replaceFirst('www.', '').toLowerCase();

    if (host == 'youtu.be' && uri.pathSegments.isNotEmpty) {
      return VideoInfo(
        provider: VideoProvider.youtube,
        videoId: uri.pathSegments.first,
        format: VideoFormat.video,
      );
    }
    if (host == 'youtube.com' || host == 'm.youtube.com') {
      final segments = uri.pathSegments;
      if (segments.isNotEmpty &&
          segments.first == 'shorts' &&
          segments.length > 1) {
        return VideoInfo(
          provider: VideoProvider.youtube,
          videoId: segments[1],
          format: VideoFormat.short,
        );
      }
      if (segments.isNotEmpty &&
          segments.first == 'embed' &&
          segments.length > 1) {
        return VideoInfo(
          provider: VideoProvider.youtube,
          videoId: segments[1],
          format: VideoFormat.video,
        );
      }
      final id = uri.queryParameters['v'];
      if (id != null && id.isNotEmpty) {
        return VideoInfo(
          provider: VideoProvider.youtube,
          videoId: id,
          format: VideoFormat.video,
        );
      }
    }
    return const VideoInfo(
      provider: VideoProvider.web,
      videoId: '',
      format: VideoFormat.video,
    );
  }

  /// Privacy-enhanced embed URL for in-app playback.
  static String? embedUrl(String url) {
    final info = parse(url);
    if (info.provider == VideoProvider.youtube && info.videoId.isNotEmpty) {
      return 'https://www.youtube-nocookie.com/embed/${info.videoId}?rel=0&playsinline=1';
    }
    return null;
  }
}

/// A curated learning video attached to a lesson (online — requires internet)
/// or bundled locally.
class VideoContent {
  const VideoContent({
    required this.title,
    required this.url,
    this.description = '',
    this.provider = VideoProvider.youtube,
    this.format = VideoFormat.video,
    this.durationSeconds = 0,
    this.level = 'A1',
    this.topic = '',
    this.required = false,
    this.vocabulary = const [],
    this.questions = const [],
    this.transcript = const [],
  });

  final String title;
  final String url;
  final String description;
  final VideoProvider provider;
  final VideoFormat format;
  final int durationSeconds;
  final String level;
  final String topic;

  /// External videos should stay optional so availability never blocks
  /// course progression.
  final bool required;

  /// Words featured in the video.
  final List<VocabItem> vocabulary;

  /// Comprehension questions answered after watching.
  final List<Exercise> questions;

  /// Author-provided transcript lines (never scraped).
  final List<String> transcript;

  String get id => VideoUrlParser.parse(url).videoId.isNotEmpty
      ? 'yt_${VideoUrlParser.parse(url).videoId}'
      : url;

  factory VideoContent.fromJson(Map<String, dynamic> json) {
    final url = json['url'] as String? ?? json['asset'] as String? ?? '';
    final parsed = VideoUrlParser.parse(url);
    return VideoContent(
      title: json['title'] as String? ?? 'Video',
      url: url,
      description: json['description'] as String? ?? '',
      provider: json['provider'] != null || json['source'] != null
          ? VideoProvider.fromString(
              (json['provider'] ?? json['source']) as String?,
            )
          : parsed.provider,
      format: json['format'] != null
          ? VideoFormat.fromString(json['format'] as String?)
          : parsed.format,
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      level: json['level'] as String? ?? 'A1',
      topic: json['topic'] as String? ?? '',
      required: json['required'] as bool? ?? false,
      vocabulary:
          (json['vocabulary'] as List?)
              ?.map((e) => VocabItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      questions:
          (json['questions'] as List?)
              ?.map((e) => Exercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      transcript:
          (json['transcript'] as List?)?.map((e) => e as String).toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'url': url,
    if (description.isNotEmpty) 'description': description,
    'provider': provider.name,
    'format': format.name,
    if (durationSeconds > 0) 'durationSeconds': durationSeconds,
    'level': level,
    if (topic.isNotEmpty) 'topic': topic,
    'required': required,
    if (vocabulary.isNotEmpty)
      'vocabulary': vocabulary.map((v) => v.toJson()).toList(),
    if (questions.isNotEmpty)
      'questions': questions.map((q) => q.toJson()).toList(),
    if (transcript.isNotEmpty) 'transcript': transcript,
  };
}
