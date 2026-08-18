'use strict';

// Emulator tests for ../../firestore.rules.
//
// This is a client-only app (no Cloud Functions), so these rules are the
// entire security model — nothing else stands between a user's device and
// Firestore. `flutter test` cannot reach these rules at all, so this is the
// only place the security properties claimed in the rules file (and in the
// MVP redefinition plan, M2.1) are actually checked.
//
// Run via `firebase emulators:exec` from health_duel/ — see README.md in
// this directory. Never run against a real project: initializeTestEnvironment
// below always targets a `demo-*` projectId, which the Local Emulator Suite
// treats as fully offline (no real Firebase project, no credentials, no
// billing).

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');
const {
  doc,
  getDoc,
  setDoc,
  updateDoc,
  collection,
  getDocs,
  query,
  where,
  Timestamp,
} = require('firebase/firestore');

const RULES_PATH = path.resolve(__dirname, '../../firestore.rules');

const HOUR = 60 * 60 * 1000;
const nowTs = () => Timestamp.fromMillis(Date.now());
const plusMs = (ts, ms) => Timestamp.fromMillis(ts.toMillis() + ms);

let testEnv;

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'demo-health-duel',
    firestore: {
      rules: fs.readFileSync(RULES_PATH, 'utf8'),
      host: '127.0.0.1',
      port: 8080,
    },
  });
});

after(async () => {
  await testEnv.cleanup();
});

afterEach(async () => {
  await testEnv.clearFirestore();
});

/** Writes a document bypassing all rules — for arranging test fixtures. */
async function seed(collectionPath, id, data) {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), collectionPath, id), data);
  });
}

/** Builds a well-formed, rule-satisfying new-user payload. */
function newUserData({ name = 'Alice' } = {}) {
  return {
    name,
    photoUrl: null,
    createdAt: nowTs(),
    currentStreak: 0,
    longestStreak: 0,
    lastCompletedDate: null,
  };
}

/** Builds a well-formed, rule-satisfying "active" solo challenge payload. */
function activeChallengeData({ userId, createdAt = nowTs(), target = 8000 }) {
  return {
    userId,
    metric: 'steps',
    target,
    currentValue: 0,
    status: 'active',
    startTime: createdAt,
    endTime: plusMs(createdAt, 24 * HOUR),
    createdAt,
    completedAt: null,
  };
}

/** Builds a well-formed, rule-satisfying "pending" duel payload. */
function pendingDuelData({ challengerId, challengedId, createdAt = nowTs() }) {
  return {
    challengerId,
    challengedId,
    challengerValue: 0,
    challengedValue: 0,
    status: 'pending',
    startTime: createdAt,
    endTime: plusMs(createdAt, 24 * HOUR),
    createdAt,
    acceptedAt: null,
    completedAt: null,
    participants: [challengerId, challengedId],
    winnerId: null,
    challengerName: 'Challenger',
    challengedName: 'Challenged',
    challengerPhotoUrl: null,
    challengedPhotoUrl: null,
  };
}

describe('users/{uid}', () => {
  it('any signed-in user can read another user doc (needed for search)', async () => {
    await seed('users', 'alice', { name: 'Alice', photoUrl: null, createdAt: nowTs() });
    const bob = testEnv.authenticatedContext('bob');
    await assertSucceeds(getDoc(doc(bob.firestore(), 'users/alice')));
  });

  it('a user can create their own doc', async () => {
    const alice = testEnv.authenticatedContext('alice');
    await assertSucceeds(setDoc(doc(alice.firestore(), 'users/alice'), newUserData()));
  });

  it('cannot write an email field into a user doc', async () => {
    const alice = testEnv.authenticatedContext('alice');
    await assertFails(
      setDoc(doc(alice.firestore(), 'users/alice'), {
        ...newUserData(),
        email: 'alice@example.com',
      }),
    );
  });

  it('cannot create another user’s doc', async () => {
    const alice = testEnv.authenticatedContext('alice');
    await assertFails(
      setDoc(doc(alice.firestore(), 'users/bob'), { ...newUserData(), name: 'Impersonator' }),
    );
  });

  it('cannot create a doc with a non-zero starting streak', async () => {
    const alice = testEnv.authenticatedContext('alice');
    await assertFails(
      setDoc(doc(alice.firestore(), 'users/alice'), { ...newUserData(), currentStreak: 5 }),
    );
  });
});

