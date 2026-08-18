# Health Duel — MVP v1.0 Redefinition: "Play Store Launch"

**Status:** In progress · **Terakhir diupdate:** 2026-08-17
**Origin:** hasil sesi plan-mode "redefine MVP jadi lebih product-driven, harus bisa submit ke Play Store"

> **Resume di komputer lain? Baca dulu bagian "⚠️ Yang TIDAK ada di git" di bawah** sebelum lanjut coding — ada beberapa file secret yang sengaja gitignored dan harus dipindah manual.

---

## 📋 Progress Checklist

Legend: `[x]` selesai & terverifikasi · `[~]` sebagian / blocked · `[ ]` belum dikerjakan

### M0 — Play account (bukan kode, aksi manual di luar repo)
- [ ] Buat akun Google Play Developer ($25 one-time)
- [ ] Cek jenis akun (personal baru vs org) — personal baru butuh 12 tester × 14 hari closed test sebelum production
- [ ] Buat Firebase Android app baru untuk package id final (lihat M1 di bawah — **BLOCKED, butuh aksi user**)

### M1 — Gate B: build acceptable
- [x] `applicationId`/`namespace`: `com.example.health_duel` → **`app.arkariz.healthduel`** (commit `492da0f`)
- [x] `MainActivity.kt` dipindah ke `android/app/src/main/kotlin/app/arkariz/healthduel/`
- [x] Release keystore digenerate: `android/app/upload-keystore.jks` + `android/key.properties` (**gitignored, lihat bagian secrets**)
- [x] `signingConfigs.create("release")` wired di `build.gradle.kts`, fallback ke debug key kalau `key.properties` gak ada
- [x] **Bug pre-existing ditemukan & diperbaiki**: Kotlin Android Gradle plugin gak pernah di-apply di `app/build.gradle.kts` (cuma dideclare di `settings.gradle.kts` dengan `apply false`) — ini yang bikin build Android gak pernah sukses dari awal, dikonfirmasi dengan test di file original sebelum perubahan apapun
- [x] `targetSdk` 35 → 36 (deadline Play: 2026-08-31)
- [x] `android:label` → `"Health Duel"`
- [x] Hapus `WRITE_STEPS`/`Steps.WRITE` permission (gak pernah dipakai, cuma `READ`)
- [x] Hapus `_TestCredentialsHint` (kredensial `test@email.com/test123` yang render di production login screen)
- [x] Drop unused deps: `firebase_messaging`, `permission_handler`, `firestore` (git pkg), `cupertino_icons`; `dio` → dev-only
- [ ] **BLOCKED — butuh aksi user di Firebase Console**: regenerate `google-services.json` untuk package id baru. Langkah:
  1. Firebase console → project `health-duel` → Add app → Android → package name `app.arkariz.healthduel`
  2. Download `google-services.json` baru, replace `health_duel/android/app/google-services.json`
  3. Run `flutterfire configure` (atau update manual `lib/core/config/firebase_options.dart` — Android `appId` masih nunjuk ke app registration lama)
  4. Setelah upload pertama ke Play Console, tambahin **Play App Signing SHA-1 + upload-key SHA-1** ke Firebase project settings, kalau enggak Google Sign-In bakal break di production
- [x] App icon + adaptive icon (`flutter_launcher_icons`) — "Spark" bolt mark, brand green `#00E5A0` di atas `#080C10`
- [x] `isMinifyEnabled` + `proguard-rules.pro` — verified dengan `flutter build apk --release` sukses end-to-end (59.0MB), termasuk `isShrinkResources`
- [x] `android/key.properties.example` + `android/KEYSTORE_README.md` dibuat (template + dokumentasi backup/recovery)

### M2 — Gate A: legal + security
- [x] **M2.1 Firestore rules** (commit `4414e51`, `7d9dd62`) — `firestore.rules` mencakup `users/{uid}`, `users/{uid}/friends/{friendId}`, `duels/{duelId}` untuk semua write path yang ada sekarang. **Diverifikasi dengan emulator test suite: 34/34 pass** (naik dari 29 — M2.4 nambah rule + 5 test buat account-deletion anonymize) (`health_duel/firebase/test/rules.test.js`, run via `firebase emulators:exec`)
  - [x] Email dihapus total dari Firestore (`user_model.dart`, `friend_firestore_datasource.dart`, `friends_screen.dart` search card)
  - [x] `firebase.json` firestore block ditambah, `firestore.indexes.json` dipindah dari repo root ke `health_duel/`
  - [x] `.firebaserc` dibuat, project default `health-duel`
  - [x] `firebase deploy --only firestore:rules` ke project live — **selesai** (dikerjain user, token direfresh via `firebase login --reauth`; rule anonymize dari M2.4 dideploy terpisah setelahnya). Diverifikasi ulang dengan `--dry-run`: compile sukses, gak ada error auth lagi
- [x] **M2.2 P0 data-integrity bugs** — `cancelDuel` & `acceptDuel` di `duel_firestore_datasource.dart` sekarang guarded transaction (sebelumnya: participant bisa cancel duel yang lagi aktif). Dibackup dengan Firestore rules juga
- [x] **M2.3 Website** (Firebase Hosting free tier) — `/privacy` + `/delete-account`, **deployed** ke `health-duel.web.app`. ⚠️ Kontak email & nama developer masih placeholder (`TODO-privacy-contact@example.com`), ditandai jelas di kedua halaman — ganti sebelum submit ke Play
- [x] **M2.4 Settings screen + account deletion** — `features/account/` baru, `/settings` diregister di `app_router.dart`. Reauth-aware delete (password buat email/password, native Google picker buat Google), Firestore atomic wipe + anonymize, `RevokeHealthPermissions`, sign-out dipindah dari home app bar ke sini. **Diverifikasi run + debug beneran di emulator**, bukan cuma analyze/test
- [x] **M2.5 Health Connect rationale copy** — "Your data stays private" (yang gak akurat, karena steps di-share ke opponent) diganti jadi copy yang jujur (commit di step 1)
  - [ ] "Learn more" link ke `/privacy` belum ditambah (nunggu M2.3)
