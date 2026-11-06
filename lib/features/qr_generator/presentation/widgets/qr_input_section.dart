import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';

class QrInputSection extends StatefulWidget {
  final ValueChanged<String> onGenerate;

  const QrInputSection({super.key, required this.onGenerate});

  @override
  State<QrInputSection> createState() => _QrInputSectionState();
}

class _QrInputSectionState extends State<QrInputSection> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() {
      final hasTextNow = _controller.text.trim().isNotEmpty;
      if (hasTextNow != _hasText) {
        setState(() => _hasText = hasTextNow);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    widget.onGenerate(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          maxLines: 1,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            labelText: AppStrings.inputLabel,
            hintText: AppStrings.inputHint,
            prefixIcon: const Icon(
              Icons.link_rounded,
              color: AppColors.primary,
              size: 22,
            ),
            suffixIcon: _hasText
                ? IconButton(
                    icon: const Icon(
                      Icons.cancel_rounded,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _hasText = false);
                    },
                    tooltip: 'Clear',
                  )
                : null,
          ),
        ),
        const SizedBox(height: AppDimensions.md),
        ElevatedButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.qr_code_rounded, size: 22),
          label: const Text(AppStrings.generateButton),
        ),
      ],
    );
  }
}
