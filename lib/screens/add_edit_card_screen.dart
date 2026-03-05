import 'package:flutter/material.dart';
import '../models/folder.dart';
import '../models/card.dart';
import '../repositories/card_repository.dart';

class AddEditCardScreen extends StatefulWidget {
  final Folder folder;            // the folder we came from
  final PlayingCard? existingCard; // null = add, non-null = edit

  const AddEditCardScreen({
    super.key,
    required this.folder,
    this.existingCard,
  });

  @override
  State<AddEditCardScreen> createState() => _AddEditCardScreenState();
}

class _AddEditCardScreenState extends State<AddEditCardScreen> {
  final CardRepository _cardRepo = CardRepository();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  late String _selectedSuit;
  late int _selectedFolderId;

  @override
  void initState() {
    super.initState();

    // Default values for ADD
    _selectedSuit = widget.folder.folderName;
    _selectedFolderId = widget.folder.id!;

    // If EDIT, prefill fields
    final c = widget.existingCard;
    if (c != null) {
      _nameController.text = c.cardName;
      _imageController.text = c.imageUrl ?? '';
      _selectedSuit = c.suit;
      _selectedFolderId = c.folderId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final img = _imageController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Card name is required')),
      );
      return;
    }

    if (widget.existingCard == null) {
      // ADD
      final newCard = PlayingCard(
        cardName: name,
        suit: _selectedSuit,
        imageUrl: img.isEmpty ? null : img,
        folderId: _selectedFolderId,
      );
      await _cardRepo.insertCard(newCard);
    } else {
      // EDIT
      final updated = widget.existingCard!.copyWith(
        cardName: name,
        suit: _selectedSuit,
        imageUrl: img.isEmpty ? null : img,
        folderId: _selectedFolderId,
      );
      await _cardRepo.updateCard(updated);
    }

    if (!mounted) return;
    Navigator.pop(context, true); // return "changed"
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existingCard != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Edit Card' : 'Add Card'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Card Name (Ace, 2, ... King)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _selectedSuit,
              items: const [
                DropdownMenuItem(value: 'Hearts', child: Text('Hearts')),
                DropdownMenuItem(value: 'Diamonds', child: Text('Diamonds')),
                DropdownMenuItem(value: 'Clubs', child: Text('Clubs')),
                DropdownMenuItem(value: 'Spades', child: Text('Spades')),
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() => _selectedSuit = v);
              },
              decoration: const InputDecoration(
                labelText: 'Suit',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _imageController,
              decoration: const InputDecoration(
                labelText: 'Image Asset Path (optional)',
                hintText: 'assets/cards/hearts_ace.png',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}