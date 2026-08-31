import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../app/theme/app_dimensions.dart';
import '../../data/models/video_content.dart';

/// Reusable in-app player for curated web videos (YouTube embeds).
///
/// Handles loading, embed failures, and offline state without ever crashing
/// or leaving a blank WebView; always offers "open externally" as an escape
/// hatch. Online-only: callers must treat video as optional content.
class LearningVideoPlayer extends StatefulWidget {
  const LearningVideoPlayer({super.key, required this.video});

  final VideoContent video;

  @override
  State<LearningVideoPlayer> createState() => _LearningVideoPlayerState();
}

class _LearningVideoPlayerState extends State<LearningVideoPlayer> {
  WebViewController? _controller;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    final embed = VideoUrlParser.embedUrl(widget.video.url);
    if (embed == null) {
      _failed = true;
      _loading = false;
      return;
    }
    try {
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (_) {
              if (mounted) setState(() => _loading = false);
            },
            onWebResourceError: (error) {
              // Only a main-frame failure means the embed itself is broken.
              if (error.isForMainFrame ?? true) {
                if (mounted) {
                  setState(() {
                    _failed = true;
                    _loading = false;
                  });
                }
              }
            },
          ),
        )
        ..loadRequest(Uri.parse(embed));
      _controller = controller;
    } catch (_) {
      _failed = true;
      _loading = false;
    }
  }

  Future<void> _openExternally() async {
    final uri = Uri.tryParse(widget.video.url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't open the video.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.medium,
      child: AspectRatio(
        aspectRatio: widget.video.format == VideoFormat.short ? 9 / 14 : 16 / 9,
        child: ColoredBox(
          color: Colors.black,
          child: _failed
              ? _FallbackView(onOpen: _openExternally)
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_controller != null)
                      WebViewWidget(controller: _controller!),
                    if (_loading)
                      const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _FallbackView extends StatelessWidget {
  const _FallbackView({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎬', style: TextStyle(fontSize: 36)),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              "This video can't play here.\nIt may need an internet "
              'connection or external playback.',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: const Text('Open video externally'),
            ),
          ],
        ),
      ),
    );
  }
}
