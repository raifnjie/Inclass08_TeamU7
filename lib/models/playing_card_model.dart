class PlayingCardModel {
  final int? id;
  final String cardName;
  final String suit;
  final String imageUrl; // stores asset path like assets/cards/2_of_clubs.png
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
}