- [x] **M2.6 Crash reporting** — `firebase_crashlytics` ditambah, `main.dart` dibungkus `runZonedGuarded` + `FlutterError.onError` + `PlatformDispatcher.instance.onError`. Collection dimatikan di debug (`!kDebugMode`) biar gak spam dari hot reload. Diverifikasi: `flutter analyze` 0 error, `flutter build apk --release` sukses (58.9MB)
- [ ] **M2.7 Health Apps declaration form** — form di Play Console, tinggal isi (dependency: M1 permission cleanup udah selesai, jadi tinggal isi form pas submit)

### M3 — Gate C part 1: solo spine (belum dimulai)
- [ ] Solo challenge feature (`lib/features/challenge/` — entity, usecases, bloc, screens)
- [ ] Streak counter (`currentStreak`, `longestStreak`, `lastCompletedDate` di `users/{uid}`)
- [ ] `DuelMetric` abstraction (`challengerSteps`/`challengedSteps` → `challengerValue`/`challengedValue`, 49 occurrence di 9 file — **harus dikerjain sebelum ada data produksi**)

### M4 — Gate C part 2: duel via QR + typed code (belum dimulai)
- [ ] `invites/{code}` collection (domain/data/repo layer)
- [ ] Firestore rules untuk `invites/{code}` (belum ditambah ke `firestore.rules` — nunggu M4 jalan biar rule-nya match implementasi asli, bukan spekulatif)
- [ ] `InviteBloc` + QR screen + enter-code screen
- [ ] Rewrite `create_duel_screen.dart`, hapus `OpponentSource`/`GetOpponents` (unbounded read semua user doc)

### M5 — Local notifications (belum dimulai)
- [ ] `flutter_local_notifications` + `timezone` + `flutter_timezone`
- [ ] Schedule saat start (bukan saat lead berubah — itu butuh server, di-defer ke v2)

### M6 — Gate D: store listing + polish
- [x] Emoji loser 💪 → 🙇 disamain antara `duel_result_screen.dart` & `duel_card.dart` (udah match sama share card)
- [x] `login_page_test.dart` diperbaiki (assert ke elemen yang udah dihapus)
- [ ] 3 test yang masih merah (pre-existing, dikonfirmasi BUKAN dari perubahan sesi ini — lihat catatan di bawah)
- [ ] 40 analyzer info/warning yang masih ada (pre-existing)
- [ ] App icon, feature graphic, screenshot, Data Safety form, content rating

---

## ⚠️ Yang TIDAK ada di git — wajib dipindah manual ke komputer lain

Semua file di bawah ini **gitignored dengan sengaja** (secret / environment-specific) dan **cuma ada di komputer sekarang**. `git pull` di komputer lain TIDAK akan membawa file-file ini — tanpa mereka, build/run bakal gagal atau (lebih parah) diam-diam berjalan dengan config yang salah.

| File | Kenapa penting | Cara pindah |
|---|---|---|
| `health_duel/android/key.properties` | Password keystore release. **Kalau hilang & app udah pernah publish ke Play, gak bisa update lagi selamanya** dengan identity yang sama | Copy manual via password manager / encrypted storage. **JANGAN generate baru** — itu bikin identity signing berbeda |
| `health_duel/android/app/upload-keystore.jks` | Keystore file-nya sendiri | Sama seperti di atas — copy fisik file-nya, jangan generate ulang |
| `health_duel/android/app/google-services.json` | Firebase Android config. Tanpa ini, Firebase gak bisa init sama sekali | Download ulang dari Firebase console (project `health-duel`), atau copy dari komputer ini |
| `health_duel/lib/core/config/firebase_options.dart` | Config Firebase per-platform (Android/iOS/web) | Regenerate via `flutterfire configure`, atau copy dari komputer ini |
| `health_duel/.envs/dev.env`, `health_duel/.envs/prod.env` | Env vars per flavor (dipakai `envied`) | Copy manual, atau minta ke teammate |
| `health_duel/lib/env/env.g.dart` | Generated dari `.env` files di atas via `build_runner` | Regenerate: `flutter pub run build_runner build` setelah `.env` files ada |

**Detail lengkap keystore (backup, recovery, cara generate dari nol kalau memang belum pernah publish):** `health_duel/android/KEYSTORE_README.md` — file ini SUDAH ada di git.

**Kalau lupa mindahin semua ini**, build masih bisa jalan tapi:
- Tanpa `key.properties` → release build otomatis fallback ke debug signing (aman, gak akan ke-generate identity baru secara tidak sengaja, tapi gak bisa dipakai upload ke Play)
- Tanpa `google-services.json` / `firebase_options.dart` → build **gagal total** di step `processDebugGoogleServices` / Firebase init

---

## 🔨 Blocker aktif saat ini (per 2026-08-18)

Kedua blocker sebelumnya udah **selesai**:

