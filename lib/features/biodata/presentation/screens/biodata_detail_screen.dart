import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymmy/core/theme/app_colors.dart';
import 'package:gymmy/features/auth/presentation/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class BiodataDetailScreen extends ConsumerStatefulWidget {
  const BiodataDetailScreen({super.key});
  @override
  ConsumerState<BiodataDetailScreen> createState() => _State();
}

class _State extends ConsumerState<BiodataDetailScreen> {
  bool _loading = true;
  bool _saving = false;
  final _nameCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _gender = 'male';
  String _goal = 'fitness';
  String _activity = 'medium';
  DateTime _birthDate = DateTime(2000, 1, 1);

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _nameCtrl.dispose(); _weightCtrl.dispose(); _heightCtrl.dispose(); _notesCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    final uid = ref.read(authProvider).user?.uid;
    if (uid == null) { setState(() => _loading = false); return; }
    try {
      final doc = await FirebaseFirestore.instance.collection('user_biodata_profiles').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final d = doc.data()!;
        _nameCtrl.text = d['bio_full_name'] ?? '';
        _weightCtrl.text = (d['bio_weight'] as num?)?.toString() ?? '';
        _heightCtrl.text = (d['bio_height'] as num?)?.toString() ?? '';
        _notesCtrl.text = d['bio_medical_notes'] ?? '';
        _gender = d['bio_gender'] ?? 'male';
        _goal = d['bio_goal_type'] ?? 'fitness';
        _activity = d['bio_daily_activity_frequency'] ?? 'medium';
        final bd = d['bio_birth_date'];
        if (bd is Timestamp) _birthDate = bd.toDate();
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final uid = ref.read(authProvider).user?.uid;
    if (uid == null) return;
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('user_biodata_profiles').doc(uid).set({
        'bio_user_uid': uid, 'bio_full_name': _nameCtrl.text, 'bio_birth_date': Timestamp.fromDate(_birthDate),
        'bio_weight': double.tryParse(_weightCtrl.text) ?? 0, 'bio_height': double.tryParse(_heightCtrl.text) ?? 0,
        'bio_daily_activity_frequency': _activity, 'bio_gender': _gender, 'bio_goal_type': _goal,
        'bio_medical_notes': _notesCtrl.text, 'bio_updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Biodata berhasil diperbarui')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) return Scaffold(appBar: AppBar(title: const Text('Biodata Saya')), body: const Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('Biodata Saya', style: TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _field(theme, 'Nama Lengkap', _nameCtrl, Icons.person_outline),
        const SizedBox(height: 16),
        // Birth date
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(context: context, initialDate: _birthDate,
              firstDate: DateTime(1950), lastDate: DateTime.now());
            if (picked != null) setState(() => _birthDate = picked);
          },
          child: InputDecorator(
            decoration: InputDecoration(labelText: 'Tanggal Lahir', prefixIcon: const Icon(Icons.cake_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.15)))),
            child: Text(DateFormat('dd MMMM yyyy', 'id_ID').format(_birthDate)),
          ),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _field(theme, 'Berat (kg)', _weightCtrl, Icons.monitor_weight_outlined, num: true)),
          const SizedBox(width: 12),
          Expanded(child: _field(theme, 'Tinggi (cm)', _heightCtrl, Icons.height, num: true)),
        ]),
        const SizedBox(height: 16),
        _dropdown(theme, 'Jenis Kelamin', _gender, {'male': 'Laki-laki', 'female': 'Perempuan'}, (v) => setState(() => _gender = v!)),
        const SizedBox(height: 16),
        _dropdown(theme, 'Tujuan Fitness', _goal, {'cutting': 'Cutting', 'bulking': 'Bulking', 'fitness': 'Fitness'}, (v) => setState(() => _goal = v!)),
        const SizedBox(height: 16),
        _dropdown(theme, 'Aktivitas Harian', _activity, {'low': 'Rendah', 'medium': 'Sedang', 'high': 'Tinggi'}, (v) => setState(() => _activity = v!)),
        const SizedBox(height: 16),
        _field(theme, 'Catatan Medis', _notesCtrl, Icons.medical_information_outlined, maxLines: 3),
        const SizedBox(height: 32),
        SizedBox(width: double.infinity, child: FilledButton(
          onPressed: _saving ? null : _save,
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.darkBackground,
            padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: _saving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Simpan Biodata'),
        )),
      ])),
    );
  }

  Widget _field(ThemeData theme, String label, TextEditingController ctrl, IconData icon, {bool num = false, int maxLines = 1}) {
    return TextField(controller: ctrl, maxLines: maxLines, keyboardType: num ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label, prefixIcon: maxLines == 1 ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.15)))));
  }

  Widget _dropdown(ThemeData theme, String label, String value, Map<String, String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(initialValue: value, onChanged: onChanged,
      decoration: InputDecoration(labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.15)))),
      items: items.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList());
  }
}
