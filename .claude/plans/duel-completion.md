# Plan: Duel Completion — Selesaikan Duel Saat Waktu 24 Jam Habis

> **Status:** Disetujui, BELUM diimplementasikan (0 perubahan kode).
> **Dibuat:** 2026-07-05 · Siap dieksekusi oleh sesi/model lain.
> **Verifikasi env:** fvm Flutter `C:\Users\arkariz\fvm\default\bin\flutter.bat` (PowerShell,
> `flutter` tidak ada di bash PATH). Cek `git diff pubspec.lock` setelah analyze/test — sering drift.

## Context

Saat waktu duel habis, **tidak terjadi apa-apa**: tidak ada satu pun kode yang menulis
`status: completed` / `winnerId` / `completedAt` ke Firestore. Komentar di `DuelBloc`
mengasumsikan Cloud Functions yang menyelesaikan duel — tapi functions itu **tidak ada
di repo**. Akibatnya dokumen duel tetap `active` selamanya:

- Duel expired terus muncul di tab **Active** (query `status == active`)
- Tab **History** selamanya kosong (query `status == completed`)
- `DuelResultScreen` tidak pernah bisa diakses (satu-satunya jalur = tap card History)
- Deteksi expiry di countdown tick rusak: `duel.isExpired && duel.isActive` saling
  kontradiksi (`isActive => !isExpired`) — event `DuelCompletionDetected` tak pernah fire
- **Bug tersembunyi ke-2**: `_onUpdateSucceeded` branch `duel.isCompleted` (yang true
  untuk duel expired-tapi-masih-active) langsung `_cancelTimers()` → membuka duel yang
  sudah expired mematikan countdown timer pada emisi stream pertama

**Keputusan produk (sudah dikonfirmasi user):**
1. **Time-based saja** — duel selesai saat `endTime` (24 jam) lewat. TIDAK ada step goal
   (konsep goal memang tidak ada di data model & PRD).
2. **Client-side completion** via Firestore transaction (idempotent — dua partisipan
   bisa mendeteksi bersamaan).
3. **Auto-navigate ke Result screen** saat selesai (pakai `NavigatePushEffect` yang
   sudah ada di effect system).

---

## Langkah Implementasi

### 1. Entity — getter baru
`health_duel/lib/features/duel/domain/entities/duel.dart` (tepat setelah `isExpired`, ~line 78):
```dart
/// Duel is past its end time but Firestore still says `active` —
/// the client must finalize it (write completed status + winner).
bool get needsCompletion =>
    status == DuelStatus.active && DateTime.now().isAfter(endTime);
```
Getter lama (`isExpired`/`isActive`/`isCompleted`) TIDAK diubah — dipakai
`remainingTime`, `result`, guard Result screen, dan test existing.

### 2. Data layer
**Datasource** `health_duel/lib/features/duel/data/datasources/duel_firestore_datasource.dart` —
method baru `Future<DuelDto> completeDuel(String duelId)`:
- `_firestore.runTransaction`: `transaction.get(docRef)` →
  - doc tidak ada → throw `Exception('Duel not found: $duelId')` (pola `getDuelById`)
  - `status != DuelStatus.active.name` → return tanpa menulis (**idempotent success** —
    pihak lain sudah menyelesaikan; transaction retry otomatis menangani race)
  - `DateTime.now().isBefore(endTime)` →
    `throw const ValidationFailure(message: 'Duel has not ended yet')`
    (`Failure implements Exception` di `lib/core/error/failures.dart:6`, jadi bisa di-throw;
    perlu import `package:health_duel/core/error/failures.dart`)
  - else: hitung `winnerId` = pemilik steps lebih tinggi (`challengerSteps` vs
    `challengedSteps` di data doc), `null` jika seri; lalu
    `transaction.update(docRef, {'status': DuelStatus.completed.name,
    'winnerId': winnerId, 'completedAt': Timestamp.fromDate(endTime)})`
- Setelah transaction commit: `return getDuelById(duelId)` (pola "update lalu get" yang
  sama dengan `acceptDuel`/`updateStepCount` di file yang sama)
- **`completedAt = endTime`** (bukan serverTimestamp): PRD bilang pemenang dihitung
  tepat di tanda 24 jam; deterministik & idempotent walau sweep terlambat berhari-hari;
  ordering `getDuelHistory` (orderBy completedAt desc) tetap benar; dua client yang
  race menghasilkan payload identik.

