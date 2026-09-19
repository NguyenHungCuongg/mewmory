import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/constants.dart';
import '../config/theme.dart';
import '../models/definition.dart';
import '../providers/auth_provider.dart';
import '../providers/connectivity_provider.dart';
import '../providers/lookup_provider.dart';
import '../providers/services_provider.dart';
import '../widgets/common/loading_indicator.dart';
import '../widgets/common/mew_button.dart';
import '../widgets/common/mew_text_field.dart';
import '../widgets/common/offline_banner.dart';
import '../widgets/vocabulary/duplicate_warning.dart';
import '../widgets/vocabulary/lookup_result_view.dart';

class AddWordPage extends ConsumerStatefulWidget {
  const AddWordPage({super.key});

  @override
  ConsumerState<AddWordPage> createState() => _AddWordPageState();
}

class _AddWordPageState extends ConsumerState<AddWordPage> {
  final _wordController = TextEditingController();

  // Manual fallback fields (for offline or manual input)
  final _manualPhoneticController = TextEditingController();
  final _manualDefViController = TextEditingController();
  final _manualDefEnController = TextEditingController();
  final _manualExampleController = TextEditingController();
  String _manualPos = 'noun';
  String _manualCefr = 'B1';

  bool _isSaving = false;
  bool _isDuplicate = false;
  bool _manualMode = false;

  @override
  void dispose() {
    _wordController.dispose();
    _manualPhoneticController.dispose();
    _manualDefViController.dispose();
    _manualDefEnController.dispose();
    _manualExampleController.dispose();
    super.dispose();
  }

  Future<void> _handleLookup() async {
    final word = _wordController.text.trim();
    if (word.isEmpty) return;

    FocusScope.of(context).unfocus();

    // Check duplicate in local Drift cache first
    final user = ref.read(currentUserProvider);
    if (user != null) {
      final existing = await ref
          .read(vocabularyServiceProvider)
          .getAll(user.id, searchQuery: word);
      setState(() {
        _isDuplicate = existing.any((item) =>
            item.vocabulary.word.toLowerCase() == word.toLowerCase());
      });
    }

    await ref.read(lookupProvider.notifier).lookupWord(word);
  }

  Future<void> _handleSave() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final word = _wordController.text.trim();
    if (word.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập từ tiếng Anh.'),
          backgroundColor: MewColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final vocabService = ref.read(vocabularyServiceProvider);
      final colService = ref.read(collectionServiceProvider);
      final now = DateTime.now();

      if (_manualMode) {
        // Save manual input
        if (_manualDefViController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vui lòng nhập nghĩa tiếng Việt.'),
              backgroundColor: MewColors.error,
            ),
          );
          setState(() => _isSaving = false);
          return;
        }

        final def = Definition(
          id: '',
          vocabularyId: '',
          definitionVi: _manualDefViController.text.trim(),
          definitionEn: _manualDefEnController.text.trim().isNotEmpty
              ? _manualDefEnController.text.trim()
              : null,
          example: _manualExampleController.text.trim().isNotEmpty
              ? _manualExampleController.text.trim()
              : null,
          sortOrder: 0,
          createdAt: now,
          updatedAt: now,
        );

