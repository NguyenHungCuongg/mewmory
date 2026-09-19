import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../config/constants.dart';
import '../config/theme.dart';
import '../db/database.dart' as db;
import '../models/definition.dart' as models;
import '../models/vocabulary.dart' as models;
import '../providers/services_provider.dart';
import '../providers/vocabulary_provider.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/loading_indicator.dart';
import '../widgets/common/mew_button.dart';
import '../widgets/common/mew_card.dart';
import '../widgets/common/mew_chip.dart';
import '../widgets/common/mew_text_field.dart';

class WordDetailPage extends ConsumerStatefulWidget {
  final String id;

  const WordDetailPage({
    super.key,
    required this.id,
  });

  @override
  ConsumerState<WordDetailPage> createState() => _WordDetailPageState();
}

class _EditableDefinitionItem {
  final String? id;
  final TextEditingController viController;
  final TextEditingController enController;
  final TextEditingController exampleController;
  final DateTime? createdAt;

  _EditableDefinitionItem({
    this.id,
    required String definitionVi,
    String? definitionEn,
    String? example,
    this.createdAt,
  })  : viController = TextEditingController(text: definitionVi),
        enController = TextEditingController(text: definitionEn ?? ''),
        exampleController = TextEditingController(text: example ?? '');

  void dispose() {
    viController.dispose();
    enController.dispose();
    exampleController.dispose();
  }
}

class _WordDetailPageState extends ConsumerState<WordDetailPage> {
  // Audio Player
  AudioPlayer? _player;
  bool _isPlaying = false;

  // Edit Mode State
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isDeleting = false;

