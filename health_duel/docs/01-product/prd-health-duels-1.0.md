# Product Requirements Document (PRD)

## 1. Overview

**Product Name:** Health Duel
**Platform:** Android & iOS (Flutter)
**Version:** MVP v1.0
**Owner:** Product / Engineering
**Status:** In Development — ~47% of MVP acceptance criteria implemented as of
2026-07-09 (see the Implementation Status note below and the `[x]` marks
throughout Section 7)

Health Duel is a mobile application that enables users to challenge friends in
24-hour health competitions focused on step counts. The app combines social
accountability with health habits to create engaging, time-bound competitions
that motivate daily activity.

> **Note — Implementation status (last updated 2026-07-09):** Section 7 was
> audited requirement-by-requirement against the current codebase on
> 2026-07-07. Grouping tightly related and nested criteria into 86 distinct
> requirements, 37 are implemented, 12 are partially implemented (annotated
> inline below), and 37 are not started; 52 of the section's 111 individual
> checkboxes are checked. Each criterion is checked off (`- [x]`) only if
> fully implemented; a partial implementation stays unchecked with a short
> note explaining the gap. The single largest gap is **push notifications**:
> no Cloud Functions exist in the repository and `firebase_messaging` is an
> unused dependency, so every "notify the other participant" criterion across
> FR-DUEL-002, FR-DUEL-003, FR-DUEL-005, and all of FR-NOTIF-001–004 is
> unimplemented for this one structural reason. The duel lifecycle itself
> (creation through completion, including sent/received invitations and
> client-side 24-hour expiry) and share cards (FR-SHARE-001/002, added
> 2026-07-09) are the most complete areas; notifications and the user profile
> screen are the least complete.

## 2. Problem Statement

Many people have good intentions to live healthier lives (walking more,
staying active), but struggle with consistency because:

* **Lack of external motivation**: Individual health goals feel isolating and
  easy to abandon
* **Long-term commitment fatigue**: Traditional health apps focus on long-term
  tracking that feels overwhelming
* **Missing social element**: Health improvement feels like a solo journey
  without peer support
* **No sense of urgency**: Open-ended goals lack the immediacy that drives action

Users need a **lightweight, fast, and social** way to motivate daily healthy
actions through friendly competition.

## 3. Goals & Success Metrics

### Product Goals

* **Drive daily activity**: Motivate users to increase step counts through
  competitive challenges
* **Create recurring engagement**: Establish a social loop where users return
  for repeated duels
* **Deliver quick wins**: Provide 24-hour cycles that fit into daily life
  without long-term commitment
* **Keep complexity low**: MVP focuses on core competition mechanics with
  minimal friction

### Success Metrics (MVP)

**Engagement Metrics:**
* Duel completion rate: % of accepted duels that reach the 24-hour completion
* Duels per user per week: Average number of duels each user participates in
* 7-day repeat rate: % of users who participate in another duel within 7 days
  of completing one

**Social Metrics:**
* Duel acceptance rate: % of challenges that get accepted by invited users
* Share rate: % of completed duels that generate a share card export
* Friend invitations: Number of new users joining via friend invitations

**Technical Metrics:**
* Health permission grant rate: % of users who grant step data access
* Real-time sync accuracy: % of duels with correct step counts at completion
* Push notification delivery rate: % of lead change notifications delivered

**Target Benchmarks (3 months post-launch):**
* 60%+ duel completion rate
* 2+ duels per user per week
* 40%+ 7-day repeat rate
* 70%+ duel acceptance rate

## 4. Target Users

### Primary Persona

**Active Social Millennial**
* **Age:** 18–35 years old
* **Behavior:** Mobile-first, active on social platforms (WhatsApp, Instagram)
* **Health attitude:** Casually health-conscious, not serious athletes
* **Motivation:** Social connection, friendly competition, bragging rights

**Pain Points:**
* Gym memberships feel like waste if not used consistently
* Health tracking apps feel lonely and boring
* Hard to stay motivated without accountability
* Want to be healthier but struggle with long-term commitment

**Desired Outcomes:**
* Quick, fun way to compete with friends
* Visible progress and achievement within one day
* Social proof and sharing opportunities
* Low commitment, high engagement

### Secondary Persona

