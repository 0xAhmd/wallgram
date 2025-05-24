# Wallgram - A Text-Based Social Media App

![wall](https://github.com/user-attachments/assets/61fca610-0eaa-49c5-902a-e1b0329a6d1d)
<!-- Replace with your actual logo -->

Wallgram is a minimalist, text-based social media application built with Flutter and Firebase. It focuses on meaningful connections through shared thoughts and ideas.

## Features

### Authentication
- **Email & Password** login/signup
- **Google OAuth** integration
- Secure authentication flow

### User Profiles
- Customizable user profiles
- Bio section for personal information
- Follow/unfollow functionality

### Content
- Create, view, and delete text posts
- Like and comment on posts
- Two feed views:
  - **For You** - Algorithmic recommendations
  - **Following** - Posts from users you follow

### Moderation & Safety
- Report inappropriate content
- Block unwanted users
- Account deletion option

### Personalization
- Multiple app themes
- User preferences

## Getting Started

### Prerequisites
- Flutter SDK
- Firebase project setup
- Google OAuth credentials

### Installation
1. Clone the repository
   ```bash
   git clone https://github.com/0xAhmd/wallgram.git
   ```
2. Install dependencies
   ```bash
   flutter pub get
   ```
3. Set up Firebase:
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) files
   - Enable Email/Password and Google authentication in Firebase Console
4. Run the app
   ```bash
   flutter run
   ```

## Firebase Configuration
Wallgram uses the following Firebase services:
- Authentication (Email/Password, Google)
- Firestore (User data, posts, interactions)
- Storage (Future profile picture support)

## Next Steps (Planned Features)
1. UI/UX improvements
2. Additional OAuth providers (GitHub)


