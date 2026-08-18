# Firestore rules tests

`../firestore.rules` is the entire server-side security model for this app — there are no Cloud
Functions. `flutter test` cannot reach Firestore rules at all, so this Node/mocha suite is the only
thing that actually exercises them, against the real Local Emulator Suite (not a mock).

## Run

From `health_duel/` (one level up from this directory):

```sh
cd firebase && npm install && cd ..
firebase emulators:exec --project=demo-health-duel --only firestore "npm --prefix firebase test"
```

`--project=demo-health-duel` matters: any `demo-*` project ID runs the emulator fully offline — no
real Firebase project, no login, no billing, and no risk of ever touching production data.

## What's covered

- `users/{uid}` — any signed-in user can read (needed for name search), only the owner can write,
  and an `email` field is rejected outright (Firestore rules can't hide a field within a readable
  document, so the app never writes one — see `firestore.rules` for the reasoning)
- `users/{uid}/friends/{friendId}` — owner-only in both directions
- `duels/{duelId}` create — shape validation matching `DuelFirestoreDataSource.createDuel`
- accept — only the challenged user, only before the pending deadline
- **cancel — a participant cannot cancel a live, active duel** (this is the P0 bug this rule set
  specifically closes; see M2.2 in the MVP redefinition plan)
- **step writes — each participant can only write their own step field**, never their opponent's
  (this is the fix for the client-side field-picking in `updateStepCount`)
- complete — only after the 24h window ends, and only with the deterministic winner the step counts
  actually produce
- enumeration — a non-participant can neither `get` nor `list` a duel they're not part of

This is not exhaustive — it covers the properties that would otherwise be silent, unenforced
assumptions in a client-only app.
