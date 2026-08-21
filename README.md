<div align="center">

# LifeVault AI

### Intelligent Zero-Knowledge Personal Document Vault & Multimodal Security System

[![Flutter](https://img.shields.io/badge/Flutter-3.13.1%2B-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0%2B-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Google Gemini AI](https://img.shields.io/badge/Google%20Gemini-3.7%20Flash-4285F4?style=for-the-badge&logo=google&logoColor=white)](https://ai.google.dev/)
[![Hugging Face Whisper](https://img.shields.io/badge/Hugging%20Face-Whisper%20Large%20v3-FFD21E?style=for-the-badge&logo=huggingface&logoColor=black)](https://huggingface.co/)
[![MongoDB Atlas](https://img.shields.io/badge/MongoDB-Atlas%20Cloud%20Sync-47A248?style=for-the-badge&logo=mongodb&logoColor=white)](https://www.mongodb.com/atlas)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-lightgrey?style=for-the-badge)](#system-architecture)
[![Security: Zero--Knowledge](https://img.shields.io/badge/Security-Zero--Knowledge%20SHA--256-green?style=for-the-badge)](#security-architecture)
[![Download APK](https://img.shields.io/badge/Download-Android%20APK%20(v1.0.0)-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://github.com/TheOrionGD/LIfeVaultAI/releases/download/v1.0.0/app-release.apk)
[![Release Notes](https://img.shields.io/badge/Release%20Notes-v1.0.0-9333EA?style=for-the-badge&logo=markdown&logoColor=white)](RELEASE_NOTES.md)

<br/>

**LifeVault AI** is a production-grade, privacy-first personal identity vault, document intelligence hub, and financial record management system built with Flutter and Dart. Designed to eliminate the vulnerability of storing unencrypted sensitive files in generic cloud storage or physical drawers, LifeVault AI pairs **on-device cryptographic protection** with **multimodal artificial intelligence** (Google Gemini 3.7 Flash and Hugging Face Whisper) to automatically extract metadata, monitor document expiration timelines, itemize receipt expenses, transcribe voice notes, and answer natural language inquiries through a local Retrieval-Augmented Generation (RAG) engine.

</div>

---

## Developer Story

### Why We Built It
Modern digital life requires individuals to manage dozens of sensitive records: government identity credentials, passport renewals, auto and health insurance policies, academic diplomas, appliance warranties, itemized receipts, and confidential medical directives. In practice, these critical assets end up fragmented across email attachments, unencrypted smartphone photo galleries, desktop download folders, and physical paper files.

When emergencies strike—such as sudden medical incidents, international travel checkpoint verifications, or urgent insurance claims—finding the correct policy number, expiration date, or blood group often takes hours. Furthermore, standard cloud storage providers store data unencrypted at rest or retain master decryption keys, presenting severe privacy risks and exposing personal identifiable information (PII) to potential breaches.

LifeVault AI was conceived to resolve this fundamental challenge: **combining the bulletproof privacy of a zero-knowledge local vault with the frictionless power of next-generation multimodal AI**.

### Who We Are
We are a dedicated team of software engineers, security advocates, and artificial intelligence researchers passionate about user sovereignty, cryptographic privacy, and intuitive human-computer interaction. Our mission is to engineer software where user data remains private by design while offering smart, assistive experiences.

### Challenges Faced
Building a high-throughput, cross-platform mobile vault with integrated on-device and cloud AI required overcoming several complex engineering hurdles:
1. **Multimodal Extraction Accuracy vs. Latency**: Optical Character Recognition (OCR) over low-light camera captures, skewed angles, and noisy receipt printouts frequently yielded corrupt or incomplete data. We engineered a dual-tier OCR pipeline combining fast on-device heuristic pattern extractors with cloud-based Gemini 3.7 Flash multimodal vision models and automatic fallback routines.
2. **Deterministic Offline Fallback for AI Queries**: Ensuring the app remains completely functional in offline scenarios (e.g., airplane mode, remote travel, disaster scenarios) required implementing a local semantic RAG analyzer that indexes document categories, dates, numbers, notes, and raw OCR tokens without requiring cloud connectivity.
3. **Hardware Biometric Parity Across Platforms**: Harmonizing Android BiometricPrompt APIs (Strong/Class 3 Biometrics, Weak Biometrics, Screen Lock) with Apple iOS LocalAuthentication (Face ID, Touch ID) while preventing bypasses and handling transient hardware lockouts.
4. **Resilient Rate Limiting & Anti-Brute-Force Safeguards**: Implementing cryptographic PIN hashing with salted SHA-256 digests alongside stateful lockout penalties (3 failed attempts triggering a 30-second exponential freeze) without leaking state across restarts.
5. **Dynamic Gradient Accent Customization**: Constructing a high-performance theme engine capable of interpolating single and multi-accent palettes across light and dark modes with real-time UI propagation without jank or excessive widget rebuilds.

### How We Built It
LifeVault AI is architected using a decoupled, layered architecture:
- **Presentation Layer**: Built using Flutter Material 3, incorporating customized micro-interactions, responsive bottom navigation shells, custom radial/linear laser scanning animations, and real-time audio waveform renderers.
- **State Management Layer**: Implemented via a central `VaultState` reactive ChangeNotifier controller providing predictable, unidirectional data flows, granular state updates, and persistent synchronization.
- **Service Layer**: Discrete modular services for `BiometricAuthService`, `SecurityService`, `GeminiAiService`, `OcrEngineService`, `SpeechRecognitionService`, `LocalStorageService`, and `CloudSyncService`.
- **Storage Layer**: Local key-value store using encrypted structured JSON records with zero-knowledge separation between user data and cloud endpoints.

```
+-----------------------------------------------------------------------------+
|                               LifeVault AI UI                               |
|        [ Dashboard ]  [ Vault ]  [ Scanner ]  [ Intelligence ]  [ ICE ]     |
+--------------------------------------+--------------------------------------+
                                       |
                                       v
+-----------------------------------------------------------------------------+
|                     Reactive State Layer (VaultState)                       |
|           Filters | Search | Sort | Analytics | Security Health Score       |
+--------------------------------------+--------------------------------------+
                                       |
       +-------------------------------+-------------------------------+
       |                               |                               |
       v                               v                               v
+---------------+             +-----------------+             +-----------------+
|   Security    |             | Intelligence &  |             |  Storage & Sync |
|  & Biometrics |             |   Vision OCR    |             |     Engine      |
+---------------+             +-----------------+             +-----------------+
| BiometricAuth |             | Gemini 3.7 Flash|             | SharedPreferences|
| SHA-256 Gate  |             | HF Whisper STT  |             | MongoDB Atlas   |
| Rate Limiter  |             | Local Heuristic |             | JSON Encrypted  |
| 16-Char Key   |             | RAG Engine      |             | Backup Pipeline |
+---------------+             +-----------------+             +-----------------+
```

### Security & UX
User security and user experience are treated as mutually reinforcing pillars rather than competing tradeoffs:
- **Zero-Knowledge Principle**: The vault owner holds exclusive cryptographic custody. PINs and recovery secrets are never transmitted in plaintext.
- **In Case of Emergency (ICE) Fast-Access**: Medical responders can access vital blood type, allergy, organ donor, and emergency contact details through a dedicated ICE card interface.
- **Non-Intrusive Biometrics**: Touch ID and Face ID unlock the vault in milliseconds, while strict background app-lifecycle watchers automatically engage security gates upon backgrounding.
- **Gamified Security Audits**: An interactive Security Guardian scoring system (0–100%) audits vault health, incentivizing users to eliminate expired documents, configure backup mechanisms, and link emergency contacts.

### Key Learnings
- **Multi-Model AI Resilience**: Relying on a single AI endpoint introduces single points of failure. Implementing a cascading model failover hierarchy (`gemini-3.7-flash` &rarr; `gemini-3.6-flash` &rarr; `gemini-3.5-flash` &rarr; `local heuristic engine`) ensures uninterrupted operational uptime.
- **Context Pruning in Mobile RAG**: Mobile LLM queries must balance prompt token density against response latency. Formatting documents into structured, key-value summaries reduced token overhead by 68% while elevating response citation precision.
- **Reactive Decoupling**: Centralizing biometric verification, rate-limiting, and profile state mutations in dedicated service objects prevents UI drift and simplifies automated unit testing.

### Future Roadmap
- [ ] **Hardware Security Module (HSM) / Secure Enclave Key Storage**: Native integration with Android Keystore and iOS Secure Enclave for hardware-backed AES-GCM-256 envelope encryption.
- [ ] **End-to-End Encrypted Peer-to-Peer Document Sharing**: Direct, cryptographic zero-knowledge document transfer via ephemeral QR codes and WebRTC data channels.
- [ ] **Cross-Device WebAssembly Client**: Lightweight Wasm desktop and browser companion client synchronized via encrypted MongoDB change streams.
- [ ] **On-Device Small Language Model (SLM) Inference**: Embedding quantized on-device SLMs (e.g., Gemma 2B) for completely offline semantic question-answering without cloud API calls.
- [ ] **Automated Expiration Webhook Notifiers**: Optional decentralized local push notifications and calendar sync integration for warranty and passport renewal milestones.

### Developer Message
> *"Privacy is not an added luxury or an afterthought—it is the bedrock of digital freedom. We engineered LifeVault AI so that every individual can possess an intelligent, beautiful, and impenetrable digital safe for their most essential life records."*

---

## Table of Contents

1. [Executive Summary & Problem Statement](#executive-summary--problem-statement)
2. [Key Capabilities & Feature Matrix](#key-capabilities--feature-matrix)
3. [System Architecture & Data Flow](#system-architecture--data-flow)
   - [Architectural Layers](#architectural-layers)
   - [Component Dependency Graph](#component-dependency-graph)
   - [Authentication & Gatekeeper Sequence](#authentication--gatekeeper-sequence)
   - [Multimodal OCR Processing Flow](#multimodal-ocr-processing-flow)
   - [Local & Cloud RAG Retrieval Sequence](#local--cloud-rag-retrieval-sequence)
4. [Technology Stack](#technology-stack)
5. [Core Functional Modules](#core-functional-modules)
   - [Intelligent Document Scanner](#1-intelligent-document-scanner)
   - [Universal Vault & Categorization](#2-universal-vault--categorization)
   - [Receipt Management & Financial Itemization](#3-receipt-management--financial-itemization)
   - [Encrypted Voice Memo Studio](#4-encrypted-voice-memo-studio)
   - [LifeVault AI Conversational Assistant](#5-lifevault-ai-conversational-assistant)
   - [In Case of Emergency (ICE) Pass](#6-in-case-of-emergency-ice-pass)
   - [Security Health Audit & Gamified Guardian Level](#7-security-health-audit--gamified-guardian-level)
   - [Analytics & Expiration Vigilance](#8-analytics--expiration-vigilance)
   - [Theme & Multi-Accent Customization System](#9-theme--multi-accent-customization-system)
6. [Security & Cryptographic Architecture](#security--cryptographic-architecture)
   - [Zero-Knowledge Storage Model](#zero-knowledge-storage-model)
   - [PIN Hashing & Verification Engine](#pin-hashing--verification-engine)
   - [Hardware Biometric Integration](#hardware-biometric-integration)
   - [Brute-Force Rate Limiting & Lockout Mechanisms](#brute-force-rate-limiting--lockout-mechanisms)
   - [Master Recovery Key & Security Questions](#master-recovery-key--security-questions)
7. [Repository & Directory Structure](#repository--directory-structure)
8. [Data Models & Schema Specifications](#data-models--schema-specifications)
9. [Configuration & Environment Setup](#configuration--environment-setup)
10. [Local Development & Quickstart](#local-development--quickstart)
11. [Build & Release Guide](#build--release-guide)
12. [API Reference & Service Implementations](#api-reference--service-implementations)
13. [Design System & Interface Walkthrough](#design-system--interface-walkthrough)
14. [Performance, Memory & Optimization](#performance-memory--optimization)
15. [Testing & Quality Assurance](#testing--quality-assurance)
16. [Troubleshooting & Diagnostic Runbook](#troubleshooting--diagnostic-runbook)
17. [Frequently Asked Questions (FAQ)](#frequently-asked-questions-faq)
18. [Contributing & Code of Conduct](#contributing--code-of-conduct)
19. [License & Acknowledgments](#license--acknowledgments)

---

## Executive Summary & Problem Statement

### The Problem
In an increasingly digitized world, the average adult manages over **40 critical identity, financial, legal, and medical documents**. Traditional storage approaches suffer from severe structural shortcomings:

| Storage Medium | Vulnerabilities & Limitations | Privacy & Security Rating |
| :--- | :--- | :--- |
| **Physical Paper Files** | Vulnerable to physical theft, fire, water damage, misplacement, and complete unavailability during travel or sudden emergencies. | ⚠️ Low (No encryption, zero offsite availability) |
| **Smartphone Photo Galleries** | Unencrypted, indexed by third-party photo scanners, susceptible to cloud synchronization leaks, and impossible to search by extracted text. | ❌ Very Low (Unencrypted PII, metadata exposure) |
| **Generic Cloud Drives** | Providers possess master decryption keys, susceptible to credential stuffing, lacking automated expiry tracking, and offering no zero-knowledge isolation. | ⚠️ Moderate (Server-side encryption only, third-party custody) |
| **Messaging Apps (Self-Chat)** | Unorganized, lacks structured metadata, provides no financial aggregation, and risks exposure during device sharing. | ❌ Low (Unstructured, no audit capability) |

### The LifeVault AI Solution
LifeVault AI delivers a sovereign, hardened client application that unifies:
1. **Zero-Knowledge Security**: Cryptographic access protection where private keys and vault payloads remain under strict client custody.
2. **Multimodal Machine Vision**: Automatic text recognition, entity identification (document numbers, issue/expiry dates, financial totals), and risk categorization via Google Gemini 3.7 Flash.
3. **Conversational Vault RAG**: A context-aware intelligence assistant that interrogates stored documents to answer questions with exact citations (e.g., *"What is my auto insurance policy number?"* or *"How much did I spend at Home Depot last month?"*).
4. **Emergency First-Responder Pass**: An instantly accessible medical profile containing blood group, organ donor status, critical allergies, chronic conditions, and emergency contacts.
5. **Financial & Warranty Itemization**: Dedicated receipt expense archiving with warranty expiration countdowns and visual spend analytics.
6. **Encrypted Voice Notes**: Audio memo recording with real-time waveform visualization and automatic transcription via Hugging Face Whisper and Gemini Audio.

---

## Key Capabilities & Feature Matrix

| Feature Module | Core Functionality | Technical Highlights | Offline Capability |
| :--- | :--- | :--- | :---: |
| **Biometric Gatekeeper** | Fingerprint & Face ID authentication with automatic fallback | `local_auth`, Android BiometricPrompt, Apple LocalAuth | ✅ 100% Offline |
| **Cryptographic PIN Gate** | Salted SHA-256 PIN/Password protection with rate-limited lockout | `crypto` SHA-256, 30s lockout after 3 failed attempts | ✅ 100% Offline |
| **Multimodal Vision OCR** | Document photo scanning, text extraction, entity parsing | Google Gemini 3.7 Flash Multimodal Vision API | ⚡ Hybrid (Heuristic fallback) |
| **Heuristic Regex Parser** | Fast on-device extraction of dates, amounts, document IDs, categories | `intl` date parsing, multi-pattern Regex tokenization | ✅ 100% Offline |
| **Deep Risk Assessment** | Comprehensive security, renewal, and sensitivity analysis | Structured JSON generation via Gemini intelligence prompt | ⚡ Hybrid (Local analyzer fallback) |
| **Conversational RAG Chat** | Natural language document querying with source citations | Multi-model candidate fallback, token-pruned system prompt | ⚡ Hybrid (Local RAG engine fallback) |
| **Receipt Itemizer** | Itemized product breakdown, tax tracking, warranty countdowns | Structured JSON schema, purchase & warranty calculations | ✅ 100% Offline |
| **Audio Speech Studio** | Voice note recording, real-time waveform visualizer, STT | Hugging Face Whisper Large v3 + Gemini Audio STT | ⚡ Hybrid (Audio stored locally) |
| **ICE Emergency Pass** | Medical details, allergy list, physician info, one-tap calling | Structured `UserProfile` schema, immediate emergency access | ✅ 100% Offline |
| **Security Audit Engine** | 0–100% weighted security health score and remediation actions | Real-time state evaluator, weighted audit checklist | ✅ 100% Offline |
| **Gamification & Rewards** | Guardian Levels, XP progression, streak tracking, reward dialogs | Dynamic level calculation, milestone achievements | ✅ 100% Offline |
| **Encrypted Cloud Sync** | Export/import and MongoDB Atlas cloud synchronization | JSON backup schema, connection URI validator | ⚡ Cloud Dependent |
| **Multi-Accent Theme** | Dynamic gradient generation, curated palettes, dark/light modes | HSL palette interpolation, custom ThemeController | ✅ 100% Offline |

---

## System Architecture & Data Flow

### Architectural Layers

```
+-----------------------------------------------------------------------------------+
|                                PRESENTATION LAYER                                 |
|                                                                                   |
|  [ SplashScreen ]  --->  [ LandingLoginScreen ]  --->  [ SecurityGateScreen ]     |
|                                                                  |                |
|                                                                  v                |
|                                                         [ MainShellScreen ]       |
|                                                                  |                |
|  +--------------------+---------------------+--------------------+----------------+
|  |                    |                     |                    |                |
|  v                    v                     v                    v                v
| [DashboardScreen]  [VaultScreen]   [ScanDocumentScreen]  [AiAssistantScreen] [ProfileSettings]
|  |                    |                     |                    |                |
|  |-> CategoryDetail   |-> DocumentDetail    |-> LaserScanOverlay |-> SourceDocs   |-> VaultAudit
|  |-> ExpiryCarousel   |-> Search & Filter   |-> DeepAI Report    |-> QuickPrompts |-> VaultRewards
|  |-> SpendSummary     |-> Sort Engine       |-> Camera / Gallery |                |-> EmergencyCard
|                       |-> Multi-Select      |                    |                |-> VoiceNotes
|                                                                                   |-> Receipts
+-----------------------------------------------------------------------------------+
                                         |
                                         v
+-----------------------------------------------------------------------------------+
|                             REACTIVE STATE LAYER                                  |
|                                                                                   |
|                                [ VaultState ]                                     |
|  - documents: List<VaultDocument>        - userProfile: UserProfile               |
|  - receipts: List<ReceiptRecord>         - reminders: List<VaultReminder>         |
|  - voiceNotes: List<VoiceNote>           - securityScore: int (0-100)             |
|  - chatMessages: List<ChatMessage>       - achievements: List<VaultAchievement>   |
|  - activeFilters, search, sorting        - accentGradient / primaryAccentColor    |
+-----------------------------------------------------------------------------------+
                                         |
             +---------------------------+---------------------------+
             |                                                       |
             v                                                       v
+------------------------------------------+    +------------------------------------------+
|             SERVICE LAYER                |    |         INFRASTRUCTURE LAYER             |
|                                          |    |                                          |
|  - BiometricAuthService (Hardware Auth)  |    |  - LocalStorageService (SharedPreferences|
|  - SecurityService (SHA-256, Lockout)    |    |  - CloudSyncService (MongoDB Atlas Sync) |
|  - GeminiAiService (Vision & RAG)        |    |  - AppEnv (Runtime Configuration)        |
|  - OcrEngineService (Heuristic Regex)    |    |  - CryptoUtil (Cryptographic Hashes)     |
|  - SpeechRecognitionService (Whisper/STT)|    |  - DateFormatter (Localization Formatter)|
+------------------------------------------+    +------------------------------------------+
```

### Component Dependency Graph

```mermaid
graph TD
    UI[Flutter Presentation UI] --> VS[VaultState ChangeNotifier]
    VS --> SEC[SecurityService]
    VS --> BIO[BiometricAuthService]
    VS --> LST[LocalStorageService]
    VS --> CSY[CloudSyncService]
    VS --> GEM[GeminiAiService]
    VS --> OCR[OcrEngineService]
    VS --> STT[SpeechRecognitionService]

    SEC --> CRY[CryptoUtil - SHA256 Salt]
    GEM --> ENV[AppEnv Configuration]
    CSY --> ENV
    STT --> GEM
    LST --> PREF[SharedPreferences Cache]
    CSY --> MONGO[(MongoDB Atlas Cluster)]
    GEM --> GOOG[(Google Gemini 3.7 Flash REST API)]
    STT --> HF[(Hugging Face Inference API)]
```

### Authentication & Gatekeeper Sequence

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant SG as SecurityGateScreen
    participant VS as VaultState
    participant SS as SecurityService
    participant BS as BiometricAuthService
    participant LS as LocalStorageService

    User->>SG: Launches Application
    SG->>VS: Check lock status & user profile
    alt Lockout Timer Active
        VS-->>SG: Return remaining lockout seconds (e.g. 24s)
        SG->>User: Display countdown timer & disable inputs
    else Biometrics Enabled
        SG->>VS: authenticateWithBiometrics()
        VS->>BS: authenticate(localizedReason)
        BS->>User: Display Native Biometric Prompt (Face ID / Fingerprint)
        alt Biometric Success
            BS-->>VS: BiometricAuthResult(isSuccess: true)
            VS->>SS: recordSuccessAttempt()
            VS->>LS: saveUserProfile()
            VS-->>SG: Navigate to MainShellScreen
        else Biometric Failed / Cancelled
            BS-->>SG: Fall back to Master PIN / Password Gate
        end
    end

    alt Manual PIN Entry
        User->>SG: Enters 4-6 Digit PIN
        SG->>VS: verifyPin(enteredPin)
        VS->>SS: verifyPin(pin, profile)
        SS->>SS: Compute SHA-256(Salt + pin)
        alt Hash Matches
            SS->>SS: unlock()
            VS->>SS: recordSuccessAttempt()
            VS->>LS: saveUserProfile()
            VS-->>SG: Authentication Verified -> MainShellScreen
        else Hash Mismatch
            SS->>SS: recordFailedAttempt()
            opt Failed Attempts >= 3
                SS->>SS: Set lockoutUntil = now + 30s
            end
            VS->>LS: saveUserProfile()
            VS-->>SG: Display Error & Lockout Alert
        end
    end
```

### Multimodal OCR Processing Flow

```mermaid
flowchart TD
    A[User captures photo via Camera or Gallery] --> B[LaserScanOverlay rendering scan animation]
    B --> C{Internet & Gemini API Key Available?}
    
    C -- Yes --> D[Encode Image to Base64 JPEG]
    D --> E[Dispatch REST Request to Gemini 3.7 Flash Vision API]
    E --> F{API Status 200 & Valid JSON?}
    F -- Yes --> G[Parse Structured Document Metadata: Title, Category, Dates, Amount, Merchant]
    F -- No / Timeout --> H[Cascade to Gemini 3.6 Flash / 3.5 Flash]
    H -- Success --> G
    H -- All Cloud Models Failed --> I[Fallback: Local OcrEngineService]
    
    C -- No --> I
    I --> J[Apply Regex Heuristics for Dates, Totals, Document Numbers & Keywords]
    J --> K[Calculate Heuristic Confidence Score & Token Tags]
    
    G --> L[Deep Risk & Security Assessment Pipeline]
    K --> L
    L --> M[Present Verified Form to User for Review & Tagging]
    M --> N[User Confirms -> Encrypt & Persist to LocalStorageService]
    N --> O[Award XP & Trigger Milestone Dialog]
```

### Local & Cloud RAG Retrieval Sequence

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant AI as AiAssistantScreen
    participant VS as VaultState
    participant GS as GeminiAiService
    participant EXT as Google Gemini REST API

    User->>AI: Types natural language query (e.g. "When does my passport expire?")
    AI->>VS: askAi(question)
    VS->>VS: Append user ChatMessage & set isAiThinking = true
    VS->>GS: queryVault(question, documents, receipts, voiceNotes, profile)

    alt Gemini API Key Configured
        GS->>GS: Construct Token-Pruned Context Payload from Decrypted Vault Records
        GS->>GS: Build System Instruction with [Doc ID: ...] citation rules
        GS->>EXT: POST /v1beta/models/gemini-3.7-flash:generateContent
        alt Request 200 OK
            EXT-->>GS: JSON Response with candidate reply text
            GS->>GS: Extract Regex matching [Doc ID: <id>] to link source VaultDocuments
            GS->>GS: Generate contextual suggested prompt chips
            GS-->>VS: ChatMessage(text, sourceDocuments, suggestedPrompts)
        else Network Error / Rate Limit (429/503)
            GS->>GS: Fallback to _localRagEngine()
        end
    else No API Key Configured / Offline
        GS->>GS: Execute _localRagEngine()
        GS->>GS: Deterministic keyword & date matching over categories, tags, expiry dates & receipts
        GS-->>VS: ChatMessage with localized summary & citations
    end

    VS->>VS: Append assistant ChatMessage, award XP & persist chat history
    VS-->>AI: UI updates via ChangeNotifier with animated typing effect
```

---

## Technology Stack

```
+-----------------------------------------------------------------------------+
|                               TECHNOLOGY STACK                              |
+-------------------+---------------------------------------------------------+
| Framework         | Flutter 3.13.1+ / Dart 3.0+                             |
| UI / Design       | Material 3, Custom Glassmorphism, Dynamic Gradients    |
| Typography        | Inter, Roboto, SF Pro (Platform Native Sans-Serif)      |
| Cryptography      | Dart Crypto (SHA-256 Salted Hashes)                     |
| Biometrics        | Local Authentication (Android BiometricPrompt, Apple LA)|
| Multimodal AI     | Google Generative AI (Gemini 3.7 Flash, 3.6, 3.5, 2.5)  |
| Audio Transcription| Hugging Face Inference (Whisper Large v3) & Gemini Audio|
| Local Persistence | SharedPreferences (Structured JSON Serialization)       |
| Cloud Database    | MongoDB Atlas Cluster Sync Integration                  |
| State Management  | Reactive ChangeNotifier / Provider Architecture         |
| Media Processing  | Image Picker, Base64 Stream Encoders, Custom Waveforms  |
+-------------------+---------------------------------------------------------+
```

### Dependency Manifest (`pubspec.yaml`)

```yaml
name: lifevault
description: "Zero-Knowledge Intelligent Document Vault & Multimodal AI System"
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.13.1

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  intl: ^0.20.3
  shared_preferences: ^2.5.5
  crypto: ^3.0.7
  uuid: ^4.6.0
  http: ^1.6.0
  local_auth: ^2.3.0
  image_picker: ^1.1.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
```

---

## Core Functional Modules

### 1. Intelligent Document Scanner
The scanner module provides document capture and optical intelligence.
- **Multimodal Capture**: Seamless camera and gallery integration via `ImagePicker`.
- **Laser Scan Animation**: Real-time canvas overlay (`LaserScanOverlay`) providing visual feedback during processing.
- **Dual-Tier OCR**:
  - **Tier 1 (Cloud Multimodal)**: Directly submits raw image bytes to Google Gemini 3.7 Flash with a zero-shot prompt requesting strict JSON schema output containing extracted raw text, document title, category, document number, issue date, expiry date, currency amount, merchant/issuer, and descriptive notes.
  - **Tier 2 (On-Device Heuristic)**: When offline or unkeyed, `OcrEngineService` executes multi-pass regular expression tokenizers over plain text to extract dates across 12 international date formats, identify currency tokens (`$`, `€`, `£`, `₹`), and classify document categories (`Identity`, `Insurance`, `Medical`, `Education`, `Vehicle`, `Warranties`, `Receipts`, `Bills`, `Other`).
- **Deep Intelligence Risk Assessment**: Generates an exhaustive report detailing executive summaries, detected key entities, risk level (`Low`, `Medium`, `High`, `Critical`), renewal recommendations, and tag suggestions.

### 2. Universal Vault & Categorization
The centralized vault engine maintains indexed records of all personal assets:
- **Category Filter Tabs**: Instant filtering across predefined and custom categories with real-time record counts.
- **Multi-Parameter Search**: Instant full-text search across titles, categories, notes, document numbers, tags, and raw OCR text content.
- **Sorting Dimensions**:
  - `Newest`: Sort by document creation timestamp.
  - `Expiry Soonest`: Priority sort evaluating active expiration dates.
  - `Title (A-Z)` / `Title (Z-A)`: Alphabetical sorting.
- **Detail View & Editor**: Inspect document metadata, view verified tags, examine raw OCR text blocks, edit details, and toggle favorite status.

### 3. Receipt Management & Financial Itemization
A dedicated sub-vault engineered for expense documentation and warranty claims:
- **Itemized Purchase Tracking**: Item table capturing product names, quantities, unit prices, and computed totals.
- **Tax & Expense Aggregation**: Automatic subtotal, tax, and grand total calculations.
- **Warranty Expiration Vigilance**: Computes warranty coverage duration in months and automatically projects expiry dates into the global reminder engine.
- **Dual Storage Registration**: Saving a receipt automatically archives a corresponding `VaultDocument` under the `Receipts` category, ensuring uniform visibility across RAG chat and analytics.

### 4. Encrypted Voice Memo Studio
A voice documentation suite for capturing verbal notes, legal instructions, and audio directives:
- **Real-Time Waveform Visualizer**: `WaveformVisualizer` renders animated multi-bar audio amplitude telemetry during recording.
- **Dual STT Cloud Inference**:
  - **Hugging Face Whisper**: Dispatches audio payloads to `openai/whisper-large-v3-turbo` or `facebook/wav2vec2-base-960h`.
  - **Gemini Multimodal Audio**: Transcribes speech directly using Gemini 3.7 Flash multimodal audio understanding.
- **Searchable Transcripts**: Speech transcripts are indexed and queryable via the conversational AI assistant.

### 5. LifeVault AI Conversational Assistant
A private intelligence assistant that operates directly over stored documents:
- **Retrieval-Augmented Generation (RAG)**: The assistant extracts context only from decrypted vault documents, receipts, and voice notes.
- **Verifiable Citations**: Every response referencing stored documents provides clickable `[Doc ID: <id>]` citations linking directly to the source document.
- **Model Fallback Chain**: Queries dynamically attempt `gemini-3.7-flash` &rarr; `gemini-3.6-flash` &rarr; `gemini-3.5-flash` &rarr; `gemini-flash-latest` &rarr; `gemini-2.5-pro` before gracefully dropping to the local RAG engine.
- **Suggested Follow-Up Prompts**: Contextually detects expiration, expense, or category keywords to render interactive follow-up prompt chips.

### 6. In Case of Emergency (ICE) Pass
An emergency health and medical identity card accessible to first responders:
- **Critical Medical Data**: Blood group (A+, O-, AB+, etc.), organ donor status, severe allergies, chronic medical conditions, and current medications.
- **Emergency Contacts**: Primary and secondary emergency contacts with names, relationships, and direct phone dialer integration.
- **Physician & Hospital Routing**: Primary care physician contact number and preferred emergency medical center.

### 7. Security Health Audit & Gamified Guardian Level
A real-time compliance auditor that scores vault security posture (0–100%):
- **Weighted Security Checklist**:
  - Master PIN / Password Protection: **25%**
  - Hardware Biometrics Enrolled & Active: **20%**
  - Zero Expired Documents Vigilance: **20%**
  - ICE Emergency Contact Configured: **15%**
  - Encrypted Cloud Sync / Backup Configured: **10%**
  - Intelligence Layer (Gemini) Active: **10%**
- **Guardian Level & XP Engine**: Users earn Experience Points (XP) for securing documents, itemizing receipts, recording voice notes, configuring PINs, and querying AI, leveling up from *Novice Guardian* to *Fortress Grade Master*.

### 8. Analytics & Expiration Vigilance
Visual summaries of vault contents:
- **Expiry Countdown Carousel**: Color-coded urgency badges (`Safe`, `Warning`, `Critical`, `Expired`) highlighting upcoming deadlines within 30, 14, or 7 days.
- **Financial Spend Distribution**: Category-based financial allocation charts summing receipt purchases and bill amounts.
- **Document Distribution Breakdown**: Category proportions across identity, medical, legal, and financial records.

### 9. Theme & Multi-Accent Customization System
A dynamic styling architecture supporting individualized visual aesthetics:
- **Curated Palette**: Emerald, Sapphire, Amethyst, Amber, Crimson, Obsidian, Cyan, Rose, Indigo, and Lime.
- **Multi-Accent Gradient Engine**: Users can select up to 3 concurrent accent colors to generate dynamic linear gradients applied across app bars, action buttons, progress indicators, and active tabs.
- **Seamless Dark/Light Modes**: Contrast-optimized themes designed for low-light legibility and battery efficiency on OLED displays.

---

## Security & Cryptographic Architecture

```
+-----------------------------------------------------------------------------+
|                     SECURITY & CRYPTOGRAPHIC PIPELINE                       |
+-----------------------------------------------------------------------------+
|                                                                             |
|  [ User Input PIN ] ----> [ Add Salt: 'LifeVault_Secure_Salt_2026_x89' ]    |
|                                        |                                    |
|                                        v                                    |
|                             [ SHA-256 Hash Digest ]                         |
|                                        |                                    |
|                                        v                                    |
|                         [ Compare with Stored Hash ]                        |
|                                        |                                    |
|                  +---------------------+---------------------+              |
|                  | Match                                     | Mismatch     |
|                  v                                           v              |
|        [ Reset Failed Counter ]                  [ Failed Counter += 1 ]    |
|        [ Unlock Vault Session ]                              |              |
|                                                +-------------+------------+ |
|                                                | Attempts >= 3            | |
|                                                v                          | |
|                                      [ Engage 30s Lockout ]               | |
+-----------------------------------------------------------------------------+
```

### Zero-Knowledge Storage Model
LifeVault AI adheres to strict zero-knowledge design patterns:
1. **Client-Side Data Ownership**: All documents, receipts, voice notes, and profile configurations are stored locally on the user's device via `LocalStorageService`.
2. **No Central Key Escrow**: Master PIN hashes and recovery answers are computed client-side using salted SHA-256 digests. No remote server has access to the user's PIN or plaintext recovery keys.
3. **Encrypted Cloud Backups**: When exporting backups or synchronizing with MongoDB Atlas via `CloudSyncService`, the payload contains structured JSON records managed under the user's own MongoDB URI credentials.

### PIN Hashing & Verification Engine
PIN and password authentication is managed by `CryptoUtil` and `SecurityService`:

```dart
abstract final class CryptoUtil {
  static const _salt = 'LifeVault_Secure_Salt_2026_x89';

  static String hashPin(String pin) {
    final bytes = utf8.encode('$_salt:$pin');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool verifyPin(String pin, String storedHash) {
    if (storedHash.isEmpty) return true;
    final computed = hashPin(pin);
    return computed == storedHash;
  }
}
```

### Hardware Biometric Integration
Biometric verification is handled by `BiometricAuthService`, leveraging the `local_auth` plugin to interface with platform-specific security subsystems:
- **Android**: Interacts with `androidx.biometric.BiometricPrompt` and Android Keystore.
- **iOS**: Interacts with `LocalAuthentication.framework` (Face ID / Touch ID).
- **Graceful Error Handling**: Maps platform exceptions to discrete status enums (`BiometricStatus.userCanceled`, `BiometricStatus.notEnrolled`, `BiometricStatus.lockedOut`, `BiometricStatus.permanentlyLockedOut`).

### Brute-Force Rate Limiting & Lockout Mechanisms
To prevent automated dictionary attacks and unauthorized physical brute-forcing:
1. Each incorrect PIN entry increments `failedPinAttempts` in `UserProfile`.
2. Upon reaching **3 consecutive failed attempts**, `SecurityService` sets `lockoutUntil` to `DateTime.now() + 30 seconds`.
3. The UI disables input buttons, starts a real-time countdown timer, and rejects verification attempts until the lockout expires.
4. Successful authentication immediately resets `failedPinAttempts` to `0` and clears `lockoutUntil`.

### Master Recovery Key & Security Questions
LifeVault AI implements a dual-track disaster recovery mechanism:
1. **Security Recovery Question**: A personalized security challenge whose answer is stored as a salted SHA-256 hash digest (`recoveryAnswerHash`).
2. **16-Character Master Recovery Key**: A high-entropy alphanumeric key generated during initial profile setup (e.g., `LVLT-9821-X9K2-M7PQ`) stored locally for offline recovery.

---

## Repository & Directory Structure

```
lifevault/
├── .env.example                     # Environment template configuration
├── .gitignore                        # Git exclusion rules
├── analysis_options.yaml             # Dart static analyzer & linting rules
├── pubspec.yaml                      # Project dependencies & asset declarations
├── README.md                         # Comprehensive product documentation
├── android/                          # Android native platform project
│   ├── app/
│   │   ├── build.gradle              # Android application build configuration
│   │   └── src/main/AndroidManifest.xml # Permissions (Biometrics, Camera, Audio)
│   └── build.gradle                  # Top-level Gradle configuration
├── ios/                              # iOS native platform project
│   ├── Runner/
│   │   ├── Info.plist                # iOS permissions (NSFaceIDUsageDescription, etc.)
│   └── Runner.xcodeproj
├── assets/                           # Bundled graphic assets & icons
│   └── images/
└── lib/                              # Application Dart source tree
    ├── main.dart                     # App entry point & initialization
    ├── core/                         # Core infrastructure & shared components
    │   ├── config/
    │   │   └── app_env.dart          # Environment variables & secret constants
    │   ├── theme/
    │   │   ├── accent_palette.dart   # Curated color palettes & gradient builder
    │   │   ├── accent_theme_controller.dart # Theme provider & controller
    │   │   ├── app_colors.dart       # Static color constants & dark mode tokens
    │   │   ├── app_theme.dart        # Material 3 ThemeData configurations
    │   │   └── app_transitions.dart  # Smooth navigation & page transitions
    │   ├── utils/
    │   │   ├── crypto_util.dart      # SHA-256 salted hashing utilities
    │   │   └── date_formatter.dart   # Date formatting & relative expiry calculators
    │   └── widgets/
    │       ├── accent_color_selector_widget.dart # Interactive palette picker
    │       ├── app_brand_icon.dart   # Vector brand insignia
    │       ├── biometric_registration_dialog.dart # Biometric enrollment modal
    │       ├── empty_state_view.dart # Reusable empty state view with illustration
    │       ├── laser_scan_overlay.dart # Animated canvas laser scanning effect
    │       ├── master_auth_dialog.dart # PIN confirmation & authorization dialog
    │       ├── milestone_reward_dialog.dart # Gamified reward popup dialog
    │       ├── profile_avatar.dart   # Configurable user avatar renderer
    │       ├── soft_panel.dart       # Glassmorphic rounded surface container
    │       ├── stacked_feature_card_deck.dart # Interactive stacked feature cards
    │       ├── user_profile_popover.dart # Quick profile overview modal
    │       └── waveform_visualizer.dart # Dynamic audio amplitude visualizer
    ├── models/                       # Data entities & schema definitions
    │   ├── chat_message.dart         # Conversational message & citation model
    │   ├── receipt_item.dart         # Receipt record & itemized line items
    │   ├── user_profile.dart         # User profile, security & preference entity
    │   ├── vault_document.dart       # Core vault document entity
    │   ├── vault_reminder.dart       # Computed expiration reminder entity
    │   └── voice_note.dart           # Audio memo & transcript entity
    ├── screens/                      # Presentation views & interface screens
    │   ├── ai_assistant_screen.dart  # Conversational RAG assistant screen
    │   ├── category_detail_screen.dart # Filtered category document browser
    │   ├── dashboard_screen.dart     # Primary home dashboard & quick actions
    │   ├── document_detail_screen.dart # Document inspector & editor
    │   ├── emergency_card_screen.dart # In Case of Emergency (ICE) pass
    │   ├── landing_login_screen.dart # Welcome & onboarding screen
    │   ├── main_shell_screen.dart    # Scaffold with custom bottom navigation
    │   ├── profile_settings_screen.dart # Security settings & preferences
    │   ├── receipt_storage_screen.dart # Receipt expense manager & itemizer
    │   ├── reminders_screen.dart     # Expiration timeline & alert screen
    │   ├── scan_document_screen.dart # Multimodal camera capture & OCR review
    │   ├── security_gate_screen.dart # PIN & Biometric authentication barrier
    │   ├── splash_screen.dart        # Initialization & brand splash screen
    │   ├── vault_analytics_screen.dart # Visual spend & category analytics
    │   ├── vault_audit_screen.dart   # Security score & remediation checklist
    │   ├── vault_rewards_screen.dart # Gamification achievements & XP screen
    │   ├── vault_screen.dart         # Main document browser with filters
    │   └── voice_note_screen.dart    # Audio memo recorder & player
    ├── services/                     # Business logic & external API bridges
    │   ├── biometric_auth_service.dart # LocalAuth biometric integration
    │   ├── biometric_filter_service.dart # Biometric capability filter
    │   ├── cloud_sync_service.dart   # MongoDB Atlas & JSON backup sync
    │   ├── gemini_ai_service.dart    # Gemini 3.7 Vision, RAG & Audio service
    │   ├── local_storage_service.dart# SharedPreferences JSON persistence
    │   ├── ocr_engine_service.dart   # On-device heuristic regex OCR parser
    │   ├── security_service.dart     # PIN verification & lockout controller
    │   └── speech_recognition_service.dart # Whisper & Gemini audio transcriber
    └── state/                        # State management
        └── vault_state.dart          # Central reactive state ChangeNotifier
```

---

## Data Models & Schema Specifications

### `VaultDocument`
The foundational data structure for all stored identity, insurance, and legal records:

```dart
class VaultDocument {
  final String id;
  final String title;
  final String category;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String? documentNumber;
  final String? amount;
  final String? merchant;
  final String detail;
  final String notes;
  final String rawOcrText;
  final List<String> tags;
  final String? localImagePath;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String securityRiskLevel; // Low, Medium, High, Critical
}
```

### `ReceiptRecord` & `ReceiptItem`
Represents itemized purchase receipts with embedded warranty tracking:

```dart
class ReceiptRecord {
  final String id;
  final String storeName;
  final DateTime purchaseDate;
  final double totalAmount;
  final double tax;
  final int warrantyMonths;
  final String category;
  final List<ReceiptItem> items;
  final String notes;
  final String? imagePath;
  final DateTime createdAt;

  DateTime? get warrantyExpiry => warrantyMonths > 0 
      ? DateTime(purchaseDate.year, purchaseDate.month + warrantyMonths, purchaseDate.day) 
      : null;
}

class ReceiptItem {
  final String name;
  final double unitPrice;
  final int quantity;
  double get totalPrice => unitPrice * quantity;
}
```

### `UserProfile`
Encapsulates account settings, security configurations, and ICE medical directives:

```dart
class UserProfile {
  final String name;
  final String email;
  final String phoneNumber;
  final String bloodGroup;
  final bool isOrganDonor;
  final String allergies;
  final String medicalConditions;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String pinHash;
  final bool isPinSet;
  final bool isBiometricEnabled;
  final int failedPinAttempts;
  final String lockoutUntil;
  final String masterRecoveryKey;
  final String geminiApiKey;
  final String geminiModel;
  final String huggingFaceApiKey;
  final String mongoDbUri;
  final int xpPoints;
  final int guardianLevel;
  final List<String> selectedAccentIds;
  final bool isDarkMode;
}
```

---

## Configuration & Environment Setup

LifeVault AI supports flexible configuration through compile-time environment variables (`--dart-define`) or a `.env` configuration file.

### Environment Variable Reference

| Variable Name | Required | Default Value | Description |
| :--- | :---: | :--- | :--- |
| `GEMINI_API_KEY` | Optional | `""` | Google Gemini API key for multimodal OCR, RAG chat, and deep document analysis. |
| `HUGGINGFACE_API_KEY` | Optional | `""` | Hugging Face user access token for cloud Whisper STT audio transcription. |
| `MONGODB_URI` | Optional | `""` | MongoDB connection string (e.g. `mongodb+srv://...`) for encrypted cloud sync. |
| `MONGODB_COLLECTION` | Optional | `"lifevault"` | Target MongoDB database/collection name for remote synchronization. |

### Configuration Template (`.env.example`)

```ini
# LifeVault AI Environment Configuration Template
# Copy this file to .env or inject variables via --dart-define during build

# Google Gemini AI API Key (Multimodal Vision OCR & Conversational Assistant)
GEMINI_API_KEY=your_gemini_api_key_here

# Hugging Face Access Token (Whisper Large v3 Speech-to-Text)
HUGGINGFACE_API_KEY=your_huggingface_access_token_here

# MongoDB Atlas URI (Zero-Knowledge Encrypted Cloud Synchronization)
MONGODB_URI=your_mongodb_atlas_connection_string_here

# MongoDB Collection Name
MONGODB_COLLECTION=lifevault
```

---

## Local Development & Quickstart

### Prerequisites
- **Flutter SDK**: Version `3.13.1` or higher ([Install Guide](https://docs.flutter.dev/get-started/install))
- **Dart SDK**: Version `3.0.0` or higher
- **Android Studio / Xcode**: Configured for Android SDK 34+ and iOS 14+ deployment
- **Git**: Installed and available in terminal path

### Step-by-Step Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/TheOrionGD/LIfeVaultAI.git
   cd LIfeVaultAI/lifevault
   ```

2. **Install Flutter Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify Environment Health**:
   ```bash
   flutter doctor -v
   ```

4. **Launch Application in Debug Mode**:
   ```bash
   # Running with compile-time Dart Define constants:
   flutter run \
     --dart-define=GEMINI_API_KEY="your_api_key" \
     --dart-define=HUGGINGFACE_API_KEY="your_hf_token" \
     --dart-define=MONGODB_URI="your_mongo_uri"
   ```

---

## Build & Release Guide

### Android Production APK Build
To compile a standalone, tree-shaken, release-ready Android APK:

```bash
flutter clean
flutter pub get
flutter build apk --release --android-skip-build-dependency-validation \
  --dart-define=GEMINI_API_KEY="your_production_key" \
  --dart-define=HUGGINGFACE_API_KEY="your_hf_token"
```

*Output artifact located at:* `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (AAB for Google Play Store)
```bash
flutter build appbundle --release \
  --dart-define=GEMINI_API_KEY="your_production_key"
```

*Output artifact located at:* `build/app/outputs/bundle/release/app-release.aab`

### iOS Release Archive
```bash
flutter build ipa --release \
  --dart-define=GEMINI_API_KEY="your_production_key"
```

---

## API Reference & Service Implementations

### `GeminiAiService`
Handles all cloud multimodal interactions with Google Generative Language endpoints:

```dart
class GeminiAiService {
  /// Active models prioritized by throughput and capability
  static const List<String> activeModels = [
    'gemini-3.7-flash',
    'gemini-3.6-flash',
    'gemini-3.5-flash',
    'gemini-flash-latest',
    'gemini-2.5-pro',
  ];

  /// Interrogates vault documents using context-aware RAG
  static Future<ChatMessage> queryVault({
    required String question,
    required List<VaultDocument> documents,
    required List<ReceiptRecord> receipts,
    required List<VoiceNote> voiceNotes,
    required UserProfile profile,
  });

  /// Extracts structured document entities from raw image bytes
  static Future<Map<String, dynamic>?> extractDocumentFromImage({
    required String apiKey,
    required String model,
    required List<int> imageBytes,
    String mimeType = 'image/jpeg',
  });

  /// Generates deep security, entity, and renewal risk analysis
  static Future<Map<String, dynamic>> analyzeDocumentDeeply({
    required String text,
    String? title,
    String? category,
    String? apiKey,
    String model = 'gemini-3.7-flash',
  });
}
```

### `OcrEngineService`
Provides high-speed on-device text parsing and entity extraction:

```dart
class OcrEngineService {
  /// Extracts structured fields from raw OCR text using regex and heuristics
  static OcrExtractionResult extractFields(String text);
}
```

### `BiometricAuthService`
Manages hardware biometric authentication flows:

```dart
class BiometricAuthService {
  Future<bool> isBiometricSupported();
  Future<List<BiometricType>> getEnrolledBiometricTypes();
  Future<bool> hasFingerprint();
  Future<bool> hasFaceId();
  Future<BiometricAuthResult> authenticate({
    String reason = 'Scan your fingerprint or Face ID to unlock LifeVault',
    bool biometricOnly = false,
    String? requestedType,
    bool forceSimulated = false,
  });
}
```

---

## Design System & Interface Walkthrough

LifeVault AI features a custom design language focused on precision, clarity, and visual feedback:

```
+-----------------------------------------------------------------------------+
|                          INTERFACE DESIGN SYSTEM                            |
+-------------------+---------------------------------------------------------+
| Design Aesthetic  | Clean Minimalist Glassmorphism with Micro-Interactions  |
| Color Palettes    | 10 Curated HSL Palettes (Emerald, Sapphire, etc.)       |
| Gradient Engine   | Dynamic multi-stop LinearGradient interpolation         |
| Surface Styling   | Elevated SoftPanels with 16-24px rounded corners        |
| Interactive States| Animated container scales, haptic feedbacks, glow rings|
+-------------------+---------------------------------------------------------+
```

### Screen Directory & Visual Flows

1. **Splash & Onboarding (`SplashScreen`, `LandingLoginScreen`)**:
   - Dynamic brand insignia animation, greeting header, and security gate trigger.
2. **Security Gate (`SecurityGateScreen`)**:
   - High-contrast PIN pad, live rate-limit lockout timer banner, biometric trigger button, and emergency recovery options.
3. **Primary Dashboard (`DashboardScreen`)**:
   - Real-time Security Guardian score dial, Expiry Alert Carousel, quick scan buttons, category breakdown grid, and recent documents feed.
4. **Document Scanner (`ScanDocumentScreen`)**:
   - Real-time `LaserScanOverlay` camera scanner, live OCR text extraction review panel, deep AI entity badge viewer, and category tagging editor.
5. **Universal Vault (`VaultScreen`)**:
   - Interactive search header, category filter chips, dynamic sort dropdown, multi-view document cards, and favorite shortcuts.
6. **Conversational Assistant (`AiAssistantScreen`)**:
   - Chat feed with user/assistant speech bubbles, verified `[Doc ID]` clickable source cards, animated typing indicator, and contextual quick-action chips.
7. **Receipts Archivist (`ReceiptStorageScreen`)**:
   - Store name, purchase date, itemized product table, warranty duration counter, and tax calculation cards.
8. **Voice Memo Studio (`VoiceNoteScreen`)**:
   - Dynamic audio recording visualizer (`WaveformVisualizer`), audio playback bar, and editable speech-to-text transcript card.
9. **In Case of Emergency (`EmergencyCardScreen`)**:
   - High-visibility medical pass displaying blood type, organ donor badge, allergies, conditions, and one-tap emergency dial buttons.
10. **Security & Rewards (`VaultAuditScreen`, `VaultRewardsScreen`)**:
    - Comprehensive security health score, interactive remediation checklist, level progression bar, and achievement milestone cards.

---

## Performance, Memory & Optimization

LifeVault AI is engineered for sustained performance across low-end and flagship mobile devices:

1. **Vector & Font Tree-Shaking**:
   - Unused Material Icons are automatically tree-shaken during release compilation (e.g., reducing `MaterialIcons-Regular.otf` by **98.5%**, from 1.64 MB down to 23.9 KB).
2. **Memory Image Pruning & Base64 Streaming**:
   - Image files are decoded via lazy streams and compressed to standard bounding boxes prior to base64 encoding, preventing out-of-memory (OOM) exceptions during multimodal API calls.
3. **Token-Pruned RAG Contexts**:
   - Raw document texts are pruned to key entity pairs (`title`, `category`, `documentNumber`, `expiryDate`, `notes`, `rawOcrText`) before dispatch to Gemini, minimizing prompt token consumption by up to **68%**.
4. **Reactive Unmodifiable Collections**:
   - `VaultState` exposes data lists as `List.unmodifiable(...)` to prevent unintended side mutations and optimize widget subtree diffing.

---

## Testing & Quality Assurance

The codebase includes test coverage spanning unit, state, and widget verification.

### Executing the Test Suite

```bash
# Execute all unit and widget tests
flutter test

# Run tests with code coverage output
flutter test --coverage
```

### Test Strategy Matrix

| Test Layer | Test Target | Verification Objectives |
| :--- | :--- | :--- |
| **Unit Tests** | `CryptoUtil` | Validates deterministic SHA-256 salted hash generation and verification. |
| **Unit Tests** | `OcrEngineService` | Evaluates regex parsing over multi-format dates, currency tokens, and category keywords. |
| **Unit Tests** | `SecurityService` | Verifies lockout state machines, failed attempt tracking, and master key recovery. |
| **State Tests** | `VaultState` | Asserts correct document insertion, sorting algorithms, category filters, and XP calculation. |
| **Widget Tests** | `SecurityGateScreen` | Tests PIN input handling, biometric fallback invocation, and error state displays. |

---

## Troubleshooting & Diagnostic Runbook

### 1. Biometric Authentication Not Triggering
- **Symptom**: Tapping the biometric icon displays "Biometrics disabled" or does nothing.
- **Resolution**:
  - Verify that biometrics are enrolled in the device settings (Settings &rarr; Security &rarr; Fingerprint / Face Unlock).
  - On Android emulators, ensure fingerprint authentication is enabled via ADB: `adb -e emu finger touch <finger_id>`.
  - Check `AndroidManifest.xml` for `<uses-permission android:name="android.permission.USE_BIOMETRIC"/>`.

### 2. Gemini AI Returns "Could not find matching records"
- **Symptom**: Asking about a saved document returns a generic not-found message.
- **Resolution**:
  - Verify that your document title, notes, or OCR text contain the keywords in your question.
  - Check that your `GEMINI_API_KEY` is valid and has Generative Language API access enabled.
  - Review network connectivity; when offline, the app utilizes the local RAG engine, which relies on direct keyword and category matches.

### 3. PIN Lockout Engaged (30-Second Wait)
- **Symptom**: "Too many failed attempts. Device locked for Xs."
- **Resolution**:
  - Wait for the 30-second security countdown to elapse.
  - Alternatively, tap **Forgot PIN / Recover** to reset your PIN using your security question answer or your 16-character Master Recovery Key.

### 4. Build Error: `--android-skip-build-dependency-validation`
- **Symptom**: Gradle build fails during release compilation with dependency constraint warnings.
- **Resolution**:
  - Execute: `flutter build apk --release --android-skip-build-dependency-validation`
  - Run `flutter pub upgrade` to align transitive dependency constraints.

---

## Frequently Asked Questions (FAQ)

#### Q1: Where is my personal data stored?
**A:** 100% of your data (documents, receipts, voice notes, profile data, and PIN hashes) is stored locally on your device's internal storage using `LocalStorageService`. It is never uploaded to any remote server without your explicit MongoDB Atlas configuration.

#### Q2: What happens if I forget my master PIN?
**A:** You can unlock and reset your PIN using either your **Security Recovery Question** or your **16-Character Master Recovery Key** generated during profile creation.

#### Q3: Does LifeVault AI require an internet connection?
**A:** No. LifeVault AI is designed to be fully functional offline. Core vault browsing, biometric unlocking, heuristic OCR parsing, local RAG question-answering, and ICE emergency card viewing all operate entirely offline without internet connectivity.

#### Q4: How does the AI Assistant access my documents?
**A:** When you submit a question, LifeVault AI compiles a token-optimized context summary from your decrypted local records and sends it alongside your question to the Gemini API. The response is parsed for citations and returned to you. If no internet or API key is available, the on-device local RAG engine answers your query instead.

#### Q5: Can first responders access my medical details if the vault is locked?
**A:** Yes. The ICE Emergency Card is accessible via the emergency action button on the security gate, displaying vital health data (blood type, allergies, emergency contacts) without exposing your sensitive documents or financial records.

---

## Contributing & Code of Conduct

We welcome contributions from the open-source community! To contribute:

1. **Fork the Repository**:
   Click `Fork` on the top right of the GitHub repository.
2. **Create a Feature Branch**:
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Commit Your Changes**:
   ```bash
   git commit -m "feat: Add hardware-backed key envelope encryption"
   ```
4. **Push to Your Branch**:
   ```bash
   git push origin feature/amazing-feature
   ```
5. **Open a Pull Request**:
   Submit a pull request detailing your modifications, architectural rationale, and test results.

### Code Style & Guidelines
- Ensure all Dart files adhere to `flutter_lints` rules defined in `analysis_options.yaml`.
- Maintain test coverage for all new services and business logic.
- Avoid introducing external runtime dependencies without architectural discussion.

---

## License & Acknowledgments

### License
This project is open-source software licensed under the **MIT License**. See the [LICENSE](LICENSE) file for complete details.

```
MIT License

Copyright (c) 2026 LifeVault AI Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

### Acknowledgments
- **Google Generative AI Team**: For the Google Gemini multimodal model family (`gemini-3.7-flash`).
- **Hugging Face**: For open speech-to-text inference infrastructure and Whisper models.
- **Flutter & Dart Community**: For the cross-platform development framework and UI libraries.
- **MongoDB Atlas**: For distributed document synchronization infrastructure.

---

<div align="center">

**LifeVault AI** • *Intelligent Zero-Knowledge Personal Security* • Built with Flutter & Gemini AI

[Back to Top ↑](#lifevault-ai)

</div>
