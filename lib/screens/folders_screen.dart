import 'package:flutter/material.dart';
import '../models/folder.dart';
import '../repositories/folder_repository.dart';
import '../repositories/card_repository.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Card Organizer')),
      body: 
          _loading ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
            itemCount: _folders.length,
            itemBuilder: (context, index) {
              final folder = _folders[index];
              return ListTile(
                title: Text(folder.folderName),
                subtitle: Text('${_cardCounts[folder.id!] ?? 0} cards'),
              );
            },
          )
    );
  }
}