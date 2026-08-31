# App Privacy answers — for App Store Connect

App Store Connect → your app → **App Privacy**. This is Apple's equivalent of the Play
Store's Data Safety form, covering the **iOS build**, which integrates Google AdMob (same
6 ad formats as Android) plus `app_tracking_transparency` for the ATT consent prompt.

**Cross-check against Google's own published mapping before submitting** — Apple's exact
categories/wording change periodically, and this should match Google's current answers for
the Mobile Ads SDK: https://support.google.com/admob/answer/6128543 and
https://developers.google.com/admob/ios/privacy/manifest

## Do you collect data from this app?

**Yes.**

## Data types to declare

| Apple category | Collected? | Linked to identity? | Used for tracking? | Purpose |
|---|---|---|---|---|
| Identifiers → Device ID | Yes | Depends on ATT consent | Yes, if ATT granted | Advertising, analytics/measurement, fraud prevention |
| Usage Data → Advertising Data | Yes | No | Yes, if ATT granted | Advertising |
| Diagnostics → Crash Data / Performance Data | No | — | — | No crash-reporting or analytics SDK integrated |
| Contact Info, Health, Financial Info, Location, Browsing History, Search History, User Content, Contacts | No | — | — | Not collected — no account system, no server, no location access requested |

## "Used to Track You" question

Apple asks explicitly whether data is used to track users across apps/websites owned by
other companies. Answer **Yes** — AdMob's advertising identifier use, when the user grants
App Tracking Transparency permission, meets Apple's definition of tracking. This is exactly
why the ATT prompt exists: declining it in the OS prompt means Bonjourney/AdMob does not
track the user (ads still show, just non-personalized), and iOS enforces this at the OS
level regardless of what's declared here.

## Data not linked to the user

If the form lets you distinguish "linked to identity" vs not: the advertising identifier is
device-level, not tied to a Bonjourney account (there is no account system), so where
Apple's form allows nuance, the honest answer is data collected but **not linked to a
Bonjourney-controlled user identity** — Apple/AdMob's own linkage (e.g. an ad network
correlating the ID across apps) is between the user, Apple, and Google, not something
Bonjourney's code does.

## Third-party partners

Declare **Google (AdMob)** as a third-party partner receiving the advertising identifier
and ad-interaction data described above.

## Re-check this whenever

- You change AdMob SDK versions (`google_mobile_ads` in `pubspec.yaml`) — Google
  periodically updates what the SDK collects.
- You add any other SDK (analytics, crash reporting, backend).
