import 'dart:io' show Platform;

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob ad unit ids for every format Bonjourney monetizes with.
///
/// AdMob policy forbids generating impressions/clicks on live ad units from
/// a developer device — doing so risks account suspension. Debug and
/// profile builds always resolve to Google's public test units; only
/// release builds serve the real, revenue-generating ids below.
///
/// AdMob ids are per-platform: an Android ad unit id will not serve on iOS.
/// Android and iOS are separate apps in the AdMob console, each with its
/// own App ID and ad unit ids.
abstract final class AdUnitIds {
  static const String androidAppId = 'ca-app-pub-9960557555177349~9792648934';
  static const String iosAppId = 'ca-app-pub-9960557555177349~4716311024';

  static const String _androidBanner =
      'ca-app-pub-9960557555177349/8479567263';
  static const String _androidInterstitial =
      'ca-app-pub-9960557555177349/7166485591';
  static const String _androidRewardedInterstitial =
      'ca-app-pub-9960557555177349/9596268469';
  static const String _androidRewarded =
      'ca-app-pub-9960557555177349/6921626368';
  static const String _androidNativeAdvanced =
      'ca-app-pub-9960557555177349/5688435742';
  static const String _androidAppOpen =
      'ca-app-pub-9960557555177349/5840856282';

  static const String _iosBanner = 'ca-app-pub-9960557555177349/4416550829';
  static const String _iosInterstitial =
      'ca-app-pub-9960557555177349/8283643643';
  static const String _iosRewardedInterstitial =
      'ca-app-pub-9960557555177349/9525784575';
  static const String _iosRewarded =
      'ca-app-pub-9960557555177349/1790387486';
  static const String _iosNativeAdvanced =
      'ca-app-pub-9960557555177349/6851142475';
  static const String _iosAppOpen =
      'ca-app-pub-9960557555177349/5370539844';

  static const String _testBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedInterstitial =
      'ca-app-pub-3940256099942544/5354046379';
  static const String _testRewarded =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _testNativeAdvanced =
      'ca-app-pub-3940256099942544/2247696110';
  static const String _testAppOpen =
      'ca-app-pub-3940256099942544/9257395921';

  /// Picks between a real Android id, a real iOS id (if one has been filled
  /// in above), and Google's test id — never an Android id on iOS.
  static String _resolve({
    required String android,
    required String? ios,
    required String test,
  }) {
    if (!kReleaseMode) return test;
    if (Platform.isIOS) return ios ?? test;
    return android;
  }

  static String get banner =>
      _resolve(android: _androidBanner, ios: _iosBanner, test: _testBanner);
  static String get interstitial => _resolve(
    android: _androidInterstitial,
    ios: _iosInterstitial,
    test: _testInterstitial,
  );
  static String get rewardedInterstitial => _resolve(
    android: _androidRewardedInterstitial,
    ios: _iosRewardedInterstitial,
    test: _testRewardedInterstitial,
  );
  static String get rewarded => _resolve(
    android: _androidRewarded,
    ios: _iosRewarded,
    test: _testRewarded,
  );
  static String get nativeAdvanced => _resolve(
    android: _androidNativeAdvanced,
    ios: _iosNativeAdvanced,
    test: _testNativeAdvanced,
  );
  static String get appOpen =>
      _resolve(android: _androidAppOpen, ios: _iosAppOpen, test: _testAppOpen);
}

/// Registered on the Android side (MainActivity.kt) to inflate native ad
/// views for the Learn tab's lesson list.
const String nativeAdFactoryId = 'listNativeAdFactory';

/// Preloads and shows full-screen interstitials, reloading after every show
/// (or failure) so one is ready again as soon as possible.
class InterstitialAdManager {
  InterstitialAd? _ad;
  bool _isLoading = false;

  bool get isReady => _ad != null;

  void load() {
    if (_isLoading || _ad != null) return;
    _isLoading = true;
    InterstitialAd.load(
      adUnitId: AdUnitIds.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoading = false;
          _ad = ad;
        },
        onAdFailedToLoad: (_) {
          _isLoading = false;
          _ad = null;
        },
      ),
    );
  }

  /// Shows the interstitial if one is loaded. [onComplete] always fires
  /// once the ad is dismissed — or immediately if none was ready, so
  /// callers are never blocked waiting on ad inventory.
  void show({VoidCallback? onComplete}) {
    final ad = _ad;
    if (ad == null) {
      load();
      onComplete?.call();
      return;
    }
    _ad = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        load();
        onComplete?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        load();
        onComplete?.call();
      },
    );
    ad.show();
  }

  void dispose() => _ad?.dispose();
}

/// Preloads and shows rewarded ads. Use for an explicit, user-initiated
/// "watch an ad for X" button.
class RewardedAdManager {
  RewardedAd? _ad;
  bool _isLoading = false;

