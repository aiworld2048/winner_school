import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/student_note.dart';
import '../providers/student_notes_provider.dart';

class StudentNotesScreen extends ConsumerStatefulWidget {
  const StudentNotesScreen({super.key});

  @override
  ConsumerState<StudentNotesScreen> createState() => _StudentNotesScreenState();
}

class _StudentNotesScreenState extends ConsumerState<StudentNotesScreen> {
  bool _showPinnedOnly = false;

  Future<void> _openComposer({StudentNote? editing}) async {
    final controller = ref.read(studentNotesControllerProvider.notifier);
    final result = await showModalBottomSheet<_NoteFormResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NoteComposerSheet(note: editing),
    );

    if (result == null) return;

    if (editing == null) {
      await controller.createNote(
        title: result.title,
        content: result.content,
        colorHex: result.colorHex,
        isPinned: result.isPinned,
        tags: result.tags,
      );
    } else {
      await controller.updateNote(
        editing,
        title: result.title,
        content: result.content,
        colorHex: result.colorHex,
        isPinned: result.isPinned,
        tags: result.tags,
      );
    }
  }

  Future<void> _deleteNote(StudentNote note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete note?'),
        content: const Text('This note will be removed permanently.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(studentNotesControllerProvider.notifier).deleteNote(note.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesState = ref.watch(studentNotesControllerProvider);
    final notes = notesState.valueOrNull ?? [];
    final filteredNotes =
        _showPinnedOnly ? notes.where((note) => note.isPinned).toList() : notes;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(studentNotesControllerProvider.notifier).refresh(),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(child: _NotebookHero(onAddTap: () => _openComposer())),
              SliverAppBar(
                pinned: true,
                automaticallyImplyLeading: false,
                toolbarHeight: 74,
                backgroundColor: Theme.of(context).colorScheme.surface,
                title: Row(
                  children: [
                    Text(
                      _showPinnedOnly ? 'Pinned notes' : 'All notes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(width: 12),
                    FilterChip(
                      label: const Text('Pinned only'),
                      selected: _showPinnedOnly,
                      onSelected: (value) {
                        HapticFeedback.selectionClick();
                        setState(() => _showPinnedOnly = value);
                      },
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    tooltip: 'New note',
                    icon: const Icon(Icons.note_add_outlined),
                    onPressed: () => _openComposer(),
                  ),
                ],
              ),
              notesState.when(
                loading: () => const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48),
                      const SizedBox(height: 12),
                      Text(error.toString(), textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => ref.read(studentNotesControllerProvider.notifier).refresh(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (_) {
                  if (filteredNotes.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.menu_book_outlined, size: 72),
                          const SizedBox(height: 16),
                          const Text(
                            'Your notebook is empty',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Capture quick study tips, homework, or reminders.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: () => _openComposer(),
                            icon: const Icon(Icons.add),
                            label: const Text('Start a note'),
                          ),
                        ],
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final note = filteredNotes[index];
                          return _NotebookCard(
                            note: note,
                            onTap: () => _openComposer(editing: note),
                            onTogglePin: () => ref
                                .read(studentNotesControllerProvider.notifier)
                                .updateNote(note, isPinned: !note.isPinned),
                            onDelete: () => _deleteNote(note),
                          );
                        },
                        childCount: filteredNotes.length,
                      ),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 320,
                        mainAxisExtent: 230,
                        mainAxisSpacing: 18,
                        crossAxisSpacing: 18,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openComposer(),
        icon: const Icon(Icons.edit_note),
        label: const Text('New note'),
      ),
    );
  }
}

class _NotebookHero extends StatelessWidget {
  const _NotebookHero({required this.onAddTap});

  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary, colors.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_stories_rounded, color: colors.onPrimary),
              const SizedBox(width: 12),
              Text(
                'Student notebook',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Sketch ideas, jot homework, and track progress with a tactile, lined-paper experience built for modern study habits.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colors.onPrimary.withOpacity(0.85),
                ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _HeroChip(icon: Icons.push_pin_outlined, label: 'Pin urgent tasks'),
              _HeroChip(icon: Icons.palette_outlined, label: 'Color-coded sheets'),
              _HeroChip(icon: Icons.timeline_outlined, label: 'Auto timeline'),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAddTap,
            icon: const Icon(Icons.add),
            label: const Text('Create note'),
            style: FilledButton.styleFrom(
              backgroundColor: colors.onPrimary,
              foregroundColor: colors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotebookCard extends StatelessWidget {
  const _NotebookCard({
    required this.note,
    required this.onTap,
    required this.onTogglePin,
    required this.onDelete,
  });

  final StudentNote note;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = _colorFromHex(
      note.colorHex,
      Theme.of(context).colorScheme.secondaryContainer,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              offset: const Offset(0, 8),
              blurRadius: 20,
            ),
          ],
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: _NotebookLines()),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        note.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      ),
                      tooltip: note.isPinned ? 'Unpin' : 'Pin',
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        onTogglePin();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Delete',
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onDelete();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    note.content ?? 'No content',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                        ),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    ...note.tags
                        .map(
                          (tag) => Chip(
                            label: Text(tag),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                        )
                        .toList(),
                  ],
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    note.friendlyUpdatedAt,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NotebookLines extends StatelessWidget {
  const _NotebookLines();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _NotebookLinePainter(
          lineColor: Colors.black.withOpacity(0.05),
          marginColor: Colors.redAccent.withOpacity(0.2),
        ),
      ),
    );
  }
}

