/// Centralized Application Environment Configuration
/// Reads secret keys from environment variables or bundled definitions.
class AppEnv {
  AppEnv._();

  /// Google Gemini AI API Key (used for OCR, document intelligence, chatbot assistant)
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  /// Hugging Face API User Access Token (used for Whisper STT cloud audio transcription)
  static const String huggingFaceApiKey = String.fromEnvironment(
    'HUGGINGFACE_API_KEY',
    defaultValue: '',
  );

  /// MongoDB Atlas connection string (used for zero-knowledge encrypted cloud sync)
  static const String mongoDbUri = String.fromEnvironment(
    'MONGODB_URI',
    defaultValue: 'mongodb+srv://godfreytrprof_db_user:6JjxTbgSJbzjBkv4@hellotheoriongd.rbxbuxe.mongodb.net/?appName=hellotheOrionGD',
  );

  /// MongoDB database / collection name
  static const String mongoDbCollection = String.fromEnvironment(
    'MONGODB_COLLECTION',
    defaultValue: 'lifevault',
  );
}
