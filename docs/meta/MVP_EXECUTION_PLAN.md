# 🏋️ GymOS — MVP Execution Plan

This document breaks down the immediate next steps to complete **Phase 1: Core SaaS MVP** as outlined in the `GymOS_Master_Research_Analysis.md`. We have successfully completed the foundation (Auth, Theme Engine, Config, Layout). We are now moving into the Business Logic modules.

---

## 📅 Upcoming Milestones

### 1. Dashboard & Analytics Module (Next)
**Objective**: Build the Owner/Admin dashboard for a high-level overview of gym performance.
- **Tasks**:
  - Implement `DashboardScreen` UI (Grid of cards).
  - Create PocketBase queries to fetch: Total Members, Active Members, Present Today, Revenue this month.
  - Display recent activity feed (latest check-ins).
- **Target**: Make it look premium with dynamic gradients and micro-animations.

### 2. Member Management (CRM)
**Objective**: A robust directory to view, add, and edit members.
- **Tasks**:
  - Implement `MemberDirectoryScreen` with a paginated data table or sleek list view.
  - Implement Search/Filter capabilities (by name, phone, status).
  - Create `MemberProfileScreen` (Detailed view showing their active plans, payment history, and attendance graph).
  - Add "New Member" modal/form (capturing face photo/avatar, contact info).

### 3. Membership & Plans (In Progress)
### 3. Membership & Plans (Completed)
**Objective**: Allow admins to create standard plans (e.g., "Monthly Cardio", "Annual Elite") and assign them to members.
- **Tasks**:
  - [x] `PlanManagementScreen` (CRUD operations for predefined gym plans).
  - [x] UI flow to assign a plan to a member from their profile.
  - [x] Logic to calculate expiry dates and grace periods.

### 4. Payments & Billing
**Objective**: Record financial transactions securely.
- **Tasks**:
  - Implement payment modal when assigning a plan.
  - Record full or partial payments.
  - Display outstanding balances (Dues) on the member profile and dashboard.
  - Generate basic digital receipt UI.

### 5. Active Mode & Check-In Kiosk
**Objective**: The primary screen displayed at the front desk for member entry.
- **Tasks**:
  - Implement `ActiveModeScreen` (A locked down, full-screen UI).
  - Add a manual search bar (fallback).
  - Add QR code scanner integration.
  - Display a large, clear "Access Granted / Access Denied (Dues Pending)" overlay animation when someone checks in.
  - Append to a live attendance feed on the side of the screen.

---

*This plan acts as our immediate checklist. We will tackle **Dashboard & Analytics** and **Member Management** next.*