1. ~~`google-services.json` perlu diregenerate~~ ✅ **Selesai** (dikerjain user). `flutter build apk --release --dart-define=FLAVOR=dev` sukses end-to-end pertama kalinya di repo ini (59.0MB, minify + shrinkResources aktif) — dulu gagal karena bug Kotlin plugin, terus gagal lagi di `processDebugGoogleServices`.
2. ~~Firestore rules belum di-deploy ke production~~ ✅ **Selesai** (dikerjain user via `firebase login --reauth`, lalu `firebase deploy --only firestore:rules`). Diverifikasi ulang dengan dry-run: compile sukses, gak ada error auth.

**Gak ada blocker aktif yang butuh aksi manual user saat ini.** Gate A (legal) dan Gate B (technical) kini realistis buat dianggap selesai — sisa kerjaan (M2.3 website, M2.4 settings/deletion, M2.6 crash reporting, M3+) semuanya bisa dikerjain langsung tanpa nunggu.

---

## Context

PRD lama (`health_duel/docs/01-product/prd-health-duels-1.0.md` §6) mendefinisikan MVP sebagai
**checklist 12 fitur**. Gak ada konsep *shippable* di situ — gak nyebut package ID, signing key,
Firestore rules, privacy policy, atau account deletion sama sekali, padahal itu semua yang beneran
berdiri antara repo ini dan listing di Play Store.

