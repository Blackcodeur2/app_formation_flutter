import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_colors.dart';
import '../widgets/responsive_layout_wrapper.dart';
import '../screens/root/root_navigation.dart';
import 'providers/auth_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _pageController = PageController();
  int _currentStep = 0;
  final _formKeys = [GlobalKey<FormState>(), GlobalKey<FormState>(), GlobalKey<FormState>()];

  // Step 1: Info Personnelles
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _selectedBirthDate;
  String _selectedGender = 'Masculin';

  // Step 2: Parcours Scolaire
  String _selectedSchoolLevel = 'Secondaire';
  String? _selectedClass;
  final Map<String, List<String>> _schoolClasses = {
    'Primaire': ['SIL', 'CP', 'CE1', 'CE2', 'CM1', 'CM2'],
    'Secondaire': ['6ème', '5ème', '4ème', '3ème', 'Seconde', 'Première', 'Terminale'],
    'Supérieur': ['Licence 1', 'Licence 2', 'Licence 3', 'Master 1', 'Master 2', 'Doctorat'],
  };

  // Step 3: Compte
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _selectedClass = _schoolClasses[_selectedSchoolLevel]![0];
  }

  void _nextStep() {
    if (_formKeys[_currentStep].currentState!.validate()) {
      if (_currentStep < 2) {
        setState(() => _currentStep++);
        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      } else {
        _handleRegister();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pop(context);
    }
  }

  void _handleRegister() async {
    final success = await ref.read(authProvider.notifier).register(
      nom: _nameController.text.trim(),
      prenom: _surnameController.text.trim(),
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      sexe: _selectedGender,
      telephone: _phoneController.text.trim(),
      dateNaissance: _selectedBirthDate?.toIso8601String().split('T')[0] ?? '',
      niveauEtude: _selectedClass!,
      niveauScolaire: _selectedSchoolLevel,
    );

    if (success && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const RootNavigation()),
        (route) => false,
      );
    } else if (mounted) {
      final error = ref.read(authProvider).errorMessage ?? 'Erreur lors de l\'inscription';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
    }
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 15)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: MyAppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedBirthDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStepIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                ],
              ),
            ),
            _buildFooter(authState.status == AuthStatus.loading),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          IconButton(
            onPressed: _previousStep,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50, 
              padding: const EdgeInsets.all(12)
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inscription',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Étape ${_currentStep + 1} sur 3',
                  style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6), fontSize: 13),
                ),
              ],
            ),
          ),
          //ThemeToggleButton(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(3, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
              decoration: BoxDecoration(
                color: index <= _currentStep ? MyAppColors.primary : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200),
                borderRadius: BorderRadius.circular(2)
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKeys[0],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Informations Personnelles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('Nom'),
                      _buildPremiumTextField(controller: _nameController, hint: 'Nom', icon: Icons.person_outline),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('Prénom'),
                      _buildPremiumTextField(controller: _surnameController, hint: 'Prénom', icon: Icons.person_outline),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildFieldLabel('Sexe'),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              dropdownColor: isDark ? Colors.grey.shade900 : Colors.white,
              decoration: _buildInputDecoration(Icons.people_outline),
              items: ['Masculin', 'Féminin'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _selectedGender = val!),
            ),
            const SizedBox(height: 20),
            _buildFieldLabel('Date de naissance'),
            InkWell(
              onTap: _selectBirthDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 20, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6)),
                    const SizedBox(width: 12),
                    Text(
                      _selectedBirthDate == null ? 'Choisir une date' : '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}',
                      style: TextStyle(color: _selectedBirthDate == null ? (isDark ? Colors.white24 : Colors.black38) : (isDark ? Colors.white70 : Colors.black87)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildFieldLabel('Téléphone'),
            _buildPremiumTextField(controller: _phoneController, hint: '6xx xx xx xx', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKeys[1],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Parcours Scolaire', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildFieldLabel('Cycle Scolaire'),
            DropdownButtonFormField<String>(
              value: _selectedSchoolLevel,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              dropdownColor: isDark ? Colors.grey.shade900 : Colors.white,
              decoration: _buildInputDecoration(Icons.account_tree_outlined),
              items: ['Primaire', 'Secondaire', 'Supérieur'].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedSchoolLevel = val!;
                  _selectedClass = _schoolClasses[_selectedSchoolLevel]![0];
                });
              },
            ),
            const SizedBox(height: 24),
            _buildFieldLabel('Classe / Niveau d\'étude'),
            DropdownButtonFormField<String>(
              value: _selectedClass,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              dropdownColor: isDark ? Colors.grey.shade900 : Colors.white,
              decoration: _buildInputDecoration(Icons.school_outlined),
              items: _schoolClasses[_selectedSchoolLevel]!.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _selectedClass = val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKeys[2],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Informations du Compte', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildFieldLabel('Nom d\'utilisateur'),
            _buildPremiumTextField(controller: _usernameController, hint: 'johndoe123', icon: Icons.alternate_email),
            const SizedBox(height: 20),
            _buildFieldLabel('Email'),
            _buildPremiumTextField(controller: _emailController, hint: 'john@example.com', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 20),
            _buildFieldLabel('Mot de passe'),
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: _buildInputDecoration(Icons.lock_outline).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility, size: 20, color: isDark ? Colors.white60 : Colors.black54),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              ),
              validator: (val) => (val?.length ?? 0) < 6 ? 'Min 6 caractères' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: isLoading ? null : _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: MyAppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
          ),
          child: isLoading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(_currentStep == 2 ? 'Finaliser l\'inscription' : 'Continuer', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8))),
    );
  }

  InputDecoration _buildInputDecoration(IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      prefixIcon: Icon(icon, size: 20, color: isDark ? Colors.white60 : Colors.black54),
      filled: true,
      fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade100)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: MyAppColors.primary, width: 1.5)),
      hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
    );
  }

  Widget _buildPremiumTextField({required TextEditingController controller, required String hint, required IconData icon, TextInputType? keyboardType}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: _buildInputDecoration(icon).copyWith(hintText: hint),
      validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
    );
  }
}