describe('users/{uid} — streak updates', () => {
  it('the owner can update their own streak fields', async () => {
    await seed('users', 'alice', newUserData());
    const alice = testEnv.authenticatedContext('alice');
    await assertSucceeds(
      updateDoc(doc(alice.firestore(), 'users/alice'), {
        currentStreak: 1,
        longestStreak: 1,
        lastCompletedDate: '2026-08-18',
      }),
    );
  });

  it('cannot set longestStreak below the new currentStreak', async () => {
    await seed('users', 'alice', newUserData());
    const alice = testEnv.authenticatedContext('alice');
    await assertFails(
      updateDoc(doc(alice.firestore(), 'users/alice'), {
        currentStreak: 5,
        longestStreak: 2,
        lastCompletedDate: '2026-08-18',
      }),
    );
  });

  it('cannot update someone else’s streak', async () => {
    await seed('users', 'alice', newUserData());
    const mallory = testEnv.authenticatedContext('mallory');
    await assertFails(
      updateDoc(doc(mallory.firestore(), 'users/alice'), {
        currentStreak: 99,
        longestStreak: 99,
        lastCompletedDate: '2026-08-18',
      }),
    );
  });

  it('cannot smuggle a name change through a streak update', async () => {
    await seed('users', 'alice', newUserData());
    const alice = testEnv.authenticatedContext('alice');
    await assertFails(
      updateDoc(doc(alice.firestore(), 'users/alice'), {
        currentStreak: 1,
        longestStreak: 1,
        lastCompletedDate: '2026-08-18',
        name: 'Not Alice',
      }),
    );
  });
});

describe('users/{uid}/friends/{friendId}', () => {
  it('owner can add a friend without an email field', async () => {
    const alice = testEnv.authenticatedContext('alice');
    await assertSucceeds(
      setDoc(doc(alice.firestore(), 'users/alice/friends/bob'), {
        id: 'bob',
        name: 'Bob',
        photoUrl: null,
        addedAt: nowTs(),
      }),
    );
  });

  it('cannot write into someone else’s friend list', async () => {
    const mallory = testEnv.authenticatedContext('mallory');
    await assertFails(
      setDoc(doc(mallory.firestore(), 'users/alice/friends/mallory'), {
        id: 'mallory',
        name: 'Mallory',
        photoUrl: null,
        addedAt: nowTs(),
      }),
    );
  });

  it('cannot read someone else’s friend list', async () => {
    await seed('users/alice/friends', 'bob', {
      id: 'bob',
      name: 'Bob',
      photoUrl: null,
      addedAt: nowTs(),
    });
    const mallory = testEnv.authenticatedContext('mallory');
    await assertFails(getDoc(doc(mallory.firestore(), 'users/alice/friends/bob')));
  });
});

describe('users/{uid}/challenges/{id} — create', () => {
  it('the owner can start a well-formed active challenge', async () => {
    const alice = testEnv.authenticatedContext('alice');
    const data = activeChallengeData({ userId: 'alice' });
    await assertSucceeds(setDoc(doc(alice.firestore(), 'users/alice/challenges/c1'), data));
  });

  it('cannot start a challenge under someone else’s uid', async () => {
    const mallory = testEnv.authenticatedContext('mallory');
    const data = activeChallengeData({ userId: 'mallory' });
    await assertFails(setDoc(doc(mallory.firestore(), 'users/alice/challenges/c1'), data));
  });

  it('cannot start with a non-zero currentValue', async () => {
    const alice = testEnv.authenticatedContext('alice');
    const data = { ...activeChallengeData({ userId: 'alice' }), currentValue: 500 };
    await assertFails(setDoc(doc(alice.firestore(), 'users/alice/challenges/c1'), data));
  });

  it('cannot start with a zero or negative target', async () => {
    const alice = testEnv.authenticatedContext('alice');
    const data = { ...activeChallengeData({ userId: 'alice' }), target: 0 };
    await assertFails(setDoc(doc(alice.firestore(), 'users/alice/challenges/c1'), data));
  });
});

