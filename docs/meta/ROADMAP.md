# Roadmap

This document outlines the phased delivery plan for GymKit.

## 🟢 Phase 1: Core SaaS MVP (Complete)
- [x] Repo scaffold (feature-first, Riverpod, go_router, strict lints)
- [x] PocketBase schema + migrations + API rules (users, plans, members)
- [x] Tenant config loader + Theme System (AsyncNotifier + Dynamic Colors)
- [x] Authentication & Role-Based Access Control
- [x] Layout & Docks (macOS style dynamic docks)
- [x] Settings → Branding with live preview (Local Theme Preferences)
- [x] Admin Dashboard (Revenue, Members, Present Now metrics)
- [x] Member Management CRM (CRUD, profiles)
- [x] Membership Plans & Assignment (Creation, expiry tracking)
- [x] Manual Payments & Receipts (Invoices, partial payments)
- [ ] GST Invoicing & Compliance
- [x] Active Mode / Attendance (QR & Manual check-in, Live Feed)
- [ ] Local Offline-first SQLite Sync (Future optimization)

## 🟡 Phase 1.5: Engagement & Fitness (Current)
- [ ] Staff & Employee Management (Roles, permissions, invites)
- [ ] Workout Plans (Sets, reps, weights assigned by trainers)
- [ ] Progress Tracking (Measurements, photos)
- [ ] Group Classes & Slot Bookings
- [ ] WhatsApp Automation (Expiry alerts, payment reminders)
- [ ] Optional Cloud Backup & Sync Engine
- [ ] Audit Logs for Staff Actions

## 🔴 Phase 2: Enterprise & Hardware
- [ ] In-app Chat (Trainers <-> Members)
- [ ] Payment Gateway Integration (Stripe / Razorpay)
- [ ] Hardware Turnstile/RFID Integration
- [ ] Software Face Recognition (Tier 1 Biometric Check-in)
- [ ] Push Notifications (FCM)

