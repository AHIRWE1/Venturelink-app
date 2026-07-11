# Campus Ventures Link

Connecting ALU students with startup opportunities.

Campus Ventures Link is a Flutter + Firebase mobile platform built for the
ALU ecosystem. Verified ALU startups post real internship/volunteer
opportunities, students discover and apply to them, and ALU admins run a
lightweight verification gate so only startups the university actually
recognizes can appear on the platform.

## Who it's for

The app has three roles, each with its own dashboard and permissions:

- **Student** — browse a personalized, skill-matched feed of opportunities,
  bookmark them, apply with a cover letter, and track application status.
- **Founder** — create a startup profile, wait for admin verification, then
  post opportunities and review applicants.
- **Admin** — approve or reject startup verification requests and manage
  user roles.

## Features

- Email/password authentication restricted to `@alustudent.com` addresses,
  plus a guided onboarding flow (role selection, skills, bio, links).
- Startup creation with an admin verification workflow (`pending` →
  `approved`/`rejected`), including a resubmit flow if rejected.
- Opportunity posting (category, employment type, required skills,
  deadline) — **hard-gated** so only founders with an approved startup can
  post, enforced server-side by the query itself, not just hidden in the UI.
- Opportunity discovery: search, category filters, a skill-matched
  "Recommended" carousel, and a "Browse by category" grid.
- Applications with cover letters and a status pipeline
  (`pending → interview → accepted/rejected`).
- Bookmarking, with a grid/list view toggle.
- Founder and Admin dashboards with live stats, quick actions, and preview
  lists — everything updates in real time from Firestore.
- Light/dark theme with a manual override (Profile → Appearance), on top of
  following the OS setting by default.
- Consistent design system: shared color/spacing/typography tokens and a
  reusable widget library (`lib/shared/widgets/`) — gradient headers, stat
  cards, action tiles, chips, section cards, empty states — used across
  every screen instead of one-off styling per screen.

## Tech stack

- **Flutter** (Dart) — UI framework
- **Firebase Authentication** — email/password sign-in
- **Cloud Firestore** — real-time backend (`users`, `startups`,
  `opportunities`, `applications`, `bookmarks` collections)
- **Riverpod** (`flutter_riverpod`) — state management (`StreamProvider`,
  `NotifierProvider`, `FutureProvider.family`)
- **go_router** — declarative routing with a role-based redirect
- **shared_preferences** — persisting the theme preference

## Architecture

Feature-first, layered structure — each feature owns its own data,
state, and UI slice. This is the real, current tree (not aspirational):

```
lib/
├── core/
│   ├── router/          # app_router.dart — go_router config + role-based redirect
│   ├── theme/           # app_colors, app_text_styles, app_spacing, app_theme,
│   │                     # theme_controller (persisted light/dark/system)
│   ├── constants/        # app_routes, app_strings, firestore_constants
│   └── utils/            # auth_exception_mapper, validators
│
├── features/
│   ├── auth/                          # login/register, AuthController, AuthRepository
│   ├── onboarding/                    # role + profile setup after first sign-in
│   ├── startup/                       # startup profile CRUD + admin verification screen
│   ├── opportunity/                   # posting, explore/search, + domain/ matching logic
│   ├── application/                   # apply, applications list, founder applicants
│   ├── bookmark/                      # save/unsave, bookmarks list
│   ├── profile/                       # student/founder/admin dashboards + profile screen
│   │                                   #   (all three role dashboards live here — see note)
│   ├── providers/                     # auth_provider.dart — low-level cross-feature
│   │                                   #   repository providers, outside the per-feature pattern
│   └── splash/                        # splash screen
│
└── shared/
    ├── models/     # AppUser, Opportunity, Startup, ApplicationModel, Bookmark
    └── widgets/    # design-system components: GradientHeader, MetricCard, ActionTile,
                     # AppChip, SectionCard, InfoRow/InfoCard, CategoryCard,
                     # SearchBarWidget, OpportunityCard, StatusBadge, EmptyStateWidget,
                     # BookmarkToggleButton, SectionHeader, AppTextField, AppPrimaryButton,
                     # AuthFormScaffold
```

Within a feature: `data/` holds the repository (the only code that talks to
`cloud_firestore`), `presentation/controllers/` holds Riverpod providers and
`Notifier`s (the only code that talks to a repository), and
`presentation/screens/` holds widgets (the only code that watches a
provider and renders UI) — so it's always
`screen → controller (Riverpod) → repository → Firestore`, never a widget
calling Firestore directly.

Two structural quirks worth knowing if you're navigating the code: the
**`profile` feature is where every role's dashboard actually lives**
(`student_dashboard_screen.dart`, `founder_dashboard_screen.dart`,
`admin_dashboard_screen.dart`, `admin_users_screen.dart`, plus the shared
`profile_screen.dart` and the bottom-nav shell `main_shell.dart`) rather
than each role having its own top-level feature folder; and
**`features/providers/auth_provider.dart`** holds `authRepositoryProvider`
and `userRepositoryProvider` as a small shared exception to the
per-feature-owns-its-repository rule, since both are needed across several
features. A handful of other empty scaffold folders (`features/admin/`,
`core/services/`, `features/auth/domain/`, etc.) exist from early project
setup but hold no code — they're not part of the real architecture.

See the technical report for the complete architecture writeup with
diagrams, database schema, and justification of the major design
decisions.

## Getting started

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install)
   and make sure `flutter doctor` is clean.
2. Clone the repo and fetch dependencies:
   ```bash
   cd campus_ventures_link
   flutter pub get
   ```
3. This repo already includes a configured `firebase_options.dart` and
   `android/app/google-services.json` for the project's Firebase backend.
   If you're pointing this at your **own** Firebase project instead, run
   `flutterfire configure` to regenerate those files, and create the five
   Firestore collections listed above (they're created automatically on
   first write, so no manual setup is required beyond an empty Firestore
   database).
4. Run on a connected device or emulator (the app must run on a real
   device/emulator, not just a browser):
   ```bash
   flutter run
   ```

### Firestore Security Rules

`firestore.rules` is included in the repo but **is not deployed
automatically**. Paste its contents into Firebase Console → Firestore
Database → Rules (or wire up `firebase deploy --only firestore:rules` via
the Firebase CLI) before treating the app's permission checks as
server-enforced rather than UI-only.

## Testing

```bash
flutter analyze
flutter test
```

## Known limitations

- `firestore.rules` isn't deployed yet — see above.
- No pagination, push notifications, in-app messaging, or profile
  photo/CV upload yet (the last one has its dependencies declared but not
  wired up).
- Admin can't disable a user's account — that requires the Firebase Admin
  SDK, out of reach for a Flutter-client-only app.

Full details and design rationale are in the technical report submitted
alongside this repository.
