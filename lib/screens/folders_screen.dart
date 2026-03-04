import 'package:flutter/material.dart';
import '../models/folder.dart';
import '../repositories/folder_repository.dart';
import '../repositories/card_repository.dart';
import '../screens/cards_screen.dart';

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({super.key});

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  final FolderRepository _folderRepo = FolderRepository();
  final CardRepository _cardRepo = CardRepository();

  List<Folder> _folders = [];
  Map<int, int> _cardCounts = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final folders = await _folderRepo.getAllFolders();

    final Map<int, int> counts = {};
    for (final folder in folders) {
      final id = folder.id!;
      counts[id] = await _cardRepo.getCardCountByFolder(id);
    }

    setState(() {
      _folders = folders;
      _cardCounts = counts;
      _loading = false;
    });
  }

String _getSuitSymbol(String suitName) {
  switch (suitName) {
    case 'Hearts':
      return '♥';
    case 'Diamonds':
      return '♦';
    case 'Clubs':
      return '♣';
    case 'Spades':
      return '♠';
    default:
      return '?';
  }
}

Color _getSuitColor(String suitName) {
  switch (suitName) {
    case 'Hearts':
    case 'Diamonds':
      return Colors.red;
    case 'Clubs':
    case 'Spades':
      return Colors.black;
    default:
      return Colors.grey;
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Card Organizer')),
      body: 
          _loading ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: _folders.length,
          itemBuilder: (context, index) {
            final folder = _folders[index];
            final count = _cardCounts[folder.id!] ?? 0;

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CardsScreen(folder: folder),
                    ),
                  );
                  _loadFolders();
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getSuitSymbol(folder.folderName),
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: _getSuitColor(folder.folderName),
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      folder.folderName,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text('$count cards', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
            );
          },
      ),
    );
  }
}