import 'dart:io';
import 'package:firebase_admob/firebase_admob.dart';

final bannerAdIdAndroid =
    "ca-app-pub-7831186229252322/6549223566"; //myID ca-app-pub-3940256099942544/6300978111
final intertstitialAdIdAndroid =
    "ca-app-pub-7831186229252322/7884973074"; //myId ca-app-pub-7831186229252322/7884973074
final rewardedVideoAdIdAndroid =
    "ca-app-pub-7831186229252322/3632888368"; //myId ca-app-pub-7831186229252322/3632888368
final nativeAdIdAndroid =
    "ca-app-pub-7831186229252322/8542072878"; //"ca-app-pub-7831186229252322/8542072878"

MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
  keywords: <String>["gym", "academia", "treino", "musculação", "bodybuilding"],
  contentUrl: 'https://flutter.io',
  childDirected: false,
);

BannerAd myBanner;
InterstitialAd myInterstitial;
bool isInterstitialAdReady;

double bottomPadding = 0;

String bannerAdUnitId() {
  if (Platform.isAndroid) {
    return bannerAdIdAndroid;
  } else if (Platform.isIOS) {
    return "<YOUR_IOS_BANNER_AD_UNIT_ID>";
  } else {
    throw new UnsupportedError("Unsupported platform");
  }
}

String rewardedAdUnitId() {
  if (Platform.isAndroid) {
    return rewardedVideoAdIdAndroid;
  } else if (Platform.isIOS) {
    return "<YOUR_IOS_NATIVE_AD_UNIT_ID>";
  } else {
    throw new UnsupportedError("Unsupported platform");
  }
}

String interstitialAdUnitId() {
  if (Platform.isAndroid) {
    return intertstitialAdIdAndroid;
  } else if (Platform.isIOS) {
    return "<YOUR_IOS_BANNER_AD_UNIT_ID>";
  } else {
    throw new UnsupportedError("Unsupported platform");
  }
}

String nativeAdUnitId() {
  if (Platform.isAndroid) {
    return nativeAdIdAndroid;
  } else if (Platform.isIOS) {
    return "<YOUR_IOS_BANNER_AD_UNIT_ID>";
  } else {
    throw new UnsupportedError("Unsupported platform");
  }
}

void startBanner() {
  myBanner = BannerAd(
    adUnitId: bannerAdIdAndroid,
    size: AdSize.smartBanner,
    targetingInfo: targetingInfo,
    listener: (MobileAdEvent event) {
      if (event == MobileAdEvent.opened) {
        bottomPadding = 60;
        print("Banner acionado");
        // MobileAdEvent.opened
        // MobileAdEvent.clicked
        // MobileAdEvent.closed
        // MobileAdEvent.failedToLoad
        // MobileAdEvent.impression
        // MobileAdEvent.leftApplication
      } else if (event == MobileAdEvent.failedToLoad) {
        print("FAILED TO LOAD SAPORRA");
        return "Failed to load";
      }
      print("BannerAd event is $event");
    },
  );
}

BannerAd getBanner(AdSize size) {
  return BannerAd(
    adUnitId: bannerAdIdAndroid,
    size: size,
    listener: (MobileAdEvent event) {
      if (event == MobileAdEvent.opened) {
        // MobileAdEvent.opened
        // MobileAdEvent.clicked
        // MobileAdEvent.closed
        // MobileAdEvent.failedToLoad
        // MobileAdEvent.impression
        // MobileAdEvent.leftApplication
      } else if (event == MobileAdEvent.failedToLoad) {
        print("FAILED TO LOAD SAPORRA");
      }
      print("BannerAd event is $event");
    },
  );
}

InterstitialAd buildInterstitial() {
  return InterstitialAd(
      adUnitId: intertstitialAdIdAndroid,
      targetingInfo: MobileAdTargetingInfo(
        keywords: <String>[
          "gym",
          "academia",
          "treino",
          "musculação",
          "bodybuilding"
        ],
      ),
      listener: (MobileAdEvent event) {
        if (event == MobileAdEvent.loaded) {
          myInterstitial?.show();
        }
        if (event == MobileAdEvent.clicked || event == MobileAdEvent.closed) {
          myInterstitial.dispose();
        }
      });
}