class _NotebookLinePainter extends CustomPainter {
  _NotebookLinePainter({required this.lineColor, required this.marginColor});

  final Color lineColor;
  final Color marginColor;

  @override
  void paint(Canvas canvas, Size size) {
    final horizontalPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;
    for (double y = 24; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), horizontalPaint);
    }

    final marginPaint = Paint()
      ..color = marginColor
      ..strokeWidth = 1.5;
    canvas.drawLine(const Offset(28, 0), Offset(28, size.height), marginPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NoteComposerSheet extends StatefulWidget {
  const _NoteComposerSheet({this.note});

  final StudentNote? note;

  @override
  State<_NoteComposerSheet> createState() => _NoteComposerSheetState();
}

class _NoteComposerSheetState extends State<_NoteComposerSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _tagController;
  late bool _isPinned;
  late String? _colorHex;
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _tagController = TextEditingController();
    _isPinned = widget.note?.isPinned ?? false;
    _colorHex = widget.note?.colorHex;
    _tags = [...(widget.note?.tags ?? [])];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag(String value) {
    final tag = value.trim();
    if (tag.isEmpty) return;
    setState(() {
      _tags = [..._tags, tag];
    });
    _tagController.clear();
  }

  void _removeTag(String tag) {
    setState(() {
      _tags = _tags.where((item) => item != tag).toList();
    });
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    Navigator.of(context).pop(
      _NoteFormResult(
        title: _titleController.text.trim(),
        content: _contentController.text.trim().isEmpty ? null : _contentController.text.trim(),
        colorHex: _colorHex,
        isPinned: _isPinned,
        tags: _tags,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;
    final palette = _notebookPalette;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.6,
      expand: false,
      builder: (context, controller) {
        return Container(
          padding: EdgeInsets.only(bottom: inset),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              children: [
                Align(
                  child: Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.note == null ? 'Create note' : 'Edit note',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g. History recap or HW checklist',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    labelText: 'Notebook page',
                    hintText: 'Write your summary, doodles, or todo list...',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Pin to top'),
                    Switch(
                      value: _isPinned,
                      onChanged: (value) => setState(() => _isPinned = value),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Color palette',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  children: palette
                      .map(
                        (hex) => GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _colorHex = hex);
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _colorFromHex(hex, Colors.white),
                              border: Border.all(
                                color: _colorHex == hex
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),
                Text(
                  'Tags',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._tags.map(
                      (tag) => InputChip(
                        label: Text(tag),
                        onDeleted: () => _removeTag(tag),
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: TextField(
                        controller: _tagController,
                        decoration: const InputDecoration(
                          labelText: 'Add tag',
                          hintText: 'Press enter',
                        ),
                        onSubmitted: _addTag,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(widget.note == null ? 'Save note' : 'Update note'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NoteFormResult {
  _NoteFormResult({
    required this.title,
    this.content,
    this.colorHex,
    required this.isPinned,
    required this.tags,
  });

  final String title;
  final String? content;
  final String? colorHex;
  final bool isPinned;
  final List<String> tags;
}

const _notebookPalette = [
  '#FDF6E3',
  '#EAF4FF',
  '#FCEBFF',
  '#E6FAF1',
  '#FFF1E0',
  '#F4F1FF',
];

Color _colorFromHex(String? hex, Color fallback) {
  if (hex == null || hex.isEmpty) return fallback;
  final sanitized = hex.replaceAll('#', '');
  final buffer = StringBuffer();
  if (sanitized.length == 6) buffer.write('ff');
  buffer.write(sanitized);
  try {
    return Color(int.parse(buffer.toString(), radix: 16));
  } catch (_) {
    return fallback;
  }
}


