# GymOS Master Architecture & Project Plan

## 1. System Overview
GymOS (GymKit) is a multi-tenant, cross-platform application designed to manage gyms. 
- **Frontend:** Flutter (Mobile, Web, Desktop) utilizing Riverpod for state management and GoRouter for navigation.
- **Backend:** PocketBase.
- **Multi-Tenancy Model:** Strict Isolation (One PocketBase instance per client/gym). The app connects to the correct backend using `--dart-define=PB_URL=...`.
- **Theming Architecture:** "One-Point System" using `AppTokens` and `TenantConfig`. Hardcoded colors and radii are forbidden. Theme configuration is driven by database fields (`app_config`), allowing each gym to have a white-labeled appearance instantly.

---

## 2. Account Types (Personas) & Role-Based Access Control

### 1. Admin (Owner / Client)
**Description:** Has full visibility and control over operations, finances, and configuration.
**Core Features:**
- Multi-tenant configurations (Theme colors, logos, currency).
- Financial Dashboards (Revenue, pending dues).
- Staff & Team management (Assign roles).
- Creating Membership Plans.
**Primary Platform:** Web Dashboard (with Mobile fallback).

### 2. Groups (Staff / Trainers / Receptionist / Manager)
**Description:** Day-to-day operators with limited access to financial configuration.
**Core Features:**
- **Receptionist:** Fast QR check-in processing, registering walk-ins, handling cash payments.
- **Trainer:** Assign workout plans, view member progress, manage group classes.
- **Manager:** Staff shifts, overriding locks.
**Primary Platform:** Web & Tablet Dashboard.

### 3. Customer (Member)
**Description:** The end-user attending the gym.
**Core Features:**
- Digital QR code for check-in.
- View active membership days remaining and payment history.
- Log body metrics and workout sets.
- Book slots for classes (Zumba, HIIT, etc.).
**Primary Platform:** Mobile App.

---

## 3. UI/UX Structure (Pages & Components)

### App Shell (`AppLayout`)
- **Web/Tablet View:** Split view for login, persistent top/bottom docks dynamically rounded and colored via `context.tokens`.
- **Global Scanner Listener:** A background listener capturing physical barcode scanner inputs from any admin screen.

### Core Screens
1. **Auth (`/login`)**: Login screen adapting to mobile/desktop, displaying the gym's specific logo.
2. **Dashboard (`/dashboard`)**: (Admins/Staff) Real-time stats (Total Members, Active, Present Today, Revenue).
3. **Members List (`/members`)**: Search, filter by active/expired.
4. **Member Profile (`/member/:id`)**: Detailed view of a single member. 
   - **Dialogs:** `AssignPlanDialog`, `RecordPaymentDialog`.
5. **Plans (`/plans`)**: CRUD operations for Gym Memberships.
6. **Kiosk / Check-in (`/kiosk`)**: Open-ended scanning page for hardware integration.
7. **Member Portal (`/member`)**: The mobile-first view for Customers. 
8. **Settings (`/settings`)**: Theme editor, gym details, default currency, and staff management.

### Common Components
- `AppButton`: Inherits global corner radius and brand colors.
- `AppTextField`: Adheres to `TenantConfig.inputStyle` (outlined, filled, underlined).
- `_StatCard`: Dashboard analytic cards.

---

## 4. Feature Matrix & Roadmap

### Phase 1.1 (Core Hardening) - COMPLETED
- Multi-tenant Core & Dynamic Theming (White-labeling).
- Auth & RBAC (Admin, Staff, Member).
- Global Hardware Barcode Scanner integration.
- Check-in/Check-out Debounce Logic.
- Currency Configuration & Payment Tracking.

### Phase 1.5 (Engagement & Fitness) - UPCOMING
- **Workouts Module:** Trainers assign exercises, sets, and reps to Members. Members log completion.
- **Progress Metrics:** Charting bodyweight and body fat percentage over time via `fl_chart`.
- **Class Bookings:** Scheduling and capacity enforcement for Group Classes.

### Phase 2.0 (Advanced Operations) - FUTURE
- **In-app Chat:** Direct messaging between Trainers and Members.
- **Diet Plans:** Macronutrient tracking.
- **E-Commerce:** In-gym store for supplements and gear.
- **Hardware Integrations:** Native Turnstile/RFID hooks.
