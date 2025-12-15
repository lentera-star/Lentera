import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lentera/auth/supabase_auth_manager.dart';
import 'package:lentera/models/user.dart' as app_user;
import 'package:lentera/services/user_service.dart';
import 'package:lentera/supabase/supabase_config.dart';
import 'package:lentera/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  String? _avatarUrl;
  bool _saving = false;

  final _auth = SupabaseAuthManager();
  final _userService = UserService();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await _auth.getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _fullNameCtrl.text = user.fullName;
        _avatarUrl = user.avatarUrl;
      });
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _usernameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    // Deprecated in favor of avatar shop. Keep for backward compatibility.
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      await _uploadToSupabase(bytes, file.name);
    } catch (e) {
      debugPrint('Image pick error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    }
  }

  Future<void> _uploadToSupabase(Uint8List bytes, String filename) async {
    try {
      final uid = SupabaseConfig.auth.currentUser?.id;
      if (uid == null) return;
      final path = 'public/$uid/${DateTime.now().millisecondsSinceEpoch}_$filename';
      await SupabaseConfig.client.storage
          .from('avatars')
          .uploadBinary(path, bytes, fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true));
      final publicUrl = SupabaseConfig.client.storage.from('avatars').getPublicUrl(path);
      setState(() => _avatarUrl = publicUrl);
    } catch (e) {
      debugPrint('Upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal upload avatar: $e')),
        );
      }
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _saving = true);
    try {
      final uid = _auth.currentUserId;
      if (uid == null) return;
      final cur = await _userService.getUserById(uid);
      if (cur == null) return;
      var updated = cur.copyWith(fullName: _fullNameCtrl.text.trim(), avatarUrl: _avatarUrl);
      await _userService.updateUser(updated);

      // Try to update username if the column exists (fail silently)
      final uname = _usernameCtrl.text.trim();
      if (uname.isNotEmpty) {
        try {
          await SupabaseConfig.client.from('users').update({'username': uname}).eq('id', uid);
        } catch (e) {
          debugPrint('Username not updated (possibly missing column): $e');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil diperbarui')),
        );
        context.pop();
      }
    } catch (e) {
      debugPrint('Save profile error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final branding = theme.extension<BrandingColors>() ?? BrandingColors.light;

    Future<void> _openAvatarShop() async {
      await context.push('/avatar-shop');
      await _load();
    }

    Widget avatar() {
      return Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: branding.lightTealBg,
            backgroundImage: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                ? (_avatarUrl!.startsWith('http')
                    ? NetworkImage(_avatarUrl!)
                    : AssetImage(_avatarUrl!) as ImageProvider)
                : null,
            child: (_avatarUrl == null || _avatarUrl!.isEmpty)
                ? Icon(Icons.person, color: branding.slateBlue, size: 42)
                : null,
          ),
          Positioned(
            right: 4,
            bottom: 4,
            child: GestureDetector(
              onTap: _openAvatarShop,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: branding.deepTeal,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.storefront, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                avatar(),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fullNameCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _usernameCtrl,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: branding.deepTeal),
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text('Simpan', style: theme.textTheme.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
