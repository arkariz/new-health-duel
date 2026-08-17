# Release signing keystore

`android/app/upload-keystore.jks` + `android/key.properties` sign every release build. Both are
git-ignored (`android/.gitignore`) — neither has ever been committed, and neither should be.

## Why this matters more than a normal secret

Google Play identifies your app by the certificate its uploads are signed with. **If this keystore
is lost and the app has already been published, there is no way to publish an update to it again
under the same listing** — reviews, install count, and the Play Store URL are all tied to it. Losing
it means shipping the "same" app as a brand-new listing from zero.

(Play App Signing, once enrolled, lets Google re-sign your app with a separate app-signing key it
custodies — but you still need *this* upload key to authenticate each upload to Play in the first
place, and Google's key-loss recovery process for the upload key is itself a manual, days-long
identity-verification flow. Don't rely on it as a backup plan.)

## Back it up now

This file and the `.jks` next to it currently exist **only on this machine**. Before doing anything
else:

1. Copy `android/app/upload-keystore.jks` somewhere outside this machine — a password manager that
   supports file attachments, or encrypted cloud storage.
2. Store the `storePassword` / `keyPassword` from `key.properties` in a password manager.
3. Do **not** put either in a plain cloud drive folder, email, or chat history that isn't
   access-controlled.

## Setting up on a new machine / for a teammate

You already have the real keystore — don't generate a new one (see above). Instead:

1. Copy `upload-keystore.jks` into `android/app/`.
2. Copy `key.properties.example` in this directory to `key.properties`, fill in the real
   `storePassword` / `keyPassword` from your password manager.

## Generating a keystore from scratch (new project / never published before)

Only do this if no keystore exists yet for this app identity — i.e. `app.arkariz.healthduel` has
never had a release build signed and uploaded to Play.

```sh
keytool -genkeypair -v \
  -keystore upload-keystore.jks \
  -storetype JKS \
  -keyalg RSA -keysize 2048 -validity 10950 \
  -alias upload
```

Run from `android/app/`. `keytool` ships with any JDK (e.g. under `<Android Studio>/jbr/bin/` or a
JDK's `bin/` directory). Then create `key.properties` from the `.example` template next to this file.

## CI

Never commit the keystore or `key.properties`. Store the keystore as a base64-encoded CI secret and
the passwords as separate secrets; have the CI job decode the keystore to
`android/app/upload-keystore.jks` and write `android/key.properties` from secrets at build time,
before running `flutter build appbundle --release`.
