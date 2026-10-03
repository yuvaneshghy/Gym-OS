# Roadmap

This document outlines the phased delivery plan for GymKit.

## 🟢 Phase 1: Core SaaS MVP (Current)
- [x] Repo scaffold (feature-first, Riverpod, go_router, strict lints)
- [x] PocketBase schema + migrations + API rules (users, plans, members)
- [x] Tenant config loader + Theme System (AsyncNotifier + Dynamic Colors)
- [x] Authentication & Role-Based Access Control
- [x] Layout & Docks (macOS style dynamic docks)
- [x] Settings → Branding with live preview (Local Theme Preferences)
- [x] Admin Dashboard (Revenue, Members, Present Now metrics)
- [ ] Member Management CRM (CRUD, profiles)
- [ ] Membership Plans & Assignment (Creation, expiry tracking)
- [ ] Manual Payments & Receipts (Invoices, partial payments)
- [ ] Active Mode / Attendance (QR & Manual check-in, Live Feed)
- [ ] Local Offline-first SQLite Sync (Future optimization)

## 🟡 Phase 1.5: Engagement & Fitness
- [ ] Workout Plans (Sets, reps, weights assigned by trainers)
- [ ] Progress Tracking (Measurements, photos)
- [ ] Group Classes & Slot Bookings
- [ ] Automated Expiry/Dues Reminders (pb_hooks)

## 🔴 Phase 2: Enterprise & Hardware
- [ ] In-app Chat (Trainers <-> Members)
- [ ] Payment Gateway Integration (Stripe / Razorpay)
- [ ] Hardware Turnstile/RFID Integration
- [ ] Push Notifications (FCM)

