# LifeVault AI v1.1.0 — Production Release (Android APK)

> **Tag:** `v1.1.0`  
> **Release Target:** `main`  
> **Package:** `com.theoriongd.lifevault` (LifeVault AI)  
> **Build:** `1.1.0+2`  
> **Asset:** `lifevault-release.apk` / `LifeVault-v1.1.0-release.apk` (85.7 MB)

---

## 🌟 Overview

We are thrilled to announce the official **v1.1.0 production release of LifeVault AI**! 

**LifeVault AI** is a zero-knowledge, privacy-first personal document intelligence vault and multimodal security system. Built with Flutter and Dart, it combines client-side cryptographic storage with multimodal artificial intelligence (**Google Gemini 3.7 Flash** and **Hugging Face Whisper**) to provide automated document OCR, conversational retrieval (RAG), expense and warranty tracking, encrypted voice notes, and instant emergency medical access.

---

## 📦 Binary Assets & Checksums

Download the standalone production APK below:

| File | Type | Size | SHA-256 Checksum |
| :--- | :--- | :--- | :--- |
| **`lifevault-release.apk`** | Android Standalone APK (arm64-v8a, armeabi-v7a, x86_64) | `~85.8 MB` (`89,961,248 bytes`) | `e05a571f774b9d273151b6192acbaf1317b1b4778c9f15ff7fc37fe6ef48c8fa` |
| **`LifeVault-v1.1.0-release.apk`** | Android Standalone APK (arm64-v8a, armeabi-v7a, x86_64) | `~85.8 MB` (`89,961,248 bytes`) | `e05a571f774b9d273151b6192acbaf1317b1b4778c9f15ff7fc37fe6ef48c8fa` |

### Checksum Verification

To verify the integrity of the downloaded APK file on your machine:

**Windows (PowerShell):**
```powershell
Get-FileHash -Path ".\lifevault-release.apk" -Algorithm SHA256
# Expected: E05A571F774B9D273151B6192ACBAF1317B1B4778C9F15FF7FC37FE6EF48C8FA
```

**Linux / macOS:**
```bash
sha256sum lifevault-release.apk
# Expected: e05a571f774b9d273151b6192acbaf1317b1b4778c9f15ff7fc37fe6ef48c8fa  lifevault-release.apk
```

---

## 🚀 What's New in v1.1.0

### 📎 1. Raw Media Retention & In-App Preview / Download / Share
- **Original Document & Receipt Archiving**: Preserves raw captured photos, scans, and PDFs alongside extracted OCR text.
- **In-App Fullscreen Preview Modal**: Features pinch-to-zoom, panning (`InteractiveViewer`), 90° rotation, and raw OCR text inspection.
- **Cross-Platform Download & Share**: Download original files directly to local storage or share via system share sheets.

### 🎙️ 2. Encrypted Audio Voice Memos & Separation
- **Dedicated Audio Player**: Interactive in-app audio player with dynamic waveform animation, Play/Pause control, progress scrubber, and elapsed/total duration counters.
- **Clean Audio vs. Transcript Separation**: Clear visual distinction between original audio recordings and editable AI speech-to-text transcripts.

### 💱 3. Multi-Currency Engine & Synchronous Dashboard Sync
- **7 International Currencies**: Full support for USD ($), EUR (€), GBP (£), INR (₹), JPY (¥), CAD (C$), and AUD (A$) with real-time conversion.
- **Instant Dashboard Update**: Changing preferred currency in profile settings immediately updates the Dashboard, Quick Companion Cards, Analytics, and itemized receipts without reload delays.

### 📱 4. Responsive Mobile Resolution & Overflow Elimination
- Fixed text, button, chip, and tag clipping on compact mobile screens across date pickers, STT engine selectors, and category filter chips.

### 🛡️ 5. Centered Biometric Authentication UI
- Balanced padding and symmetrical alignment for biometric radar scanning sensors on mobile viewports.

### 🚪 6. "Exit App" Session Controls
- Added dedicated **"Exit App"** action alongside **"Log Out & Lock Vault"** in both the top-right profile popover and profile settings.

---

## 📱 Installation Instructions (Android)

1. **Download `lifevault-release.apk`** from the project root.
2. If installing directly on your Android device:
   - Open the downloaded file.
   - If prompted, permit your browser/file manager to **"Install unknown apps"** in Android Settings.
   - Tap **Install** and launch **LifeVault AI**.
3. **Initial Setup**:
   - Create your 4–6 digit Master PIN.
   - Save your **16-Character Master Recovery Key**.
   - Enable Biometrics (Fingerprint / Face Unlock) for instantaneous unlocking.
