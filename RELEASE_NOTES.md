# LifeVault AI v1.0.0 — Production Release (Android APK)

> **Tag:** `v1.0.0`  
> **Release Target:** `main`  
> **Package:** `com.theoriongd.lifevault` (LifeVault AI)  
> **Build:** `1.0.0+1`  
> **Asset:** `app-release.apk` (54.9 MB)

---

## 🌟 Overview

We are thrilled to announce the official **v1.0.0 production release of LifeVault AI**! 

**LifeVault AI** is a zero-knowledge, privacy-first personal document intelligence vault and multimodal security system. Built with Flutter and Dart, it combines client-side cryptographic storage with multimodal artificial intelligence (**Google Gemini 3.7 Flash** and **Hugging Face Whisper**) to provide automated document OCR, conversational retrieval (RAG), expense and warranty tracking, encrypted voice notes, and instant emergency medical access.

---

## 📦 Binary Assets & Checksums

Download the standalone production APK below:

| File | Type | Size | SHA-256 Checksum |
| :--- | :--- | :--- | :--- |
| **`app-release.apk`** | Android Standalone APK (arm64-v8a, armeabi-v7a, x86_64) | `~54.9 MB` (`57,567,806 bytes`) | `a758f9848ff73f10fa839e84f46b3a7d8695170251feb1a961c1999855d1d173` |

### Checksum Verification

To verify the integrity of the downloaded APK file on your machine:

**Windows (PowerShell):**
```powershell
Get-FileHash -Path ".\app-release.apk" -Algorithm SHA256
# Expected: A758F9848FF73F10FA839E84F46B3A7D8695170251FEB1A961C1999855D1D173
```

**Linux / macOS:**
```bash
sha256sum app-release.apk
# Expected: a758f9848ff73f10fa839e84f46b3a7d8695170251feb1a961c1999855d1d173  app-release.apk
```

---

## 🚀 Key Features & Highlights

### 🛡️ Zero-Knowledge Security & Biometric Gatekeeper
- **Hardware Biometrics**: Instant fingerprint and Face ID authentication backed by `androidx.biometric.BiometricPrompt`.
- **Cryptographic Master PIN**: Salted SHA-256 password/PIN hashing with strict client-side verification.
- **Anti-Brute-Force Lockout**: 3 consecutive failed attempts trigger an automated 30-second exponential freeze.
- **Master Recovery Pipeline**: High-entropy 16-character Master Recovery Key (`LVLT-XXXX-XXXX-XXXX`) and salted security questions.

### 👁️ Multimodal Document Vision & Dual-Tier OCR
- **Google Gemini 3.7 Flash Integration**: Cloud vision model for zero-shot text recognition, structured entity parsing (document numbers, issue/expiry dates, issuers, amounts), and deep risk assessments.
- **On-Device Heuristic Fallback**: 100% offline regex parsing across 12 international date formats, currency symbols, and category classification keywords.
- **Laser Scanner FX**: High-fidelity animated scanning overlay with real-time feedback.

### 🤖 Conversational Intelligence Assistant (Local & Cloud RAG)
- **Zero-Knowledge RAG**: Natural language questioning over your personal documents, receipts, and voice notes.
- **Verifiable Citations**: Interactive `[Doc ID]` cards directly linking assistant replies to source documents.
- **Multi-Model Dynamic Failover**: Automatic cascading across `gemini-3.7-flash` → `gemini-3.6-flash` → `gemini-3.5-flash` → `gemini-flash-latest` → on-device heuristic engine.
- **Contextual Quick Chips**: Auto-suggested follow-up prompts for renewals, warranty checks, and spend breakdowns.

### 🧾 Smart Receipt Archivist & Financial Tracker
- **Itemized Purchase Breakdown**: Multi-line item tables capturing product descriptions, quantities, unit prices, and grand totals.
- **Tax & Expense Aggregation**: Automatic subtotal, tax calculation, and category expense charts.
- **Warranty Countdown Vigilance**: Computes active warranty coverage and synchronizes reminders.

