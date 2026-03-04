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
                  leading: const Icon(Icons.style),
                  title: Text(card.cardName),
                  subtitle: Text(card.suit),
                );
              },
            ),
    );
  }
}