**Interface** `health_duel/lib/features/duel/domain/repositories/duel_repository.dart`
(setelah `cancelDuel`, ~line 40):
```dart
/// Finalize an expired active duel (client-side completion)
///
/// Writes status=completed, winnerId (null on tie), completedAt=endTime
/// atomically via Firestore transaction. Idempotent: returns the duel
/// unchanged if it is already completed/cancelled.
///
/// Returns completed [Duel] or [Failure].
Future<Either<Failure, Duel>> completeDuel(String duelId);
```

**Impl** `health_duel/lib/features/duel/data/repositories/duel_repository_impl.dart` —
try/catch gaya existing, tapi tangkap `Failure` DULU agar ValidationFailure lolos utuh:
```dart
@override
Future<Either<Failure, Duel>> completeDuel(String duelId) async {
  try {
    final duelDto = await _dataSource.completeDuel(duelId);
    return Right(duelDto.toEntity());
  } on Failure catch (failure) {
    return Left(failure);
  } catch (e) {
    return Left(ServerFailure(message: 'Failed to complete duel: $e'));
  }
}
```

### 3. Use case
Baru: `health_duel/lib/features/duel/domain/usecases/complete_duel.dart` — thin delegation
(validasi HARUS di dalam transaction agar race-safe; pre-read hanya menambah TOCTOU):
```dart
class CompleteDuel {
  const CompleteDuel(this._repository);
  final DuelRepository _repository;
  Future<Either<Failure, Duel>> call(String duelId) => _repository.completeDuel(duelId);
}
```
Export dari `health_duel/lib/features/duel/domain/domain.dart` (bagian "Use Cases",
urut alfabet: setelah `accept_duel.dart`... → `export 'usecases/complete_duel.dart';`).

### 4. DI — `health_duel/lib/features/duel/di/duel_module.dart`
File ini pakai cascade `getIt..registerFactory(...)..`:
- Tambah `..registerFactory(() => CompleteDuel(getIt<DuelRepository>()))` di blok use case
- Tambah `completeDuel: getIt<CompleteDuel>(),` ke factory `DuelBloc` **dan** `DuelListBloc`

### 5. DuelBloc — `health_duel/lib/features/duel/presentation/bloc/duel_bloc.dart`
- Constructor: `required CompleteDuel completeDuel` → field `_completeDuel`
  (catatan: file sudah direformat very_good_analysis — field SETELAH constructor)
- Import `package:health_duel/core/router/routes.dart`
- Guard flags (field baru, reset ke `false` di awal `_onLoadRequested`):
  `bool _completionHandled = false;` dan `bool _navigatedToResult = false;`
