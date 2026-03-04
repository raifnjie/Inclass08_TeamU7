import 'package:flutter/material.dart';

import '../models/playing_card_model.dart';
import '../repositories/card_repository.dart';

class AddEditCardScreen extends StatefulWidget {
  final int folderId;
  final String defaultSuit;
  final PlayingCardModel? card;

  const AddEditCardScreen({
    super.key,
    required this.folderId,
    required this.defaultSuit,
    this.card,
  });

  @override
  State<AddEditCardScreen> createState() => _AddEditCardScreenState();
}

class _AddEditCardScreenState extends State<AddEditCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardRepo = CardRepository();

  late TextEditingController _cardNameController;
  late TextEditingController _imageUrlController;
  late String _selectedSuit;
  bool _isSaving = false;

  final List<String> _suits = ['Spades', 'Hearts', 'Diamonds', 'Clubs'];

  @override
  void initState() {
    super.initState();

    _cardNameController =
        TextEditingController(text: widget.card?.cardName ?? '');
    _imageUrlController =
        TextEditingController(text: widget.card?.imageUrl ?? '');

    _selectedSuit = widget.card?.suit ?? widget.defaultSuit;
    if (!_suits.contains(_selectedSuit)) {
      _selectedSuit = 'Spades';
    }
  }

  @override
  void dispose() {
    _cardNameController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final model = PlayingCardModel(
        id: widget.card?.id,
        cardName: _cardNameController.text.trim(),
        suit: _selectedSuit,
        imageUrl: _imageUrlController.text.trim(),
        folderId: widget.folderId,
      );

      if (widget.card == null) {
        await _cardRepo.insertCard(model);
      } else {
        await _cardRepo.updateCard(model);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.card == null ? 'Card added' : 'Card updated'),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.card != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Card' : 'Add Card'),
      ),
      body: AbsorbPointer(
        absorbing: _isSaving,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _cardNameController,
                  decoration: const InputDecoration(
                    labelText: 'Card Name (ex: Ace, King, 2)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter a card name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedSuit,
                  decoration: const InputDecoration(
                    labelText: 'Suit',
                    border: OutlineInputBorder(),
                  ),
                  items: _suits
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedSuit = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Image URL (optional)',
                    border: OutlineInputBorder(),
                    hintText: 'https://deckofcardsapi.com/static/img/AS.png',
                  ),
                ),
                const SizedBox(height: 20),
                if (_imageUrlController.text.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Image.network(
                      _imageUrlController.text.trim(),
                      height: 140,
                      errorBuilder: (_, __, ___) =>
                          const Text('Image preview unavailable'),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving ? null : () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}