# LifeVault AI v2.1.4 — Production Release (Android APK)

> **Tag:** `v2.1.4`  
> **Release Target:** `main`  
> **Package:** `com.theoriongd.lifevault` (LifeVault AI)  
> **Build:** `2.1.4+1`  
> **Asset:** `lifevault-release.apk` / `LifeVault-v2.1.4-release.apk` (85.9 MB)

---

## 🌟 Overview

We are thrilled to announce the official **v2.1.4 production release of LifeVault AI**! 

**LifeVault AI** is a zero-knowledge, privacy-first personal document intelligence vault and multimodal security system. Built with Flutter and Dart, it combines client-side cryptographic storage with multimodal artificial intelligence (**Google Gemini 3.7 Flash** and **Hugging Face Whisper**) to provide automated document OCR, conversational retrieval (RAG), expense and warranty tracking, encrypted voice notes, and instant emergency medical access.

---

## 📦 Binary Assets & Checksums

Download the standalone production APK below:

| File | Type | Size | SHA-256 Checksum |
| :--- | :--- | :--- | :--- |
| **`lifevault-release.apk`** | Android Standalone APK (arm64-v8a, armeabi-v7a, x86_64) | `~85.9 MB` (`90,094,382 bytes`) | `334A0A895A0B8A40FF40DE212517F8BAF90E2EA05654A2F8754B36A0D979A8B0` |
| **`LifeVault-v2.1.4-release.apk`** | Android Standalone APK (arm64-v8a, armeabi-v7a, x86_64) | `~85.9 MB` (`90,094,382 bytes`) | `334A0A895A0B8A40FF40DE212517F8BAF90E2EA05654A2F8754B36A0D979A8B0` |

### Checksum Verification

To verify the integrity of the downloaded APK file on your machine:

**Windows (PowerShell):**
```powershell
Get-FileHash -Path ".\LifeVault-v2.1.4-release.apk" -Algorithm SHA256
# Expected: 334A0A895A0B8A40FF40DE212517F8BAF90E2EA05654A2F8754B36A0D979A8B0
```

**Linux / macOS:**
```bash
sha256sum LifeVault-v2.1.4-release.apk
# Expected: 334a0a895a0b8a40ff40de212517f8baf90e2ea05654a2f8754b36a0d979a8b0  LifeVault-v2.1.4-release.apk
```

---

## 🚀 What's New in v2.1.4

### 🛡️ 1. Cyber-Security Animated Splash Screen
- **Multi-Ring Glowing Orbit**: 3D rotating shield brand emblem surrounded by expanding radial glow and particle fields.
- **Dynamic Security Status Ticker**: Real-time loading milestones (*"Initializing Secure Enclave..."*, *"Arming AES-256 Zero-Knowledge..."*, *"Loading Neural AI & OCR Models..."*, *"Biometric Enclave Ready"*).
- **Sleek Linear Progress Indicator & v2.1.4 Badge**: Fluid startup with tap-to-skip fast track.

### 🌟 2. 14-Slide Interactive Onboarding Experience (`OnboardingScreen`)
- **14 Comprehensive Feature Walkthrough Slides**:
  1. **Next-Gen AI Privacy Vault** (Zero-knowledge architecture & offline-first overview)
  2. **Zero-Knowledge AES-256 Storage** (PBKDF2 key derivation & encrypted cipher visualizer)
  3. **AI Scanner & Automatic OCR** (Real-time laser detection & smart categorization)
  4. **Gemini 3.7 & Local AI Intelligence** (Conversational Q&A & document summarizer)
  5. **Smart Expiry & Renewal Alerts** (Urgency tiers & days-remaining countdowns)
  6. **Itemized Receipt Tracker** (Expense statistics, multi-currency converter & warranty monitors)
  7. **Encrypted Voice Notes & Whisper STT** (Interactive audio waveform & Whisper AI transcription)
  8. **One-Tap ICE Emergency Medical Card** (Offline paramedic pass & SOS dialer)
  9. **Dynamic Multi-Accent & Fluid Themes** (Interactive palette swatches & liquid gradients)
  10. **Real-Time Security Health Audit** (Radial 92% health gauge & risk evaluation)
  11. **Vault Guardian XP & Milestones** (Guardian tier progression, XP rewards & privacy streaks)
  12. **Designated Trustee & Legacy Shield** (Dead-man switch rules & automated emergency transfer)
  13. **End-to-End Encrypted Cloud Sync** (Custom MongoDB cluster URI & encrypted JSON import/export)
  14. **Biometric Gate & Master PIN Access** (Tri-mode Face ID, Fingerprint & 6-digit PIN defense)
- **Interactive Capabilities**: Live interactive preview mini-widgets on every slide, slide dots indicator, step counter badge (`1 / 14`), Next/Back/Skip navigation controls, and 50 XP milestone award upon completion.

### 🏦 3. Integrated Landing & Authentication Flow
- **Seamless Startup Routing**: Splash $\rightarrow$ Onboarding (first run) $\rightarrow$ Landing/Login $\rightarrow$ Dashboard.
- **App Tour Re-entry Button**: Prominent quick-tour button in header and Profile Settings to relaunch the 14-slide tour anytime.
- **Biometric & MPIN Viewfinder**: Modern Neo-Bank inspired luxury authentication with immediate feedback.

---

## 🔒 Security & Privacy Guarantees

- **Zero-Knowledge Architecture**: Encryption and decryption keys remain strictly on the client device.
- **AES-256-GCM / PBKDF2**: Client-side cryptography with SHA-256 integrity verification.
- **Anti-Brute Force Protection**: Exponential lockout timers on repeated PIN failure attempts.
