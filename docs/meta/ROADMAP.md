# Roadmap

This document outlines the phased delivery plan for GymKit.

## 🟢 Phase 1: Core SaaS MVP (Current)
- [x] Repo scaffold (feature-first, Riverpod, go_router, strict lints)
- [ ] PocketBase schema + migrations + API rules (users, plans, members)
- [ ] Tenant config loader + Theme System (`AppTokens`, `App*` widgets)
- [ ] Authentication & Role-Based Access Control
- [ ] Settings → Branding with live preview
- [ ] Member management & Memberships
- [ ] Manual Payments + Receipts
- [ ] QR Attendance check-in
- [ ] Owner Dashboard (Analytics)
- [ ] Provisioning script (`ops/provision.sh`)

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
