# Campus Ventures Link

Campus Ventures Link is a Flutter and Firebase application built for the African Leadership University (ALU) ecosystem. The platform connects ALU students with verified startup opportunities by enabling startups to post internships and volunteer positions while allowing students to discover, apply for, and track opportunities in one centralized system.

---

## Demo Video

Demo Link: https://youtu.be/ii5KpxJh3bU 

---

# Problem Statement

Many ALU students struggle to find practical opportunities that match their skills and interests, while student-led startups often have difficulty reaching qualified talent. Existing solutions rely heavily on informal channels such as WhatsApp groups and word of mouth, making it difficult to track applications and verify opportunities.

Campus Ventures Link addresses this problem by providing:

- A centralized platform for startup opportunities.
- Startup verification to ensure legitimacy.
- Personalized opportunity discovery.
- Application tracking for students.
- Opportunity management tools for founders.
- Administrative oversight for the university.

---

# Features

## Authentication and Onboarding

- Email and password authentication using Firebase Authentication.
- Registration restricted to `@alustudent.com` email addresses.
- User registration and login.
- Multi-role support:
  - Student
  - Founder
  - Admin
- Profile setup:
  - Bio
  - Skills
  - Interests
  - Social links

---

## Student Features

- Personalized dashboard
- Search opportunities
- Browse opportunities by category
- Recommended opportunities
- Bookmark opportunities
- Apply with a cover letter
- Track application status
- View application history
- Edit profile
- Dark mode support

---

## Founder Features

- Create startup profile
- Update startup information
- Resubmit rejected startups
- View verification status
- Create opportunities
- Edit opportunities
- View applicants
- Update application statuses
- Dashboard with live statistics

---

## Admin Features

- Verify startups
- Approve or reject startup requests
- View platform statistics
- Manage user roles
- View all users
- Monitor startups and opportunities

---

# Startup Verification Workflow

```text
Founder
   ↓
Create Startup
   ↓
Pending Verification
   ↓
Admin Review
   ↓
Approved / Rejected
   ↓
Approved founders can create opportunities
```

This workflow ensures that only legitimate and verified startups can post opportunities on the platform.

---

# Application Workflow

```text
Student
   ↓
Apply
   ↓
Pending
   ↓
Interview
   ↓
Accepted / Rejected
```

---

# Technology Stack

| Technology | Purpose |
|------------|----------|
| Flutter | Frontend framework |
| Dart | Programming language |
| Firebase Authentication | User authentication |
| Cloud Firestore | Real-time database |
| Riverpod | State management |
| Go Router | Navigation |
| Shared Preferences | Theme persistence |

---

# Architecture

The application follows a Feature-First Layered Architecture.

```
Presentation Layer
       ↓
Riverpod Controllers
       ↓
Repositories
       ↓
Firebase Services
       ↓
Cloud Firestore
```

### Architectural Principles

- Separation of concerns
- Low coupling
- High cohesion
- Scalability
- Testability
- Maintainability

---

# Project Structure

```text
lib/
├── core/
│   ├── constants/
│   ├── router/
│   ├── theme/
│   └── utils/
│
├── features/
│   ├── auth/
│   ├── onboarding/
│   ├── startup/
│   ├── opportunity/
│   ├── application/
│   ├── bookmark/
│   ├── profile/
│   ├── providers/
│   └── splash/
│
└── shared/
    ├── models/
    └── widgets/
```

---

# Database Schema

The application uses five primary collections:

## users

```text
uid
name
email
role
bio
skills
interests
```

## startups

```text
id
ownerId
name
description
industry
verificationStatus
createdAt
```

## opportunities

```text
id
startupId
title
description
category
employmentType
requiredSkills
deadline
status
createdAt
```

## applications

```text
id
studentId
opportunityId
coverLetter
status
createdAt
```

## bookmarks

```text
id
studentId
opportunityId
createdAt
```

---

# State Management

The application uses Riverpod.

Provider types used:

- StreamProvider
- FutureProvider
- NotifierProvider
- Provider.family

Benefits:

- Real-time updates
- Dependency injection
- Clean architecture
- Improved testability
- Reduced boilerplate
- Better scalability

---

# Design System

The application includes a reusable component library.

Reusable widgets include:

- EmptyStateWidget
- OpportunityCard
- StatusBadge
- BookmarkToggleButton
- SectionHeader
- SearchBarWidget
- CategoryCard
- MetricCard
- ActionTile
- GradientHeader
- SectionCard
- InfoCard

---

# Theme Support

The application supports:

- Light Theme
- Dark Theme
- System Theme

Theme preferences are persisted using SharedPreferences.

---

# Security

The application includes:

- Firebase Authentication
- Firestore Security Rules
- Role-based routing
- Startup verification gate
- Permission-based UI rendering
- Admin-only operations

---

# Testing

Run static analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

The project currently includes:

- Widget testing
- Responsive layout testing
- Splash screen testing

---

# Installation

## Clone the repository

```bash
git clone https://github.com/AHIRWE1/Venturelink-app.git

cd Venturelink-app
cd campus_ventures_link
```

## Install dependencies

```bash
flutter pub get
```

## Configure Firebase

```bash
flutterfire configure
```

## Run the application

```bash
flutter run
```

---

# Firestore Rules

Deploy the included rules:

```bash
firebase deploy --only firestore:rules
```

or manually copy them into:

```text
Firebase Console
→ Firestore Database
→ Rules
```

---

# Known Limitations

- No push notifications
- No in-app messaging
- No CV upload
- No profile photo upload
- No pagination
- Limited automated testing
- Admin cannot disable user accounts without Firebase Admin SDK

---

# Future Improvements

- Push notifications
- Email notifications
- Profile photo upload
- CV upload
- In-app messaging
- Pagination
- Interview scheduling
- Analytics dashboard
- Advanced recommendation engine

---

# Challenges and Lessons Learned

## Challenges

- Managing role-based navigation.
- Handling Firestore composite indexes.
- Designing reusable widgets.
- Implementing startup verification.
- Maintaining real-time synchronization.

## Lessons Learned

- The importance of clean architecture.
- The benefits of Riverpod for state management.
- The need for extensive manual testing with Firebase.
- The value of reusable components and design systems.

---

# Author

Ange Gabriella Ahirwe

BSc (Hons) Software Engineering

African Leadership University

Course:
Mobile Application Development – Formative Assessment 2

---

# Acknowledgements

- Flutter Team
- Firebase Team
- Riverpod Community
- Go Router Package Maintainers
- African Leadership University

---

# License

This project was developed for educational purposes as part of the Mobile Application Development coursework at African Leadership University.