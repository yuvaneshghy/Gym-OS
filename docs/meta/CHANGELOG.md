# Changelog

All notable changes to GymKit will be documented in this file.

## [Unreleased]
### Added
- **Backend Validation**: Overhauled core prototype migrations (v0.40 compliant), using flat properties, explicit dummy Collection parsing for `core.Field` injection, and accurate role mappings (owner, manager, receptionist, trainer, member).
- **API Security**: Added strict API Rules to all generated collections to prevent unauthenticated data access, tested and confirmed via local cURL.
- **Tenant Config Loader**: Implemented `TenantConfigRepository` utilizing Riverpod to read tenant configuration first from shared preferences (cache) and then seamlessly refresh from the API.
- **Seed Data**: Added dev-only seed script to create initial admin and member accounts for frontend testing.

## [v0.1.0] - 2026-10-02
### Added
- Initial Flutter project scaffold (`flutter_riverpod`, `go_router`, `pocketbase`).
- Feature-first directory structure.
- Strict lints and CI theme-rule grep checker.
- Comprehensive documentation hub (`docs/`) and `README.md`.
- Architecture and requirements planning.
