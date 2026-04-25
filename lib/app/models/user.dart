class User {
  final int id;
  final String nom;
  final String prenom;
  final String username;
  final String email;
  final String? sexe;
  final String? bio;
  final String role;
  final String? avatar;
  final String? telephone;
  final String? dateNaissance;
  final String? niveauEtude;
  final String? niveauScolaire;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.username,
    required this.email,
    this.sexe,
    this.bio,
    required this.role,
    this.avatar,
    this.telephone,
    this.dateNaissance,
    this.niveauEtude,
    this.niveauScolaire,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      sexe: json['sexe'],
      bio: json['bio'],
      role: json['role'] ?? 'student',
      avatar: json['avatar'],
      telephone: json['telephone'],
      dateNaissance: json['date_naissance'],
      niveauEtude: json['niveau_etude'],
      niveauScolaire: json['niveau_scolaire'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'username': username,
      'email': email,
      'sexe': sexe,
      'bio': bio,
      'role': role,
      'avatar': avatar,
      'telephone': telephone,
      'date_naissance': dateNaissance,
      'niveau_etude': niveauEtude,
      'niveau_scolaire': niveauScolaire,
    };
  }
}
