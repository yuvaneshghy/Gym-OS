# Changelog

All notable changes to GymKit will be documented in this file.

## [Unreleased]
### Added
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
