# 🎬 Akislar — Turkish Series Streaming Platform

<div align="center">

**Watch your favorite Turkish series — anytime, anywhere.**

*Kurulus: Osman • Dirilis: Ertugrul • Magnificent Century • and more*

![iOS 16+](https://img.shields.io/badge/iOS-16%2B-blue?logo=apple)
![macOS 13+](https://img.shields.io/badge/macOS-13%2B-blue?logo=apple)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5.9-orange?logo=swift)
![License](https://img.shields.io/badge/License-MIT-green)

</div>

---

## ✨ Features

- 🎭 **8+ Turkish Series** — Kurulus Osman, Dirilis Ertugrul, Magnificent Century, Payitaht Abdulhamid, and more
- 🌍 **Multi-Language Streaming** — Watch in Turkish, English, Arabic, Urdu, French, German, Spanish, Indonesian
- 🌐 **App Language** — Full UI localization in 7 languages
- 🎨 **Custom App Icons** — Choose from Default, Dark, Gold, or Ottoman themes
- 🔐 **Authentication** — Sign in with Google or Email
- 📱 **AltStore Ready** — Unsigned IPA built via GitHub Actions
- 🎬 **Custom Video Player** — Full-screen player with language switching, seek, PiP
- 🌙 **Dark Mode** — Premium dark theme with gold accents

## 🚀 Getting Started

### Prerequisites
- A GitHub account (for building via Actions)
- [AltStore](https://altstore.io) installed on your iPhone

### Build & Install

1. **Fork this repo** on GitHub
2. **Push to `main`** — GitHub Actions will automatically build the IPA
3. **Download the IPA** from the Actions tab → Artifacts
4. **Sideload with AltStore** onto your iPhone

### Manual Build (if you have Xcode)

```bash
# Install XcodeGen
brew install xcodegen

# Generate Xcode project
xcodegen generate

# Open in Xcode
open Akislar.xcodeproj
```

## 🏗 Project Structure

```
Akislar/
├── App/                    # App entry & navigation
├── Models/                 # Data models
├── Services/               # Auth, Catalog, Settings
├── ViewModels/             # MVVM view models
├── Views/
│   ├── Home/               # Home screen with hero carousel
│   ├── Browse/             # Series catalog & detail
│   ├── Player/             # Video player
│   ├── Settings/           # Settings, Login, Language & Icon picker
│   └── Components/         # Reusable UI components
├── Assets.xcassets/        # Colors, icons, images
└── Info.plist              # App configuration
```

## 📋 Configuration

### Google Sign-In
1. Create a project in [Google Cloud Console](https://console.cloud.google.com)
2. Enable Google Sign-In API
3. Create OAuth credentials
4. Replace `YOUR_CLIENT_ID` in `Info.plist`

### Adding Content
Replace the placeholder stream URLs in `CatalogService.swift` with your licensed HLS (.m3u8) stream URLs.

## 📄 License
MIT License — see [LICENSE](LICENSE) for details.

---

<div align="center">
Made with ❤️ for Turkish drama fans worldwide
</div>
