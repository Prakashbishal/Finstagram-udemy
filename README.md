# 📸 Finstagram

Finstagram is a minimal social photo-sharing app built with **Flutter**, **Firebase**, and **Cloudinary**. Users can register with a profile picture, log in, upload photo posts with captions, and view their feed and profile.

---

## 🚀 Features

- 📥 User Registration with profile picture (uploaded to Cloudinary)
- 🔐 Firebase Authentication
- 🖼️ Upload photos with captions
- 📰 Feed showing posts from all users
- 👤 Profile page with user info and their own posts
- ☁️ Cloudinary integration for image uploads
- ☁️ Firebase Firestore for storing user and post data

---

## 🛠️ Tech Stack

- **Flutter** (UI Framework)
- **Firebase Authentication** (Login/Register)
- **Firebase Firestore** (Database)
- **Cloudinary** (Image hosting)
- **GetIt** (Service Locator)
- **Image Picker** (Select images from gallery)

---

## 🔐 Firebase Setup

1. Create a Firebase project.
2. Enable **Email/Password** Authentication.
3. Create two Firestore collections:
   - `users`: Store user details
   - `posts`: Store uploaded post data
4. Add Firebase config files to your Flutter project.

---

## ☁️ Cloudinary Setup

1. Create a Cloudinary account.
2. Create an **unsigned upload preset**.
3. Replace `cloud_name` and `upload_preset` in `cloudinary_service.dart`.

---

## 📦 Dependencies

Add these to your `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^latest
  firebase_auth: ^latest
  cloud_firestore: ^latest
  image_picker: ^latest
  cloudinary_public: ^latest
  get_it: ^latest
  intl: ^latest