  bool get isReady => _ad != null;

  void load() {
    if (_isLoading || _ad != null) return;
    _isLoading = true;
    RewardedAd.load(
      adUnitId: AdUnitIds.rewarded,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoading = false;
          _ad = ad;
        },
        onAdFailedToLoad: (_) {
          _isLoading = false;
          _ad = null;
        },
      ),
    );
  }

  /// [onEarnedReward] fires only once the learner watches to completion.
  /// [onUnavailable] fires immediately when no ad is loaded yet (a reload
  /// is kicked off so the next attempt is more likely to succeed).
  void show({
    required VoidCallback onEarnedReward,
    VoidCallback? onDismissed,
    VoidCallback? onUnavailable,
  }) {
    final ad = _ad;
    if (ad == null) {
      load();
      onUnavailable?.call();
      return;
    }
    _ad = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        load();
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        load();
        onUnavailable?.call();
      },
    );
    ad.show(onUserEarnedReward: (_, _) => onEarnedReward());
  }

  void dispose() => _ad?.dispose();
}

/// Preloads and shows rewarded interstitials — the format Google designed
/// for spontaneous, auto-surfaced prompts (it carries its own opt-in
/// intro), so this is used where the app offers a reward without the user
/// having tapped a dedicated "watch ad" button first.
class RewardedInterstitialAdManager {
  RewardedInterstitialAd? _ad;
  bool _isLoading = false;

  bool get isReady => _ad != null;

  void load() {
    if (_isLoading || _ad != null) return;
    _isLoading = true;
    RewardedInterstitialAd.load(
      adUnitId: AdUnitIds.rewardedInterstitial,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoading = false;
          _ad = ad;
        },
        onAdFailedToLoad: (_) {
          _isLoading = false;
          _ad = null;
        },
      ),
    );
  }

  void show({
    required VoidCallback onEarnedReward,
    VoidCallback? onDismissed,
    VoidCallback? onUnavailable,
  }) {
    final ad = _ad;
    if (ad == null) {
      load();
      onUnavailable?.call();
      return;
    }
    _ad = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        load();
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        load();
        onUnavailable?.call();
      },
    );
    ad.show(onUserEarnedReward: (_, _) => onEarnedReward());
  }

  void dispose() => _ad?.dispose();
}

/// Preloads and shows app-open ads on cold start and on every foreground
/// resume. Ads expire after four hours per Google's guidance, so a stale
/// cached ad is never shown.
class AppOpenAdManager {
  static const Duration _maxCacheDuration = Duration(hours: 4);

  AppOpenAd? _ad;
  bool _isLoading = false;
  DateTime? _loadTime;
  bool isShowingAd = false;

  bool get _isFresh =>
      _loadTime != null &&
      DateTime.now().difference(_loadTime!) < _maxCacheDuration;

  bool get isAdAvailable => _ad != null && _isFresh;

  void load() {
    if (_isLoading || isAdAvailable) return;
    _isLoading = true;
    AppOpenAd.load(
      adUnitId: AdUnitIds.appOpen,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoading = false;
          _ad = ad;
          _loadTime = DateTime.now();
        },
        onAdFailedToLoad: (_) {
          _isLoading = false;
          _ad = null;
        },
      ),
    );
  }

  /// Shows the cached ad if one is fresh; otherwise kicks off a load for
  /// next time and does nothing (never blocks the caller).
  void showAdIfAvailable() {
    if (isShowingAd) return;
    if (!isAdAvailable) {
      load();
      return;
    }
    final ad = _ad!;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => isShowingAd = true,
      onAdDismissedFullScreenContent: (ad) {
        isShowingAd = false;
        ad.dispose();
        _ad = null;
        load();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        isShowingAd = false;
        ad.dispose();
        _ad = null;
        load();
      },
    );
    ad.show();
  }

  void dispose() => _ad?.dispose();
}

/// Owns every ad manager and the SDK lifecycle. One instance lives for the
/// app's lifetime (see `adsServiceProvider`).
class AdsService {
  final InterstitialAdManager interstitial = InterstitialAdManager();
  final RewardedAdManager rewarded = RewardedAdManager();
  final RewardedInterstitialAdManager rewardedInterstitial =
      RewardedInterstitialAdManager();
  final AppOpenAdManager appOpen = AppOpenAdManager();

  Future<void> initialize() async {
    // iOS 14+ requires this consent prompt before requesting personalized
    // (IDFA-based) ads; Android has no equivalent step.
    if (!kIsWeb && Platform.isIOS) {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    }
    await MobileAds.instance.initialize();
    interstitial.load();
    rewarded.load();
    rewardedInterstitial.load();
    appOpen.load();
  }

  void dispose() {
    interstitial.dispose();
    rewarded.dispose();
    rewardedInterstitial.dispose();
    appOpen.dispose();
  }
}
