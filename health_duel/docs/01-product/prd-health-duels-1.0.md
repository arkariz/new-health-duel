# Product Requirements Document (PRD)

## 1. Overview

**Product Name:** Health Duel
**Platform:** Android & iOS (Flutter)
**Version:** MVP v1.0
**Owner:** Product / Engineering
**Status:** In Development - Phase 1

Health Duel is a mobile application that enables users to challenge friends in
24-hour health competitions focused on step counts. The app combines social
accountability with health habits to create engaging, time-bound competitions
that motivate daily activity.

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
- [ ] Email/password registration with validation
- [ ] Google OAuth integration
- [ ] Apple Sign-In integration (iOS)
- [ ] Email verification sent after registration
- [ ] User profile created in Firestore after successful registration
- [ ] Error handling for duplicate emails

**FR-AUTH-002: User Login**
- Users can log in with registered credentials
- Session persists across app restarts
- Support for password reset flow

**Acceptance Criteria:**
- [ ] Login with email/password
- [ ] Login with Google
- [ ] Login with Apple (iOS)
- [ ] "Remember me" persists session
- [ ] "Forgot password" triggers reset email
- [ ] Invalid credentials show clear error messages

**FR-AUTH-003: User Profile**
- Users can view and edit their profile
- Display name, avatar, and basic stats visible to friends

**Acceptance Criteria:**
- [ ] View profile screen with stats (duels won/lost, current streak)
- [ ] Edit name and bio
- [ ] Upload and change profile photo
- [ ] Changes sync to Firestore immediately

### 7.2 Friend Management

**FR-FRIEND-001: Add Friends**
- Users can add friends via invitation link or contact import

**Acceptance Criteria:**
- [ ] Generate unique invitation link per user
- [ ] Copy invitation link to clipboard
- [ ] Share invitation link via system share sheet
- [ ] New user clicking link creates account and adds friend relationship
- [ ] Display pending friend requests

**FR-FRIEND-002: Friend List**
- Users can view list of friends and their availability status

**Acceptance Criteria:**
- [ ] Display friend list sorted by recent activity
- [ ] Show friend online/offline status
- [ ] Show friend current active duel count
- [ ] Search/filter friends by name
- [ ] Remove friend option with confirmation

### 7.3 Duel Creation

**FR-DUEL-001: Create Duel**
- Users can initiate a duel by selecting a friend and metric

**Acceptance Criteria:**
- [ ] Select friend from friend list
- [ ] Metric defaults to "Steps" (only option in MVP)
- [ ] Display estimated start time (immediate upon acceptance)
- [ ] Display end time (24 hours from start)
- [ ] Preview duel details before sending
- [ ] Send duel challenge notification to friend

**FR-DUEL-002: Duel Invitation**
- Challenged user receives notification and can accept or decline

**Acceptance Criteria:**
- [ ] Push notification sent to challenged user
- [ ] In-app notification badge on duels screen
- [ ] Accept/Decline buttons in notification and app
- [ ] Duel starts immediately when accepted
- [ ] Challenger notified of acceptance/decline

### 7.4 Duel Lifecycle

**FR-DUEL-003: Duel States**
- Duels transition through three states: Pending, Active, Completed

**State Definitions:**
* **Pending:** Challenge sent, awaiting acceptance (max 24 hours)
* **Active:** Both participants accepted, competition in progress (exactly 24 hours)
* **Completed:** 24-hour window ended, winner determined

**Acceptance Criteria:**
- [ ] Pending duels expire after 24 hours if not accepted
- [ ] Active duels automatically transition to Completed after 24 hours
- [ ] Completed duels remain in history indefinitely
- [ ] State transitions trigger appropriate notifications

**FR-DUEL-004: Progress Tracking**
- Users can view current step counts for active duels