describe('users/{uid}/challenges/{id} — progress & completion', () => {
  it('the owner can update progress while active', async () => {
    const now = nowTs();
    await seed('users/alice/challenges', 'c1', activeChallengeData({ userId: 'alice', createdAt: now }));
    const alice = testEnv.authenticatedContext('alice');
    await assertSucceeds(
      updateDoc(doc(alice.firestore(), 'users/alice/challenges/c1'), { currentValue: 4321 }),
    );
  });

  it('cannot update someone else’s challenge progress', async () => {
    const now = nowTs();
    await seed('users/alice/challenges', 'c1', activeChallengeData({ userId: 'alice', createdAt: now }));
    const mallory = testEnv.authenticatedContext('mallory');
    await assertFails(
      updateDoc(doc(mallory.firestore(), 'users/alice/challenges/c1'), { currentValue: 4321 }),
    );
  });

  it('the owner can complete a challenge once the window has ended', async () => {
    const past = plusMs(nowTs(), -25 * HOUR);
    await seed('users/alice/challenges', 'c1', activeChallengeData({ userId: 'alice', createdAt: past }));
    const alice = testEnv.authenticatedContext('alice');
    const endTime = plusMs(past, 24 * HOUR);
    await assertSucceeds(
      updateDoc(doc(alice.firestore(), 'users/alice/challenges/c1'), {
        status: 'completed',
        completedAt: endTime,
      }),
    );
  });

  it('cannot complete before the 24h window has ended', async () => {
    const now = nowTs();
    await seed('users/alice/challenges', 'c1', activeChallengeData({ userId: 'alice', createdAt: now }));
    const alice = testEnv.authenticatedContext('alice');
    await assertFails(
      updateDoc(doc(alice.firestore(), 'users/alice/challenges/c1'), {
        status: 'completed',
        completedAt: plusMs(now, 24 * HOUR),
      }),
    );
  });
});

describe('duels/{duelId} — create', () => {
  it('challenger can create a well-formed pending duel', async () => {
    const alice = testEnv.authenticatedContext('alice');
    const data = pendingDuelData({ challengerId: 'alice', challengedId: 'bob' });
    await assertSucceeds(setDoc(doc(alice.firestore(), 'duels/d1'), data));
  });

  it('cannot challenge yourself', async () => {
    const alice = testEnv.authenticatedContext('alice');
    const data = pendingDuelData({ challengerId: 'alice', challengedId: 'alice' });
    await assertFails(setDoc(doc(alice.firestore(), 'duels/d1'), data));
  });

  it('cannot create a duel where you are not the challenger', async () => {
    const mallory = testEnv.authenticatedContext('mallory');
    const data = pendingDuelData({ challengerId: 'alice', challengedId: 'bob' });
    await assertFails(setDoc(doc(mallory.firestore(), 'duels/d1'), data));
  });

  it('cannot start with non-zero step counts', async () => {
    const alice = testEnv.authenticatedContext('alice');
    const data = pendingDuelData({ challengerId: 'alice', challengedId: 'bob' });
    data.challengerValue = 9999;
    await assertFails(setDoc(doc(alice.firestore(), 'duels/d1'), data));
  });

  it('cannot backdate createdAt beyond the clock-skew tolerance', async () => {
    const alice = testEnv.authenticatedContext('alice');
    const data = pendingDuelData({
      challengerId: 'alice',
      challengedId: 'bob',
      createdAt: plusMs(nowTs(), -5 * HOUR),
    });
    await assertFails(setDoc(doc(alice.firestore(), 'duels/d1'), data));
  });
});

describe('duels/{duelId} — accept', () => {
  async function seedPending(id, overrides = {}) {
    const data = { ...pendingDuelData({ challengerId: 'alice', challengedId: 'bob' }), ...overrides };
    await seed('duels', id, data);
    return data;
  }

  it('the challenged user can accept before the deadline', async () => {
    await seedPending('d1');
    const bob = testEnv.authenticatedContext('bob');
    const now = nowTs();
    await assertSucceeds(
      updateDoc(doc(bob.firestore(), 'duels/d1'), {
        status: 'active',
        startTime: now,
        endTime: plusMs(now, 24 * HOUR),
        acceptedAt: now,
      }),
    );
  });

  it('the challenger cannot accept their own challenge', async () => {
    await seedPending('d1');
    const alice = testEnv.authenticatedContext('alice');
    const now = nowTs();
    await assertFails(
      updateDoc(doc(alice.firestore(), 'duels/d1'), {
        status: 'active',
        startTime: now,
        endTime: plusMs(now, 24 * HOUR),
        acceptedAt: now,
      }),
    );
  });

  it('cannot accept after the pending deadline has passed', async () => {
    const past = plusMs(nowTs(), -25 * HOUR);
    await seedPending('d1', { createdAt: past, startTime: past, endTime: plusMs(past, 24 * HOUR) });
    const bob = testEnv.authenticatedContext('bob');
    const now = nowTs();
    await assertFails(
      updateDoc(doc(bob.firestore(), 'duels/d1'), {
        status: 'active',
        startTime: now,
        endTime: plusMs(now, 24 * HOUR),
        acceptedAt: now,
      }),
    );
  });
});

