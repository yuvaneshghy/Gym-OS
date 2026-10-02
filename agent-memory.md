# 🧠 Agent Memory — GymKit (working name)

> [!IMPORTANT]
> **Purpose**: Persistent memory for AI agents working on this project.
> **Always read this fully before making changes. Always update it after making changes.**
> Keep it short. If a section grows past ~40 lines, move detail to `docs/` and link it.

---

## 📋 Project Identity

**Version:** 0.1.0
**Goal:** A fast, compact, white-label Gym management product (member app + owner dashboard) on one Flutter codebase, sold to gym owners as (a) a one-time white-label template and (b) a monthly managed service.

| Field            | Value                                                        |
|------------------|--------------------------------------------------------------|
| **Product Name** | GymKit (placeholder)                                         |
| **Platforms**    | Android, iOS, Web (PWA). Desktop optional                    |
| **Client**       | Flutter (Dart), Riverpod, go_router                          |
| **Backend**      | PocketBase, **one instance per client (tenant)**             |
| **Hosting**      | Docker containers + Caddy reverse proxy on a VPS/OCI VM      |
| **CI/CD**        | GitHub Actions, build matrix per client flavor               |
| **Repo Path**    | `/mnt/sda5/Projects/GYM CT`                                  |
| **GitHub Repo**  | `https://github.com/North-Abyss/GYM-CT`                      |

---

## 📚 Documentation Hub

