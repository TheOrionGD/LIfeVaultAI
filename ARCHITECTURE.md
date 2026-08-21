build it fully..by separate for cross platform page..implement transition,animation, and so on
LifeVault AI: Flutter Architecture & Tech Stack
1. Abstract (Updated for Flutter)
LifeVault AI is a privacy-focused mobile application designed to provide users with a simple and secure platform for managing important personal information and documents. Built using the Flutter framework and Dart language, the system allows users to scan or upload documents, add receipts, warranty details, notes, and optional voice notes, organizing them into categorized digital records. Optical Character Recognition (OCR) is achieved using highly optimized native mobile vision APIs (Google ML Kit for Android, Apple Vision for iOS) via Flutter plugins, ensuring privacy by processing data entirely on-device. The application provides proactive reminders for upcoming expirations, warranties, and other important dates using Flutter's local notification services. A key feature is the natural-language Gemini AI assistant, enabling users to ask questions about their stored information (e.g., "When does my passport expire?"). The system securely transmits sanitized context to the Gemini API and displays answers along with relevant stored source references. Security is paramount, leveraging Flutter plugins for biometric authentication (FaceID/TouchID), PIN protection, privacy controls, notifications, and encrypted synchronization with MongoDB Atlas.
2. Problem Statement (Unchanged)
Managing critical personal documents, product warranties, financial receipts, and expiration timelines is typically fragmented across physical folders, camera rolls, and disconnected digital apps. Users face several key challenges:
Manual Tracking Overhead: Forgetting exact warranty expiration dates, passport renewal windows, or insurance deadlines, resulting in missed renewals or financial loss.
Information Disorganization: Difficulty instantly locating specific details (e.g., "How much did I pay for the washing machine?" or "When does my vehicle insurance expire?").
Privacy and Security Concerns: Storing sensitive legal, identity, and medical documents in unsecured cloud environments risks data privacy breaches.
Lack of Intelligent Context: Conventional file storage solutions lack a smart semantic layer to answer natural language questions based on a user's local or cloud-synced records.
3. Proposed Solution (Updated for Flutter)
LifeVault AI addresses these challenges by delivering an intelligent, privacy-first personal information management framework:
Automated Native OCR: Leverages Flutter plugins interfacing directly with Apple Vision (iOS) and Google ML Kit (Android) to ingest physical documents via camera, instantly pulling out dates, amounts, and categories on-device.
Context-Aware AI Assistant ("Ask AI"): Integrates the Google Gemini API using Flutter's networking capabilities to securely query securely-stored vault records, returning exact answers with source document references.
Proactive Expiry Management: Utilizes Flutter local notification packages (e.g., flutter_local_notifications) to schedule offline reminders for impending warranty expirations.
Encrypted Storage Architecture: Secures data entry using hardware-level biometrics (local_auth package) and integrates with MongoDB Atlas for encrypted cloud backup and synchronization.
4. System / App Layers (Updated for Flutter)
Layer
Architecture Component
Technology / Language
Purpose / Function
1. Presentation Layer
UI & Widgets
Flutter SDK (Dart), Material Design
Renders the mobile interface, bottom navigation tabs, and responsive mobile layouts.
2. State Management Layer
Application Logic
Riverpod or Bloc (Dart)
Manages the state of authentication, vault documents, notifications, and the AI chat interface.
3. Device Integration Layer
Hardware & Native APIs
Flutter Plugins (camera, google_ml_kit, local_auth, flutter_local_notifications)
Interfaces with camera scanning, on-device OCR, biometric locks, and local alerts.
4. Processing Layer
Data Parsing & Crypto
Dart (Client-side) & Packages
Extracts metadata (dates, amounts) from raw OCR text via custom functions before syncing. Handles local encryption keys.
5. Database Layer
Cloud Data Storage
MongoDB Atlas & Flutter SDK (mongo_dart or REST API)
Provides secure, NoSQL database operations synchronized with the cloud backend.
6. Intelligence Layer
AI & Natural Language
Google Gemini API (via http package)
Powers the "Ask AI" assistant module to process natural language user questions.

