import 'package:flutter/material.dart';
import '../models/folder.dart';
import '../models/card.dart';
import '../repositories/card_repository.dart';


class CardsScreen extends StatefulWidget {
  final Folder folder;
  const CardsScreen({super.key, required this.folder});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final CardRepository _cardRepo = CardRepository();

  List<PlayingCard> _cards = [];
  bool _loading = true;

  @override
  void initState(){
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final cards = await _cardRepo.getCardsByFolderId(widget.folder.id!);

    setState(() {
      _cards = cards;
      _loading = false;
    });
  }

  Future<void> _confirmDelete(PlayingCard card) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Card'),
          content: Text('Are you sure you want to delete ${card.cardName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _cardRepo.deleteCard(card.id!);
      _loadCards();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.folderName),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                final card = _cards[index];

                return ListTile(
                  leading: Image.asset(
                    card.imageUrl ?? '',
                    width: 40,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                  title: Text(card.cardName),
                  subtitle: Text(card.suit),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // nothing for now
                        },
                      ),

                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _confirmDelete(card);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}