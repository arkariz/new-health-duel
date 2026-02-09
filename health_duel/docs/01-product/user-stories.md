# User Stories

This document contains detailed user stories for Health Duel MVP v1.0. Each
story follows the format: "As a [user type], I want [goal], so that [benefit]."

Stories are grouped by feature area and prioritized for MVP development.

## Table of Contents

- [Authentication](#authentication)
- [Friend Management](#friend-management)
- [Duel Creation](#duel-creation)
- [Active Duels](#active-duels)
- [Duel Results](#duel-results)
- [Notifications](#notifications)
- [Health Integration](#health-integration)
- [Profile Management](#profile-management)

---

## Authentication

### US-AUTH-001: Register with Email

**As a** new user
**I want** to create an account using my email and password
**So that** I can access Health Duel and start competing with friends

**Priority:** P0 (Critical)

**Acceptance Criteria:**
- [ ] User can enter email, password, and display name
- [ ] Email validation ensures correct format
- [ ] Password must be at least 8 characters
- [ ] Display name is required (3-30 characters)
- [ ] Duplicate email shows friendly error message
- [ ] Successful registration creates user profile in Firestore
- [ ] Verification email sent to registered address
- [ ] User automatically logged in after registration

**Design Notes:**
- Clean, minimal registration form
- Clear password requirements displayed
- "Sign up with Google/Apple" alternatives shown

---

### US-AUTH-002: Register with Social Login

**As a** new user
**I want** to create an account using Google or Apple sign-in
**So that** I can register quickly without creating a new password

**Priority:** P0 (Critical)

**Acceptance Criteria:**
- [ ] "Sign in with Google" button triggers Google OAuth flow
- [ ] "Sign in with Apple" button triggers Apple Sign-In (iOS only)
- [ ] OAuth flow requests profile info (name, email, avatar)
- [ ] User profile automatically populated from OAuth provider
- [ ] User redirected to health permission screen after first login
- [ ] Error handling for OAuth cancellation or failure

**Design Notes:**
- Social login buttons prominently displayed
- Clear branding for each provider (Google/Apple design guidelines)

---

### US-AUTH-003: Login

**As a** registered user
**I want** to log in to my existing account
**So that** I can access my duels and friend list

**Priority:** P0 (Critical)

**Acceptance Criteria:**
- [ ] User can enter email and password
- [ ] Invalid credentials show clear error message
- [ ] "Remember me" checkbox persists session
- [ ] "Forgot password" link triggers reset flow
- [ ] Social login options available (Google, Apple)
- [ ] Successful login navigates to home screen
- [ ] Session persists across app restarts

**Design Notes:**
- Toggle to show/hide password
- Clear distinction between login and register flows

---

### US-AUTH-004: Password Reset

**As a** registered user who forgot their password
**I want** to reset my password via email
**So that** I can regain access to my account

**Priority:** P1 (High)

**Acceptance Criteria:**
- [ ] "Forgot password" button on login screen
- [ ] User enters email address for reset
- [ ] Reset email sent with secure reset link
- [ ] Link opens password reset screen (web or app)
- [ ] User can enter and confirm new password
- [ ] Success message confirms password updated
- [ ] User can log in with new password immediately

---

### US-AUTH-005: Logout

**As a** logged-in user
**I want** to log out of my account
**So that** I can secure my account on shared devices

**Priority:** P1 (High)

**Acceptance Criteria:**
- [ ] "Logout" option in settings/profile menu
- [ ] Confirmation dialog: "Are you sure you want to logout?"
- [ ] Logout clears session token and cached data
- [ ] User redirected to login screen
- [ ] Subsequent app launch requires login

---

## Friend Management

### US-FRIEND-001: Add Friend via Invitation Link

**As a** user
**I want** to invite friends to Health Duel via a shareable link
**So that** I can add them to my friend list and challenge them

**Priority:** P0 (Critical)

**Acceptance Criteria:**
- [ ] "Add Friend" button generates unique invitation link
- [ ] "Copy Link" button copies link to clipboard with confirmation
- [ ] "Share" button opens system share sheet
- [ ] Invitation link format: `healthduel.app/invite/{userId}`
- [ ] New user clicking link creates account and adds friend relationship
- [ ] Existing user clicking link adds friend relationship
- [ ] Both users notified when friend connection established

**Design Notes:**
- Prominent "Add Friend" CTA on home screen
- Visual confirmation when link copied
- Share sheet includes WhatsApp, Instagram, Messages

---

### US-FRIEND-002: View Friend List

**As a** user
**I want** to see a list of my friends
**So that** I can quickly select someone to challenge

**Priority:** P0 (Critical)

**Acceptance Criteria:**
- [ ] Friend list displays all connected friends
- [ ] Each friend shows: avatar, name, online status
- [ ] Friends sorted by: online status first, then alphabetical
- [ ] Empty state: "No friends yet. Invite friends to get started!"
- [ ] Pull-to-refresh updates friend statuses
- [ ] Tapping friend opens friend detail view

**Design Notes:**
- List view with clear visual hierarchy
- Online indicator (green dot) for active friends
- Avatar placeholders for friends without photos

---

### US-FRIEND-003: Remove Friend

**As a** user
**I want** to remove a friend from my list
**So that** I can manage my connections

**Priority:** P2 (Medium)

**Acceptance Criteria:**
- [ ] Swipe-to-delete gesture on friend list
- [ ] Confirmation dialog: "Remove [Friend Name]?"
- [ ] Removal deletes friend relationship in Firestore
- [ ] Both users' friend lists updated immediately
- [ ] Past duel history with removed friend remains visible
- [ ] Cannot challenge removed friend

**Design Notes:**
- Destructive action requires confirmation
- Clear warning that past duels remain

---

### US-FRIEND-004: Search Friends

**As a** user with many friends
**I want** to search my friend list
**So that** I can quickly find a specific friend to challenge

**Priority:** P2 (Medium)

**Acceptance Criteria:**
- [ ] Search bar at top of friend list
- [ ] Real-time filtering as user types
- [ ] Search matches friend display name (case-insensitive)
- [ ] Clear button to reset search
- [ ] Empty search results show "No friends match '[query]'"

---

## Duel Creation

### US-DUEL-001: Create New Duel

**As a** user
**I want** to create a new 24-hour step count duel
**So that** I can challenge a friend to compete

**Priority:** P0 (Critical)

**Acceptance Criteria:**
- [ ] "New Duel" button prominently displayed on home screen
- [ ] Tapping opens duel creation flow
- [ ] Step 1: Select friend from list
- [ ] Step 2: Review duel details (metric: steps, duration: 24 hours)
- [ ] Step 3: Confirm and send challenge
- [ ] Challenge notification sent to friend
- [ ] Duel created in Firestore with status "Pending"
- [ ] Creator shown "Waiting for [Friend] to accept..." status

**Design Notes:**
- Simple 3-step flow with clear progress indication
- Preview of duel card before sending
- "Back" navigation at each step

---

### US-DUEL-002: Review Pending Duel

**As a** user who created a duel
**I want** to see the status of my pending challenges
**So that** I know whether my friend has accepted

**Priority:** P1 (High)

**Acceptance Criteria:**
- [ ] Pending duels shown in separate section on home screen
- [ ] Each pending duel shows: friend name, time since sent
- [ ] Status text: "Waiting for acceptance..."
- [ ] Cancel button to withdraw challenge
- [ ] Notification when friend accepts or declines
- [ ] Pending duels expire after 24 hours if not accepted

**Design Notes:**
- Distinct visual style from active duels
- Clear "Pending" label

---

### US-DUEL-003: Accept Duel Invitation

**As a** user who received a duel invitation
**I want** to accept the challenge
**So that** I can start competing with my friend

**Priority:** P0 (Critical)

**Acceptance Criteria:**
- [ ] Push notification alerts user of new challenge
- [ ] In-app notification badge on duels screen
- [ ] Invitation card shows: challenger name, avatar, metric, duration
- [ ] "Accept" button starts duel immediately
- [ ] Health permission requested if not granted
- [ ] Duel status changes to "Active" in Firestore
- [ ] Both users notified that duel has started
- [ ] Countdown timer begins at acceptance

**Design Notes:**
- Invitation card visually exciting to encourage acceptance
- Clear explanation: "24-hour step count duel"

---

### US-DUEL-004: Decline Duel Invitation

**As a** user who received a duel invitation
**I want** to decline the challenge
**So that** I can opt out if I'm not available

**Priority:** P1 (High)

**Acceptance Criteria:**
- [ ] "Decline" button on invitation card
- [ ] Optional: brief decline reason (not required in MVP)
- [ ] Challenger notified of decline
- [ ] Duel removed from both users' pending lists
- [ ] No penalty or negative consequence

**Design Notes:**
- Decline option clear but not overly prominent
- Friendly decline message to challenger

---

## Active Duels

### US-DUEL-005: View Active Duel Progress

**As a** user in an active duel
**I want** to see real-time step counts for both participants
**So that** I know if I'm winning or losing

**Priority:** P0 (Critical)

**Acceptance Criteria:**
- [ ] Active duel screen shows both participants' step counts
- [ ] Progress bars visualize relative performance
- [ ] Lead indicator shows who is currently winning
- [ ] Countdown timer displays time remaining (HH:MM:SS format)
- [ ] Step counts update automatically every 5 minutes
- [ ] Pull-to-refresh manually syncs latest data
- [ ] Last sync timestamp displayed: "Updated 2 minutes ago"

**Design Notes:**
- Bold, clear typography for step counts
- Progress bars with contrasting colors
- Lead indicator (trophy icon or "You're winning!" text)
- Countdown timer always visible

---

### US-DUEL-006: Receive Lead Change Notification

**As a** user in an active duel
**I want** to be notified when the lead changes
**So that** I'm motivated to increase my activity

**Priority:** P1 (High)

**Acceptance Criteria:**
- [ ] Push notification sent when lead switches to other participant
- [ ] Notification title: "Lead Change!"
- [ ] Notification body: "[Friend Name] just took the lead!"
- [ ] Or: "You're now in the lead!"
- [ ] Throttled to max 1 notification per 15 minutes
- [ ] Tapping notification opens active duel screen
- [ ] In-app badge indicator shows unread lead changes

**Design Notes:**
- Exciting, motivational tone
- Notification includes current step counts

---

### US-DUEL-007: Monitor Countdown Timer

**As a** user in an active duel
**I want** to see how much time remains
**So that** I can plan my activity to maximize steps

**Priority:** P1 (High)

**Acceptance Criteria:**
- [ ] Countdown timer prominently displayed on active duel screen
- [ ] Format: "HH:MM:SS" or "X hours Y minutes remaining"
- [ ] Timer updates in real-time (every second)
- [ ] Timer turns red when <1 hour remains (urgency)
- [ ] Push notification sent at 1 hour remaining: "One hour left!"
- [ ] Timer reaches 00:00:00 and duel automatically completes

**Design Notes:**
- Large, easily readable font
- Color change for final hour creates urgency

---

### US-DUEL-008: Manually Refresh Step Data

**As a** user in an active duel
**I want** to manually refresh my step count
**So that** I can see my latest progress immediately

**Priority:** P1 (High)

**Acceptance Criteria:**
- [ ] Pull-to-refresh gesture on active duel screen
- [ ] Loading spinner during refresh
- [ ] Step count updates after refresh completes
- [ ] Last sync timestamp updates: "Updated just now"
- [ ] Error message if refresh fails: "Unable to sync. Try again."

**Design Notes:**
- Standard pull-to-refresh pattern
- Clear visual feedback during sync

---

## Duel Results

### US-DUEL-009: View Duel Result

**As a** user whose duel just completed
**I want** to see the final result with a clear winner/loser
**So that** I know who won and by how much

**Priority:** P0 (Critical)

**Acceptance Criteria:**
- [ ] Push notification at duel completion directs to result screen
- [ ] Result screen shows: both participants, final step counts, winner
- [ ] Winner displayed with celebration icon/animation (🎉, ⭐)
- [ ] Loser displayed with punishment emoji (🙇)
- [ ] Margin of victory shown: "You won by 1,234 steps!"
- [ ] Duel date and time range displayed
- [ ] "Share Result" button prominent
- [ ] "Back to Home" navigation

**Design Notes:**
- Winner/loser distinction immediately obvious
- Celebration for winner, lighthearted commiseration for loser
- Vibrant colors and animations

---

### US-DUEL-010: Handle Tie Result

**As a** user in a duel that ended in a tie
**I want** to see a tie outcome
**So that** I know the competition was even

**Priority:** P2 (Medium)

**Acceptance Criteria:**
- [ ] Tie occurs when both participants have identical step counts
- [ ] Result screen shows: "It's a tie!"
- [ ] Both participants shown with equal standing (no winner/loser)
- [ ] Share card reflects tie outcome
- [ ] Both users considered "winners" in statistics

**Design Notes:**
- Friendly tie message: "You're equally awesome!"
- Special tie badge or icon

---

### US-DUEL-011: View Duel History

**As a** user
**I want** to see a list of my past completed duels
**So that** I can review my performance and track progress

**Priority:** P1 (High)

**Acceptance Criteria:**
- [ ] "History" tab on home screen
- [ ] List of completed duels sorted by date (most recent first)
- [ ] Each entry shows: opponent, result (win/loss/tie), final score, date
- [ ] Tapping entry opens full result screen
- [ ] Filter options: All / Wins / Losses (optional MVP)
- [ ] Summary stats at top: Total duels, wins, losses, win rate

**Design Notes:**
- Clear visual indicators for win/loss (green checkmark, red X)
- Summary stats card at top of screen

---

## Notifications

### US-NOTIF-001: Receive Duel Invitation Notification

**As a** user
**I want** to receive a push notification when challenged
**So that** I can respond quickly to invitations

**Priority:** P0 (Critical)

**Acceptance Criteria:**
- [ ] Push notification sent immediately when challenge created
- [ ] Notification title: "New Duel Challenge!"
- [ ] Notification body: "[Friend Name] challenged you to a 24-hour step duel!"
- [ ] Action buttons: "Accept" | "Decline"
- [ ] Tapping notification opens duel invitation screen
- [ ] In-app badge indicator shows unread invitations

---

### US-NOTIF-002: Receive Duel Start Notification

**As a** user whose duel just became active
**I want** to receive a notification
**So that** I know the competition has begun

**Priority:** P1 (High)

**Acceptance Criteria:**
- [ ] Push notification sent when both users accepted
- [ ] Notification title: "Duel Started!"
- [ ] Notification body: "Your duel with [Friend Name] has begun. Time to move!"
- [ ] Includes duel end time
- [ ] Tapping notification opens active duel screen

---

### US-NOTIF-003: Receive Duel End Notification

**As a** user whose duel just completed
**I want** to receive a notification with the result
**So that** I know the outcome immediately

**Priority:** P0 (Critical)

**Acceptance Criteria:**
- [ ] Push notification sent exactly at 24-hour mark
- [ ] Winner notification: "You won! Final: [Your Steps] vs [Their Steps]"
- [ ] Loser notification: "Duel complete. Final: [Your Steps] vs [Their Steps]"
- [ ] Tapping notification opens result screen

---

### US-NOTIF-004: Manage Notification Preferences

**As a** user
**I want** to control which notifications I receive
**So that** I'm not overwhelmed by alerts

**Priority:** P2 (Medium)

**Acceptance Criteria:**
- [ ] Settings screen with notification toggles
- [ ] Options: Duel invitations, Lead changes, Duel start, Duel end
- [ ] Each toggle saves preference to Firestore
- [ ] Disabled notifications still show in-app (not push)
- [ ] System notification permissions respected

---

## Health Integration

### US-HEALTH-001: Grant Health Permission

**As a** new user
**I want** to understand why Health Duel needs health data access
**So that** I feel comfortable granting permission

**Priority:** P0 (Critical)

**Acceptance Criteria:**
- [ ] Permission request screen explains data usage clearly
- [ ] Text: "Health Duel reads your step count to track duel progress. Your data is private and only shared with duel participants."
- [ ] iOS: Tapping "Allow" triggers HealthKit permission dialog
- [ ] Android: Tapping "Allow" triggers Health Connect permission flow
- [ ] Permission granted: User proceeds to home screen
- [ ] Permission denied: Educational screen explains limitations

**Design Notes:**
- Clear, friendly explanation
- Visual of step count data being used
- "Learn More" link to privacy policy

---

### US-HEALTH-002: Sync Step Data

**As a** user in an active duel
**I want** my step count to sync automatically
**So that** my progress is always up to date

**Priority:** P0 (Critical)

**Acceptance Criteria:**
- [ ] App queries health API every 5 minutes for active duels
- [ ] iOS: Query HealthKit for HKQuantityTypeIdentifierStepCount
- [ ] Android: Query Health Connect for Steps data type
- [ ] Data filtered to current duel 24-hour window
- [ ] Synced step count stored in Firestore
- [ ] Last sync timestamp displayed in UI
- [ ] Background sync when app is closed (best effort)

---

### US-HEALTH-003: Handle Missing Health Permission

**As a** user who denied health permission
**I want** to be guided to re-enable it
**So that** I can participate in duels

**Priority:** P1 (High)

**Acceptance Criteria:**
- [ ] Attempting to accept duel without permission shows error
- [ ] Error message: "Health access required to participate in duels"
- [ ] "Enable Access" button opens permission flow again
- [ ] iOS: Button opens Settings app to Health permissions
- [ ] Android: Button re-triggers Health Connect permission
- [ ] After granting, user returns to duel acceptance

---

### US-HEALTH-004: View Sync Status

**As a** user
**I want** to see when my step data was last synced
**So that** I know my progress is current

**Priority:** P2 (Medium)

**Acceptance Criteria:**
- [ ] Last sync timestamp displayed on active duel screen
- [ ] Format: "Updated X minutes ago" or "Updated just now"
- [ ] Sync indicator icon changes color based on status:
  - [ ] Green: Synced < 5 minutes ago
  - [ ] Yellow: Synced 5-15 minutes ago
  - [ ] Red: Not synced in 15+ minutes
- [ ] Tapping indicator explains sync status

---

## Profile Management

### US-PROFILE-001: View My Profile

**As a** user
**I want** to view my profile
**So that** I can see my stats and information

**Priority:** P1 (High)

**Acceptance Criteria:**
- [ ] Profile screen accessible from settings/menu
- [ ] Displays: avatar, display name, bio (optional)
- [ ] Shows stats: Total duels, wins, losses, win rate, current streak
- [ ] "Edit Profile" button navigates to edit screen

**Design Notes:**
- Clean card-based layout
- Stats prominently displayed with icons

---

### US-PROFILE-002: Edit Profile

**As a** user
**I want** to update my display name and avatar
**So that** my friends recognize me

**Priority:** P1 (High)

**Acceptance Criteria:**
- [ ] "Edit Profile" screen allows changing: display name, bio, avatar
- [ ] Tap avatar to upload new photo (camera or gallery)
- [ ] Display name validation: 3-30 characters, alphanumeric + spaces
- [ ] Bio optional, max 150 characters
- [ ] "Save" button updates Firestore user document
- [ ] Changes reflected immediately in UI and for friends

---

### US-PROFILE-003: View Friend Profile

**As a** user
**I want** to view a friend's profile
**So that** I can see their duel stats

**Priority:** P2 (Medium)

**Acceptance Criteria:**
- [ ] Tapping friend in list opens their profile
- [ ] Displays: avatar, name, bio
- [ ] Shows stats: Total duels with me, their win rate against me
- [ ] "Challenge" button to start new duel
- [ ] "View Duel History" shows past duels with this friend

---

## Priority Summary

**P0 (Critical - MVP Blockers):**
- Authentication (register, login)
- Friend management (add, view list)
- Duel creation and invitation
- Active duel progress tracking
- Duel results display
- Health permission and sync
- Core notifications (invitation, end)

**P1 (High - MVP Important):**
- Password reset
- Duel history
- Lead change notifications
- Profile management
- Pending duel management

**P2 (Medium - Nice to Have):**
- Friend search and removal
- Notification preferences
- Tie handling
- Friend profile viewing
- Advanced sync status

---

## Related Documents

- [Product Requirements Document](prd-health-duels-1.0.md) - Complete PRD
- [Architecture Overview](../02-architecture/ARCHITECTURE_OVERVIEW.md) - Technical architecture
- [Feature Guides](../05-guides/feature-guides/) - Implementation guides

---

**Document Version:** 1.0
**Last Updated:** 2026-02-08
**Total User Stories:** 34 (18 P0, 9 P1, 7 P2)