5. Pages / App Screens List (Unchanged UI Flow, updated implementation)
Splash Screen: Looping 2D/3D MP4 animated introduction video (displayed via video_player package).
Login & Security Screen: PIN/Password validation and biometric unlock (via local_auth plugin).
Home Dashboard: Greeting, quick action grid, and summary widgets.
My Documents (Vault) Screen: Categorized folders (Identity, Education, Insurance, Medical, Vehicle, Bills, Warranties, Other).
Scan / Add Document Screen: Camera viewfinder, document upload, and native OCR token extraction preview.
Receipt Storage Screen: Parsed item records (Store, Date, Amount, Item).
Voice Note Screen: Audio recording interface with real-time speech-to-text transcription.
Reminder & Alerts Page: Upcoming expiry countdowns and notification warnings (via flutter_local_notifications).
AI Assistant ("Ask AI") Screen: Conversational chat layout with source document tags (powered by google_generative_ai package).
Profile & Security Settings Screen: Biometric toggles, cloud backup status, and emergency contacts.
Document Detail / Viewer Page: Deep view of stored image, editable metadata, and management controls.
6. App Flow (Updated for Flutter)
App Initialization: The app boots up, displaying the seamless looping MP4 video on the Splash Screen (handled by video_player) while initial authentication state and localisarion assets load.
Authentication Gate: The user is met with the Login & Security Screen, requiring a 4-digit PIN or hardware Biometric Authentication (Fingerprint/Face ID via local_auth).
Dashboard Landing: Upon successful auth, the user enters the Home Dashboard, viewing greeting indicators and quick action shortcuts.
Data Ingestion Flow: From the Home or Vault screens, the user triggers Scan Document, Add Receipt, or Voice Notes. The system captures media via Flutter Camera/Audio plugins, parses the raw data using client-side native OCR/regex, and pushes structured metadata to MongoDB Atlas (via mongo_dart or HTTPS).
Active Monitoring & Querying:
Background service checks expiry dates to push alerts via Reminders Page (handled by flutter_local_notifications).
Users can enter the AI Assistant Screen to naturally question records using the Gemini API (google_generative_ai package).
7. Each Screen's Data Specifications (Updated for Flutter)
Screen 1: Splash Screen
Input Data: App configuration, pre-cached assets.
Processing Logic: Timer or async promise checking secure storage and database session using Flutter FutureBuilder.
Output Data: Unmounts splash container to reveal security or home view.
Screen 2: Login & Security Screen
Input Data: User input PIN string, biometric hardware callback signal.
Processing Logic: Hashed PIN comparison against secure local storage (flutter_secure_storage package); biometric validation via local_auth plugin.
Output Data: Authorization state flag (isAuthenticated: true).
Screen 3: Home Dashboard
Input Data: User profile summary, pending notification counters, recent document arrays fetched from MongoDB Atlas.
Processing Logic: Aggregating active document expiration counts versus current system date.
Output Data: Rendered dashboard widgets using Flutter SliverGrid/ListView, quick action navigation triggers.
Screen 4: My Documents (Vault) Screen
Input Data: Full document collection metadata filtered by user ID.
Processing Logic: Category grouping logic (Identity, Education, Insurance, Medical, Vehicle, Bills, Warranties, Other), live search filter string matching.
Output Data: Rendered folder grid counters and matching file records.
Screen 5: Scan / Add Document Screen
Input Data: Camera binary image stream.
Processing Logic: Native OCR (Google ML Kit / Apple Vision); regular expression matching for dates (DD/MM/YYYY), amounts, and header labels.
Output Data: Parsed JSON object containing extracted fields ready for user review and database insertion.
Screen 6: Receipt Storage Screen
Input Data: Captured receipt image file and extracted token properties.
Processing Logic: Mapping fields to specific key-value pairs (Store Name, Purchase Date, Total Amount, Item Description).
Output Data: Saved MongoDB document record stored under the "Receipts" schema.
Screen 7: Voice Note Screen
Input Data: Audio stream from microphone plugin (record or flutter_sound package) or speech-to-text API.
Processing Logic: Converting spoken audio string into structured text notes (e.g., "Remember I purchased this washing machine on August 10").
Output Data: Text string appended with timestamp metadata saved to local/cloud vaults.
Screen 8: Reminder & Alerts Page
Input Data: Document collection expiry date properties.
Processing Logic: Date-math comparison against system clock; scheduling native OS notifications via flutter_local_notifications (e.g., 30, 7, and 1 day prior).
Output Data: Categorized warning list (Warranty, Document, Insurance) and active device push alerts.
Screen 9: AI Assistant ("Ask AI") Screen
Input Data: User natural language query string, contextual string array of user's MongoDB records.
Processing Logic: Packaging user vault data context into a secure prompt payload sent to the Google Gemini API (google_generative_ai package).
Output Data: Generated conversational text response coupled with source document reference tags.
Screen 10: Profile & Security Settings Screen
Input Data: User preference toggles (Biometric switch, notification frequency, cloud backup connection status).
Processing Logic: Updating local app preference state (using shared_preferences or hive) and MongoDB Atlas account settings.
Output Data: Saved security configuration preferences.
Screen 11: Document Detail / Viewer Page
Input Data: Unique Document ID selected from the Vault list.
Processing Logic: Fetching high-resolution file payload via path_provider local storage or MongoDB Atlas Data API.
Output Data: Detailed view showing full image/PDF preview, editable metadata fields, and action buttons (Delete, Share, Export).

