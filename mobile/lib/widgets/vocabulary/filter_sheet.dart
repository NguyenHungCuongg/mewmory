import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../providers/vocabulary_provider.dart';
import '../common/mew_button.dart';
import '../common/mew_chip.dart';

class FilterSheet extends ConsumerStatefulWidget {
  const FilterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: MewColors.eggshell,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const FilterSheet(),
    );
  }

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  late String? _selectedCefr;
  late String? _selectedPos;
  late String? _selectedUsage;
  late String _selectedSortBy;
  late bool _ascending;

  @override
  void initState() {
    super.initState();
    final filters = ref.read(vocabularyFilterProvider);
    _selectedCefr = filters.cefrLevel;
    _selectedPos = filters.partOfSpeech;
    _selectedUsage = filters.usageRegister;
    _selectedSortBy = filters.sortBy;
    _ascending = filters.ascending;
  }

  void _applyFilters() {
    final notifier = ref.read(vocabularyFilterProvider.notifier);

    // Update CEFR
    if (_selectedCefr != ref.read(vocabularyFilterProvider).cefrLevel) {
      notifier.setCefrLevel(_selectedCefr);
    }
    // Update POS
    if (_selectedPos != ref.read(vocabularyFilterProvider).partOfSpeech) {
      notifier.setPartOfSpeech(_selectedPos);
    }
    // Update Usage
    if (_selectedUsage != ref.read(vocabularyFilterProvider).usageRegister) {
      notifier.setUsageRegister(_selectedUsage);
    }
    // Update Sort
    notifier.setSorting(_selectedSortBy, ascending: _ascending);

    Navigator.of(context).pop();
  }

  void _resetFilters() {
    ref.read(vocabularyFilterProvider.notifier).resetFilters();
    setState(() {
      _selectedCefr = null;
      _selectedPos = null;
      _selectedUsage = null;
      _selectedSortBy = 'created_at';
      _ascending = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: MewColors.stone,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            const SizedBox(height: 16),

            // Header: Title + Reset
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bộ lọc & Sắp xếp',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: MewColors.ink,
                    ),
                  ),
                  TextButton(
                    onPressed: _resetFilters,
                    child: Text(
                      'Xóa bộ lọc',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: MewColors.smoke,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: MewColors.stone, height: 1),

            // Filter Options Body
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // Section 1: CEFR Level
                  _buildSectionTitle('Cấp độ (CEFR)'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppConstants.cefrLevels.map((level) {
                      final isSelected = _selectedCefr == level;
                      return MewChip(
                        label: level,
                        isSelected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCefr = selected ? level : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Section 2: Part of Speech
                  _buildSectionTitle('Loại từ'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppConstants.partsOfSpeech.map((pos) {
                      final isSelected = _selectedPos == pos;
                      return MewChip(
                        label: pos,
                        isSelected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedPos = selected ? pos : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Section 3: Usage Register
                  _buildSectionTitle('Ngữ cảnh sử dụng'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppConstants.usageRegisters.map((reg) {
                      final isSelected = _selectedUsage == reg;
                      return MewChip(
                        label: reg,
                        isSelected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedUsage = selected ? reg : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Section 4: Sort By
                  _buildSectionTitle('Sắp xếp theo'),
                  _buildSortTile(
                    title: 'Mới nhất',
                    selected: _selectedSortBy == 'created_at' && !_ascending,
                    onTap: () {
                      setState(() {
                        _selectedSortBy = 'created_at';
                        _ascending = false;
                      });
                    },
                  ),
                  _buildSortTile(
                    title: 'Cũ nhất',
                    selected: _selectedSortBy == 'created_at' && _ascending,
                    onTap: () {
                      setState(() {
                        _selectedSortBy = 'created_at';
                        _ascending = true;
                      });
                    },
                  ),
                  _buildSortTile(
                    title: 'Từ A đến Z',
                    selected: _selectedSortBy == 'word' && _ascending,
                    onTap: () {
                      setState(() {
                        _selectedSortBy = 'word';
                        _ascending = true;
                      });
                    },
                  ),
                  _buildSortTile(
                    title: 'Từ Z đến A',
                    selected: _selectedSortBy == 'word' && !_ascending,
                    onTap: () {
                      setState(() {
                        _selectedSortBy = 'word';
                        _ascending = false;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Bottom Apply Action
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: MewButton.filled(
                label: 'Áp dụng',
                onPressed: _applyFilters,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: MewColors.ink,
        ),
      ),
    );
  }

  Widget _buildSortTile({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected ? MewColors.ink : MewColors.graphite,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check_circle_rounded, color: MewColors.ink, size: 20)
          : null,
      onTap: onTap,
    );
  }
}
