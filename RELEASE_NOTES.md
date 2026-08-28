# LifeVault AI v5.2.4 — Production Release (Android APK)

> **Tag:** `v5.2.4`  
> **Release Target:** `main`  
> **Package:** `com.theoriongd.lifevault` (LifeVault AI)  
> **Build:** `5.2.4+1`  
> **Asset:** `LifeVault-v5.2.4-release.apk` / `lifevault-release.apk` (88.7 MB)

---

## 🌟 Overview

We are proud to present **LifeVault AI v5.2.4**, featuring enhanced cross-platform audio recording, emergency medical dispatch with GPS coordinates, local background notifications, dedicated Cyber Face ID biometric scanning, instant Amazon-style auto-lock on app switching, and biometric zero-knowledge authentication.

**LifeVault AI** is a zero-knowledge, privacy-first personal document intelligence vault and multimodal security system built with Flutter and Dart. It combines client-side cryptographic storage with multimodal artificial intelligence (**Google Gemini 3.7 Flash** and **Hugging Face Whisper**) to provide automated document OCR, conversational retrieval (RAG), expense and warranty tracking, encrypted voice notes, and instant emergency medical access.

---

## 📦 Binary Assets & Checksums

| File | Type | Size | SHA-256 Checksum |
| :--- | :--- | :--- | :--- |
| **`LifeVault-v5.2.4-release.apk`** | Android Standalone Release APK | `~88.7 MB` (`92,990,199 bytes`) | `58AD3C07ED587629691B0112FA3DCA6FDE54582514F277AF54F4B2AA25F4DF3A` |
| **`lifevault-release.apk`** | Android Standalone Release APK | `~88.7 MB` (`92,990,199 bytes`) | `58AD3C07ED587629691B0112FA3DCA6FDE54582514F277AF54F4B2AA25F4DF3A` |

### Checksum Verification

**Windows (PowerShell):**
```powershell
Get-FileHash -Path ".\LifeVault-v5.2.4-release.apk" -Algorithm SHA256
# Expected: 58AD3C07ED587629691B0112FA3DCA6FDE54582514F277AF54F4B2AA25F4DF3A
```

**Linux / macOS:**
```bash
sha256sum LifeVault-v5.2.4-release.apk
# Expected: 58ad3c07ed587629691b0112fa3dca6fde54582514f277af54f4b2aa25f4df3a  LifeVault-v5.2.4-release.apk
```

---

## 🚀 Key Fixes & New Features in v5.2.4

### 👤 1. Dedicated Cyber Face ID Recognition Scanner
- **Immersive Face ID Scanner Viewfinder**: Animated 3D-styled face mesh wireframe, rotating radar rings, and animated laser sweep.
- **Android Front-Camera Face Unlock**: Relaxed biometric restrictions so Android's front camera face recognition triggers seamlessly with custom `AndroidAuthMessages`.
- **Instant Fallback**: Quick access to Fingerprint and 4-digit Master PIN at any time.

### 🔒 2. Amazon Mobile App Style Instant Auto-Lock
- **Background Auto-Lock**: Automatically locks the vault the exact moment you leave or switch to another app.
- **Seamless Biometric Resume**: Returning to LifeVault immediately presents the Face ID / Biometrics prompt without requiring extra button taps.
- **Fixed Landing Page Navigation**: Guaranteed navigation into dashboard upon successful biometric or PIN login.

### ⚡ 3. Android Installation & Startup Optimization
- **Zero Package Parse Errors**: Clean build with `compileSdk = 37`, `targetSdk = 34`, and `minSdk = 24` for 100% installation compatibility.
- **Instant Startup**: Asynchronous notification loading and animation completion listeners so the splash screen and app launch instantaneously without hanging.
