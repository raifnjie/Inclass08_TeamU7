class PlayingCardModel {
  final int? id;
  final String cardName;
  final String suit;
  final String imageUrl;
  final int folderId;

  PlayingCardModel({
    this.id,
    required this.cardName,
    required this.suit,
    required this.imageUrl,
    required this.folderId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'card_name': cardName,
      'suit': suit,
      'image_url': imageUrl,
      'folder_id': folderId,
    };
  }

  factory PlayingCardModel.fromMap(Map<String, dynamic> map) {
    return PlayingCardModel(
      id: map['id'],
      cardName: map['card_name'],
      suit: map['suit'],
      imageUrl: map['image_url'] ?? '',
      folderId: map['folder_id'],
    );
  }

  PlayingCardModel copyWith({
    int? id,
    String? cardName,
    String? suit,
    String? imageUrl,
    int? folderId,
  }) {
    return PlayingCardModel(
      id: id ?? this.id,
      cardName: cardName ?? this.cardName,
      suit: suit ?? this.suit,
      imageUrl: imageUrl ?? this.imageUrl,
      folderId: folderId ?? this.folderId,
    );
  }
}