Drift-nya kelihatan jelas: sebulan terakhir kerjaan masuk ke offline action queue (825 LOC + 627 LOC
test, subsystem core baru, dan ADR-0006 yang secara eksplisit membalikkan keputusan ADR-0001 "no
offline queue for MVP") — satu checkbox di §8.2 — sementara **dua dari dua belas item MUST-HAVE
masih di angka nol** dan semua launch blocker belum disentuh.

Tapi masalah yang lebih dalam ada di product loop itu sendiri. Sekarang app ini gak ngasih value
apa-apa ke **satu orang**. Sebelum ada yang lihat satu duel pun:

> A install → sign up → grant Health Connect → mikirin mau tantang siapa → kirim invite → **lalu
> nunggu B** tap → install → sign up → grant Health Connect → accept

Sepuluh langkah, dua orang, dua kali install app. Redesign layar create-duel gak bakal nyelesain ini.
Dan konsekuensinya langsung, gak bisa dinego:

> **Reviewer Play install ini, buka, terus gak nemu apa-apa yang bisa dia lakuin.** Satu device, gak
> ada temen yang punya app, gak ada cara evaluasi core feature. Sama juga buat masing-masing dari 12
> closed tester kalau akunnya butuh itu.

Dokumen ini mendefinisikan ulang MVP di sekitar satu pertanyaan: **hal terkecil apa yang bisa kita
taruh di depan real user di Google Play?** Menggantikan checklist fitur dengan solo spine, social
upgrade, dan empat launch gate.

### Locked decisions

| Decision | Choice |
|---|---|
| Platform | **Android / Play Store only.** iOS → v1.1 (bundle ID masih `com.example.fintrackLite`, gak ada HealthKit entitlement, gak ada `GoogleService-Info.plist`) |
| Core loop | **Solo challenge + streak adalah spine-nya.** Duel adalah upgrade |
| Metric | **Steps only di v1**, tapi dibangun di atas `DuelMetric` abstraction. Lihat §Metrics |
| Duel start | **QR code + typed code.** Gak ada deep link, gak ada App Links, gak ada `assetlinks.json` |
| Push notifications | **v2.** Gak ada FCM, gak ada Cloud Functions, gak ada Blaze. Local notifications aja |
| "Challenge a random player" | **Dihapus** (membalikkan keputusan Phase 8) |
| Friends | **Dipertahankan**, dengan `email` dihapus dari Firestore |
| Hosting | **Firebase Hosting free tier** — cuma privacy policy + deletion page |
| Play account | **Belum ada** — lihat M0 |

---

## The loop

```
   SOLO SPINE  ── 1 orang, 3 langkah, jalan hari pertama di device baru
   grant health ──▶ set target ──▶ 24h progress ──▶ result ──▶ share card
                         ▲                            │
                         └──────── streak +1 ─────────┘

   SOCIAL UPGRADE  ── dua-duanya udah punya app, in-person atau lewat telpon
   "Duel a friend" ──▶ show QR / read out code ──▶ B scans atau types ──▶ duel starts
```

**Kenapa QR + typed code, bukan share link.** Persona di PRD sendiri itu in-person — "office
coworkers compete during lunch breaks", "couples motivate each other". QR di layar A yang di-scan B
lebih bagus dari link buat kasus-kasus itu: gak perlu ngetik, gak perlu pindah app, instant. Typed
8-char code nutup kasus "dibacain lewat telpon" dan paste ke chat.

Ini juga menghapus satu subsystem yang rawan gagal dari scope sama sekali: **gak ada App Links, gak
ada `assetlinks.json`, gak ada dependency ke Play-App-Signing fingerprint, gak ada hosting rewrite,
gak ada `PendingInvitePointer`, dan gak ada auth-redirect surgery** — karena B udah signed in dan
udah di dalam app pas scan. Kira-kira 200 LOC QR widget + `mobile_scanner` dibanding ~800 LOC
deep-link plumbing dengan empat failure mode berbeda.

Trade-off-nya: QR gak nyelesain masalah *acquisition* — B butuh app-nya dulu. Acceptable buat v1,
karena solo spine bikin user baru punya sesuatu buat dilakuin begitu install. Remote invite link
masuk v1.1.

---

## Metrics — evaluation and decision

Duel 24 jam butuh metric yang **akumulatif** (UI-nya progress bar lawan countdown) dan **adil antara
dua tubuh yang berbeda**.

| Metric | Akumulatif | Adil H2H | Cukup HP aja | Verdict |
|---|---|---|---|---|
| **Steps** | ✅ | ✅ | ✅ | **Default v1** |
| Distance (`DISTANCE_DELTA` / `DISTANCE_WALKING_RUNNING`) | ✅ | ⚠️ ~95% korelasi sama steps | ✅ | v1.1 — bagus, tapi hampir game yang sama |
| Active minutes (`EXERCISE_TIME`) | ✅ | ✅ gak tergantung tubuh | ⚠️ lebih baik pakai wearable | **v1.1 — metric kedua yang paling beda** |
| Active calories (`ACTIVE_ENERGY_BURNED`) | ✅ | ❌ beda ~2× tergantung berat badan | ⚠️ butuh weight/height | **Solo only** — gak adil head-to-head |
| Floors climbed | ✅ | ✅ | ⚠️ barometer, gak konsisten | Niche, skip |
| **Pace / `SPEED`** | ❌ **ini rate, bukan akumulasi** | ❌ | ✅ | **Gak cocok.** "Best pace in 24h" dimenangin sprint 10 detik; "average pace" konvergen ke ~0. Ini metric workout, bukan race akumulasi |
| Heart rate | ❌ | ❌ lebih tinggi ≠ lebih baik | ❌ | Enggak — eskalasi sensitivitas medis |

**Decision: v1 ship steps only, di atas abstraksi `DuelMetric`.**

1. **Migrasinya cuma gratis sekali ini.** `challengerSteps`/`challengedSteps` muncul **49 kali di 9
   file** (17 di `duel.dart` doang), plus DTO, Firestore rules, dan semua widget duel. Rename ke
   `challengerValue`/`challengedValue` + `DuelMetric { steps, distance, activeMinutes }` itu schema
   migration. **Sekarang belum ada data produksi** — setelah launch, biayanya jadi backfill, dual-read
   code, dan schema version field.
2. **Review Health Connect pertama itu yang paling berisiko.** App kesehatan yang baru pertama kali
   minta empat health permission bakal jauh lebih diperiksa ketat dibanding yang cuma minta
   `READ_STEPS` dengan justifikasi yang jelas. Approved dulu, baru expand — nambah permission di app
   yang udah established itu hal rutin.

**Asimetri yang bisa dimanfaatin:** solo challenge bisa nawarin metric yang duel gak bisa. Calories
gak adil head-to-head tapi fine kalau lawan diri sendiri. Model `DuelMetric` dengan flag
`supportsHeadToHead` dari awal.

---

## The four gates

> **v1 selesai kalau orang asing bisa install Health Duel dari Play Store, bikin step challenge buat
> diri sendiri, bangun streak, duel temen yang lagi di sebelahnya, share hasilnya, dan hapus akunnya.**

| Gate | Pertanyaan | Status |
|---|---|---|
| **A — Legal** | Google bisa list app ini secara legal? | ⚠️ Rules, website, account deletion, crash reporting semua selesai — sisa cuma ganti placeholder contact di `/privacy` & `/delete-account` sebelum submit |
| **B — Technical** | Play bakal terima upload-nya? | ✅ **Selesai** — signing, applicationId, google-services.json, icon, minify/proguard semua beres; `flutter build apk --release` sukses end-to-end |
| **C — Product loop** | Jalan buat satu orang di hari pertama? | ❌ solo loop belum dibangun |
| **D — Listing** | Ada store page yang layak di-tap? | ❌ belum ada apa-apa |

### Cut dari definisi MVP lama

| Item §6 lama | Nasib | Kenapa |
|---|---|---|
| #6 Push notifications | → **v2** | Butuh Blaze + Cloud Functions. Local notifications nutup 3 dari 4 requirement karena window 24 jam itu fully deterministic |
| #10 User profile (standalone) | → **dilebur ke Settings** | Stats gak launch-critical; Settings iya, karena Play wajibin in-app account deletion |
| #9 Friend invitation *links* | → **digantikan** duel code | Satu mekanisme, surface lebih kecil |
| Apple Sign-In | → **v1.1** | Android-only launch. Code tetep ada, tinggal gak ada button |
| Lead-change notifications | → **v2** | Satu-satunya notification yang beneran butuh server |
| "Challenge a random player" | → **dihapus** | Lihat M4 |

### Ditambah (yang gak ada sama sekali di PRD lama)

Solo challenge + streak · Firestore security rules · account deletion · privacy policy · release
signing · non-`com.example` package ID · Health Apps declaration · crash reporting · store listing
assets · Play developer account.

---

## M0 — Play account (mulai dari sekarang; latency multi-hari)

Bukan kode. Semua yang di bawah nunggu ini.

1. Buat akun — **$25 one-time**. Verifikasi identitas bisa berhari-hari, kadang berminggu.
2. Cek jenis akun. **Akun personal yang dibuat setelah Nov 2023 wajib jalanin closed test dengan 12
   tester opted-in selama 14 hari berturut-turut** sebelum bisa apply production access. Kalau iya,
   siapin 12 tester dari sekarang, dan anggap artifact pertama itu AAB *closed-testing*, bukan
   production.
3. Buat Firebase Android app production setelah package ID final dipilih (M1).

> **Timeline realistis:** verifikasi + closed test 14 hari bikin listing publik **4–6 minggu lagi**
> walaupun kode selesai besok. Solo spine penting juga di sini — tiap tester bisa evaluasi app
> sendirian tanpa perlu nyari partner.

---

## M1 — Gate B: make the build acceptable

Semua di `health_duel/android/`. Bukan feature work; semuanya hard reject kalau gak dikerjain.

| # | Change | File | Status |
|---|---|---|---|
| 1 | `applicationId` + `namespace`: `com.example.health_duel` → real ID. **Permanen begitu dipublish** | `android/app/build.gradle.kts:11,22` | ✅ `app.arkariz.healthduel` |
| 2 | Release keystore + `key.properties` + `signingConfigs.create("release")`. Dulu `release` pakai `signingConfigs.getByName("debug")` — Play reject upload yang debug-signed | `android/app/build.gradle.kts:31-37` | ✅ |
| 3 | `targetSdk` 35 → **36** (deadline Play: **2026-08-31**) | `android/app/build.gradle.kts:26` | ✅ |
| 4 | `android:label="health_duel"` → `"Health Duel"` | `AndroidManifest.xml:20` | ✅ |
| 5 | Hapus `WRITE_STEPS` + `Steps.WRITE` — dideclare, gak pernah dipakai (`_accessTypes = [HealthDataAccess.READ]`). Health-write permission yang gak dipakai itu penyebab rejection yang umum | `AndroidManifest.xml:8,12` | ✅ |
| 6 | Icon asli + adaptive icon (`mipmap-anydpi-v26/`) — "Spark" bolt mark (brand green `#00E5A0` / bg `#080C10`), generated via `flutter_launcher_icons` dari `assets/icon/icon_master.png` + `icon_foreground.png` | `pubspec.yaml`, `android/app/src/main/res/mipmap-*` | ✅ |
| 7 | **Hapus `_TestCredentialsHint`** — render `test@email.com / test123` unconditional, gak ada guard `kDebugMode` | `login_form.dart:293-337`, dipakai di `:128` | ✅ |
| 8 | Drop unused deps: `firebase_messaging`, `permission_handler`, `firestore` (git), `cupertino_icons`; pindahin `dio` ke dev | `pubspec.yaml` | ✅ |
| 9 | Regenerate `google-services.json` buat ID baru; tambahin **Play App Signing SHA-1 + upload-key SHA-1** ke Firebase kalau gak **Google Sign-In break di production** | Firebase console | ⬜ **BLOCKED — aksi user** |
| 10 | `isMinifyEnabled` + `isShrinkResources` + `proguard-rules.pro` (play-core `dontwarn` landmine + grpc/firestore optional-dep `dontwarn`) | `android/app/build.gradle.kts`, `android/app/proguard-rules.pro` | ✅ |

**Bonus temuan yang gak ada di plan awal:** Kotlin Android Gradle plugin dideclare di
`settings.gradle.kts` (`apply false`) tapi **gak pernah di-apply** di `app/build.gradle.kts`. Ini
sebabnya `flutter build apk` gak pernah sukses dari awal — dikonfirmasi dengan test di file original
sebelum ada perubahan apapun dari sesi ini. Fix: tambahin `id("org.jetbrains.kotlin.android")` ke
`plugins {}` block. **Sudah diperbaiki.**

**Flavor trap:** gak ada gradle product flavor sama sekali — `Env` itu Dart-only. Build pakai
`--dart-define=FLAVOR=prod`, jangan pernah `--flavor prod`. `env.dart:14` diam-diam fallback ke
config **dev** kalau define-nya kelewat, jadi AAB release bisa keship nunjuk ke dev tanpa error.

---

## M2 — Gate A: legal + security

### M2.1 Firestore rules — kerjaan paling high-leverage di sini ✅

**Gak ada `firestore.rules` sama sekali, dan gak pernah dicommit sebelumnya.** Database jalan di apa
pun yang ada di console, kemungkinan besar default test template yang udah expired. Di app
client-only tanpa Cloud Functions, **rules ini adalah seluruh security model.**

**Status: file udah dibuat dan diverifikasi lewat emulator (29/29 test pass), belum di-deploy ke
production** (lihat blocker section di atas).

- **`users/{uid}`** — write cuma owner; readable oleh signed-in user manapun buat friend search.
  **Berhenti nulis `email` ke doc** (`user_model.dart:58-63`, `firebase_session_data_source.dart`).
  Rules cuma bisa restrict *document*, bukan *field*, jadi gak nampilin email di UI itu bukan fix.
  Email user sendiri udah ada di Firebase Auth; email user lain gak pernah dibutuhkan. Dihapus juga
  dari `users/{uid}/friends/{friendId}` (`friend_firestore_datasource.dart`) dan `friends_screen.dart`.
- **`duels/{id}`** — `get`/`list` cuma buat `uid() in resource.data.participants`.
- **Field-level value protection** — dua `allow update` terpisah biar tiap participant cuma bisa
  nulis field value miliknya sendiri. Dulu `updateStepCount`
  (`duel_firestore_datasource.dart:281-301`) milih nama field **client-side**, jadi participant bisa
  overwrite skor lawan.
- **Status guard di tiap transition** — nutup lubang `cancelDuel` (M2.2).
- **Clock-skew bound** — semua keputusan waktu itu client `DateTime.now()`. Dibatasi dengan
  `request.time ± 60s` dan `endTime == startTime + 24h`.
- **`invites/{code}`** — **belum ditambah ke rules file** (nunggu M4 beneran jalan biar rule-nya
  match implementasi asli, bukan spekulatif).

**Diverifikasi pakai emulator.** `@firebase/rules-unit-testing` — Node toolchain di repo Flutter,
tapi tetep dikerjain; `flutter test` gak bisa nyentuh rules ini dan itu adalah seluruh security
model. Test suite ada di `health_duel/firebase/test/rules.test.js`, cara jalanin ada di
`health_duel/firebase/README.md`. **29/29 pass**, meng-cover: enumeration denied, cancel-active
denied (P0 fix), opponent-writes-my-value denied (field-level fix), skewed-clock create denied, dan
lain-lain.

> **Jujur di listing:** value itu client-sourced dari Health Connect. Rules ini nyetop *opponent*
> ngutak-atik skor *kamu*; gak nyetop orang yang inflate skor sendiri. Caveat yang sama berlaku buat
> streak counter. v1 itu trust-based antara orang yang saling kenal.

### M2.2 Two P0 data-integrity bugs ✅

- `cancelDuel` (`duel_firestore_datasource.dart:178-182`) dulu unguarded
  `update({'status': 'cancelled'})` — **participant bisa cancel duel yang lagi live.** Sekarang
  guarded transaction, matching pattern `completeDuel`.
- `acceptDuel` juga sama, sekarang guarded (cek status pending + belum lewat deadline).
- Dibackup dengan Firestore rules juga.

### M2.3 The website (Firebase Hosting, free Spark tier) ✅

`health_duel/public/` → **live** di `health-duel.web.app`. Plain HTML/CSS, gak ada JS/build step,
`hosting` block ditambah ke `firebase.json` (clean URLs, no trailing slash).

- `/privacy` — data yang dikumpulin (nama, foto, step count via `READ_STEPS`), bahwa value
  di-share ke opponent duel selama duel aktif, caveat trust-based security model (konsisten sama
  M2.5), cara hapus data.
- `/delete-account` — instruksi in-app (`Settings → Delete Account`, asumsi M2.4 udah jalan), apa
  yang dihapus vs. di-anonymize (duel record lawan tetap ada tapi gak bisa ditrace balik ke kamu),
  plus fallback manual via email buat yang gak bisa akses app lagi.
- ⚠️ **Kontak email & nama developer masih placeholder** (`TODO-privacy-contact@example.com`,
  `TODO: developer/entity name`) — ditandai jelas dengan banner di kedua halaman. **Wajib diganti
  sebelum halaman ini dipakai buat submit ke Play Console.**

### M2.4 Account deletion — hard Play requirement ✅

`/settings` registered di `app_router.dart` (baru `features/account/`, Settings gabung profile
display + sign-out + delete account, EffectBloc pattern). Sign-out dipindah dari home app bar ke
sini (`HomeBloc.HomeSignOutRequested` dihapus, gak dipakai lagi).

- **Reauth-aware deletion**: `AccountRepository.deleteAccount({password})` — password wajib buat
  akun email/password (`EmailAuthProvider.credential` + reauth), native Google picker buat akun
  Google (gak butuh input diketik). Reauth SELALU jalan duluan sebelum apapun yang destruktif, biar
  gak ada state "Firestore udah kehapus tapi Auth masih hidup" kalau reauth gagal di tengah.
- **Firestore wipe** (satu atomic `WriteBatch`): anonymize `challengerName`/`challengerPhotoUrl`
  (atau versi `challenged*`) di semua duel yang partisipasinya match `uid`, hapus
  `users/{uid}/friends/*`, hapus `users/{uid}`.
- **`firestore.rules` ditambah** — dua rule baru: participant boleh anonymize field nama/foto
  miliknya sendiri di duel doc, kapan aja, status apa aja (bukan cuma punya lawan, bukan bisa
  smuggle status/score change bareng). **Deployed ke production**, diverifikasi emulator: 34/34
  pass (naik dari 29 — 5 test baru buat rule ini).
- `RevokeHealthPermissions` usecase baru (health feature) — dipanggil best-effort setelah delete
  sukses, gak nge-block flow kalau gagal.
- Link ke `/privacy` di Settings (pakai `url_launcher`, dependency baru).
- **Diverifikasi run + debug beneran** di Android emulator (bukan cuma `flutter analyze`/`test`) —
  register → Settings screen → delete account flow dites end-to-end sama user.

Satu `SettingsScreen` minimal di `/settings`:
- display name + avatar (nyerap fitur "profile" yang dulu) + streak/stats
- **Delete account** — reauthenticate → hapus `users/{uid}`, `users/{uid}/friends/*`,
  `users/{uid}/challenges/*`; tombstone/anonymize duel docs; panggil `revokePermissions()` (udah
  ada di `health_platform_data_source.dart:203-213`, sekarang gak ada UI caller-nya); hapus Firebase
  Auth user
- link ke `/privacy`; pindahin sign-out ke sini dari home app bar

### M2.5 Health Connect rationale — copy-nya dulu salah ✅

`health_permission_view.dart` bilang **"Your data stays private"** padahal step count di-upload ke
Firestore dan dibaca opponent. Diganti jadi copy yang jujur:

> "Health Duel reads your step count to track duel progress. Your data is private and only shared
> with duel participants."

Link "Learn more" ke `/privacy` **belum ditambah** (nunggu M2.3 jadi).

### M2.6 Crash reporting ✅

`firebase_crashlytics: ^5.2.7` ditambah (`flutter pub add`, resolve otomatis compatible sama BOM
Firebase yang lain di project). `main.dart` sekarang:

- Seluruh `main()` dibungkus `runZonedGuarded` — nangkep error yang lolos dari Flutter framework
  error zone, termasuk yang kejadian sebelum `FlutterError.onError` sempat di-wire (mis. crash pas
  `initializeDependencies()`).
- `FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError` — widget-tree
  errors.
- `PlatformDispatcher.instance.onError` — uncaught async/platform errors di luar widget tree.
- `setCrashlyticsCollectionEnabled(!kDebugMode)` — collection mati total di debug build (hot
  reload/restart bukan crash beneran), otomatis nyala buat dev & prod flavor lainnya.
- Gak nambah Crashlytics Gradle plugin (`com.google.firebase.crashlytics`) di
  `android/app/build.gradle.kts` — itu cuma buat upload ProGuard mapping file (readable stack trace
  di release yang di-obfuscate), bukan syarat crash reporting basic buat nyala. Bisa ditambah nanti
  kalau stack trace release build susah dibaca di Crashlytics console.

**Diverifikasi:** `flutter analyze` → 0 error (baseline 40 info/warning gak berubah),
`flutter build apk --release` → sukses, 58.9MB (naik ~0.1MB dari M1, wajar buat SDK baru).

### M2.7 Health Apps declaration ⬜

Form di Play Console, tinggal diisi pas submit. Setelah M1 #5 (udah selesai), permintaannya minimal
dan defensible: **`READ_STEPS` doang**.

---

## M3 — Gate C, part 1: the solo spine (BELUM DIMULAI)

**Ini yang bikin app reviewable, testable, dan valuable buat satu orang.** Sebagian besar tinggal
nyelesain sesuatu yang udah ada di layar: `steps_hero_card_section.dart:22` udah render progress
ring lawan `const goal = 10000` yang hardcoded dengan copy *"of daily goal"* — tanpa persistence,
tanpa stakes, tanpa ending, tanpa result.

### Solo challenge
- User set target 24 jam (default suggestion 8,000; tawarin "beat yesterday" sebagai preset **cuma
  kalau ada history Health Connect** — device baru gak punya history, dan opponent 0-step itu duel
  yang trivially menang, persis yang bakal dilihat reviewer).
- Reuse furniture duel yang udah ada: progress bar, countdown, `SyncHealthData`, result screen,
  share card. Semantics window 24 jam sama kayak duel.
- Firestore `users/{uid}/challenges/{id}` — owner-only, **gak ada concurrency, gak ada transaction,
  gak ada multi-party rules.** Ini fitur paling simple di seluruh plan.

```
lib/features/challenge/
  domain/entities/solo_challenge.dart · value_objects/challenge_status.dart
  domain/repositories/solo_challenge_repository.dart
  domain/usecases/{start,get_active,complete,get_history}_solo_challenge.dart
  data/models/solo_challenge_dto.dart · datasources/... · repositories/...
  presentation/bloc/solo_challenge_bloc.dart (EffectBloc per ADR-0004)
  presentation/pages/{set_challenge,active_challenge}_screen.dart
```

### Streak
- `currentStreak`, `longestStreak`, `lastCompletedDate` di `users/{uid}` — owner-only write.
- Rule: kena target → +1; skip sehari → reset ke 0. Rollover di midnight **lokal**; simpan tanggal
  sebagai string `yyyy-MM-dd` lokal, bukan UTC timestamp, kalau enggak travel antar timezone bikin
  berantakan.
- Simple aja di v1 — gak ada streak freeze, gak ada grace period.
- Tampilin di home dan di share card.

### Metric abstraction (kerjain di sini, mumpung gratis)
Introduce `DuelMetric { steps, distance, activeMinutes }` dengan `unit`, `displayName`, dan
`supportsHeadToHead`. Rename `challengerSteps`/`challengedSteps` → `challengerValue`/`challengedValue`
di 9 file / 49 occurrence, plus DTO, rules, dan widget. **Ship cuma dengan `steps` yang selectable.**

---

## M4 — Gate C, part 2: duels via QR + typed code (BELUM DIMULAI)

```
invites/{CODE}   challengerId, challengerName, challengerPhotoUrl, metric,
                 status: open|claimed|revoked|expired,
                 claimedBy, claimedAt, duelId, createdAt, expiresAt

duels/{CODE}     ← doc ID == invite code, jadi "maksimal satu duel per invite"
                   di-enforce sama uniqueness dokumen Firestore sendiri. Dibuat
                   pas claim, dengan kedua participant udah diketahui, status: active.
```

**Kenapa collection terpisah, bukan `challengedId` yang nullable:** `challengedId` itu non-nullable
dan load-bearing di 10 tempat di entity `Duel`; bikin dia nullable bakal ripple ke semua query,
widget, dan test — dan `getSentDuels` filter `status == 'pending'`, jadi status `pendingInvite` baru
bakal diam-diam drop dari expiry sweep dan gak pernah expire.

**Format code:** 8 karakter, Crockford alphabet (`0-9A-Z` minus `I L O U`), ditampilin sebagai
`ABCD-EFGH`. 40 bit, typeable, unambiguous.

**Claim** itu satu `runTransaction`, idempotent buat user yang sama (mirror `completeDuel`):
not-found → expired → already-claimed → self-claim → create `duels/{CODE}` → mark invite claimed.

**UI:** A tap "Duel a friend" → full-screen QR + code gede + "First to accept gets the duel." B tap
"Scan" (`mobile_scanner`) atau "Enter code".

**Claiming HARUS TIDAK lewat offline queue** — deliberate departure dari semua duel action lain:
1. Firestore `runTransaction` **gak jalan sama sekali offline** (butuh round trip).
2. Compare-and-set di resource yang contended dengan TTL 24 jam — replay yang telat kemungkinan
   besar kena invite yang udah kebakar, munculin snackbar `ActionConflicted` yang membingungkan
   berjam-jam kemudian.
3. **Time-anchored** — claiming artinya "jam 24-nya mulai sekarang." Replay tiga jam kemudian diam-
   diam ngasih B duel yang mulai tiga jam setelah dia tekan Accept.

### Cut list
`OpponentSource` enum, `SegmentedButton` di create_duel_screen, `GetOpponents` use case + repo +
datasource method (**unbounded read semua user doc**), DI registration, `CreateDuelBloc._getOpponents`.

---

## M5 — Local notifications (BELUM DIMULAI)

`flutter_local_notifications` + `timezone` + `flutter_timezone`. Yang terakhir **wajib**: `tz.local`
default ke UTC kalau gak di-set, jadi notification 24-jam-lagi di device UTC+7 bakal geser 7 jam.

> ⚠️ **Play-policy landmine.** `AndroidScheduleMode.exactAllowWhileIdle` butuh `USE_EXACT_ALARM`,
> permission yang **dibatasi Play** cuma buat app alarm/calendar. Reminder step gak qualify dan
> **minta ini berisiko rejection.** Pakai `inexactAllowWhileIdle`.

Semua dijadwalin sekali, di main isolate, pas start time — karena window 24 jam itu fully
deterministic dari `endTime`. WorkManager isolate (`health_sync_background_task.dart`) tetep cuma
pegang satu job: sync value.

---

## M6 — Gate D: store listing + polish

- [x] Emoji loser 💪 → 🙇 disamain
- [x] `login_page_test.dart` diperbaiki
- [ ] App icon (512×512), feature graphic (1024×500), ≥2 screenshot, Data Safety form
- [ ] 3 test yang masih merah (**dikonfirmasi pre-existing, bukan regression dari sesi ini** — lihat
      catatan verifikasi di bawah)
- [ ] 40 analyzer info/warning (pre-existing, gak ada yang baru dari sesi ini)

---

## Verifikasi yang udah dijalanin sesi ini

- `flutter analyze` → 0 error di semua step (40 info/warning pre-existing, konsisten sebelum-sesudah)
- `flutter test` → 237 pass / 3 fail di semua step, **3 failure yang sama** dikonfirmasi pre-existing
  dan deterministic (dijalanin sendiri-sendiri, gak flaky):
  - `active_duel_screen_test.dart`: "shows participant names on DuelLoaded" — stale "Opponent" text
  - `create_duel_screen_test.dart`: "shows error state on CreateDuelFailure" — RenderFlex overflow 12px
  - `duel_list_screen_test.dart`: "shows duel card when active duel is present" — stale "Opponent" text
- `firebase emulators:exec` + mocha → **29/29 rules test pass**, dijalanin dengan JDK 21 dari Android
  Studio bundled runtime (`Program Files/Android/Android Studio/jbr/bin`) karena firebase-tools
  butuh Java 21+ buat emulator, sedangkan default `JAVA_HOME` di mesin ini masih JDK 17
- `flutter build apk --debug --dart-define=FLAVOR=dev` → gagal di step **`processDebugGoogleServices`**
  dengan error `No matching client found for package name 'app.arkariz.healthduel'` — **ini expected
  dan confirms semua config sebelumnya bener**; satu-satunya yang nyisa adalah regenerate
  `google-services.json` (butuh akses Firebase console, lihat blocker section)

---

## Explicitly OUT of scope for v1

FCM + Cloud Functions · lead-change notifications · remote invite links / App Links · iOS · Apple
Sign-In · metrics selain steps (abstraksi dibangun, cuma steps yang enabled) · standalone profile
screen · friend invitation links · challenge-a-random-player / matchmaking · password reset · email
verification · onboarding tutorial · streak freezes · group duels · server-side anti-cheat.

---

## Doc updates yang diimplikasikan plan ini (belum dikerjain)

- Rewrite PRD §6 di sekitar solo spine + social upgrade dan four gates; pindahin item yang dicut ke §12
- Update status header yang stale (masih "~47% as of 2026-07-09"; terakhir disentuh 2026-07-17)
- **Buat ADR-0005 yang hilang** — folder ADR loncat 0004 → 0006, dan PRD §10 & §14 dua-duanya link
  ke `0005-design-token-strategy.md`, yang gak ada
- ADR baru: "Client-only security model — Firestore rules as the sole authority"
- ADR baru: "Solo challenge as the primary loop; duels as an upgrade"
- ADR baru: "QR + typed code over deep links for duel initiation"
- ADR baru: "Metric abstraction, steps-only launch"
- Amend FR-FRIEND-001 buat describe search+add (yang beneran dibangun) bukan invitation links

---

## Cara lanjut di sesi berikutnya (checklist singkat)

1. Baca bagian "⚠️ Yang TIDAK ada di git" di atas, pastiin semua file secret udah dipindah kalau ganti komputer
2. **Gate A dan Gate B selesai total** (M1, M2.1–M2.4, M2.6) — gak ada blocker manual yang nyisa
3. **Ganti placeholder contact** di `/privacy` & `/delete-account` (`TODO-privacy-contact@example.com`, `TODO: developer/entity name`) sebelum submit ke Play — satu-satunya utang yang masih nyisa dari Gate A
4. M2.7 (Health Apps declaration form) tinggal isi form di Play Console pas submit — bukan kerjaan kode
5. M3 (solo spine) adalah kerjaan produk paling besar & paling penting yang belum disentuh sama sekali — prioritas berikutnya, dan satu-satunya yang nyisa buat Gate C
6. M4 (duel via QR) dan M5 (local notifications) nunggu M3 kelar; M6 (store listing) independen, bisa disiapin kapan aja
