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
- **Agent Memory**: Initialized `agent-memory.md` linking to a newly structured `docs/` hub.

## [v0.1.0] - 2026-10-02
### Added
- Initial Flutter project scaffold (`flutter_riverpod`, `go_router`, `pocketbase`).
- Feature-first directory structure.
- Strict lints and CI theme-rule grep checker.
- Comprehensive documentation hub (`docs/`) and `README.md`.
- Architecture and requirements planning.
