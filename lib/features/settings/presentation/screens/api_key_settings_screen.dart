import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
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
  String _activeProviderName = 'None';

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  Future<void> _loadKey() async {
    final configured = await ApiKeyStorageService.getEffectiveProviderKey();
    if (mounted) {
      if (configured.provider == AiVisionProvider.gemini) {
        setState(() {
          _savedMasked = 'AIza••••••••${configured.key.substring(configured.key.length - 4)}';
          _activeProviderName = 'Google Gemini 1.5 Flash';
        });
      } else if (configured.provider == AiVisionProvider.openai) {
        setState(() {
          _savedMasked = 'sk-••••••••${configured.key.substring(configured.key.length - 4)}';
          _activeProviderName = 'OpenAI gpt-4o-mini';
        });
      } else {
        setState(() {
          _savedMasked = null;
          _activeProviderName = 'None';
        });
      }
    }
  }

  Future<void> _save() async {
    final value = _controller.text.trim();
    if (!value.startsWith('sk-') && !value.startsWith('AIza')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid key format. Key should start with "AIza" (Gemini) or "sk-" (OpenAI).'),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    if (value.startsWith('AIza')) {
      await ApiKeyStorageService.saveGeminiKey(value);
    } else {
      await ApiKeyStorageService.saveOpenAiKey(value);
    }
    setState(() {
      _saving = false;
      _controller.clear();
    });
    await _loadKey();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$_activeProviderName API key saved successfully.')),
      );
    }
  }

  Future<void> _clear() async {
    await ApiKeyStorageService.clearKeys();
    await _loadKey();
  }

  Future<void> _launchGeminiKeyUrl() async {
    final Uri url = Uri.parse('https://aistudio.google.com/app/apikey');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AI Vision Key Settings', style: GoogleFonts.outfit(fontWeight: FontWeight.bold))),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add your Google Gemini or OpenAI API key for AI food scanning.',
                style: GoogleFonts.outfit(color: AppColors.lightTextPrimary, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '• Google Gemini API Key (starts with "AIza...") — Recommended, offers a free tier at aistudio.google.com\n'
                '• OpenAI API Key (starts with "sk-...") — Available at platform.openai.com',
                style: GoogleFonts.outfit(color: AppColors.lightTextSecondary, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _launchGeminiKeyUrl,
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text('Get Free Gemini Key (aistudio.google.com)'),
              ),
              const SizedBox(height: 24),
              if (_savedMasked != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0x1A10B981),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_activeProviderName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('Key: $_savedMasked', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade800)),
                          ],
                        ),
                      ),
                      TextButton(onPressed: _clear, child: const Text('Remove')),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              TextField(
                controller: _controller,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'API Key (Google Gemini or OpenAI)',
                  hintText: 'AIza... or sk-...',
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
                      : const Text('Save API Key'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
