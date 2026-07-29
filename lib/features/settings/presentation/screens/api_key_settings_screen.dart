import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/api_key_storage_service.dart';
import '../../../../core/theme/app_colors.dart';

class ApiKeySettingsScreen extends StatefulWidget {
  const ApiKeySettingsScreen({super.key});

  @override
  State<ApiKeySettingsScreen> createState() => _ApiKeySettingsScreenState();
}

class _ApiKeySettingsScreenState extends State<ApiKeySettingsScreen> {
  final _controller = TextEditingController();
  bool _obscure = true;
  bool _saving = false;
  String? _savedMasked;

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  Future<void> _loadKey() async {
    final key = await ApiKeyStorageService.getKey();
    if (key != null && key.length > 4 && mounted) {
      setState(() => _savedMasked = 'sk-••••••••${key.substring(key.length - 4)}');
    }
  }

  Future<void> _save() async {
    final value = _controller.text.trim();
    if (!value.startsWith('sk-')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('That doesn\'t look like a valid OpenAI key (should start with "sk-").')),
      );
      return;
    }
    setState(() => _saving = true);
    await ApiKeyStorageService.saveKey(value);
    setState(() {
      _saving = false;
      _controller.clear();
    });
    await _loadKey();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API key saved.')),
      );
    }
  }

  Future<void> _clear() async {
    await ApiKeyStorageService.clearKey();
    setState(() => _savedMasked = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AI Vision Key', style: GoogleFonts.outfit(fontWeight: FontWeight.bold))),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add your own OpenAI API key to run food scanning. '
              'Get one at platform.openai.com/api-keys — make sure the '
              'project has billing/credits enabled.',
              style: GoogleFonts.outfit(color: AppColors.lightTextSecondary),
            ),
            const SizedBox(height: 20),
            if (_savedMasked != null) ...[
              Row(
                children: [
                  Expanded(child: Text('Current key: $_savedMasked', style: GoogleFonts.outfit(fontWeight: FontWeight.w600))),
                  TextButton(onPressed: _clear, child: const Text('Remove')),
                ],
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _controller,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'OpenAI API Key',
                hintText: 'sk-...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save Key'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
