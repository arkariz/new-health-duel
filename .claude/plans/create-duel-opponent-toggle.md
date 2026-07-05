# Plan: Toggle "Friends / All Players" di Create Duel

> **Status:** Disetujui, belum diimplementasikan (di-pause untuk commit progress)
> **Dibuat:** 2026-07-05
> **Konteks:** User ingin tetap ada fitur menantang orang random, jadi `GetOpponents`
> dipertahankan (tidak dihapus). Create Duel harus mendukung dua sumber lawan.

## Keputusan UX (dikonfirmasi user)
Segmented toggle **[ Friends | All Players ]** di atas daftar lawan:
- **Friends** → `GetFriends` (daftar teman terkurasi)
- **All Players** → `GetOpponents` (semua user terdaftar, tantang random)

## Perubahan per file

### 1. `create_duel_event.dart` — ✅ SUDAH DIEDIT (WIP, belum di-commit)
- Tambah `enum OpponentSource { friends, all }`
- `CreateDuelOpponentsRequested` dapat parameter `source` (default `friends`)

### 2. `create_duel_bloc.dart`
- Inject kembali `GetOpponents` di samping `GetFriends`
- Handler `_onOpponentsRequested` branch berdasarkan `event.source`:
  - `friends` → `_getFriends(currentUserId)`
  - `all` → `_getOpponents(currentUserId)`
- Submit flow tidak berubah

### 3. `duel_module.dart`
- Daftarkan ulang `GetOpponents` (registrasi sebelumnya dihapus di integrasi friends)
- `CreateDuelBloc` diberi `getFriends` **dan** `getOpponents`

### 4. `create_duel_screen.dart`
- State lokal `OpponentSource _source = OpponentSource.friends`
- `SegmentedButton` (Friends / All Players) di atas daftar; onChanged →
  `setState` + dispatch `CreateDuelOpponentsRequested(currentUserId, source: _source)` +
  reset pilihan lawan
- `initState` & tombol Retry ikut mengirim `source: _source`
- Empty state kontekstual:
  - tab **Friends** kosong → "Belum ada teman — cari di tab All Players / tambah teman dulu"
  - tab **All Players** kosong → "Belum ada pemain lain"

## Yang TIDAK berubah
- `CreateDuelState` (Ready/Submitting tetap `opponents`) — source dilacak lokal di widget
- Fitur Friends (add/remove/search) & tombol Challenge di layar Friends

## Verifikasi
- `flutter analyze` → 0 error untuk fitur ini
- Cek manual: Create Duel → default Friends → toggle All Players → daftar berganti →
  pilih lawan → Send Challenge

## Di luar scope plan ini (backlog review Friends, dikerjakan terpisah)
- Debounce search di Friends screen (query Firestore tiap keystroke)
- Preselect teman saat klik "Challenge" dari layar Friends (saat ini konteks teman hilang)
- Test unit/bloc untuk Friends & Duel (Step 15 masih pending)
