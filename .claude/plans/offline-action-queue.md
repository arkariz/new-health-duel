# Offline Action Queue + Conflict Resolution (NFR-REL-001)

## Context

PRD `health_duel/docs/01-product/prd-health-duels-1.0.md` §8.2 **NFR-REL-001** mensyaratkan "Queue actions for sync when connectivity returns" — masih unchecked. Fondasi yang sudah ada: `ConnectivityCubit` (connectivity_plus, DI lazySingleton, app-wide provider), Hive terenkripsi via git-dep `storage` (`Database<T>` wrapper), dan transaksi Firestore idempoten di `completeDuel`/`expirePendingDuel` sebagai primitive conflict-resolution.

**Catatan penting:** ADR-0001 (Selective Caching) sebelumnya *menolak* offline queue untuk MVP. Task ini adalah deviasi terkontrol → wajib didokumentasikan sebagai **ADR-0005** baru (proyek documentation-first).

**Keputusan user (terkunci):**
1. Scope: **semua** aksi tulis duel — AcceptDuel, DeclineDuel/Cancel, CreateDuel, dan step sync.
2. Konflik saat replay (duel expired/berubah saat offline): **drop action + notify user** via `ShowSnackBarEffect`. Firestore = source of truth.
3. Persist di Hive, retry exponential backoff, drain dipicu transisi online dari `ConnectivityCubit`.

**Temuan kritis dari eksplorasi kode (menentukan desain):**
- `DuelRepositoryImpl` memetakan semua exception → `ServerFailure` (tidak pernah `NetworkFailure`), dan Firestore *mem-buffer* write saat offline (Future menggantung, bukan gagal) → interception harus **proaktif** (`ConnectivityCubit.isOffline` dicek di bloc SEBELUM dispatch use case), bukan reaktif.
- `UiEffect` Equatable-equal → dua snackbar identik berturut-turut tertelan `EffectListener.listenWhen`; cubit global wajib `clearEffect()` dulu.
- `ConnectivityCubit` mulai di `unknown` dengan `init()` unawaited → processor subscribe stream dulu, baru cek `isOnline`.
- Step sync via `SyncHealthData` (re-fetch langkah segar dari platform saat dieksekusi) → replay saat drain otomatis latest-wins.

## Arsitektur

Modul core-level Clean Architecture `lib/core/offline_queue/` (generik, tanpa import feature) + **executor registry**: feature duel mendaftarkan `OfflineActionExecutor` per action type ke processor saat DI (meniru pola `EffectRegistry` ADR-0004). Replay dijalankan lewat **use case existing** sehingga validasi domain re-run → `ValidationFailure` saat replay = konflik terdeteksi.

```
lib/core/offline_queue/
├── domain/
│   ├── entities/queued_action.dart            (QueuedAction, enum OfflineActionType {acceptDuel, declineDuel, createDuel, syncStepCount})
│   ├── repositories/offline_queue_repository.dart
│   ├── executor/offline_action_executor.dart  (interface: type, execute(payload), conflictMessage)
│   ├── notification/offline_queue_notification.dart (sealed: DrainSucceeded/ActionConflicted/ActionDropped/PendingChanged)
│   └── usecases/enqueue_offline_action.dart   (dedup-replace + accept↔decline cross-cancel)
├── data/
│   ├── models/queued_action_model.dart        (JSON; type via values.byName, unknown type → skip)
│   ├── datasources/offline_queue_local_datasource.dart (Database<String>, jsonEncode per entry)
│   └── repositories/offline_queue_repository_impl.dart (ADR-0002: CoreException → ExceptionMapper.toFailure)
├── application/offline_queue_processor.dart   (drain + backoff; jantung fitur)
├── presentation/cubit/offline_queue_cubit.dart + offline_queue_state.dart
└── di/offline_queue_module.dart
lib/features/duel/domain/offline_executors/duel_offline_executors.dart
```

**QueuedAction**: `id` (`${createdAt.microsecondsSinceEpoch}_${type.name}`, sortable tanpa dep uuid), `type`, `payload` (Map JSON-safe), `dedupKey`, `createdAt`, `attemptCount`, `lastAttemptAt`.

**Dedup rules (enqueue = removeWhere(dedupKey) lalu put):**
| Type | dedupKey | Ekstra |
|---|---|---|
| acceptDuel | `duel_$duelId` | hapus queued declineDuel duel yang sama (niat terakhir menang) |
| declineDuel | `duel_$duelId` | hapus queued acceptDuel duel yang sama |
| createDuel | `create_${challengerId}_$challengedId` | replace |
| syncStepCount | `steps_${duelId}_$userId` | replace (latest-wins, max 1 entry per duel/user) |

