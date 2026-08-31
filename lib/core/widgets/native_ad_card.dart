import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../app/providers.dart';
import '../../app/theme/app_dimensions.dart';
import '../services/ads_service.dart';

/// Native Advanced "sponsored" card, styled to sit inline in a lesson list.
/// Renders nothing until the ad loads and disappears again if it fails.
class NativeAdCard extends ConsumerStatefulWidget {
  const NativeAdCard({super.key});

  @override
  ConsumerState<NativeAdCard> createState() => _NativeAdCardState();
}

class _NativeAdCardState extends ConsumerState<NativeAdCard> {
  NativeAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (ref.read(adsEnabledProvider)) _load();
  }

  void _load() {
    final ad = NativeAd(
      adUnitId: AdUnitIds.nativeAdvanced,
      factoryId: nativeAdFactoryId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          if (!mounted) return;
          setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _ad = null;
            _loaded = false;
          });
        },
      ),
    );
    _ad = ad;
    ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_loaded || ad == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: SizedBox(height: 130, child: AdWidget(ad: ad)),
    );
  }
}