### 🎙️ Encrypted Voice Memo Studio
- **Dynamic Waveform Visualizer**: Real-time multi-bar audio amplitude telemetry during recording.
- **Dual Speech-to-Text**: Speech transcription via Hugging Face Whisper Large v3 and Gemini Audio STT.
- **Searchable Transcripts**: Voice notes are fully indexed for instant search and RAG queries.

### 🚨 In Case of Emergency (ICE) First Responder Pass
- **Vital Medical Data**: Immediate access to blood group, organ donor status, chronic conditions, and severe allergies.
- **Emergency Dialers**: One-tap phone dialing for primary/secondary emergency contacts and personal physicians.
- **Lock-Screen Access**: Emergency medical card accessible without entering the master vault PIN.

### 🏆 Security Health Audit & Guardian Gamification
- **0–100% Security Posture Scoring**: Weighted evaluation across PIN protection, biometrics, expired records, ICE contacts, and cloud sync.
- **Guardian Level Progression**: Level up from *Novice Guardian* to *Fortress Grade Master* by earning XP through healthy vault habits.

### 🎨 Dynamic Styling & Multi-Accent Gradient Engine
- **10 Curated HSL Palettes**: Emerald, Sapphire, Amethyst, Amber, Crimson, Obsidian, Cyan, Rose, Indigo, and Lime.
- **Multi-Accent Gradient Customization**: Select up to 3 accent colors for personalized linear gradients.
- **Dark/Light Mode Optimization**: Contrast-tailored OLED dark theme and crisp light theme.

---

## 📱 Installation Instructions (Android)

1. **Download `app-release.apk`** from the Assets section below.
2. If installing directly on your Android device:
   - Open the downloaded file.
   - If prompted, permit your browser/file manager to **"Install unknown apps"** in Android Settings.
   - Tap **Install** and launch **LifeVault AI**.
3. **Initial Setup**:
   - Create your 4–6 digit Master PIN.
   - Save your **16-Character Master Recovery Key**.
   - Enable Biometrics (Fingerprint / Face Unlock) for instantaneous unlocking.
   - (Optional) Configure your Google Gemini API Key in Settings to activate cloud AI features.

---

## 📋 Changelog (v1.0.0)

### Added
- Complete Material 3 UI shell with custom glassmorphism and navigation transitions.
- `BiometricAuthService` with support for Class 3 BiometricPrompt and fallback gates.
- `SecurityService` with salted SHA-256 hashing and 30-second lockout timer.
- `GeminiAiService` featuring multimodal OCR, deep risk assessment, and RAG document interrogation.
- `OcrEngineService` with offline regex heuristic parsing.
- `SpeechRecognitionService` supporting Hugging Face Whisper and Gemini Audio.
- Receipt itemization with automatic warranty expiration tracking.
- Interactive ICE Emergency Pass with direct phone dialer intent hooks.
- Security Audit health meter and XP/Guardian Level achievement system.
- Multi-accent gradient theme customization with 10 curated colorways.
- MongoDB Atlas cloud backup synchronization service.
- Full test suite covering unit, widget, and state management layers.

---

## 🔒 Permissions Used

| Android Permission | Purpose |
| :--- | :--- |
| `android.permission.USE_BIOMETRIC` / `USE_FINGERPRINT` | Unlocking vault with fingerprint or Face Unlock |
| `android.permission.CAMERA` | Capturing photos of documents and receipts for OCR |
| `android.permission.RECORD_AUDIO` | Recording encrypted voice memos |
| `android.permission.INTERNET` | Optional cloud AI inference (Gemini / Whisper) and MongoDB sync |
| `android.permission.CALL_PHONE` | Direct dialing emergency contacts from the ICE pass |

---

## 🤝 Support & Feedback

If you encounter any issues or have feature requests:
- Open an issue on [GitHub Issues](https://github.com/TheOrionGD/LIfeVaultAI/issues).
- Review our [Diagnostic Runbook & FAQ](https://github.com/TheOrionGD/LIfeVaultAI#troubleshooting--diagnostic-runbook).

---

*LifeVault AI — Sovereign, Intelligent, Impenetrable.*