        await vocabService.create(
          userId: user.id,
          word: word,
          phonetic: _manualPhoneticController.text.trim().isNotEmpty
              ? _manualPhoneticController.text.trim()
              : null,
          partOfSpeech: _manualPos,
          cefrLevel: _manualCefr,
          definitions: [def],
        );
      } else {
        // Save AI Lookup results
        final lookupState = ref.read(lookupProvider);
        if (lookupState.selectedDefinitionsCount == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vui lòng chọn ít nhất một nghĩa để lưu.'),
              backgroundColor: MewColors.error,
            ),
          );
          setState(() => _isSaving = false);
          return;
        }

        final defsToSave = <Definition>[];
        String? primaryPos;
        String? primaryCefr;
        String? primaryUsage;

        for (final meaning in lookupState.editableMeanings) {
          for (final d in meaning.definitions) {
            if (d.isSelected) {
              primaryPos ??= meaning.partOfSpeech;
              primaryCefr ??= meaning.cefrLevel;
              primaryUsage ??= meaning.usageRegister;

              defsToSave.add(
                Definition(
                  id: '',
                  vocabularyId: '',
                  definitionVi: d.definitionVi,
                  definitionEn: d.definitionEn,
                  example: d.example,
                  sortOrder: d.sortOrder,
                  createdAt: now,
                  updatedAt: now,
                ),
              );
            }
          }
        }

        // Handle collection links
        final collectionIds = <String>[];
        final existingCols = await colService.getAll(user.id);

        for (final colName in lookupState.selectedCollectionIds) {
          final matched = existingCols.where(
            (c) => c.collection.name.toLowerCase() == colName.toLowerCase(),
          );

          if (matched.isNotEmpty) {
            collectionIds.add(matched.first.collection.id);
          } else {
            // Auto-create AI-suggested collection
            final createdCol = await colService.create(
              userId: user.id,
              name: colName,
              isAiGenerated: true,
            );
            collectionIds.add(createdCol.id);
          }
        }

        await vocabService.create(
          userId: user.id,
          word: word,
          phonetic: lookupState.result?.phonetic,
          audioUrl: lookupState.result?.audioUrl,
          partOfSpeech: primaryPos,
          cefrLevel: primaryCefr,
          usageRegister: primaryUsage,
          definitions: defsToSave,
          collectionIds: collectionIds,
        );
      }

      if (mounted) {
        ref.read(lookupProvider.notifier).reset();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã lưu từ "$word" thành công!'),
            backgroundColor: MewColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể lưu từ vựng: $e'),
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

  @override
  Widget build(BuildContext context) {
    final lookupState = ref.watch(lookupProvider);
    final isOnline = ref.watch(connectivityProvider).value ?? true;
    final isLookupLoading = lookupState.status == LookupStatus.loading;
    final hasLookupResult = lookupState.status == LookupStatus.success;

    return Scaffold(
      backgroundColor: MewColors.eggshell,
      appBar: AppBar(
        title: Text(
          'Thêm từ mới',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: MewColors.ink,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _manualMode = !_manualMode);
            },
            child: Text(
              _manualMode ? 'Dùng AI tra cứu' : 'Nhập thủ công',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: MewColors.ink,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          if (!isOnline) const OfflineBanner(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Search Bar + Lookup Action
                  Row(
                    children: [
                      Expanded(
                        child: MewTextField(
                          controller: _wordController,
                          hintText: 'Nhập từ tiếng Anh (ví dụ: resilient)',
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) => _handleLookup(),
                        ),
                      ),
                      if (!_manualMode) ...[
                        const SizedBox(width: 10),
                        MewButton.filled(
                          label: 'Tra cứu',
                          isLoading: isLookupLoading,
                          isFullWidth: false,
                          height: 48,
                          onPressed: isLookupLoading ? null : _handleLookup,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Duplicate warning if detected
                  if (_isDuplicate)
                    DuplicateWarning(word: _wordController.text.trim()),

                  // Mode 1: Manual Input Form
                  if (_manualMode) ...[
                    _buildManualForm(),
                  ]
                  // Mode 2: Loading Indicator
                  else if (isLookupLoading) ...[
                    const SizedBox(height: 60),
                    const LoadingIndicator(size: 36),
                    const SizedBox(height: 16),
                    Text(
                      'Đang tra từ điển & phân tích AI...',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: MewColors.smoke,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ]
                  // Mode 3: Error Message
                  else if (lookupState.status == LookupStatus.error) ...[
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: MewColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: MewColors.error.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: MewColors.error, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            lookupState.errorMessage ?? 'Không tìm thấy từ vựng',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: MewColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          MewButton.outlined(
                            label: 'Chuyển sang nhập thủ công',
                            onPressed: () {
                              setState(() => _manualMode = true);
                            },
                          ),
                        ],
                      ),
                    ),
                  ]
                  // Mode 4: Success Results
                  else if (hasLookupResult) ...[
                    const LookupResultView(),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      // Bottom Persistent Save Button
      bottomSheet: (hasLookupResult || _manualMode)
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: MewColors.eggshell,
                border: Border(
                  top: BorderSide(color: MewColors.stone, width: 1),
                ),
              ),
              child: SafeArea(
                child: MewButton.filled(
                  label: 'Lưu từ vựng',
                  isLoading: _isSaving,
                  onPressed: _isSaving ? null : _handleSave,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildManualForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MewTextField(
          controller: _manualPhoneticController,
          label: 'Phiên âm IPA (tùy chọn)',
          hintText: '/rɪˈzɪliənt/',
        ),
        const SizedBox(height: 14),
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
                    initialValue: _manualPos,
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
                      if (val != null) setState(() => _manualPos = val);
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
                    initialValue: _manualCefr,
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
                      if (val != null) setState(() => _manualCefr = val);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        MewTextField(
          controller: _manualDefViController,
          label: 'Nghĩa tiếng Việt',
          hintText: 'Ví dụ: Kiên cường, mau hồi phục',
        ),
        const SizedBox(height: 14),
        MewTextField(
          controller: _manualDefEnController,
          label: 'Định nghĩa tiếng Anh (tùy chọn)',
          hintText: 'Ví dụ: Able to withstand or recover quickly',
        ),
        const SizedBox(height: 14),
        MewTextField(
          controller: _manualExampleController,
          label: 'Câu ví dụ (tùy chọn)',
          hintText: 'Ví dụ: She has a resilient personality.',
          maxLines: 2,
        ),
      ],
    );
  }
}
