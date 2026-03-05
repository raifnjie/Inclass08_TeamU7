import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/folder_model.dart';
import '../repositories/folder_repository.dart';
import 'cards_screen.dart';

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({super.key});

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  final FolderRepository _folderRepo = FolderRepository();
  late Future<List<Map<String, dynamic>>> _foldersFuture;

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  void _loadFolders() {
    _foldersFuture = _folderRepo.getFoldersWithCounts();
  }

  Future<void> _refresh() async {
    setState(() => _loadFolders());
  }

  IconData _suitIcon(String suit) {
    switch (suit.toLowerCase()) {
            case 'hearts':
            return Icons.favorite;
            case 'diamonds':
            return Icons.diamond_outlined; 
            case 'clubs':
            return Icons.local_florist; 
            case 'spades':
            return Icons.spa; 
            default:
            return Icons.folder;
        }
    }

  Future<void> _renameFolder(Map<String, dynamic> folder) async {
    final controller = TextEditingController(text: folder['folder_name']);
    final formKey = GlobalKey<FormState>();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename Folder'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Folder Name'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(context, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (ok == true) {
      try {
        await _folderRepo.updateFolder(
          FolderModel(
            id: folder['id'] as int,
            folderName: controller.text.trim(),
            timestamp: folder['timestamp'] as String,
          ),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Folder renamed')));
        _refresh();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rename failed: $e')));
      }
    }
  }

  Future<void> _deleteFolder(Map<String, dynamic> folder) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Delete Folder?'),
        content: Text('Delete "${folder['folder_name']}" and ALL cards inside?\n\nThis uses CASCADE deletion.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (ok == true) {
      try {
        await _folderRepo.deleteFolder(folder['id'] as int);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Folder deleted')));
        _refresh();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Card Organizer - Folders')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _foldersFuture,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));

          final folders = snap.data ?? [];
          if (folders.isEmpty) return const Center(child: Text('No folders found.'));

          return RefreshIndicator(
            onRefresh: _refresh,
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: folders.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.15,
              ),
              itemBuilder: (context, i) {
                final f = folders[i];
                final name = f['folder_name'] as String;
                final count = (f['card_count'] as int?) ?? 0;
                final ts = f['timestamp'] as String;

                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CardsScreen(
                            folderId: f['id'] as int,
                            folderName: name,
                          ),
                        ),
                      );
                      _refresh();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(_suitIcon(name)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text('Cards: $count'),
                          const Spacer(),
                          Text(
                            DateFormat('MM/dd/yyyy').format(DateTime.parse(ts)),
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(icon: const Icon(Icons.edit), onPressed: () => _renameFolder(f)),
                              IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteFolder(f)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}