- **`_onUpdateSucceeded`** (line ~128) — ganti branch `if (duel.isCompleted)` jadi dua:
  1. `if (duel.status == DuelStatus.completed)` (otoritatif dari Firestore — ditulis
     oleh kita/lawan/sweep): set kedua flag; emit `DuelLoaded(duel, currentTime,
     lastSyncTime carry-over)` dengan `effect: _navigatedToResult sebelumnya ? null :
     _effectNavigateToResult(duel)`; `_cancelTimers()`; return.
     (Perlu import DuelStatus — sudah tersedia via `domain/domain.dart` barrel.)
  2. `if (duel.needsCompletion && !_completionHandled)`: set `_completionHandled = true`,
     cancel HANYA `_countdownTimer` (`_countdownTimer?.cancel(); _countdownTimer = null;`),
     `add(DuelCompletionDetected(duel.id))`, lalu **lanjut** ke emit normal di bawah
     → duel yang sudah expired langsung diselesaikan pada emisi stream pertama (fix bug #2)
- **`_onCountdownTick`** (line ~213): emit `currentTime` seperti sekarang, lalu ganti
  kondisi rusak `isExpired && isActive` dengan:
  `if (!_completionHandled && currentState.duel.needsCompletion)` → set flag, cancel
  countdown timer, `add(DuelCompletionDetected(currentState.duel.id))`
- **`_onCompletionDetected`** (line ~229) — ganti seluruh body:
  `final result = await _completeDuel(event.duelId);`
  - sukses `(completedDuel)`: `_cancelTimers()`; emit `DuelLoaded(duel: completedDuel,
    currentTime: now, lastSyncTime carry-over, effect: _navigatedToResult ? null :
    _effectNavigateToResult(completedDuel))`; set `_navigatedToResult = true`
  - gagal: fallback snackbar seperti sekarang —
    `if (state is DuelLoaded) emit(current.copyWith(effect: _effectDuelCompleted(current.duel.result)))`
    (valid karena `isExpired ⇒ isCompleted` sehingga `result` tidak throw);
    JANGAN reset `_completionHandled` — stream masih hidup, branch 1 akan navigate
    saat pihak lain menyelesaikannya
- Helper baru di `duel_side_effect.dart` (part file — bisa akses `_currentUserId`):
```dart
/// Navigate to duel result screen after completion
NavigatePushEffect _effectNavigateToResult(Duel duel) => NavigatePushEffect(
      route: AppRoutes.duelResultPath(duel.id),
      arguments: {'duel': duel, 'currentUserId': _currentUserId ?? ''},
    );
```
- **Tidak ada perubahan screen**: `ActiveDuelScreen` sudah dibungkus `EffectListener`,
  `effect_handlers.dart` sudah handle `NavigatePushEffect` → `context.push(route,
  extra: arguments)`, dan route `duelResult` (`/duel/:id/result`,
  `AppRoutes.duelResultPath(id)`) sudah menerima extra `{'duel': Duel,
  'currentUserId': String}` (lihat `app_router.dart` ~130-146).

### 6. DuelListBloc sweep — `health_duel/lib/features/duel/presentation/bloc/duel_list_bloc.dart`
- Constructor: tambah `required CompleteDuel completeDuel` (dep ke-8) → `_completeDuel`
- Di `_onLoadRequested`, setelah tiga cek `isLeft` dan SEBELUM
  `emit(DuelListLoaded(...))` pertama:
```dart
var activeList = activeResult.getOrElse(() => []);
var historyList = historyResult.getOrElse(() => []);
final expired = activeList.where((d) => d.needsCompletion).toList();
if (expired.isNotEmpty) {
  for (final duel in expired) {
    await _completeDuel(duel.id); // kegagalan non-fatal, abaikan Either
  }
  final refreshedActive = await _getActiveDuels(event.userId);
  final refreshedHistory = await _getDuelHistory(event.userId);
  activeList = refreshedActive.getOrElse(() => activeList);
  historyList = refreshedHistory.getOrElse(() => historyList);
}
```
  lalu emit `DuelListLoaded(activeDuels: activeList, ..., historyDuels: historyList)`.
  Blok health-sync existing di bawahnya memakai `activeList` hasil sweep.
- → duel expired pindah ke History walau user tidak pernah membuka duel screen.
- Ekspektasi test existing TIDAK berubah (`tActiveDuel` tidak expired → sweep no-op).

### 7. Tests
- **`health_duel/test/helpers/mocks.dart`**:
  - `class MockCompleteDuel extends Mock implements CompleteDuel {}`
  - Extension `MockCompleteDuelX` dengan `setupSuccess(String duelId, Duel duel)` /
    `setupFailure(String duelId, Failure failure)` — ikuti pola `MockAcceptDuelX`
    (`when(() => call(duelId)).thenAnswer(...)`)
  - Import `package:health_duel/features/duel/domain/usecases/complete_duel.dart`
- **`health_duel/test/helpers/fixtures.dart`**: getter runtime (karena `needsCompletion`
  pakai `DateTime.now()` — ikuti pola `tActiveStartTime` yang sudah ada):
  - `tExpiredActiveDuel` — status active, endTime = now−1h, startTime = now−25h,
    steps 1500 vs 1200, id `tDuelId`
  - `tJustCompletedDuel` — sama tapi status completed, `completedAt` = endTime
  - `tExpiredTiedDuel` — status active expired, steps sama (mis. 1500 vs 1500)
- **Baru** `test/features/duel/domain/usecases/complete_duel_test.dart`
  (gaya `accept_duel_test.dart`): delegasi sukses → Right(duel); propagasi
  ServerFailure; propagasi ValidationFailure
- **`test/features/duel/data/repositories/duel_repository_impl_test.dart`**:
  completeDuel sukses → Right(entity); datasource throw exception generik →
  Left(ServerFailure); datasource throw ValidationFailure → Left(ValidationFailure) utuh
- **`test/features/duel/bloc/duel_bloc_test.dart`**:
  - Tambah `late MockCompleteDuel mockCompleteDuel;` + init di setUp + param di `buildBloc()`
  - **Update test existing** "emits DuelLoaded with duel completed effect when duel is
    completed" (~line 93-102, pakai `tCompletedDuel`): ekspektasi effect berubah dari
    `ShowSnackBarEffect` → `NavigatePushEffect`
  - Test baru: stream update duel expired-active (`tExpiredActiveDuel`) → memicu
    `CompleteDuel` (`verify(() => mockCompleteDuel(tDuelId)).called(1)`) lalu emit
    state dengan `NavigatePushEffect`
  - Test baru: echo stream setelah completion (kirim `tJustCompletedDuel` dua kali) →
    navigasi HANYA sekali (emisi kedua tanpa `NavigatePushEffect`)
  - Test baru: `CompleteDuel` gagal → fallback `ShowSnackBarEffect`
  - Test baru: kasus seri (`tExpiredTiedDuel`) → tetap complete + navigate
- **`test/features/duel/bloc/duel_list_bloc_test.dart`**:
  - Tambah mock ke `buildBloc` (ekspektasi existing tetap — `tActiveDuel` tidak expired)
  - Test baru: sweep — `getActiveDuels` awal return `[tExpiredActiveDuel]`, setelah
    `completeDuel` dipanggil, refetch return `[]` + history `[tJustCompletedDuel]`
    (stub jawaban berurutan dengan list of answers / counter) → `DuelListLoaded` akhir:
    active kosong, history berisi; `verify(() => mockCompleteDuel(...)).called(1)`
  - Test baru: `completeDuel` gagal → tetap emit `DuelListLoaded` (non-fatal)
- Widget test pakai `MockDuelBloc`/`MockDuelListBloc` (MockBloc — tidak tergantung
  constructor) → tidak perlu diubah
- Transaction datasource: tidak ada test datasource & dep `fake_cloud_firestore` di
  proyek → dibiarkan tanpa unit test (konsisten dengan datasource lain)

### 8. Urutan pengerjaan
Entity → datasource + interface + impl → use case + barrel → DuelBloc → DuelListBloc →
DI → mocks/fixtures + test → verifikasi.

---

## Verifikasi

1. `flutter analyze` (fvm, via PowerShell) → 0 error (2 warning removed_lint di
   analysis_options.yaml adalah pre-existing)
2. `flutter test` → semua pass. Catatan: 3 widget test `duel_list_screen_test.dart`
   SUDAH gagal sebelumnya (mencari teks "Opponent" sisa refactor) — pre-existing,
   di luar scope plan ini
3. **Cek `git diff pubspec.lock` setelah analyze/test** — kembalikan jika drift
4. Manual (opsional, butuh device): ubah `endTime` doc di Firestore console ke masa
   lalu → buka Active Duel screen → duel otomatis completed + navigate ke Result;
   tab History memuat duel tsb; dokumen Firestore: `status: completed`, `winnerId`
   terisi (null jika seri), `completedAt == endTime`

## Risiko / Catatan

- **Firestore security rules tidak ada di repo** — asumsi: partisipan boleh menulis
  `status`/`winnerId`/`completedAt`. Jika rules membatasi, completion gagal runtime
  (fallback snackbar) → rules perlu disesuaikan di Firebase console.
- Clock skew client menentukan deteksi & guard transaction — diterima (keputusan
  client-side).
- Race dua client: ditangani re-read transaction (return idempotent bila status sudah
  bukan active) + payload identik (`completedAt = endTime`).
- Test bloc bare-event (`_currentUserId == null`) → nav effect bawa `currentUserId: ''`
  — aman (router cast `String`; alur nyata selalu load dulu).
- `DuelDto.fromEntity:78` punya logika winnerId basi tapi TIDAK di jalur write ini —
  biarkan.
- PRD menyebut seri = "both marked winners"; implementasi ini pakai `winnerId: null`
  untuk seri + Result screen menampilkan Tie — konsisten dengan UI existing.