**Processor** (`OfflineQueueProcessor`): deps injectable — `OfflineQueueRepository`, `connectivityStream` + `isOnline()` (dari `ConnectivityCubit`), clock `now()` & `wait()` (untuk test), `executeTimeout=20s`, `maxAttempts=6`, backoff 2s→4s→8s→16s→32s→cap 60s. `start()`: subscribe stream dulu → jika online, drain. Drain FIFO by createdAt, guard `_draining` (re-entrancy):
- `Right` → remove, hitung synced.
- `ValidationFailure` → **konflik**: remove + emit `ActionConflicted(executor.conflictMessage(...))`.
- Failure lain / `TimeoutException` → retryable: incrementAttempt + `update()` (persist lintas restart); jika `attemptCount >= maxAttempts` → remove + `ActionDropped`; else `wait(backoff)` lalu retry inline.
- Mid-drain `!isOnline()` → abort, sisa action tetap di box.
- Selesai: synced > 0 → `DrainSucceeded(synced, pending)`.
Notifikasi via `StreamController<OfflineQueueNotification>.broadcast()`.

## Langkah Implementasi (urut)

1. **ADR-0005** — buat `health_duel/docs/02-architecture/adr/0005-offline-action-queue.md` (pakai template 0000): konteks NFR-REL-001 vs penolakan ADR-0001; keputusan (queue semua aksi tulis duel, replay via use case existing, drop+notify, NO optimistic UI mutation — duel tetap Pending di UI sampai replay sukses); opsi ditolak (repository decorator — repo memetakan semua ke ServerFailure; Firestore offline buffering — hang tanpa feedback/retry policy); tabel retry/dedup/pesan konflik; batasan: cubit global hanya boleh emit snackbar effect (bukan navigasi — GoRouter scope di bawah builder). **Amend ADR-0001**: status → "Accepted (amended by ADR-0005)", tambah ke Related ADRs.

2. **StorageKeys** — `lib/core/config/storage_keys.dart`: `static const String offlineQueueActions = 'feature_offline_queue_actions';` (konvensi ADR-0003).

3. **Domain layer** — entities/repo interface/executor interface/notification/`EnqueueOfflineAction` seperti di atas. Pure Dart, `Either<Failure, T>` (dartz), Failure pakai named param (`ValidationFailure(message: ...)`).

4. **Data layer** — model JSON + `OfflineQueueLocalDataSource(Database<String>)` + repo impl. Box dibuka di DI:
   ```dart
   final db = await Database.init<String>(
     name: StorageKeys.offlineQueueActions,
     openDatabase: ({required call, required function, required module}) =>
         openBox(module: module, function: function, call: call), // package:exception
     encryptionCipher: await getHiveAesCipher(),                  // package:storage
   );
   ```

5. **Processor** — `lib/core/offline_queue/application/offline_queue_processor.dart` sesuai spesifikasi di atas; `registerExecutor()` fail-fast pada duplikat type.

6. **Duel executors** — `lib/features/duel/domain/offline_executors/duel_offline_executors.dart`: `AcceptDuelExecutor(AcceptDuel)`, `DeclineDuelExecutor(DeclineDuel)` (pesan netral — payload tak bisa bedakan decline vs cancel), `CreateDuelExecutor(CreateDuel)` (payload: challengerId/challengedId/challengerName/challengedName), `SyncStepCountExecutor(SyncHealthData)` (payload: duelId/userId).

7. **DI** — buat `registerOfflineQueueModule()` (datasource, repo, `EnqueueOfflineAction` factory, processor & `OfflineQueueCubit` lazySingleton). Modif `lib/core/di/injection.dart`: panggil **setelah** `getIt.allReady()` (butuh HiveAesCipher) dan **sebelum** `registerDuelModule()`; setelah `_registerRouter()`: `unawaited(getIt<OfflineQueueProcessor>().start());`. Modif `lib/features/duel/di/duel_module.dart`: inject `ConnectivityCubit` + `EnqueueOfflineAction` ke `DuelListBloc`/`CreateDuelBloc`/`DuelBloc`; daftarkan 4 executor ke processor di akhir.

8. **Interception di bloc (proaktif)** —
   - `duel_list_bloc.dart` `_onAcceptRequested`/`_onDeclineRequested`: top-of-handler `if (_connectivity.isOffline) { await _enqueueOfflineAction(...); emitWithEffect(emit, state, _effectQueued()); return; }`. Tanpa mutasi list optimis. Tambah `_effectQueued()` di `duel_list_side_effect.dart` ("You're offline — action queued and will sync automatically.", severity info).
   - `create_duel_bloc.dart` `_onSubmitted`: setelah session lookup (lokal, jalan offline), jika offline → enqueue + emit state baru `CreateDuelQueued(effect: _effectQueued())`. Tambah state di `create_duel_state.dart` + effect di `create_duel_side_effect.dart`. `create_duel_screen.dart` (~line 71): `listenWhen` juga menerima `CreateDuelQueued` agar screen pop.
   - `duel_bloc.dart` `_onHealthSyncTriggered`: jika offline → enqueue silent (return tanpa snackbar — timer 5-menit akan spam); dedup-replace membuat timer hanya me-refresh 1 entry.