- **[docs/README.md](file:///mnt/sda5/Projects/GYM CT/docs/README.md)**: Main index.
- **[EXPLANATION.md](file:///mnt/sda5/Projects/GYM CT/docs/architecture/EXPLANATION.md)**: Read this to understand the core architecture (Q&A and Mermaid diagram).
- **[ROADMAP.md](file:///mnt/sda5/Projects/GYM CT/docs/meta/ROADMAP.md)**: Keep this updated as phases are completed.
- **[CHANGELOG.md](file:///mnt/sda5/Projects/GYM CT/docs/meta/CHANGELOG.md)**: Log major releases and features here.
- **[feature_matrix.md](file:///mnt/sda5/Projects/GYM CT/docs/requirements/feature_matrix.md)**: Check this to see which role gets which feature.

---

## 💼 Business Model (drives architecture)

1. **Template sale (one-time):** client gets a branded build + their own PocketBase instance they could take over. Needs clean tenant isolation and a handover/export path.
2. **Managed service (monthly):** we host, update, back up, support. Needs fleet tooling: provision, update, backup, monitoring.
3. **Everything client-specific is configuration, not code.** No per-client forks.
4. **Sell tiers via feature flags** (Basic / Pro) from the same codebase.

---

## 🏗️ Architecture Overview

### Multi-tenancy decision
- **One PocketBase instance (own container + own `pb_data`) per client.** Chosen for hard data isolation, per-client backup/restore, easy handover, no cross-tenant bug risk.
- Caddy routes `clientname.ourdomain.com` → container. Custom domains per client supported.
- All instances run the **same PocketBase version and same migrations** (`pb/pb_migrations/`).
- Backend access only through repositories (`features/*/data/`) so the backend can be swapped later.
- Revisit Postgres/Supabase (RLS) only if we need cross-gym analytics or pass ~100–200 tenants.
- SQLite = single writer: store **daily aggregates** (steps, stats), never raw per-minute data.

### Flutter layout (feature-first)

```text
gymkit/
├── lib/
│   ├── main.dart
│   ├── app/            ← router, root shell, responsive layout, global providers
│   ├── core/           ← theme/, tenant config, constants, widgets/ (App* components)
│   ├── features/       ← auth, members, memberships, payments, attendance, classes,
│   │                     workouts, steps, trainers, dashboard, notifications, settings
│   └── data/           ← PocketBase client, offline cache
├── pb/                 ← pb_migrations/, pb_hooks/ (shared by all tenants)
├── tenants/            ← per client: config.json, logo, icons, store assets
├── ops/                ← provision.sh, update_all.sh, backup.sh, Caddyfile template
├── docs/               ← architecture/, guides/, meta/ (roadmap, changelog, pricing)
├── agent-memory.md
└── README.md
```

Each feature: `domain/` (models + Riverpod notifiers), `data/` (repositories), `presentation/` (screens, widgets).

### Tenant config
- `app_config` collection (single record per tenant): brand name, logo, seed color, font, corner radius, input style (outlined|filled), dark/light default, currency, locale, contact info, **feature flags** (classes, workouts, steps, diet, leads, store, qr_checkin, multi_branch).
- App startup: render from **local cache first**, then refresh from PocketBase.
- Native identity (app name, icon, bundle id, splash) comes from build flavors + `tenants/<client>/` + `--dart-define=TENANT=<client>`.
- Web: one build for all tenants; tenant resolved from hostname at runtime.

---

## 🎨 Theme System (global, single source of truth)

**Goal:** change look once, everything follows. Owners can edit branding live in Settings → Branding.

Layers:
1. **`ThemeData` component themes** built by `buildTheme(TenantConfig, Brightness)` in `core/theme/`: `inputDecorationTheme` (outlined/filled), `filledButtonTheme`, `outlinedButtonTheme`, `cardTheme`, `appBarTheme`, `chipTheme`, `dialogTheme`, `bottomSheetTheme`, `navigationBarTheme`, `snackBarTheme`.
2. **`ThemeExtension<AppTokens>`** for non-Material tokens: spacing scale, radii, success/warning/info colors, shadows, gradients, status colors (active/expiring/expired).
3. **Wrapper widgets in `core/widgets/`:** `AppTextField`, `AppPasswordField`, `AppButton`, `AppCard`, `AppSectionHeader`, `AppStatusChip`, `AppEmptyState`, `AppLoader`. They hold **behavior only** (e.g. password show/hide), never styling.

Theme inputs from config: seed color, font, corner radius, input style, density (compact/comfortable), dark/light default.

**Hard rules (enforce with a grep check in CI):**
- No `Color(0x…)`, `Colors.<name>`, inline `TextStyle(`, or `BorderRadius.circular(` inside `lib/features/`.
- Features use `App*` widgets, `Theme.of(context)`, and `context.tokens` only.
- New visual need → add it to the theme/tokens first, then use it.

---

## 🧩 Product Scope by Role

**Owner / Staff**
- Fee collection & expiry tracking (expiring this week, overdue, one-tap renew); automatic reminders (push; WhatsApp/SMS later)
- Plans, freeze/extend, joining fee, coupons, trial passes
- Payments: cash/UPI/card manual entry + online; partial payments & dues; receipts/invoices (PDF)
- Attendance: QR/manual check-in; "inactive N days" alerts
- Dashboard: revenue, active vs expired, new joins, peak hours
- Roles: owner, manager, receptionist, trainer
- Leads/enquiries with follow-up reminders; expenses; announcements; CSV export
- Later: multi-branch, lockers/inventory, turnstile/biometric, store

**Member**
- Membership status/days left, renew & pay, invoices
- QR check-in + attendance streak
- Class timetable & booking
- Trainer-assigned workout plan, workout logging (sets/reps/weight), history
- Body measurements, progress photos
- Steps (Health Connect / HealthKit via `health` package → daily total stored), streaks, goals
- Diet plan, trainer chat, notifications, freeze request, referrals

---

## 🗺️ Phases

| Phase | Scope |
|-------|-------|
| **v1 (sellable)** | Auth + roles, members, plans & memberships, payments, QR attendance, expiry reminders, owner dashboard, branding/theme settings |
| **v1.5** | Classes & booking, workouts + trainer assignment, steps |
| **v2** | Diet, chat, leads, multi-branch, hardware access, store |

Build v1 as thin vertical slices. Do not start v1.5 features until v1 is stable and has been demoed.

---

## 🗄️ Data Model (PocketBase collections, draft)

`users` (role) · `app_config` · `members` · `plans` · `memberships` · `payments` · `attendance` · `classes` · `class_bookings` · `workouts` · `workout_logs` · `steps_daily` · `measurements` · `announcements` · `leads` · `expenses`

- Access control via API rules per collection (member: own records; staff/owner: all; trainer: assigned members).
- Every rule reviewed before release. Payment secrets and webhooks live in `pb_hooks` only.
- Cron hooks: expiry reminders, dues reminders, inactive-member alerts.

---

## 📐 Key Architecture Rules

- **State:** Riverpod only. Notifiers wrap repositories; UI never calls PocketBase directly.
- **Config over code:** a new client needs zero Dart changes. Add a config option or feature flag instead.
- **Material 3 only**, driven by the theme system above.
- **Compact & fast:** paginated lists, cached images, minimal dependencies (justify each), <10 MB Android release per ABI, first paint <2 s on a mid-range phone.
- **Offline tolerant:** cache reads; queue writes that matter (check-ins) and sync later.
- **Platform agnostic:** no `dart:io`-only code without a web fallback.
- **Security:** no admin credentials or payment secrets in the client.

---

## 📦 Dependencies (add a row per package with the reason)

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management |
| `go_router` | Routing, deep links, web URLs |
| `pocketbase` | Official Dart SDK |
| `cached_network_image` | Image caching |
| `mobile_scanner` / `qr_flutter` | QR check-in |
| `fl_chart` | Progress & revenue charts |
| `health` | Steps from Health Connect / HealthKit |
| cache (shared_preferences / Hive / Isar: decide) | Local config & data cache |
| Payment SDK (Razorpay / Stripe: decide) | Membership payments |

---

## ✅ Working Features

- [x] Agent memory created
- [x] Repo scaffold (feature-first, Riverpod, go_router, lints, theme grep check)
- [ ] PocketBase schema + migrations + API rules (v1 collections)
- [ ] Tenant config loader + `buildTheme` + `AppTokens` + `App*` widgets
- [ ] Settings → Branding with live preview
- [ ] Auth + roles
- [ ] Members & memberships
- [ ] Payments + receipts
- [ ] QR attendance
- [ ] Expiry/dues reminders (hooks)
- [ ] Owner dashboard
- [ ] Provisioning script (new client in <10 min)
- [ ] CI flavor matrix
- [ ] Backup + update scripts for the fleet

---

## 🚀 Ops Playbook (fill in as built)

- **Provision:** `ops/provision.sh <slug>` → container + data dir, apply migrations, create owner, seed `app_config`, add Caddy route.
- **Update fleet:** `ops/update_all.sh` → one tenant at a time, health-check, rollback on failure.
- **Backup:** nightly per-tenant `pb_data` snapshot off-box; test restores monthly.
- **Handover (template sale):** export `pb_data` + build artifacts + docs.

---

## 📌 Conventions

1. Riverpod providers, not `StatefulWidget`, beyond local animation state.
2. One feature = one folder with `domain/`, `data/`, `presentation/`.
3. Commits: `feat(scope): …`, `fix(scope): …`, `chore: …`.
4. Never commit secrets; tenant secrets live in per-tenant `.env` outside git.
5. After every task: update this file.

---

## 🐞 Known Issues / Open Questions

- Payment gateway (Razorpay vs Stripe vs both).
- Local cache package: using `shared_preferences` for now; revisit if we need structured caching.
- Push notifications: FCM per tenant vs shared sender.
- App store strategy: per-client listings vs one multi-tenant app.
- WhatsApp/SMS reminder provider and cost model.

---

## 🧾 Decision Log

| Date | Decision | Reason |
|------|----------|--------|
| — | PocketBase instance per tenant | Isolation, handover, simple ops |
| — | Runtime tenant config + flavors for native identity | No code changes per client |
| — | Global theme via ThemeData component themes + ThemeExtension + App* widgets | Change style once, everything follows |
| — | Ship v1 scope first, feature-flag the rest | Faster to a sellable product |
| 2026-10-02 | Flutter 3.47.2, PB 0.40.4, pocketbase SDK 0.25.2, flutter_riverpod 3.4.3, go_router 18.0.2 | Latest stable versions at project start |
| 2026-10-02 | shared_preferences for AsyncAuthStore + config cache | Lightest option, officially recommended by PB Dart SDK |

---

## 🔗 Reference

- Format reference: [Abyss Chat](https://github.com/North-Abyss/abyss_chat)
