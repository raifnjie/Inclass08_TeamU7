import 'package:flutter/material.dart';

import '../models/playing_card_model.dart';
import '../repositories/card_repository.dart';
import 'add_edit_card_screen.dart';

class CardsScreen extends StatefulWidget {
  final int folderId;
  final String folderName;

  const CardsScreen({
    super.key,
    required this.folderId,
    required this.folderName,
  });

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final CardRepository _cardRepo = CardRepository();
  late Future<List<PlayingCardModel>> _cardsFuture;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  void _loadCards() {
    _cardsFuture = _cardRepo.getCardsByFolder(widget.folderId);
  }

  Future<void> _refresh() async {
    setState(() {
      _loadCards();
    });
  }

  Future<void> _deleteCard(PlayingCardModel card) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Delete Card?'),
        content: Text('Delete "${card.cardName} of ${card.suit}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _cardRepo.deleteCard(card.id!);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card deleted')),
        );
        _refresh();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  Future<void> _openAddEdit({PlayingCardModel? card}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditCardScreen(
          folderId: widget.folderId,
          defaultSuit: widget.folderName,
          card: card,
        ),
      ),
    );
    _refresh();
  }

  Widget _cardImage(String url) {
    if (url.trim().isEmpty) {
      return const SizedBox(
        width: 60,
        height: 80,
        child: Icon(Icons.image_not_supported),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        url,
        width: 60,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            width: 60,
            height: 80,
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.folderName} Cards'),
      ),
      body: FutureBuilder<List<PlayingCardModel>>(
        future: _cardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final cards = snapshot.data ?? [];

          if (cards.isEmpty) {
            return const Center(child: Text('No cards in this folder.'));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final card = cards[index];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: _cardImage(card.imageUrl),
                    title: Text('${card.cardName} of ${card.suit}'),
                    subtitle: Text('ID: ${card.id}'),
                    isThreeLine: false,
                    trailing: Wrap(
                      spacing: 4,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _openAddEdit(card: card),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteCard(card),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddEdit(),
        child: const Icon(Icons.add),
      ),
    );
  }
}