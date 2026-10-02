# GymKit (White-label Gym Management)

GymKit is a fast, compact, white-label Gym management product (member app + owner dashboard) built on a single Flutter codebase. It is designed to be sold to gym owners as a one-time white-label template or as a monthly managed service.

## Tech Stack
* **Client:** Flutter (Dart), Riverpod (State Management), go_router (Routing)
* **Backend:** PocketBase (One instance per client/tenant for strict data isolation)
* **Hosting:** Docker containers + Caddy reverse proxy

## Architecture Highlights
* **Config over code:** All client-specific branding (colors, logos, fonts) and feature toggles are fetched dynamically. No per-client forks are required.
* **Global Theme System:** UI relies entirely on a centralized theme and token system to allow instant white-labeling.
* **Feature-first layout:** Code is organized by feature (`auth`, `members`, `payments`, etc.), containing `domain`, `data`, and `presentation` layers.

## Getting Started

1. Ensure you have Flutter installed (`flutter doctor`).
2. Run `flutter pub get` to install dependencies.
3. Run the app: `flutter run`

## Documentation
* See `agent-memory.md` for architecture decisions, roadmap, and project state.
* See `docs/gym_app_requirements.md` for user personas and feature requirements.