describe('duels/{duelId} — cancel (P0 fix: cannot cancel a LIVE duel)', () => {
  it('a participant can cancel while still pending', async () => {
    await seed('duels', 'd1', pendingDuelData({ challengerId: 'alice', challengedId: 'bob' }));
    const alice = testEnv.authenticatedContext('alice');
    await assertSucceeds(updateDoc(doc(alice.firestore(), 'duels/d1'), { status: 'cancelled' }));
  });

  it('a participant CANNOT cancel an active, in-progress duel', async () => {
    const now = nowTs();
    await seed('duels', 'd1', {
      ...pendingDuelData({ challengerId: 'alice', challengedId: 'bob', createdAt: now }),
      status: 'active',
      startTime: now,
      endTime: plusMs(now, 24 * HOUR),
      acceptedAt: now,
    });
    const bob = testEnv.authenticatedContext('bob');
    await assertFails(updateDoc(doc(bob.firestore(), 'duels/d1'), { status: 'cancelled' }));
  });
});

describe('duels/{duelId} — anonymize own fields (account deletion)', () => {
  it('the challenger can anonymize their own name and photo', async () => {
    await seed('duels', 'd1', pendingDuelData({ challengerId: 'alice', challengedId: 'bob' }));
    const alice = testEnv.authenticatedContext('alice');
    await assertSucceeds(updateDoc(doc(alice.firestore(), 'duels/d1'), {
      challengerName: 'Deleted user',
      challengerPhotoUrl: null,
    }));
  });

  it('the challenged user can anonymize their own name and photo', async () => {
    await seed('duels', 'd1', pendingDuelData({ challengerId: 'alice', challengedId: 'bob' }));
    const bob = testEnv.authenticatedContext('bob');
    await assertSucceeds(updateDoc(doc(bob.firestore(), 'duels/d1'), {
      challengedName: 'Deleted user',
      challengedPhotoUrl: null,
    }));
  });

  it('the challenger CANNOT anonymize the challenged user’s fields', async () => {
    await seed('duels', 'd1', pendingDuelData({ challengerId: 'alice', challengedId: 'bob' }));
    const alice = testEnv.authenticatedContext('alice');
    await assertFails(updateDoc(doc(alice.firestore(), 'duels/d1'), {
      challengedName: 'Deleted user',
      challengedPhotoUrl: null,
    }));
  });

  it('anonymizing cannot smuggle a status or score change through the same write', async () => {
    await seed('duels', 'd1', pendingDuelData({ challengerId: 'alice', challengedId: 'bob' }));
    const alice = testEnv.authenticatedContext('alice');
    await assertFails(updateDoc(doc(alice.firestore(), 'duels/d1'), {
      challengerName: 'Deleted user',
      challengerPhotoUrl: null,
      status: 'cancelled',
    }));
  });

  it('rejects an empty anonymized name', async () => {
    await seed('duels', 'd1', pendingDuelData({ challengerId: 'alice', challengedId: 'bob' }));
    const alice = testEnv.authenticatedContext('alice');
    await assertFails(updateDoc(doc(alice.firestore(), 'duels/d1'), {
      challengerName: '',
      challengerPhotoUrl: null,
    }));
  });
});

describe('duels/{duelId} — step writes (field-level tampering protection)', () => {
  async function seedActive(id) {
    const now = nowTs();
    const data = {
      ...pendingDuelData({ challengerId: 'alice', challengedId: 'bob', createdAt: now }),
      status: 'active',
      startTime: now,
      endTime: plusMs(now, 24 * HOUR),
      acceptedAt: now,
    };
    await seed('duels', id, data);
  }

  it('the challenger can write their own step count', async () => {
    await seedActive('d1');
    const alice = testEnv.authenticatedContext('alice');
    await assertSucceeds(updateDoc(doc(alice.firestore(), 'duels/d1'), { challengerValue: 4321 }));
  });

  it('the challenger CANNOT write the challenged user’s step count', async () => {
    await seedActive('d1');
    const alice = testEnv.authenticatedContext('alice');
    await assertFails(updateDoc(doc(alice.firestore(), 'duels/d1'), { challengedValue: 999999 }));
  });

  it('the challenged user CANNOT write the challenger’s step count', async () => {
    // Value must differ from the seeded challengerValue (0) — a same-value
    // write is a legitimate no-op under Firestore's diff-based onlyChanged()
    // (an empty affected-keys set is vacuously a subset of anything), so it
    // wouldn't actually exercise the field-scoping rule below.
    await seedActive('d1');
    const bob = testEnv.authenticatedContext('bob');
    await assertFails(updateDoc(doc(bob.firestore(), 'duels/d1'), { challengerValue: 777 }));
  });

  it('a non-participant cannot write either step count', async () => {
    await seedActive('d1');
    const mallory = testEnv.authenticatedContext('mallory');
    await assertFails(updateDoc(doc(mallory.firestore(), 'duels/d1'), { challengerValue: 1 }));
  });

  it('rejects an out-of-range step count', async () => {
    await seedActive('d1');
    const alice = testEnv.authenticatedContext('alice');
    await assertFails(updateDoc(doc(alice.firestore(), 'duels/d1'), { challengerValue: 999999999 }));
  });
});