9. **Notification surface global (EffectBloc-consistent)** — `OfflineQueueCubit` subscribe `processor.notifications`; setiap notifikasi: `emit(state.clearEffect())` **lalu** `emit(state.copyWith(pendingCount, effect))` (wajib — effect identik Equatable-equal tertelan listener). Modif `lib/app.dart`: tambah `BlocProvider.value(getIt<OfflineQueueCubit>())` + `MaterialApp.router(builder: (context, child) => EffectListener<OfflineQueueCubit, OfflineQueueState>(child: child ?? const SizedBox.shrink()))` — memakai handler `ShowSnackBarEffect` existing dari `setupEffectHandlers()`; `EffectListener` diimpor dari `core/presentation/widgets/widgets.dart`; `ShowSnackBarEffect` bukan const.

10. **UI banner** — pasang `AnimatedOfflineBanner` (sudah ada, belum dipakai) di `duel_list_screen.dart` (Column di atas TabBarView) dan `create_duel_screen.dart` (child pertama body). Opsional: badge `pendingCount` via `BlocBuilder<OfflineQueueCubit,...>`.

11. **Logout hygiene** — sign-out handler `auth_bloc.dart` panggil clear queue (via use case `ClearOfflineQueue` agar testable) — action antrian membawa userId, salah jika di-replay setelah ganti akun.

12. **PRD update (setelah verifikasi)** — centang NFR-REL-001 "Queue actions for sync..." dengan referensi ADR-0005.

## Testing

Baru: `test/core/offline_queue/` — enqueue dedup/cross-cancel; JSON round-trip + unknown-type tolerance; processor (fake repo in-memory, fake executor scripted Either, StreamController connectivity, injected now/wait untuk assert backoff 2/4/8...cap): drain on offline→online, drain on start-online, sukses remove+notif, ValidationFailure drop+conflict-notif, retry sampai maxAttempts lalu drop, abort mid-drain offline, re-entrancy, timeout retryable; cubit clearEffect (dua pesan identik dua-duanya fire).

Extend existing: `duel_list_bloc_test.dart` (offline accept/decline → enqueue dengan payload/dedupKey benar, TIDAK panggil use case, list tak berubah), `create_duel_bloc_test.dart` (offline submit → CreateDuelQueued), `duel_bloc_test.dart` (offline sync tick → silent enqueue). Mock `ConnectivityCubit` via mocktail di `test/helpers/mocks.dart`. Widget test duel_list mungkin perlu fake `ConnectivityCubit` (default online) di `pump_app.dart` setelah banner ditambahkan — 3 widget test di file itu sudah gagal sebelumnya (pre-existing, unrelated).

## Verifikasi

```powershell
# dari health_duel/ — fvm flutter, PowerShell (flutter tidak di bash PATH)
& "C:\Users\arkariz\fvm\default\bin\flutter.bat" pub get
& "C:\Users\arkariz\fvm\default\bin\flutter.bat" analyze   # 0 error baru
& "C:\Users\arkariz\fvm\default\bin\flutter.bat" test      # semua test baru pass; hanya 3 kegagalan pre-existing duel_list_screen_test tersisa
# cek git diff pubspec.lock sebelum commit (pub get bisa upgrade transitive deps)
```

Manual (emulator, airplane mode): (1) banner muncul saat offline di Duel List & Create Duel; (2) accept offline → snackbar queued, duel tetap di Pending; (3) create offline → pop + snackbar; (4) online kembali → "Back online — N synced", list refresh benar; (5) konflik: queue accept offline, cancel duel dari sisi lawan/console, online → snackbar konflik, action hilang, tanpa crash; (6) restart resilience: queue → kill app → relaunch → sync saat online; (7) step sync offline ter-queue dan tersinkron.

## Risiko tercatat

- "WiFi connected tapi tanpa internet" lolos cek proaktif → path lama yang menggantung tetap ada (pre-existing, out of scope; catat di ADR-0005). Mitigasi processor: `.timeout(20s)` diperlakukan retryable.
- `ServerFailure` blanket dari repo diperlakukan retryable-sampai-maxAttempts; follow-up opsional: map `FirebaseException code=='unavailable'` → `NetworkFailure`.
- Urutan DI ketat: core → offline_queue → duel (executor registration).