**Acceptance Criteria:**
- [ ] Real-time step count display for both participants
- [ ] Progress bars showing relative performance
- [ ] Lead indicator (who is currently winning)
- [ ] Countdown timer showing time remaining
- [ ] Pull-to-refresh to manually sync latest data
- [ ] Automatic refresh every 5 minutes while app is open

**FR-DUEL-005: Winner Determination**
- Winner is determined by highest step count at duel end time

**Acceptance Criteria:**
- [ ] Winner calculated exactly at 24-hour mark
- [ ] Ties result in both users marked as winners
- [ ] Winner notification sent to both participants
- [ ] Duel result stored in Firestore and user history
- [ ] Winner badge displayed on result screen

### 7.5 Health Data Integration

**FR-HEALTH-001: Permission Request**
- App requests health data permission with clear rationale

**Acceptance Criteria:**
- [ ] Permission request screen explains why data access is needed
- [ ] iOS: HealthKit permission dialog for step data read access
- [ ] Android: Health Connect permission dialog for step data
- [ ] Graceful handling if permission denied (show educational message)
- [ ] Re-request flow if user denied but later wants to participate

**FR-HEALTH-002: Step Data Sync**
- App periodically fetches step data from platform health APIs

**Acceptance Criteria:**
- [ ] Fetch step data for current 24-hour duel window
- [ ] iOS: Query HealthKit for HKQuantityTypeIdentifierStepCount
- [ ] Android: Query Health Connect for Steps data type
- [ ] Sync occurs every 5 minutes for active duels
- [ ] Background sync when app is backgrounded (best effort)
- [ ] Handle missing data gracefully (show last successful sync time)

**FR-HEALTH-003: Data Accuracy**
- Step counts reflect platform health data accurately

**Acceptance Criteria:**
- [ ] Step counts match values shown in Apple Health / Health Connect
- [ ] Data includes steps from all sources (phone, watches, other apps)
- [ ] Historical data correctly filtered to duel time window
- [ ] No double-counting of steps from multiple sources

### 7.6 Notifications

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
- [ ] Winner shown with celebratory icon/animation
- [ ] Final step counts displayed prominently for both users
- [ ] Loser shown with punishment emoji (🙇 default)
- [ ] Time range of duel displayed
- [ ] Share button to generate share card
- [ ] Return to home button

**FR-RESULT-002: Punishment Display**
- Loser receives lighthearted punishment emoji

**Acceptance Criteria:**
- [ ] Default emoji: 🙇 (bowing person)
- [ ] Displayed prominently on result screen
- [ ] Included in share card
- [ ] No financial or serious consequences (MVP scope)

### 7.8 Share Cards

**FR-SHARE-001: Share Card Generation**
- System generates shareable image of duel results

**Acceptance Criteria:**
- [ ] Auto-generate PNG image with duel results
- [ ] Image includes:
  - [ ] Health Duel branding/logo
  - [ ] "24-Hour Step Duel" title
  - [ ] Both participant names and avatars
  - [ ] Final step counts with winner indicator
  - [ ] Loser punishment emoji
  - [ ] Date range of duel
- [ ] Image sized for social media (1200x630px recommended)
- [ ] Image includes invitation CTA: "Challenge me on Health Duel!"

**FR-SHARE-002: Share Functionality**
- Users can export and share the generated card

**Acceptance Criteria:**
- [ ] "Share" button on result screen
- [ ] Tapping share opens system share sheet
- [ ] Image can be shared to any installed app (WhatsApp, Instagram, Messages, etc.)
- [ ] Image saved to device photo library with permission
- [ ] Success feedback after share

## 8. Non-Functional Requirements

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
- [ ] Queue actions for sync when connectivity returns
- [ ] Sync indicator shows connection status

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
- [ ] Firestore rules prevent unauthorized access
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
- [ ] Screen reader support (iOS VoiceOver, Android TalkBack)
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
**Last Updated:** 2026-02-08
**Status:** Approved - Development in Progress
**Owner:** Product & Engineering Team
