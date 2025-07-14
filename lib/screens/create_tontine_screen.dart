import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateTontineScreen extends StatefulWidget {
  const CreateTontineScreen({super.key});

  @override
  State<CreateTontineScreen> createState() => _CreateTontineScreenState();
}

class _CreateTontineScreenState extends State<CreateTontineScreen> {
  // Contrôleurs pour les champs de texte
  final _nomTontineController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _montantCotisationController = TextEditingController();
  final _nombreMembresMaxController = TextEditingController();

  // Liste des fréquences de cotisation possibles
  final List<String> _frequenceOptions = [
    'Journalière',
    'Hebdomadaire',
    'Mensuelle',
    'Trimestrielle',
    'Annuelle',
  ];
  String? _selectedFrequence; // Fréquence sélectionnée

  bool _isLoading = false;
  String _message = ''; // Pour afficher les messages de succès ou d'erreur

  // TODO: Pour une application réelle, l'ID de l'utilisateur devrait être récupéré
  // depuis la session de l'utilisateur (ex: SharedPreferences après la connexion).
  // Pour le test, nous utilisons un ID fixe.
  final int _currentUserId =
      2; // REMPLACER PAR L'ID DE L'UTILISATEUR RÉELLEMENT CONNECTÉ

  @override
  void dispose() {
    _nomTontineController.dispose();
    _descriptionController.dispose();
    _montantCotisationController.dispose();
    _nombreMembresMaxController.dispose();
    super.dispose();
  }

  Future<void> _createTontine() async {
    // Validation des champs
    if (_nomTontineController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _montantCotisationController.text.isEmpty ||
        _nombreMembresMaxController.text.isEmpty ||
        _selectedFrequence == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
      return;
    }

    final double? montant = double.tryParse(_montantCotisationController.text);
    final int? nombreMembres = int.tryParse(_nombreMembresMaxController.text);

    if (montant == null || montant <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un montant de cotisation valide.'),
        ),
      );
      return;
    }
    if (nombreMembres == null || nombreMembres <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un nombre de membres maximum valide.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final response = await http.post(
        Uri.parse(
          'http://localhost/api/create_tontine.php',
        ), // URL du nouveau script PHP
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nom_tontine': _nomTontineController.text.trim(),
          'description': _descriptionController.text.trim(),
          'montant_cotisation': montant,
          'frequence_cotisation': _selectedFrequence,
          'nombre_membres_max': nombreMembres,
          'createur_id': _currentUserId, // L'ID de l'utilisateur créateur
        }),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        setState(() {
          _message = data['message'];
          _nomTontineController.clear();
          _descriptionController.clear();
          _montantCotisationController.clear();
          _nombreMembresMaxController.clear();
          _selectedFrequence = null; // Réinitialiser la sélection
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['message'])));
        // Optionnel: Naviguer vers le tableau de bord ou la page de détail de la tontine créée
        // Navigator.pop(context); // Ou Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        setState(() {
          _message = data['message'] ?? 'Échec de la création de la tontine.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message'] ?? 'Échec de la création de la tontine.',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _message =
            'Erreur de connexion: ${e.toString()}. Vérifiez votre serveur PHP.';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
      print('Erreur lors de la création de la tontine: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer une Tontine'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          // Permet de faire défiler si le contenu dépasse la taille de l'écran
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: _nomTontineController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la Tontine',
                  prefixIcon: Icon(Icons.group),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description de la Tontine',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3, // Permet plusieurs lignes pour la description
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _montantCotisationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Montant de cotisation (FCFA)',
                  prefixIcon: Icon(Icons.money),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedFrequence,
                decoration: const InputDecoration(
                  labelText: 'Fréquence de cotisation',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                items: _frequenceOptions.map((String frequence) {
                  return DropdownMenuItem<String>(
                    value: frequence,
                    child: Text(frequence),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedFrequence = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nombreMembresMaxController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nombre de membres maximum',
                  prefixIcon: Icon(Icons.people),
                ),
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _createTontine,
                      child: const Text('Créer la Tontine'),
                    ),
              const SizedBox(height: 20),
              if (_message.isNotEmpty) // Afficher le message de succès/erreur
                Text(
                  _message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _message.contains('succès')
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
