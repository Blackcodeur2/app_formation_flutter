import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_colors.dart';
import '../../widgets/responsive_layout_wrapper.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as io;

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  bool _isLoading = false;
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nomController = TextEditingController(text: user?.nom);
    _prenomController = TextEditingController(text: user?.prenom);
    _phoneController = TextEditingController(text: user?.telephone);
    _bioController = TextEditingController(text: user?.bio);
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await ref.read(authProvider.notifier).updateProfile(
      nom: _nomController.text,
      prenom: _prenomController.text,
      telephone: _phoneController.text,
      bio: _bioController.text,
      avatar: _imageFile,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour avec succès'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la mise à jour'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le profil', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: ResponsiveLayoutWrapper(
          maxWidth: 600,
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: MyAppColors.secondary,
                      backgroundImage: _imageFile != null 
                          ? (kIsWeb 
                              ? NetworkImage(_imageFile!.path) 
                              : FileImage(io.File(_imageFile!.path)) as ImageProvider)
                          : (ref.watch(authProvider).user?.avatar != null 
                              ? NetworkImage(ref.watch(authProvider).user!.avatar!) 
                              : null) as ImageProvider?,
                      child: _imageFile == null && ref.watch(authProvider).user?.avatar == null 
                          ? const Icon(Icons.person, size: 50, color: Colors.white) 
                          : null,
                    ),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: MyAppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildTextField('Prénom', _prenomController, Icons.person_outline),
                const SizedBox(height: 20),
                _buildTextField('Nom', _nomController, Icons.person_outline),
                const SizedBox(height: 20),
                _buildTextField('Téléphone', _phoneController, Icons.phone_outlined, keyboardType: TextInputType.phone),
                const SizedBox(height: 20),
                _buildTextField('Bio', _bioController, Icons.info_outline, maxLines: 3),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyAppColors.primary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Enregistrer les modifications', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: MyAppColors.primary),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: (value) => value == null || value.isEmpty ? 'Ce champ est requis' : null,
        ),
      ],
    );
  }
}
