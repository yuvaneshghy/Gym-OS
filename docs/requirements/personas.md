# GymKit Requirements & Persona Breakdown

This document outlines the core requirements for a modern gym management application, separated by the primary user personas: **Customer (Member)**, **Groups (Staff/Trainers)**, and **Admin (Owner/Client)**. It covers requirements across both Web and Mobile App platforms.

## 1. Admin (Owner/Client)
The Admin needs full visibility and control over the gym's operations, finances, and member base. The Admin primarily uses the **Web Dashboard** for complex tasks but needs the **Mobile App** for on-the-go monitoring.

### Core Needs (Web & App)
- **Financial Dashboard:** Real-time revenue tracking, pending dues, and payment history.
- **Member Management:** View all members, their membership status, attendance, and contact information.
- **Plan & Pricing Control:** Create, edit, and disable membership plans, trial passes, and drop-in rates.
- **Access Control:** Assign roles (Manager, Receptionist, Trainer) and manage staff permissions.
- **Analytics & Reporting:** 
  - Active vs. Expired members.
  - Peak gym hours and attendance trends.
  - New joins vs. cancellations (Churn rate).
- **Communication:** Broadcast announcements to all members or specific groups via push notifications/emails.
- **Lead Management:** Track enquiries, assign follow-ups, and convert leads to members.
- **Tenant Configuration (White-label):** Configure app branding (colors, logos) and toggle feature flags (e.g., enable classes, workouts) from the settings.

## 2. Groups (Staff / Trainers / Receptionists)
Staff members need tools to perform their daily duties efficiently without having access to sensitive financial data (unless permitted).

### Core Needs (Web & App)
- **Receptionist (Front Desk):**
  - Fast QR / manual check-in for members.
  - Immediate alert on member check-in if dues are pending or membership is expired.
  - Process cash/card payments and generate invoices/receipts.
  - Register new walk-in members.
- **Trainer:**
  - View assigned members and their goals/measurements.
  - Create and assign workout plans (sets, reps, weights).
  - Track member progress (workout logs, progress photos).
  - View class schedules and manage attendees for classes they lead.
  - In-app chat with assigned members (Phase 2).
- **Manager:**
  - Handle day-to-day operations, expenses, and staff shifts.
  - Override system locks (e.g., allow entry for a member who forgot their wallet).

## 3. Customer (Member)
The Customer needs a frictionless experience to access the gym, track their progress, and manage their subscription. They primarily use the **Mobile App**, with a **Web Portal** fallback.

### Core Needs (Mobile App)
- **Digital Access:** Quick QR code generation for turnstile/desk check-in.
- **Membership Management:** 
  - View current plan details and days remaining.
  - Receive automated expiry/dues reminders.
  - In-app renewals and payment processing (Card/UPI).
  - Request membership freezes/extensions.
- **Fitness Tracking & Plans:**
  - View workout plans assigned by their trainer.
  - Log daily workouts and track progress over time.
  - Step tracking integration (Apple Health / Google Health Connect).
  - Log body measurements and progress photos.
- **Classes & Bookings (Phase 1.5):** View the gym timetable and book slots for group classes (Yoga, Zumba, HIIT).
- **Engagement:** 
  - Attendance streak tracking and gamification.
  - View gym announcements and offers.

---

## Technical Summary
- **Data Isolation:** Each gym (client) gets its own isolated backend (PocketBase instance) ensuring data privacy and customizability.
- **Cross-Platform:** Built with Flutter, ensuring the UI is consistent and maintainable across Android, iOS, and Web.
- **Role-Based Access Control (RBAC):** PocketBase API rules ensure that Members, Staff, and Admins can only access data permitted for their specific role.
