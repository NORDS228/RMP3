import 'package:flutter/material.dart';

void main() {
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Заметки',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: Colors.black,
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.zero),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: Colors.black54),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: Colors.black, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
        ),
      ),
      home: const NotesPage(),
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _Note {
  _Note(this.text) : key = UniqueKey();

  final Key key;
  String text;
  bool isImportant = false;
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _controller = TextEditingController();
  final List<_Note> _notes = [];
  int? _editingIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveNote() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите текст заметки')),
      );
      return;
    }

    setState(() {
      final editingIndex = _editingIndex;
      if (editingIndex == null) {
        _notes.insert(0, _Note(text));
      } else {
        _notes[editingIndex].text = text;
      }
      _editingIndex = null;
      _controller.clear();
    });
    FocusScope.of(context).unfocus();
  }

  void _editNote(int index) {
    setState(() {
      _editingIndex = index;
      _controller.text = _notes[index].text;
    });
  }

  void _showNote(int index) {
    final text = _notes[index].text;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Заметка'),
        content: SingleChildScrollView(child: Text(text)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _toggleImportant(int index) {
    setState(() {
      _notes[index].isImportant = !_notes[index].isImportant;
    });
  }

  void _restoreNote(int index) {
    setState(() {
      _notes[index].isImportant = false;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingIndex = null;
      _controller.clear();
    });
  }

  void _deleteNote(int index) {
    setState(() {
      final editingIndex = _editingIndex;
      _notes.removeAt(index);

      if (editingIndex == index) {
        _editingIndex = null;
        _controller.clear();
      } else if (editingIndex != null && editingIndex > index) {
        _editingIndex = editingIndex - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Заметки'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _controller,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Введите текст заметки',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveNote,
                      icon: Icon(
                        _editingIndex == null ? Icons.save : Icons.check,
                      ),
                      label: Text(
                        _editingIndex == null ? 'Сохранить' : 'Обновить',
                      ),
                    ),
                  ),
                  if (_editingIndex != null) ...[
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: _cancelEditing,
                      child: const Text('Отмена'),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'Список заметок',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Text('${_notes.length}'),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _notes.isEmpty
                    ? Center(
                        child: Text(
                          'Пока нет заметок',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 8),
                        itemCount: _notes.length,
                        itemBuilder: (context, index) {
                          final note = _notes[index];
                          return Dismissible(
                            key: note.key,
                            direction: note.isImportant
                                ? DismissDirection.horizontal
                                : DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 20),
                              color: Colors.green.shade100,
                              child: const Icon(Icons.star_outline),
                            ),
                            secondaryBackground: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: Colors.red.shade100,
                              child: const Icon(Icons.delete_outline),
                            ),
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.startToEnd) {
                                _restoreNote(index);
                                return false;
                              }
                              return true;
                            },
                            onDismissed: (direction) {
                              if (direction == DismissDirection.endToStart) {
                                _deleteNote(index);
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black26),
                              ),
                              child: GestureDetector(
                                onTap: () => _showNote(index),
                                onDoubleTap: () => _toggleImportant(index),
                                onLongPress: () => _editNote(index),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    8,
                                    4,
                                    8,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (note.isImportant)
                                        const Padding(
                                          padding: EdgeInsets.only(
                                            top: 12,
                                            right: 8,
                                          ),
                                          child: Icon(Icons.star),
                                        ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          child: Text(
                                            note.text,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
