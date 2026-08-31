# Manual certificate & provisioning profile — step by step

Codemagic's automatic signing (`app-store-connect fetch-signing-files ... --create`) failed
with `No matching profiles found for bundle identifier "com.bonjourney.app" and
distribution type "app_store"`. This is the manual fallback: generate a Distribution
certificate and an App Store provisioning profile yourself, then upload both to Codemagic.

**No Mac needed** — every step below runs from Apple's website plus `openssl`, which
ships with Git for Windows (so it's already available in the same Git Bash you've been
running `!` commands in).

## Before you start

Confirm the App ID is actually registered — this is the most common cause of the error
above. Apple Developer portal → **Certificates, IDs & Profiles → Identifiers** → check
`com.bonjourney.app` is listed. If it isn't, add it there first (see
[`README.md`](README.md) step 2) — a provisioning profile can't be created for an
unregistered App ID no matter which method you use.

## 1. Generate a Certificate Signing Request (CSR)

In a terminal (Git Bash), in any folder outside this project (these files are your private
key material — don't commit them):

```bash
openssl genrsa -out ios_distribution.key 2048
openssl req -new -key ios_distribution.key -out ios_distribution.csr \
  -subj "/emailAddress=YOUR_APPLE_ID_EMAIL/CN=YOUR_NAME/C=US"
```

Replace `YOUR_APPLE_ID_EMAIL` and `YOUR_NAME`. This produces two files:
- `ios_distribution.key` — your private key. **Keep this. Never share or commit it.**
- `ios_distribution.csr` — upload this to Apple in the next step.

## 2. Create the Distribution certificate in Apple Developer portal

Apple Developer portal → **Certificates, IDs & Profiles → Certificates → +**
- Certificate type: **Apple Distribution** (covers both App Store and Ad Hoc — pick this,
  not the older "iOS Distribution" if both are shown)
- Upload `ios_distribution.csr` from step 1
- Download the resulting certificate — it downloads as `distribution.cer`

## 3. Convert the certificate into a .p12 (cert + private key bundled together)

```bash
openssl x509 -in distribution.cer -inform DER -out distribution.pem -outform PEM
openssl pkcs12 -export -inkey ios_distribution.key -in distribution.pem \
  -out ios_distribution.p12 -name "Bonjourney iOS Distribution"
```

You'll be prompted to set an **export password** — pick one and remember it, you'll enter
it into Codemagic in step 6.

## 4. Create the App Store provisioning profile

Apple Developer portal → **Certificates, IDs & Profiles → Profiles → +**
- Distribution type: **App Store** (under App Store Connect distribution)
- App ID: `com.bonjourney.app`
- Certificate: select the Apple Distribution certificate from step 2
- Name it something recognizable, e.g. `Bonjourney App Store`
- Generate and **download** — it saves as a `.mobileprovision` file

## 5. Upload both to Codemagic

Codemagic → your app → **Code signing identities** (may also be under Team settings
depending on your Codemagic plan/UI version):
- **iOS certificates** → upload `ios_distribution.p12` + the export password from step 3
- **iOS provisioning profiles** → upload the `.mobileprovision` file from step 4

Once both are uploaded, `codemagic.yaml`'s `ios_signing` block (already set to
`distribution_type: app_store`, `bundle_identifier: com.bonjourney.app`) matches them
automatically during the build — no other yaml changes needed. The `codemagic.yaml` in
this repo has already been switched from the automatic `app-store-connect
fetch-signing-files` step to just `keychain add-certificates` + `xcode-project
use-profiles`, which reads whatever you uploaded here.

## 6. Retry the build

Trigger a new Codemagic build (push to `main`, or **Start new build**). The signing step
should now find the manually uploaded certificate and profile.

## If it still fails

- **"No matching profiles"** again → double check the bundle identifier in the profile
  (step 4) is exactly `com.bonjourney.app`, and the profile's distribution type is App
  Store (not Ad Hoc / Development).
- **Certificate/profile mismatch** → the profile in step 4 must be built from the *same*
  certificate uploaded in step 5 — if you regenerate the certificate later, you must also
  regenerate and re-download the profile (profiles embed the certificate, they're not
  independent).
- **Expired certificate** → Apple Distribution certificates last 1 year; when it expires,
  repeat steps 1-5 with a fresh CSR.

## Keep these safe

Store `ios_distribution.key` and `ios_distribution.p12` (plus its export password)
somewhere durable outside this project folder — same advice as the Android keystore in
`../store-listing/signing.md`. Losing the private key means starting over from step 1 with
a new certificate (and a new provisioning profile to match it).
