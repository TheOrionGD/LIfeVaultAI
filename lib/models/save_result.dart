/// Class containing file saving result information across platforms
class SaveResult {
  const SaveResult({
    required this.success,
    this.filePath,
    this.storageType = 'Storage',
  });

  final bool success;
  final String? filePath;
  final String storageType; // 'Gallery' | 'Downloads' | 'Storage'
}
