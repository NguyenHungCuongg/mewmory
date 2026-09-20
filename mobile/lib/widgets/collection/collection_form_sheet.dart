import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/collection.dart';
import '../../providers/auth_provider.dart';
import '../../providers/services_provider.dart';
import '../common/mew_button.dart';
import '../common/mew_text_field.dart';

class CollectionFormSheet extends ConsumerStatefulWidget {
  final Collection? collection;

  const CollectionFormSheet({
    super.key,
    this.collection,
  });

  static Future<bool?> show(
    BuildContext context, {
    Collection? collection,
  }) {
    final colors = context.mewColors;
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.eggshell,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CollectionFormSheet(collection: collection),
    );
  }

  @override
  ConsumerState<CollectionFormSheet> createState() =>
      _CollectionFormSheetState();
}

class _CollectionFormSheetState extends ConsumerState<CollectionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  bool _isLoading = false;
  String? _errorMessage;

  bool get _isEditMode => widget.collection != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.collection?.name ?? '');
    _descController =
        TextEditingController(text: widget.collection?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    if (user == null) {
      setState(() => _errorMessage = 'Vui lòng đăng nhập lại.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final colService = ref.read(collectionServiceProvider);
      final name = _nameController.text.trim();
      final desc = _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim();

      if (_isEditMode) {
        final updated = widget.collection!.copyWith(
          name: name,
          description: desc,
          updatedAt: DateTime.now(),
        );
        await colService.update(updated);
      } else {
        await colService.create(
          userId: user.id,
          name: name,
          description: desc,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Không thể lưu: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final colors = context.mewColors;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomInset + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.stone,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header title
            Text(
              _isEditMode
                  ? (l10n?.editCollectionTitle ?? 'Chỉnh sửa bộ sưu tập')
                  : (l10n?.createCollectionTitle ?? 'Tạo bộ sưu tập mới'),
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colors.ink,
              ),
            ),
            const SizedBox(height: 16),

            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _errorMessage!,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: colors.error,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Collection Name Field
            MewTextField(
              controller: _nameController,
              label: l10n?.collectionName ?? 'Tên bộ sưu tập',
              hintText: 'Ví dụ: Business English, IELTS Band 7...',
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return l10n?.requiredField ?? 'Vui lòng nhập tên bộ sưu tập';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Collection Description Field
            MewTextField(
              controller: _descController,
              label: l10n?.collectionDesc ?? 'Mô tả (tùy chọn)',
              hintText: 'Ghi chú về mục đích hoặc chủ đề của bộ sưu tập...',
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: MewButton.outlined(
                    label: l10n?.cancel ?? 'Hủy',
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MewButton.filled(
                    label: _isEditMode
                        ? (l10n?.save ?? 'Lưu')
                        : (l10n?.createCollection ?? 'Tạo'),
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _handleSubmit,
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
