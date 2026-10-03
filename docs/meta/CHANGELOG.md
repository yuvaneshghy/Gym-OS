# Changelog

All notable changes to GymKit will be documented in this file.

## [Unreleased]
### Added
- **Global Hardware Scanner (Phase 1.1)**: Implemented a global `HardwareKeyboard` listener at the `AppLayout` level. USB barcode scanners now automatically trigger check-ins from any admin/staff screen, eliminating the need to have the "Check-In" screen actively open.
- **Member Dashboard Overhaul (Phase 1.1)**: `MemberHomeScreen` now displays the user's active plan, expiry progress bar, and recent payment history alongside their digital ID QR code.
- **Checkout & Debounce Logic (Phase 1.1)**: `AttendanceRepository` now records `check_out_time` if a member scans their ID again after 5 minutes. It also ignores duplicate scans within a 5-minute window to prevent accidental double-logging.
- **Combined Phase 1.5 Schema**: Created `1790940001_phase1_combined_schema.js` to initialize collections for workouts, exercises, metrics, and classes.
- **Rich Seed Data**: Added `1790940002_rich_seed_data.js` migration to automatically populate the database with memberships, payments, attendance history, and sample fitness data.
- **Staff Management (Phase 1.5)**: Implemented `StaffScreen` and `AddStaffDialog` within the Settings module. Owners can now create sub-accounts for trainers, receptionists, and managers with specific role-based permissions.
- **Dashboard**: Created `DashboardScreen` displaying metrics like Total Members, Active Members, Present Today, and Monthly Revenue.
- **Member CRM (Directory & Profile)**: Built `MembersDirectoryScreen` with real-time search/filter capabilities and an "Add Member" dialog. Built `MemberProfileScreen` enabling admins to edit member profiles, assign plans, and delete members.
- **Plans Management**: Implemented `PlansScreen` allowing admins to create, edit, and delete plans.
- **Payments Integration**: Added `RecordPaymentDialog` for tracking membership fees, methods, and generation dates.
- **Check-In Scanner (Active Mode)**: Added `ActiveModeScreen` as a kiosk/scanner for fast member check-ins. Supports manual ID entry and displays a success/failure overlay on scan.
- **Member Home (QR Code)**: Created `MemberHomeScreen` integrating `qr_flutter` to display the member's digital ID for easy check-ins.
- **Theme Engine**: Built `buildGymKitTheme()` to dynamically generate `ThemeData` based on tenant config (`app_config`), ensuring 100% white-label capability (Phase 1).
- **Core UI Wrappers**: Scaffolded `AppButton` and `AppTextField` that strictly adhere to the tenant's `Theme.of(context)` to prevent hardcoded styles.
- **Role-Based Routing**: Implemented `GoRouter` configuration in `router.dart` with automatic role-based redirection (`/dashboard` for staff, `/member` for customers, `/login` for unauthenticated).
- **Auth Repository**: Built `AuthRepository` securely wrapping PocketBase `authWithPassword` logic using the `AuthStore.record` property (v0.25 SDK compliance).
- **Backend Migrations**: Overhauled core prototype migrations (v0.40 compliant), using flat properties and explicit dummy Collection parsing for `core.Field` injection. Defined core schemas (`users`, `app_config`, `members`, `plans`, `memberships`, `payments`, `attendance`).
- **Role Mappings**: Enforced precise role taxonomy (`owner`, `manager`, `receptionist`, `trainer`, `member`).
- **API Security**: Added strict API Rules to all generated collections to prevent unauthenticated data access, ensuring members only read their data, and staff can manage tenant operations.
- **Tenant Config Loader**: Implemented `TenantConfigRepository` utilizing Riverpod to read tenant configuration first from shared preferences (cache) and then seamlessly refresh from the API.
- **Seed Data**: Added dev-only seed script (`1790939800_seed_data.js`) to inject initial owner, member, plans, and configuration for rapid frontend testing.
- **Mac/Gnome Dock Layout**: Added `AppLayout` wrapper using `ShellRoute` to wrap all authenticated screens with a dynamic Top Dock (Logo, App Name, Role, Logout) and Bottom Dock (Navigation).
- **Theme Mode Switcher**: Added local `SharedPreferences` backed `ThemeModeNotifier` to allow users to toggle System/Light/Dark mode without affecting the tenant's brand color.
- **Config Realtime AsyncNotifier**: Refactored `TenantConfigRepository` into a strict `AsyncNotifier` state machine. It immediately boots with cached memory, asynchronously streams fresh data from PocketBase, and dynamically invalidates the UI on successful background loads. 
- **Developer Tools**: Upgraded `.gitignore` to safely track `pubspec.lock` while ignoring system locks, and added `-h` flag parsing to `git-sync.sh`.
- **Custom Logo Integration**: `SettingsScreen` now supports uploading a custom logo to PocketBase using `image_picker`. The uploaded logo scales dynamically and displays on the `LoginScreen` and Top Dock.
- **Dynamic Theming UI Polish**: Refactored Top/Bottom docks and Logout button to strictly adhere to the dynamic `Theme.of(context)` engine. Replaced hardcoded black shadows with `theme.shadowColor` and added `theme.colorScheme.outlineVariant` dock outlines.
- **User-Friendly Login Errors**: Caught raw `ClientException` payloads in `LoginScreen` to display user-friendly "Invalid email or password." warnings on authentication failure.
- **Data Synchronization Bugfix**: Fixed `tenant_config_repository` to query PocketBase with `sort: '-updated'` to prevent duplicate/stale records from being cached when new configurations are saved.
- **Agent Memory**: Initialized `agent-memory.md` linking to a newly structured `docs/` hub.

## [v0.1.0] - 2026-10-02
### Added
- Initial Flutter project scaffold (`flutter_riverpod`, `go_router`, `pocketbase`).
- Feature-first directory structure.
- Strict lints and CI theme-rule grep checker.
- Comprehensive documentation hub (`docs/`) and `README.md`.
- Architecture and requirements planning.
