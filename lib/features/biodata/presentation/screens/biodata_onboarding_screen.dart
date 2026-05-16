import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gymmy/core/theme/app_colors.dart';
import 'package:gymmy/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymmy/features/biodata/presentation/providers/biodata_provider.dart';

class BiodataOnboardingScreen extends ConsumerStatefulWidget {
  const BiodataOnboardingScreen({super.key});

  @override
  ConsumerState<BiodataOnboardingScreen> createState() =>
      _BiodataOnboardingScreenState();
}

class _BiodataOnboardingScreenState
    extends ConsumerState<BiodataOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _medicalCtrl = TextEditingController();

  DateTime? _birthDate;
  String _gender = 'male';
  String _activityFrequency = 'medium';
  String _goalType = 'fitness';

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _medicalCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your birth date.')),
      );
      return;
    }

    final user = ref.read(authProvider).user;
    if (user == null) return;

    await ref.read(biodataProvider.notifier).submit(
          user: user,
          fullName: _fullNameCtrl.text.trim(),
          birthDate: _birthDate!,
          gender: _gender,
          weight: double.tryParse(_weightCtrl.text) ?? 0,
          height: double.tryParse(_heightCtrl.text) ?? 0,
          activityFrequency: _activityFrequency,
          goalType: _goalType,
          medicalNotes: _medicalCtrl.text.trim(),
        );

    // Router will auto-redirect via userFlowProvider
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(biodataProvider);

    ref.listen<BiodataState>(biodataProvider, (prev, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(next.error!)));
        ref.read(biodataProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        automaticallyImplyLeading: false,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Tell us about yourself',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'This information helps us personalize your gym experience.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.lightSecondaryText,
              ),
            ),
            const SizedBox(height: 32),

            // Full Name
            _SectionLabel('Full Name'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _fullNameCtrl,
              decoration: _inputDecoration('e.g. John Doe'),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 20),

            // Birth Date
            _SectionLabel('Date of Birth'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickBirthDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border.all(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 18,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5)),
                    const SizedBox(width: 12),
                    Text(
                      _birthDate == null
                          ? 'Select birth date'
                          : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _birthDate == null
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Gender
            _SectionLabel('Gender'),
            const SizedBox(height: 8),
            _SegmentedRow(
              options: const ['male', 'female'],
              labels: const ['Male', 'Female'],
              selected: _gender,
              onChanged: (v) => setState(() => _gender = v),
            ),
            const SizedBox(height: 20),

            // Weight & Height
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel('Weight (kg)'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _weightCtrl,
                        decoration: _inputDecoration('e.g. 70'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,1}')),
                        ],
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          final n = double.tryParse(v);
                          if (n == null || n <= 0) return 'Invalid';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel('Height (cm)'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _heightCtrl,
                        decoration: _inputDecoration('e.g. 170'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,1}')),
                        ],
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          final n = double.tryParse(v);
                          if (n == null || n <= 0) return 'Invalid';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Activity Frequency
            _SectionLabel('Daily Activity Level'),
            const SizedBox(height: 8),
            _SegmentedRow(
              options: const ['low', 'medium', 'high'],
              labels: const ['Low', 'Medium', 'High'],
              selected: _activityFrequency,
              onChanged: (v) => setState(() => _activityFrequency = v),
            ),
            const SizedBox(height: 20),

            // Fitness Goal
            _SectionLabel('Fitness Goal'),
            const SizedBox(height: 8),
            _SegmentedRow(
              options: const ['cutting', 'bulking', 'fitness'],
              labels: const ['Cutting', 'Bulking', 'General Fitness'],
              selected: _goalType,
              onChanged: (v) => setState(() => _goalType = v),
            ),
            const SizedBox(height: 20),

            // Medical Notes
            _SectionLabel('Medical Notes (optional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _medicalCtrl,
              decoration: _inputDecoration('Any conditions, injuries, etc.'),
              maxLines: 3,
            ),
            const SizedBox(height: 40),

            // Submit
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.lightPrimaryText,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: state.isLoading ? null : _submit,
              child: state.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Save & Continue',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      );
}

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
      );
}

class _SegmentedRow extends StatelessWidget {
  final List<String> options;
  final List<String> labels;
  final String selected;
  final ValueChanged<String> onChanged;

  const _SegmentedRow({
    required this.options,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: List.generate(options.length, (i) {
        final isSelected = options[i] == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(options[i]),
            child: Container(
              margin: EdgeInsets.only(right: i < options.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.15),
                ),
              ),
              child: Center(
                child: Text(
                  labels[i],
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.lightPrimaryText
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
