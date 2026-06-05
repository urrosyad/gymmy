import 'package:flutter/material.dart';
import 'package:gymmy/core/widgets/gymmy_app_bar_logo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymmy/core/theme/app_colors.dart';
import 'package:gymmy/core/widgets/gymmy_button.dart';
import 'package:gymmy/core/widgets/gymmy_input.dart';
import 'package:gymmy/features/auth/presentation/providers/auth_provider.dart';
import 'package:gymmy/features/gym_tenant/presentation/providers/gym_tenant_provider.dart';

class OwnerGymSetupScreen extends ConsumerStatefulWidget {
  const OwnerGymSetupScreen({super.key});

  @override
  ConsumerState<OwnerGymSetupScreen> createState() =>
      _OwnerGymSetupScreenState();
}

class _OwnerGymSetupScreenState extends ConsumerState<OwnerGymSetupScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 5;

  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  final _formKey4 = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _dailyPriceCtrl = TextEditingController();
  final _memberPriceCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController();
  final _facilityCtrl = TextEditingController();

  final List<String> _facilities = [];

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _cityCtrl.dispose();
    _locationCtrl.dispose();
    _dailyPriceCtrl.dispose();
    _memberPriceCtrl.dispose();
    _hoursCtrl.dispose();
    _facilityCtrl.dispose();
    super.dispose();
  }

  void _addFacility() {
    final val = _facilityCtrl.text.trim();
    if (val.isEmpty) return;
    setState(() {
      _facilities.add(val);
      _facilityCtrl.clear();
    });
  }

  void _removeFacility(int index) {
    setState(() => _facilities.removeAt(index));
  }

  bool _validateCurrentPage() {
    switch (_currentPage) {
      case 0:
        return _formKey1.currentState?.validate() ?? false;
      case 1:
        return _formKey2.currentState?.validate() ?? false;
      case 2:
        return _formKey3.currentState?.validate() ?? false;
      case 3:
        if (!(_formKey4.currentState?.validate() ?? false)) return false;
        if (_facilities.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tambahkan minimal satu fasilitas')),
          );
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _nextPage() {
    if (!_validateCurrentPage()) return;
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submit() async {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    await ref
        .read(gymSetupProvider.notifier)
        .submit(
          ownerUid: user.uid,
          name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          city: _cityCtrl.text.trim(),
          location: _locationCtrl.text.trim(),
          dailyPrice: double.tryParse(_dailyPriceCtrl.text) ?? 0,
          membershipPrice: double.tryParse(_memberPriceCtrl.text) ?? 0,
          facilities: List<String>.from(_facilities),
          operationalHours: _hoursCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(gymSetupProvider);

    ref.listen<GymSetupState>(gymSetupProvider, (prev, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(next.error!)));
        ref.read(gymSetupProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const GymmyAppBarLogo(),
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentPage + 1) / _totalPages,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics:
                    const NeverScrollableScrollPhysics(), // Force using buttons
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                children: [
                  _buildStep1(theme),
                  _buildStep2(theme),
                  _buildStep3(theme),
                  _buildStep4(theme),
                  _buildStep5(theme, state),
                ],
              ),
            ),
            _buildBottomBar(theme, state),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(
              theme,
              'Informasi Dasar',
              'Mulai dengan nama dan deskripsi gym kamu.',
            ),
            const SizedBox(height: 32),
            GymmyInput(
              label: 'Nama Gym',
              hintText: 'cth. Iron Republic Gym',
              controller: _nameCtrl,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 24),
            Text(
              'Deskripsi',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descCtrl,
              decoration: _deco('Deskripsi singkat tentang gym kamu'),
              maxLines: 4,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(theme, 'Lokasi', 'Di mana lokasi gym kamu?'),
            const SizedBox(height: 32),
            GymmyInput(
              label: 'Kota',
              hintText: 'cth. Jakarta',
              controller: _cityCtrl,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 24),
            Text(
              'Alamat Lengkap / Lokasi',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _locationCtrl,
              decoration: _deco('cth. Jl. Sudirman No. 10, Jakarta'),
              maxLines: 3,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(theme, 'Harga', 'Tentukan harga harian dan bulanan.'),
            const SizedBox(height: 32),
            GymmyInput(
              label: 'Harga Harian (Rp)',
              hintText: 'cth. 50000',
              controller: _dailyPriceCtrl,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Wajib diisi';
                if (double.tryParse(v) == null) {
                  return 'Harus berupa angka yang valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            GymmyInput(
              label: 'Harga Membership (Rp)',
              hintText: 'cth. 350000',
              controller: _memberPriceCtrl,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Wajib diisi';
                if (double.tryParse(v) == null) {
                  return 'Harus berupa angka yang valid';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(
              theme,
              'Fasilitas & Jam Operasional',
              'Kapan gym buka dan apa yang kamu tawarkan?',
            ),
            const SizedBox(height: 32),
            GymmyInput(
              label: 'Jam Operasional',
              hintText: 'cth. 06:00 - 22:00',
              controller: _hoursCtrl,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 24),
            Text(
              'Fasilitas',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _facilityCtrl,
                    decoration: _deco('cth. Beban Bebas, Kardio'),
                    onFieldSubmitted: (_) => _addFacility(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addFacility,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            if (_facilities.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _facilities.asMap().entries.map((entry) {
                  return Chip(
                    label: Text(entry.value),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => _removeFacility(entry.key),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStep5(ThemeData theme, GymSetupState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(
            theme,
            'Tinjau & Konfirmasi',
            'Pastikan semua informasi sudah benar sebelum mendaftarkan gym kamu.',
          ),
          const SizedBox(height: 32),
          _summaryRow(theme, 'Nama', _nameCtrl.text),
          _summaryRow(theme, 'Kota', _cityCtrl.text),
          _summaryRow(theme, 'Harga Harian', 'Rp ${_dailyPriceCtrl.text}'),
          _summaryRow(theme, 'Harga Membership', 'Rp ${_memberPriceCtrl.text}'),
          _summaryRow(theme, 'Jam Operasional', _hoursCtrl.text),
          const SizedBox(height: 16),
          Text(
            'Fasilitas',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(_facilities.join(', '), style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _summaryRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.lightSecondaryText,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(ThemeData theme, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.lightSecondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(ThemeData theme, GymSetupState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton(
              onPressed: state.isLoading ? null : _prevPage,
              child: const Text('Kembali'),
            )
          else
            const SizedBox(width: 64),
          if (_currentPage < _totalPages - 1)
            FilledButton(onPressed: _nextPage, child: const Text('Lanjut'))
          else
            GymmyButton(
              text: 'Daftarkan Gym',
              isLoading: state.isLoading,
              onPressed: () {
                _submit();
              },
            ),
        ],
      ),
    );
  }

  InputDecoration _deco(String hint) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: theme.colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: theme.colorScheme.error),
      ),
    );
  }
}