**Fitness Enthusiast**
* **Age:** 25–45 years old
* **Behavior:** Already tracks health metrics, uses fitness apps
* **Health attitude:** Values data and competition
* **Motivation:** Benchmarking against peers, maintaining streaks

### Use Cases

**Primary Use Case:**
"I want to challenge my friend to see who can walk more today, with a fun
consequence for the loser that we can share on social media."

**Additional Use Cases:**
* Office coworkers compete during lunch breaks
* Friends keep each other accountable during lazy weekends
* Couples motivate each other to stay active together
* Remote friends stay connected through daily challenges

## 5. Core Value Proposition

> "The fastest and most fun way to challenge friends to be healthy—just 24 hours."

**Key Differentiators:**

* **Urgency:** Fixed 24-hour window creates immediate motivation and focus
* **Accountability:** Head-to-head competition means you're not alone
* **Fun:** Lighthearted punishment emojis and shareable results cards
* **Simplicity:** One metric (steps), one duration (24 hours), two people

## 6. MVP Scope

### In Scope (MVP v1.0 - MUST HAVE)

**Core Features:**
1. **User authentication**: Email, Google, Apple sign-in
2. **24-hour duels**: Fixed duration competitions
3. **Step count metric**: Single metric for MVP simplicity
4. **Head-to-head mode**: Exactly 2 participants per duel
5. **Health data integration**: HealthKit (iOS) and Health Connect (Android)
6. **Push notifications**: Duel start, lead changes, duel end, invitations
7. **Result scoreboard**: Clear winner/loser display with final step counts
8. **Share cards**: Auto-generated shareable images with results and emojis

**Supporting Features:**
9. **Friend list**: Basic friend management via invitation links
10. **User profile**: Name, avatar, basic stats
11. **Duel history**: View past completed duels
12. **Permissions flow**: Clear health data permission requests with rationale

### Out of Scope (Post-MVP)

**Future Features (Explicitly Deferred):**
* Group duels (>2 participants)
* Multi-day challenges (>24 hours)
* Additional metrics (hydration, sleep, calories, active minutes)
* Long-term analytics and trends
* Monetary rewards or betting
* AI coaching or recommendations
* Global leaderboards
* Custom punishment options
* Duel scheduling (start time selection)
* Duel templates or presets

## 7. Functional Requirements

### 7.1 Authentication & User Management

**FR-AUTH-001: User Registration**
- Users can create accounts via email/password, Google, or Apple sign-in
- Required fields: name, email
- Optional fields: profile photo, bio
- Account creation grants unique user ID

**Acceptance Criteria:**
- [x] Email/password registration with validation
- [ ] Google OAuth integration
- [ ] Apple Sign-In integration (iOS) — bloc/repository support exists, but no
      button calls it from the register screen
- [ ] Email verification sent after registration
- [x] User profile created in Firestore after successful registration
- [ ] Error handling for duplicate emails — the underlying exception is
      mapped, but the app doesn't show dedicated copy for this case

**FR-AUTH-002: User Login**
- Users can log in with registered credentials
- Session persists across app restarts
- Support for password reset flow

**Acceptance Criteria:**
- [x] Login with email/password
- [x] Login with Google
- [ ] Login with Apple (iOS) — same as registration, no UI entry point
- [ ] "Remember me" persists session — no user-facing toggle; relies on
      Firebase Auth's default persistence only
- [ ] "Forgot password" triggers reset email — no reset flow exists
- [ ] Invalid credentials show clear error messages — shown via snackbar, but
      it's the raw mapped exception message, not dedicated copy

**FR-AUTH-003: User Profile**
- Users can view and edit their profile
- Display name, avatar, and basic stats visible to friends

**Acceptance Criteria:**
- [ ] View profile screen with stats (duels won/lost, current streak)
- [ ] Edit name and bio
- [ ] Upload and change profile photo
- [ ] Changes sync to Firestore immediately

> **Note:** No profile feature exists yet — there's no profile screen, and
> `UserModel` doesn't carry bio or stats fields. This entire FR is
> unimplemented.

### 7.2 Friend Management

**FR-FRIEND-001: Add Friends**
- Users can add friends via invitation link or contact import

**Acceptance Criteria:**
- [ ] Generate unique invitation link per user
- [ ] Copy invitation link to clipboard
- [ ] Share invitation link via system share sheet
- [ ] New user clicking link creates account and adds friend relationship
- [ ] Display pending friend requests