describe('duels/{duelId} — complete', () => {
  async function seedEndedActive(id, { challengerValue = 5000, challengedValue = 3000 } = {}) {
    const past = plusMs(nowTs(), -25 * HOUR);
    const data = {
      ...pendingDuelData({ challengerId: 'alice', challengedId: 'bob', createdAt: past }),
      status: 'active',
      startTime: past,
      endTime: plusMs(past, 24 * HOUR),
      acceptedAt: past,
      challengerValue,
      challengedValue,
    };
    await seed('duels', id, data);
    return data;
  }

  it('a participant can complete once the window has ended, with the correct winner', async () => {
    const data = await seedEndedActive('d1');
    const alice = testEnv.authenticatedContext('alice');
    await assertSucceeds(
      updateDoc(doc(alice.firestore(), 'duels/d1'), {
        status: 'completed',
        winnerId: 'alice',
        completedAt: data.endTime,
      }),
    );
  });

  it('cannot complete before the 24h window has ended', async () => {
    const now = nowTs();
    await seed('duels', 'd1', {
      ...pendingDuelData({ challengerId: 'alice', challengedId: 'bob', createdAt: now }),
      status: 'active',
      startTime: now,
      endTime: plusMs(now, 24 * HOUR),
      acceptedAt: now,
    });
    const alice = testEnv.authenticatedContext('alice');
    await assertFails(
      updateDoc(doc(alice.firestore(), 'duels/d1'), {
        status: 'completed',
        winnerId: 'alice',
        completedAt: nowTs(),
      }),
    );
  });

  it('cannot claim an incorrect winner', async () => {
    const data = await seedEndedActive('d1', { challengerValue: 5000, challengedValue: 3000 });
    const alice = testEnv.authenticatedContext('alice');
    await assertFails(
      updateDoc(doc(alice.firestore(), 'duels/d1'), {
        status: 'completed',
        winnerId: 'bob', // bob had fewer steps — this is a lie
        completedAt: data.endTime,
      }),
    );
  });

  it('a tie resolves to a null winner', async () => {
    const data = await seedEndedActive('d1', { challengerValue: 4000, challengedValue: 4000 });
    const bob = testEnv.authenticatedContext('bob');
    await assertSucceeds(
      updateDoc(doc(bob.firestore(), 'duels/d1'), {
        status: 'completed',
        winnerId: null,
        completedAt: data.endTime,
      }),
    );
  });
});

describe('duels/{duelId} — enumeration protection', () => {
  it('a non-participant cannot read a duel directly', async () => {
    await seed('duels', 'd1', pendingDuelData({ challengerId: 'alice', challengedId: 'bob' }));
    const mallory = testEnv.authenticatedContext('mallory');
    await assertFails(getDoc(doc(mallory.firestore(), 'duels/d1')));
  });

  it('a non-participant cannot list duels even with a matching-looking query', async () => {
    await seed('duels', 'd1', pendingDuelData({ challengerId: 'alice', challengedId: 'bob' }));
    const mallory = testEnv.authenticatedContext('mallory');
    const q = query(collection(mallory.firestore(), 'duels'), where('status', '==', 'pending'));
    await assertFails(getDocs(q));
  });

  it('an unauthenticated client cannot read anything', async () => {
    await seed('duels', 'd1', pendingDuelData({ challengerId: 'alice', challengedId: 'bob' }));
    const anon = testEnv.unauthenticatedContext();
    await assertFails(getDoc(doc(anon.firestore(), 'duels/d1')));
  });
});
