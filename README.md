# GymKit (v0.1.0)

A fast, compact, white-label Gym management product (member app + owner dashboard) built on a single Flutter codebase.

> [!CAUTION]
> **Proprietary Software**
> This is a private, closed-source commercial product. Unauthorized copying, modification, or distribution is strictly prohibited.

## 📱 Features

### 🏢 Owner / Admin
- **Financial Dashboard:** Real-time revenue tracking, pending dues, and payment history.
- **Member Management:** View all members, membership status, attendance, and contact info.
- **Plan Control:** Create, edit, and disable membership plans, trial passes, and drop-in rates.
- **Access Control:** Assign roles (Manager, Receptionist, Trainer) and manage permissions.
- **White-label Config:** Configure app branding (colors, logos) and toggle feature flags dynamically.

### 🏋️ Customer / Member
- **Digital Access:** Quick QR code generation for turnstile/desk check-in.
- **Membership Management:** View plan details, renew via in-app payments, and receive expiry reminders.
- **Fitness Tracking:** View assigned workout plans, log daily workouts, and track progress.
- **Classes & Bookings:** View the gym timetable and book slots for group classes.

### 👥 Groups / Staff
- **Receptionist:** Fast QR check-in, immediate alerts for pending dues, and POS cash/card processing.
- **Trainer:** View assigned members, assign workout plans, track progress, and view class schedules.
- **Manager:** Handle day-to-day operations, staff shifts, and override system locks if necessary.

## 🏗️ Architecture

GymKit follows a clean **Feature-First Architecture** combined with a strict **Multi-Tenant** backend design (one PocketBase instance per client).

> [!TIP]
> **Deep Dives:**
> - Check out [docs/README.md](docs/README.md) for our beautifully organized documentation hub.
> - Check out [EXPLANATION.md](docs/architecture/EXPLANATION.md) for a comprehensive Q&A and architecture diagram.
> - Check out [agent-memory.md](agent-memory.md) for a full breakdown of the directory structure and project session logs.

### Tech Stack
| Layer | Technology | Purpose | Documentation |
|-------|------------|---------|---------------|
| **Client** | [Flutter (Dart)](https://flutter.dev/) | Cross-platform UI framework | [Docs](https://docs.flutter.dev/) |
| **State** | Riverpod (`flutter_riverpod`) | Reactive state management | [Pub](https://pub.dev/packages/flutter_riverpod) |
| **Routing** | `go_router` | Declarative routing | [Pub](https://pub.dev/packages/go_router) |
| **Backend** | [PocketBase](https://pocketbase.io/) | Multi-tenant auth, DB, and API rules | [Docs](https://pocketbase.io/docs/) |
| **Hosting** | Docker + Caddy | Containerized deployments and reverse proxy | |

### Key Components

- **`lib/core/`**: Centralized theme system, shared widgets, and constants.
- **`lib/features/`**: Business logic grouped by domain (`auth`, `members`, `payments`, etc.).
- **`lib/data/`**: PocketBase client and offline caching.
- **`lib/app/`**: High-level app initialization, router, and responsive layout wrappers.
- **`pb/`**: Shared PocketBase migrations and hooks.

## 🚀 Getting Started

Ensure you have Flutter (v3.47+) installed.

1. Clone the repository: `git clone https://github.com/North-Abyss/GYM-CT.git`
2. Install dependencies: `flutter pub get`
3. Launch PocketBase locally.
4. Run the app: `flutter run`

## 🗺️ Roadmap
Check out the phased delivery plan in [docs/meta/ROADMAP.md](docs/meta/ROADMAP.md).

## 🔗 Repository
[North-Abyss/GYM-CT](https://github.com/North-Abyss/GYM-CT) (Private)
