# LifeVault AI v5.2.4 — Production Release (Android APK)

> **Tag:** `v5.2.4`  
> **Release Target:** `main`  
> **Package:** `com.theoriongd.lifevault` (LifeVault AI)  
> **Build:** `5.2.4+1`  
> **Asset:** `LifeVault-v5.2.4-release.apk` / `lifevault-release.apk` (88.6 MB)

---

## 🌟 Overview

We are proud to present **LifeVault AI v5.2.4**, featuring enhanced cross-platform audio recording, emergency medical dispatch with GPS coordinates, local background notifications, and biometric zero-knowledge authentication.

**LifeVault AI** is a zero-knowledge, privacy-first personal document intelligence vault and multimodal security system built with Flutter and Dart. It combines client-side cryptographic storage with multimodal artificial intelligence (**Google Gemini 3.7 Flash** and **Hugging Face Whisper**) to provide automated document OCR, conversational retrieval (RAG), expense and warranty tracking, encrypted voice notes, and instant emergency medical access.

---

## 📦 Binary Assets & Checksums

| File | Type | Size | SHA-256 Checksum |
| :--- | :--- | :--- | :--- |
| **`LifeVault-v5.2.4-release.apk`** | Android Standalone Release APK | `~88.6 MB` (`92,895,435 bytes`) | `D1AC95243EE3F5C388C179987A1C457CA40D2F9B09CDC73DFD77EAD2FF3E46B4` |
| **`lifevault-release.apk`** | Android Standalone Release APK | `~88.6 MB` (`92,895,435 bytes`) | `D1AC95243EE3F5C388C179987A1C457CA40D2F9B09CDC73DFD77EAD2FF3E46B4` |

### Checksum Verification

**Windows (PowerShell):**
```powershell
Get-FileHash -Path ".\LifeVault-v5.2.4-release.apk" -Algorithm SHA256
# Expected: D1AC95243EE3F5C388C179987A1C457CA40D2F9B09CDC73DFD77EAD2FF3E46B4
```

**Linux / macOS:**
```bash
sha256sum LifeVault-v5.2.4-release.apk
# Expected: cd3dfd8e8cf0765523c6c5da412a352c135e1f96053daad7f7ce623b1fb8992b  LifeVault-v5.2.4-release.apk
```

---

## 🚀 Key Highlights & New Features in v5.2.4

### 🔔 1. Local App & System Notifications
- **Background Scheduled Notifications**: Native alerts for document expiry, warranty renewals, and daily reminders via `flutter_local_notifications`.
- **Cross-Platform Desugaring Support**: Enhanced Java 17 Core Library Desugaring for high reliability across all Android API versions.
- **Web & Desktop Fallback**: Web Notification API helper with instant permission management.

### 🆘 2. Real-Time Emergency SOS & Location Dispatch
- **Live GPS Coordination**: Instant location discovery and SOS payload assembly for medical first responders.
- **Paramedic Emergency Card**: Quick-access ICE (In Case of Emergency) medical profile with offline card viewing and contact dialer.

### 🎙️ 3. Encrypted Voice Notes & Whisper AI Transcription
- **Cross-Platform Audio Recording**: High-fidelity microphone capture with WAV conversion and streaming playback.
- **Whisper AI Integration**: Local / cloud speech-to-text with interactive audio player and waveform visualization.

### 🛡️ 4. Biometric & Master Auth Gate
- **Tri-Mode Biometric Verification**: Windows Hello, Android Biometrics (Fingerprint/Face), and Master PIN.
- **Zero-Knowledge Security**: AES-256-GCM client-side encryption for local documents and metadata.

---

## 🔒 Privacy & Cryptographic Integrity

- **Zero-Knowledge Architecture**: Encryption and decryption keys never leave the local device.
- **AES-256-GCM / PBKDF2**: Client-side cryptography with SHA-256 integrity verification.
- **Anti-Brute Force Protection**: Exponential lockout timers on repeated PIN failure attempts.
