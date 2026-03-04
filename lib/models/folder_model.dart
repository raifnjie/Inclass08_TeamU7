class FolderModel {
  final int? id;
  final String folderName;
  final String timestamp;

  FolderModel({
    this.id,
    required this.folderName,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'folder_name': folderName,
      'timestamp': timestamp,
    };
  }

  factory FolderModel.fromMap(Map<String, dynamic> map) {
    return FolderModel(
      id: map['id'],
      folderName: map['folder_name'],
      timestamp: map['timestamp'],
    );
  }

  FolderModel copyWith({
    int? id,
    String? folderName,
    String? timestamp,
  }) {
    return FolderModel(
      id: id ?? this.id,
      folderName: folderName ?? this.folderName,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}