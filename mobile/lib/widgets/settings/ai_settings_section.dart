import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user_settings.dart';
import '../../providers/settings_provider.dart';
import '../../utils/mew_toast.dart';
import '../common/mew_button.dart';
import '../common/mew_card.dart';
import '../common/mew_text_field.dart';

class AiSettingsSection extends ConsumerStatefulWidget {
  final String userId;
  final UserSettings? initialSettings;

  const AiSettingsSection({
    super.key,
    required this.userId,
    this.initialSettings,
  });

  @override
  ConsumerState<AiSettingsSection> createState() => _AiSettingsSectionState();
}

class _AiSettingsSectionState extends ConsumerState<AiSettingsSection> {
  late String _selectedProvider;
  late final TextEditingController _modelController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedProvider = widget.initialSettings?.aiProvider ?? 'gemini';
    _modelController =
        TextEditingController(text: widget.initialSettings?.aiModel ?? '');
  }

  @override
  void didUpdateWidget(covariant AiSettingsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSettings != null &&
        widget.initialSettings != oldWidget.initialSettings) {
      _selectedProvider = widget.initialSettings!.aiProvider;
      _modelController.text = widget.initialSettings!.aiModel ?? '';
    }
  }

  @override
  void dispose() {
    _modelController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      final modelText = _modelController.text.trim();
      await ref
          .read(userSettingsNotifierProvider.notifier)
          .updateAiSettings(
            aiProvider: _selectedProvider,
            aiModel: modelText.isEmpty ? null : modelText,
          );

      if (mounted) {
        MewToast.showSuccess(context, 'Đã lưu cấu hình AI thành công');
      }
    } catch (e) {
      if (mounted) {
        MewToast.showError(context, e, prefix: 'Không thể lưu cấu hình');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.mewColors;
    final l10n = AppLocalizations.of(context);

    return MewCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.eggshell,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.stone),
                ),
                child: Icon(
                  Icons.psychology_outlined,
                  size: 20,
                  color: colors.violetSpark,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n?.aiConfigTitle ?? 'Cấu hình AI',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Chọn mô hình và nhà cung cấp AI dùng cho việc phân loại từ vựng, cấp độ CEFR và dịch thuật.',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: colors.smoke,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Provider selector
          Text(
            l10n?.aiProvider ?? 'Nhà cung cấp (AI Provider)',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: colors.eggshell,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.stone),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedProvider,
                isExpanded: true,
                dropdownColor: colors.warmTaupe,
                icon: Icon(Icons.arrow_drop_down, color: colors.smoke),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: colors.ink,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'gemini',
                    child: Text(
                      'Google Gemini (Mặc định)',
                      style: GoogleFonts.inter(color: colors.ink),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'openrouter',
                    child: Text(
                      'OpenRouter',
                      style: GoogleFonts.inter(color: colors.ink),
                    ),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedProvider = val);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // AI Model Field
          MewTextField(
            controller: _modelController,
            label: l10n?.aiModel ?? 'Mô hình AI (Tùy chọn)',
            hintText: _selectedProvider == 'gemini'
                ? 'gemini-1.5-flash (mặc định)'
                : 'meta-llama/llama-3.1-8b-instruct',
          ),
          const SizedBox(height: 20),

          // Save button
          MewButton.filled(
            label: 'Lưu cấu hình',
            isLoading: _isSaving,
            onPressed: _isSaving ? null : _handleSave,
          ),
        ],
      ),
    );
  }
}