> **Note:** None of the above is implemented. What's built instead is a
> different mechanism — in-app user search with an instant "Add" button that
> writes directly to `users/{uid}/friends`, no invitation link and no
> request/approval state. It satisfies the underlying need ("find and add a
> friend") but not these specific acceptance criteria.

**FR-FRIEND-002: Friend List**
- Users can view list of friends and their availability status

**Acceptance Criteria:**
- [ ] Display friend list sorted by recent activity — currently sorted
      alphabetically by name instead
- [ ] Show friend online/offline status
- [ ] Show friend current active duel count
- [x] Search/filter friends by name
- [ ] Remove friend option with confirmation — removal works but fires
      immediately, with no confirmation dialog

### 7.3 Duel Creation

**FR-DUEL-001: Create Duel**
- Users can initiate a duel by selecting a friend and metric

**Acceptance Criteria:**
- [x] Select friend from friend list
- [x] Metric defaults to "Steps" (only option in MVP)
- [ ] Display estimated start time (immediate upon acceptance)
- [ ] Display end time (24 hours from start)
- [ ] Preview duel details before sending — flow is select opponent → send,
      with no confirmation step
- [ ] Send duel challenge notification to friend — no push infrastructure
      exists (see Implementation Status note above)

**FR-DUEL-002: Duel Invitation**
- Challenged user receives notification and can accept or decline

**Acceptance Criteria:**
- [ ] Push notification sent to challenged user
- [ ] In-app notification badge on duels screen — a count chip exists inside
      the Pending tab itself, but nothing badges the tab bar or app entry
      point proactively
- [ ] Accept/Decline buttons in notification and app — implemented in-app;
      not applicable in a notification since none exists
- [x] Duel starts immediately when accepted
- [ ] Challenger notified of acceptance/decline — visible only if the
      challenger reopens the Sent list themselves
- [x] Challenger can view the status of challenges they sent, separate from
      challenges they received
- [x] Challenger can cancel a sent challenge before it's accepted

### 7.4 Duel Lifecycle

**FR-DUEL-003: Duel States**
- Duels transition through three states: Pending, Active, Completed

**State Definitions:**
* **Pending:** Challenge sent, awaiting acceptance (max 24 hours)
* **Active:** Both participants accepted, competition in progress (exactly 24 hours)
* **Completed:** 24-hour window ended, winner determined

**Acceptance Criteria:**
- [x] Pending duels expire after 24 hours if not accepted
- [x] Active duels automatically transition to Completed after 24 hours
- [x] Completed duels remain in history indefinitely
- [ ] State transitions trigger appropriate notifications — surfaced only as
      a local snackbar on the acting device, not to the other participant

**FR-DUEL-004: Progress Tracking**
- Users can view current step counts for active duels

**Acceptance Criteria:**
- [x] Real-time step count display for both participants
- [x] Progress bars showing relative performance
- [x] Lead indicator (who is currently winning)
- [x] Countdown timer showing time remaining
- [ ] Pull-to-refresh to manually sync latest data — only a manual AppBar
      button exists, not a swipe gesture
- [x] Automatic refresh every 5 minutes while app is open

**FR-DUEL-005: Winner Determination**
- Winner is determined by highest step count at duel end time

**Acceptance Criteria:**
- [x] Winner calculated exactly at 24-hour mark
- [x] Ties result in both users marked as winners
- [ ] Winner notification sent to both participants — each device only learns
      the result from its own Firestore read
- [x] Duel result stored in Firestore and user history
- [x] Winner badge displayed on result screen

### 7.5 Health Data Integration

**FR-HEALTH-001: Permission Request**
- App requests health data permission with clear rationale

**Acceptance Criteria:**
- [ ] Permission request screen explains why data access is needed — copy is
      generic, doesn't mention duels specifically
- [x] iOS: HealthKit permission dialog for step data read access
- [x] Android: Health Connect permission dialog for step data
- [ ] Graceful handling if permission denied (show educational message) — the
      permission view re-shows, but Android can't distinguish "denied" from
      "never asked" (a platform API limitation, noted in source)
- [x] Re-request flow if user denied but later wants to participate

**FR-HEALTH-002: Step Data Sync**
- App periodically fetches step data from platform health APIs

**Acceptance Criteria:**
- [ ] Fetch step data for current 24-hour duel window — the query end time is
      the current moment, not clamped to `duel.endTime`, so a late sync can
      read slightly past the window
- [x] iOS: Query HealthKit for HKQuantityTypeIdentifierStepCount
- [x] Android: Query Health Connect for Steps data type
- [x] Sync occurs every 5 minutes for active duels
- [ ] Background sync when app is backgrounded (best effort) — sync is a
      timer tied to the duel screen's lifecycle; no background task
      registration exists
- [ ] Handle missing data gracefully (show last successful sync time) — the
      timestamp is tracked in state but not rendered anywhere in the UI

**FR-HEALTH-003: Data Accuracy**
- Step counts reflect platform health data accurately

**Acceptance Criteria:**
- [x] Step counts match values shown in Apple Health / Health Connect
- [x] Data includes steps from all sources (phone, watches, other apps)
- [x] Historical data correctly filtered to duel time window
- [x] No double-counting of steps from multiple sources

### 7.6 Notifications

> **Note:** None of FR-NOTIF-001 through FR-NOTIF-004 is implemented. There's
> no sending mechanism of any kind — no Cloud Functions exist in the
> repository, and `firebase_messaging` is listed in `pubspec.yaml` but never
> used in application code. Every checkbox in this section is accurate as
> unchecked; no per-item notes are added below to avoid repeating this once
> per line.

**FR-NOTIF-001: Duel Start Notification**
- Both participants notified when duel becomes active

**Acceptance Criteria:**
- [ ] FCM push notification sent to both users
- [ ] Notification title: "Duel Started!"
- [ ] Notification body: "Your duel with [Friend Name] has begun. Time to move!"
- [ ] Tapping notification opens active duel screen
- [ ] Notification includes duel end time

**FR-NOTIF-002: Lead Change Notification**
- Participants notified when the lead changes

**Acceptance Criteria:**
- [ ] Notification sent when step count lead switches
- [ ] Throttled to max 1 per 15 minutes to avoid spam
- [ ] Notification body: "You're now in the lead!" or "[Friend Name] just took the lead!"
- [ ] Tapping notification opens active duel screen

**FR-NOTIF-003: Duel End Notification**
- Both participants notified when duel completes

**Acceptance Criteria:**
- [ ] Notification sent exactly at 24-hour mark (via Cloud Function)
- [ ] Winner receives: "You won! Final score: [Your Steps] vs [Their Steps]"
- [ ] Loser receives: "Duel complete. Final score: [Your Steps] vs [Their Steps]"
- [ ] Tapping notification opens result screen

**FR-NOTIF-004: Duel Invitation Notification**
- Challenged user notified of new duel invitation

**Acceptance Criteria:**
- [ ] Notification sent immediately when challenge created
- [ ] Notification body: "[Friend Name] challenged you to a 24-hour step duel!"
- [ ] Action buttons: "Accept" and "Decline"
- [ ] Tapping notification opens duel invitation screen

### 7.7 Result Display & Punishment

**FR-RESULT-001: Result Screen**
- Clear display of duel outcome with winner/loser indication

**Acceptance Criteria:**
- [x] Winner shown with celebratory icon/animation
- [x] Final step counts displayed prominently for both users
- [ ] Loser shown with punishment emoji (🙇 default) — uses 💪 instead; see
      FR-RESULT-002, no punishment concept exists in code
- [x] Time range of duel displayed
- [x] Share button to generate share card — implemented 2026-07-09, see
      FR-SHARE-001/002
- [ ] Return to home button — only "Challenge Again" and "Back to Duels"
      exist; the latter pops the current route rather than routing home

**FR-RESULT-002: Punishment Display**
- Loser receives lighthearted punishment emoji

**Acceptance Criteria:**
- [ ] Default emoji: 🙇 (bowing person) — the result screen shows 💪 for the
      loser instead
- [ ] Displayed prominently on result screen — n/a, no punishment emoji exists
- [x] Included in share card — share card shows 🙇 for the loser (FR-SHARE-001),
      even though the on-screen result still shows 💪 (unchanged gap above)
- [x] No financial or serious consequences (MVP scope)

### 7.8 Share Cards

> **Note — Implemented 2026-07-09:** `ShareCardWidget` + `DuelShareService`
> (`share_plus`) capture a `RepaintBoundary` via `toImage()` and hand the PNG
> to the system share sheet from `DuelResultScreen`. Verified hands-on on a
> real device (share sheet opens with the image attached). Avatars are
> initial/emoji circles (reusing `DuelPlayerTile`), not real photos —
> `Duel` has no photo-URL field, out of scope by design (see the Share Card
> plan's locked decisions). "Saved to photo library with permission" isn't a
> separate explicit flow; it relies on the OS share sheet's own built-in
> "Save Image" option, so no custom permission handling was added.

**FR-SHARE-001: Share Card Generation**
- System generates shareable image of duel results

**Acceptance Criteria:**
- [x] Auto-generate PNG image with duel results
- [x] Image includes:
  - [x] Health Duel branding/logo
  - [x] "24-Hour Step Duel" title
  - [x] Both participant names and avatars — initial/emoji circle avatars,
        not real photos (see note above)
  - [x] Final step counts with winner indicator
  - [x] Loser punishment emoji — 🙇 on the share card (differs from the
        on-screen result screen, which still shows 💪; see FR-RESULT-001/002)
  - [x] Date range of duel
- [x] Image sized for social media (1200x630px recommended) — 600x315
      logical size captured at `pixelRatio: 2` → exactly 1200x630px
- [x] Image includes invitation CTA: "Challenge me on Health Duel!"

**FR-SHARE-002: Share Functionality**
- Users can export and share the generated card

**Acceptance Criteria:**
- [x] "Share" button on result screen
- [x] Tapping share opens system share sheet
- [x] Image can be shared to any installed app (WhatsApp, Instagram, Messages, etc.)
- [ ] Image saved to device photo library with permission — no dedicated
      save flow; relies on the OS share sheet's own built-in "Save Image"
      option (see note above)
- [x] Success feedback after share — "Shared!" snackbar on success, error
      snackbar on failure

## 8. Non-Functional Requirements

> **Note:** Most NFR criteria describe runtime/device behavior (startup
> time, frame rate, battery drain) that can't be confirmed by reading code —
> they need device testing, not a code audit, so they're left unmarked below
> rather than guessed at. Three criteria with a clear code-level signal were
> spot-checked as part of the 2026-07-07 audit and are marked accordingly;
> everything else in this section reflects the original, unaudited MVP scope.

### 8.1 Performance

**NFR-PERF-001: App Startup**
- App should launch quickly and be responsive

**Acceptance Criteria:**
- [ ] Cold start < 2 seconds on mid-range devices
- [ ] Warm start < 1 second
- [ ] Splash screen displayed immediately
- [ ] Critical data loads before main UI renders

**NFR-PERF-002: UI Responsiveness**
- UI should be smooth with no jank or lag

**Acceptance Criteria:**
- [ ] Maintain 60fps during normal usage
- [ ] Smooth animations and transitions
- [ ] No dropped frames during list scrolling
- [ ] Touch interactions respond within 100ms

**NFR-PERF-003: Battery Efficiency**
- App should minimize battery drain, especially for background health sync

**Acceptance Criteria:**
- [ ] Background health sync uses batch API calls, not continuous polling
- [ ] No unnecessary wake locks
- [ ] Location services not used (step data doesn't require location)
- [ ] Push notifications use FCM, not polling

### 8.2 Reliability

**NFR-REL-001: Offline Support**
- App should function with limited connectivity

**Acceptance Criteria:**
- [ ] View cached duel history offline
- [ ] Graceful error messages when offline
- [x] Queue actions for sync when connectivity returns — implemented
      2026-07-17, see ADR-006. Scope: accept/decline/cancel duel, create
      duel, and periodic step sync. Conflicts (duel changed/expired while
      offline) are dropped with a snackbar, not silently merged.
- [x] Sync indicator shows connection status — `ConnectivityCubit` tracks
      online/offline via `connectivity_plus` and is wired app-wide (spot-checked)

**NFR-REL-002: Data Accuracy**
- Health data must be accurate and trustworthy

**Acceptance Criteria:**
- [ ] Step counts match platform health apps (Apple Health, Health Connect)
- [ ] No double-counting from multiple sources
- [ ] Sync errors logged and reported to user
- [ ] Manual refresh option if auto-sync fails

### 8.3 Security

**NFR-SEC-001: Data Privacy**
- User health data must be protected and private

**Acceptance Criteria:**
- [ ] Health data stored encrypted in Firestore
- [ ] Firestore rules prevent unauthorized access — no `firestore.rules` file
      exists in the repository at all (spot-checked)
- [ ] Health data only visible to duel participants
- [ ] Users can delete their data at any time

**NFR-SEC-002: Authentication Security**
- User accounts must be secure

**Acceptance Criteria:**
- [ ] Passwords hashed with Firebase Auth
- [ ] OAuth flows follow best practices
- [ ] Session tokens expire after 30 days
- [ ] Failed login attempts rate-limited

### 8.4 Usability

**NFR-USA-001: Onboarding**
- New users should understand the app quickly

**Acceptance Criteria:**
- [ ] First-time onboarding explains key features in < 3 screens
- [ ] Health permission request includes clear rationale
- [ ] Tutorial duel available for first-time users (optional)
- [ ] Help/FAQ section accessible from settings

**NFR-USA-002: Accessibility**
- App should be usable by people with disabilities

**Acceptance Criteria:**
- [ ] Screen reader support (iOS VoiceOver, Android TalkBack) — no explicit
      `Semantics` widgets found anywhere in the codebase (spot-checked)
- [ ] Sufficient color contrast ratios (WCAG AA)
- [ ] Large touch targets (min 44x44 points)
- [ ] Text scales with system font size settings

### 8.5 Platform Support

**NFR-PLAT-001: Device Compatibility**
- App should support modern iOS and Android devices

**Acceptance Criteria:**
- [ ] iOS 14.0+ supported (HealthKit requirement)
- [ ] Android 8.0+ (API 26+) supported (Health Connect requirement)
- [ ] Tested on iPhone SE, iPhone 14 Pro, iPad
- [ ] Tested on Samsung Galaxy, Google Pixel devices
- [ ] Responsive layouts for different screen sizes

## 9. Technical Architecture (High Level)

### Frontend

**Technology:** Flutter 3.7.2+
**State Management:** BLoC pattern with EffectBloc extension
**Architecture:** Clean Architecture (Domain, Data, Presentation layers)
**Key Packages:**
- `flutter_bloc` - State management
- `get_it` - Dependency injection
- `go_router` - Navigation
- `dartz` - Functional error handling
- `equatable` - Value equality
- `health` - HealthKit/Health Connect integration

### Backend (MVP)

**Infrastructure:** Firebase
**Services:**
- **Firebase Auth:** User authentication and session management
- **Firestore:** NoSQL database for users, duels, friends
- **Firebase Cloud Messaging (FCM):** Push notifications
- **Cloud Functions:** Serverless automation for duel lifecycle

**Cloud Functions:**
- `onDuelAccepted`: Start duel timer
- `onDuelComplete`: Calculate winner, send notifications
- `onLeadChange`: Detect and notify lead changes (throttled)
- `onDuelExpired`: Clean up expired pending duels

### Integrations

**Health Platforms:**
- **iOS:** HealthKit (read steps permission)
- **Android:** Health Connect (read steps permission)

**Third-Party Services:**
- **Firebase:** Auth, Firestore, FCM, Cloud Functions
- **Platform Share APIs:** System share sheet for share cards

## 10. UX Principles

### Design Philosophy

Health Duel UX prioritizes:
1. **Zero learning curve:** Intuitive UI that requires no instructions
2. **Fun over precision:** Emphasis on social fun, not exact data accuracy
3. **Clear outcomes:** Unambiguous winner/loser with celebration/commiseration
4. **Social-first:** Sharing encouraged at every opportunity

### Key Interactions

**Duel Creation Flow:**
1. Tap "New Duel" button (prominent on home screen)
2. Select friend from list
3. Confirm duel details (metric: steps, duration: 24h)
4. Send challenge → friend receives push notification

**Active Duel Experience:**
1. View live step counts for both participants
2. See countdown timer (creates urgency)
3. Receive push notification when lead changes (excitement)
4. Pull-to-refresh to manually sync latest data

**Result Experience:**
1. Push notification at duel end
2. Open result screen with clear winner/loser
3. Winner sees celebration, loser sees emoji punishment
4. Prominent "Share" button to generate and export share card

### Design Tokens

Refer to ADR-005 for design token strategy. Key design principles:
- **Spacing:** Consistent padding and margins via AppSpacing
- **Colors:** Light/dark mode support via AppColorsExtension
- **Typography:** Clear hierarchy with Material Design type scale
- **Animations:** Subtle, delightful micro-interactions (EffectBloc effects)

## 11. Risks & Mitigation

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| **Health data sync delays** | Users see incorrect/stale step counts | High | Educate users about sync intervals; show last sync time; manual refresh button |
| **Health permission denial** | Users can't participate in duels | Medium | Clear permission rationale; graceful fallback with educational screen; re-request flow |
| **Push notification failures** | Users miss lead changes or duel events | Medium | In-app notification center as backup; badge indicators; retry logic in Cloud Functions |
| **Cheating (manual data entry)** | Unfair competition reduces trust | Medium | Ignored in MVP; log suspicious activity; post-MVP: detect anomalies |
| **Low duel acceptance rate** | Challenges go unanswered, reducing engagement | Medium | Optimize invitation flow; send reminder notifications; show friend availability |
| **Battery drain concerns** | Users uninstall due to battery usage | Low | Batch health data queries; optimize background sync; clear communication about battery impact |
| **Firebase cost scaling** | Firestore reads/writes become expensive at scale | Low | Implement caching strategy (ADR-001); optimize queries; monitor usage |
| **Platform API changes** | HealthKit/Health Connect APIs break functionality | Low | Monitor platform updates; maintain compatibility layers; automated tests |

## 12. Future Enhancements (Post-MVP Roadmap)

### Phase 2: Expanded Metrics
- Hydration tracking (water intake duels)
- Sleep quality duels (total sleep hours)
- Active minutes duels (moderate-to-vigorous activity)
- Custom metric selection

### Phase 3: Social Features
- Group duels (3+ participants)
- Duel leagues (recurring weekly competitions)
- Friend streaks (consecutive duels with same friend)
- Global leaderboards (opt-in)

### Phase 4: Customization
- Custom punishment options (user-defined text/emojis)
- Scheduled duels (start time selection)
- Duel templates (save and reuse favorite configurations)
- Premium themes and avatar customization

### Phase 5: Advanced Features
- Long-term analytics and trends
- AI-powered coaching and recommendations
- Integration with other fitness apps (Strava, Fitbit)
- Challenges with rewards (badges, achievements)

## 13. Open Questions

Questions to resolve during MVP development:

**Product Questions:**
* Should duels auto-start immediately or allow scheduled start times? **Decision: MVP auto-starts on acceptance for simplicity**
* What's the optimal lead change notification throttle interval? **Decision: 15 minutes to balance excitement and spam**
* Should we limit duels per day per user? **Decision: No limit in MVP, monitor for abuse**

**Technical Questions:**
* What's the best health data sync frequency for battery vs accuracy? **Decision: 5 minutes while app is open, 1 hour when backgrounded**
* How do we handle time zone differences for duel timing? **Decision: All duels use UTC; display in user's local time**
* Should we cache friend avatars or fetch on-demand? **Decision: Cache with refresh on profile update (ADR-001)**

**UX Questions:**
* Should we show real-time step counts or update periodically? **Decision: Display updates every 5 minutes with manual refresh option**
* How do we communicate health sync status to users? **Decision: Last sync timestamp + sync indicator icon**
* What happens if a user denies health permissions mid-duel? **Decision: Graceful error message; duel remains active with last known data**

## 14. Appendix

### User Stories Reference

See [User Stories](user-stories.md) for detailed user story breakdown with
acceptance criteria.

### Architecture Reference

See [Architecture Overview](../02-architecture/ARCHITECTURE_OVERVIEW.md) for
detailed technical architecture and data flow diagrams.

### Design Reference

See [Design Token Strategy (ADR-005)](../02-architecture/adr/0005-design-token-strategy.md)
for UI design system.

---

**Document Version:** 1.0
**Last Updated:** 2026-07-17 (NFR-REL-001 "Queue actions for sync when
connectivity returns" checkbox updated to reflect the newly implemented
offline action queue feature — see ADR-006; FR-SHARE-001/002 and related
FR-RESULT-001/002 checkboxes previously updated 2026-07-09 for the share
card feature; requirements text unchanged)
**Status:** Approved - Development in Progress (~47% of MVP acceptance
criteria implemented)
**Owner:** Product & Engineering Team