  // Edit Controllers
  final _wordController = TextEditingController();
  final _phoneticController = TextEditingController();
  String _posValue = 'noun';
  String _cefrValue = 'B1';
  String _usageValue = 'neutral';
  List<_EditableDefinitionItem> _editDefinitions = [];

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player?.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _player?.dispose();
    _wordController.dispose();
    _phoneticController.dispose();
    _disposeEditDefinitions();
    super.dispose();
  }

  void _disposeEditDefinitions() {
    for (final def in _editDefinitions) {
      def.dispose();
    }
    _editDefinitions = [];
  }

  Future<void> _playAudio(String url) async {
    if (_player == null || url.isEmpty) return;

    try {
      if (_isPlaying) {
        await _player!.stop();
      } else {
        await _player!.play(UrlSource(url));
      }
    } catch (_) {
      // Audio playback fallback
    }
  }

  void _enterEditMode(db.VocabularyWithDefinitions item) {
    _disposeEditDefinitions();

    _wordController.text = item.vocabulary.word;
    _phoneticController.text = item.vocabulary.phonetic ?? '';
    _posValue = item.vocabulary.partOfSpeech ?? 'noun';
    if (!AppConstants.partsOfSpeech.contains(_posValue)) {
      _posValue = AppConstants.partsOfSpeech.first;
    }
    _cefrValue = item.vocabulary.cefrLevel ?? 'B1';
    if (!AppConstants.cefrLevels.contains(_cefrValue)) {
      _cefrValue = AppConstants.cefrLevels.first;
    }
    _usageValue = item.vocabulary.usageRegister ?? 'neutral';
    if (!AppConstants.usageRegisters.contains(_usageValue)) {
      _usageValue = AppConstants.usageRegisters.first;
    }

    _editDefinitions = item.definitions.map((d) {
      return _EditableDefinitionItem(
        id: d.id,
        definitionVi: d.definitionVi ?? '',
        definitionEn: d.definitionEn,
        example: d.example,
        createdAt: d.createdAt,
      );
    }).toList();

    if (_editDefinitions.isEmpty) {
      _editDefinitions.add(_EditableDefinitionItem(definitionVi: ''));
    }

    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEditMode() {
    _disposeEditDefinitions();
    setState(() {
      _isEditing = false;
    });
  }

  Future<void> _handleSave(db.VocabularyWithDefinitions item) async {
    final word = _wordController.text.trim();
    if (word.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập từ vựng')),
      );
      return;
    }

    final validDefs = _editDefinitions
        .where((d) => d.viController.text.trim().isNotEmpty)
        .toList();

    if (validDefs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập ít nhất một nghĩa tiếng Việt')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final vocabService = ref.read(vocabularyServiceProvider);

      final updatedVocab = models.Vocabulary(
        id: item.vocabulary.id,
        userId: item.vocabulary.userId,
        word: word,
        phonetic: _phoneticController.text.trim().isEmpty
            ? null
            : _phoneticController.text.trim(),
        audioUrl: item.vocabulary.audioUrl,
        partOfSpeech: _posValue,
        cefrLevel: _cefrValue,
        usageRegister: _usageValue,
        createdAt: item.vocabulary.createdAt,
        updatedAt: DateTime.now(),
      );

      final updatedDefs = validDefs.asMap().entries.map((entry) {
        final idx = entry.key;
        final d = entry.value;
        return models.Definition(
          id: d.id ?? const Uuid().v4(),
          vocabularyId: item.vocabulary.id,
          definitionVi: d.viController.text.trim(),
          definitionEn: d.enController.text.trim().isEmpty
              ? null
              : d.enController.text.trim(),
          example: d.exampleController.text.trim().isEmpty
              ? null
              : d.exampleController.text.trim(),
          sortOrder: idx,
          createdAt: d.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }).toList();

      await vocabService.update(
        vocabulary: updatedVocab,
        definitions: updatedDefs,
      );

      if (mounted) {
        _cancelEditMode();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật từ vựng thành công')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi cập nhật: ${e.toString()}'),
            backgroundColor: MewColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _handleDelete(db.VocabularyWithDefinitions item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: MewColors.eggshell,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Xác nhận xóa',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: MewColors.ink,
          ),
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa từ "${item.vocabulary.word}" không? Từ vựng sẽ được chuyển vào thùng rác.',
          style: GoogleFonts.inter(color: MewColors.smoke),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Hủy',
              style: GoogleFonts.inter(color: MewColors.smoke),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Xóa',
              style: GoogleFonts.inter(
                color: MewColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      final vocabService = ref.read(vocabularyServiceProvider);
      await vocabService.delete(item.vocabulary.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa từ "${item.vocabulary.word}"')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xóa: ${e.toString()}'),
            backgroundColor: MewColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  void _showCollectionSheet(db.VocabularyWithDefinitions item) {
    final allCollectionsAsync = ref.read(allCollectionsProvider);
    final collections = allCollectionsAsync.value ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: MewColors.eggshell,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Quản lý Bộ sưu tập',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: MewColors.ink,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (collections.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Text(
                          'Chưa có bộ sưu tập nào',
                          style: GoogleFonts.inter(color: MewColors.smoke),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: collections.length,
                          separatorBuilder: (_, __) =>
                              const Divider(color: MewColors.stone, height: 1),
                          itemBuilder: (ctx, i) {
                            final col = collections[i];
                            final isAssigned =
                                item.collectionIds.contains(col.collection.id);

                            return CheckboxListTile(
                              value: isAssigned,
                              activeColor: MewColors.ink,
                              checkColor: MewColors.eggshell,
                              title: Text(
                                col.collection.name,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500,
                                  color: MewColors.ink,
                                ),
                              ),
                              subtitle: col.collection.description != null &&
                                      col.collection.description!.isNotEmpty
                                  ? Text(
                                      col.collection.description!,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: MewColors.smoke,
                                      ),
                                    )
                                  : null,
                              onChanged: (checked) async {
                                final colService =
                                    ref.read(collectionServiceProvider);
                                if (checked == true) {
                                  await colService.assignWord(
                                    item.vocabulary.id,
                                    col.collection.id,
                                  );
                                } else {
                                  await colService.removeWord(
                                    item.vocabulary.id,
                                    col.collection.id,
                                  );
                                }
                                setModalState(() {});
                              },
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 16),
                    MewButton.filled(
                      label: 'Xong',
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vocabDetailAsync = ref.watch(vocabularyDetailProvider(widget.id));
    final allCollectionsAsync = ref.watch(allCollectionsProvider);
    final collections = allCollectionsAsync.value ?? [];

    return vocabDetailAsync.when(
      loading: () => Scaffold(
        backgroundColor: MewColors.eggshell,
        appBar: AppBar(
          title: const Text('Chi tiết từ vựng'),
        ),
        body: const Center(child: LoadingIndicator()),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: MewColors.eggshell,
        appBar: AppBar(title: const Text('Chi tiết từ vựng')),
        body: EmptyState(
          title: 'Không thể tải từ vựng',
          message: err.toString(),
          actionLabel: 'Quay lại',
          onAction: () => context.pop(),
        ),
      ),
      data: (item) {
        if (item == null) {
          return Scaffold(
            backgroundColor: MewColors.eggshell,
            appBar: AppBar(title: const Text('Chi tiết từ vựng')),
            body: EmptyState(
              title: 'Từ vựng không tồn tại',
              message: 'Từ này có thể đã bị xóa hoặc không tìm thấy trong bộ nhớ.',
              actionLabel: 'Quay lại danh sách',
              onAction: () => context.pop(),
            ),
          );
        }

        return Scaffold(
          backgroundColor: MewColors.eggshell,
          appBar: AppBar(
            title: Text(
              _isEditing ? 'Chỉnh sửa từ vựng' : item.vocabulary.word,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: MewColors.ink,
              ),
            ),
            actions: [
              if (!_isEditing) ...[
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Chỉnh sửa',
                  onPressed: () => _enterEditMode(item),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: MewColors.error),
                  tooltip: 'Xóa từ vựng',
                  onPressed: _isDeleting ? null : () => _handleDelete(item),
                ),
              ] else ...[
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Hủy chỉnh sửa',
                  onPressed: _cancelEditMode,
                ),
              ],
            ],
          ),
          body: _isEditing
              ? _buildEditModeBody(item)
              : _buildViewModeBody(item, collections),
          bottomNavigationBar: _isEditing
              ? Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                    color: MewColors.eggshell,
                    border: Border(
                      top: BorderSide(color: MewColors.stone, width: 1),
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: MewButton.outlined(
                            label: 'Hủy',
                            onPressed: _isSaving ? null : _cancelEditMode,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MewButton.filled(
                            label: 'Lưu thay đổi',
                            isLoading: _isSaving,
                            onPressed: _isSaving ? null : () => _handleSave(item),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildViewModeBody(
    db.VocabularyWithDefinitions item,
    List<db.CollectionWithCount> allCollections,
  ) {
    // Lookup names of assigned collections
    final assignedCollectionNames = item.collectionIds.map((cid) {
      final match = allCollections.where((c) => c.collection.id == cid);
      return match.isNotEmpty ? match.first.collection.name : cid;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card 1: Word Header Card
          MewCard.elevated(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.vocabulary.word,
                            style: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.64,
                              color: MewColors.ink,
                            ),
                          ),
                          if (item.vocabulary.phonetic != null &&
                              item.vocabulary.phonetic!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              item.vocabulary.phonetic!,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: MewColors.ash,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (item.vocabulary.audioUrl != null &&
                        item.vocabulary.audioUrl!.isNotEmpty) ...[
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: MewColors.warmTaupe,
                          foregroundColor: MewColors.ink,
                          shape: const CircleBorder(),
                          side: const BorderSide(color: MewColors.stone),
                        ),
                        icon: Icon(
                          _isPlaying
                              ? Icons.volume_up_rounded
                              : Icons.volume_down_rounded,
                          size: 24,
                        ),
                        onPressed: () => _playAudio(item.vocabulary.audioUrl!),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                // Badges Row
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (item.vocabulary.partOfSpeech != null &&
                        item.vocabulary.partOfSpeech!.isNotEmpty)
                      MewChip(
                        label: item.vocabulary.partOfSpeech!.toUpperCase(),
                      ),
                    if (item.vocabulary.cefrLevel != null &&
                        item.vocabulary.cefrLevel!.isNotEmpty)
                      MewChip(
                        label: item.vocabulary.cefrLevel!,
                        customBgColor: MewColors.ink,
                        customTextColor: MewColors.eggshell,
                      ),
                    if (item.vocabulary.usageRegister != null &&
                        item.vocabulary.usageRegister!.isNotEmpty)
                      MewChip(
                        label: item.vocabulary.usageRegister!,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Card 2: Definitions List Card
          MewCard(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Định nghĩa & Ví dụ',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: MewColors.ink,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: MewColors.stone,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${item.definitions.length}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: MewColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (item.definitions.isEmpty)
                  Text(
                    'Chưa có định nghĩa nào',
                    style: GoogleFonts.inter(color: MewColors.smoke),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: item.definitions.length,
                    separatorBuilder: (_, __) =>
                        const Divider(color: MewColors.stone, height: 24),
                    itemBuilder: (_, idx) {
                      final def = item.definitions[idx];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                margin: const EdgeInsets.only(top: 2, right: 10),
                                decoration: BoxDecoration(
                                  color: MewColors.eggshell,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: MewColors.stone),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${idx + 1}',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: MewColors.smoke,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      def.definitionVi ?? '',
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: MewColors.ink,
                                      ),
                                    ),
                                    if (def.definitionEn != null &&
                                        def.definitionEn!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        def.definitionEn!,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: MewColors.smoke,
                                        ),
                                      ),
                                    ],
                                    if (def.example != null &&
                                        def.example!.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: MewColors.eggshell,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: MewColors.stone),
                                        ),
                                        child: Text(
                                          '"${def.example!}"',
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontStyle: FontStyle.italic,
                                            color: MewColors.smoke,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Card 3: Collections Card
          MewCard(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Bộ sưu tập',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: MewColors.ink,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded,
                          size: 20),
                      onPressed: () => _showCollectionSheet(item),
                      tooltip: 'Quản lý bộ sưu tập',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (assignedCollectionNames.isEmpty)
                  Text(
                    'Chưa gán vào bộ sưu tập nào',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: MewColors.smoke,
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: assignedCollectionNames.map((colName) {
                      return MewChip(
                        label: colName,
                        avatar: const Icon(Icons.folder_outlined, size: 14),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Bottom Action Buttons
          Row(
            children: [
              Expanded(
                child: MewButton.outlined(
                  label: 'Chỉnh sửa',
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: () => _enterEditMode(item),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MewButton.outlined(
                  label: 'Xóa từ',
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: MewColors.error, size: 18),
                  onPressed: _isDeleting ? null : () => _handleDelete(item),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditModeBody(db.VocabularyWithDefinitions item) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Word & Phonetic Input
          MewTextField(
            controller: _wordController,
            label: 'Từ vựng *',
            hintText: 'Nhập từ tiếng Anh',
          ),
          const SizedBox(height: 14),
          MewTextField(
            controller: _phoneticController,
            label: 'Phiên âm IPA',
            hintText: '/.../',
          ),
          const SizedBox(height: 14),

          // POS & CEFR Dropdowns
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Loại từ',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: MewColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _posValue,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: MewColors.eggshell,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: MewColors.stone),
                        ),
                      ),
                      items: AppConstants.partsOfSpeech.map((pos) {
                        return DropdownMenuItem(value: pos, child: Text(pos));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _posValue = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cấp độ CEFR',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: MewColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _cefrValue,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: MewColors.eggshell,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: MewColors.stone),
                        ),
                      ),
                      items: AppConstants.cefrLevels.map((lvl) {
                        return DropdownMenuItem(value: lvl, child: Text(lvl));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _cefrValue = val);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Usage Register
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ngữ cảnh sử dụng',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: MewColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _usageValue,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: MewColors.eggshell,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: MewColors.stone),
                  ),
                ),
                items: AppConstants.usageRegisters.map((reg) {
                  return DropdownMenuItem(value: reg, child: Text(reg));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _usageValue = val);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Definitions Editor Section
          Row(
            children: [
              Text(
                'Danh sách định nghĩa',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: MewColors.ink,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Thêm nghĩa'),
                onPressed: () {
                  setState(() {
                    _editDefinitions.add(_EditableDefinitionItem(definitionVi: ''));
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          for (var i = 0; i < _editDefinitions.length; i++) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: MewColors.warmTaupe,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: MewColors.stone),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Nghĩa #${i + 1}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: MewColors.ink,
                        ),
                      ),
                      const Spacer(),
                      if (_editDefinitions.length > 1)
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              size: 18, color: MewColors.error),
                          onPressed: () {
                            setState(() {
                              final removed = _editDefinitions.removeAt(i);
                              removed.dispose();
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  MewTextField(
                    controller: _editDefinitions[i].viController,
                    label: 'Nghĩa tiếng Việt *',
                    hintText: 'Nhập nghĩa tiếng Việt',
                  ),
                  const SizedBox(height: 10),
                  MewTextField(
                    controller: _editDefinitions[i].enController,
                    label: 'Định nghĩa tiếng Anh (tùy chọn)',
                    hintText: 'Nhập định nghĩa tiếng Anh',
                  ),
                  const SizedBox(height: 10),
                  MewTextField(
                    controller: _editDefinitions[i].exampleController,
                    label: 'Ví dụ minh họa (tùy chọn)',
                    hintText: 'Nhập câu ví dụ',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
