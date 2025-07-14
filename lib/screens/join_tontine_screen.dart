import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class JoinTontineScreen extends StatefulWidget {
  const JoinTontineScreen({super.key});

  @override
  State<JoinTontineScreen> createState() => _JoinTontineScreenState();
}

class _JoinTontineScreenState extends State<JoinTontineScreen> {
  List<dynamic> tontines = [];
  bool isLoading = true;
  String errorMessage = '';

  // TODO: Pour une application réelle, l'ID de l'utilisateur devrait être récupéré
  // depuis la session de l'utilisateur (ex: SharedPreferences après la connexion).
  // Pour le test, nous utilisons un ID fixe.
  final int _currentUserId =
      2; // REMPLACER PAR L'ID DE L'UTILISATEUR RÉELLEMENT CONNECTÉ

  @override
  void initState() {
    super.initState();
    _fetchTontines();
  }

  Future<void> _fetchTontines() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('http://localhost/api/get_tontines.php'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            tontines = data['tontines'];
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage =
                data['message'] ??
                'Erreur inconnue lors de la récupération des tontines.';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Erreur serveur: ${response.statusCode}.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage =
            'Erreur de connexion: ${e.toString()}. Vérifiez votre serveur PHP.';
        isLoading = false;
      });
      print('Erreur lors de la récupération des tontines: $e');
    }
  }

  // Fonction pour gérer l'action de rejoindre une tontine (implémentation réelle)
  Future<void> _joinTontine(int tontineId, String tontineName) async {
    setState(() {
      isLoading = true; // Activer l'indicateur de chargement pendant l'adhésion
    });

    try {
      final response = await http.post(
        Uri.parse(
          'http://localhost/api/join_tontine.php',
        ), // URL du nouveau script PHP
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'tontine_id': tontineId,
          'utilisateur_id':
              _currentUserId, // L'ID de l'utilisateur connecté (TODO: à remplacer)
        }),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['message'])));
        // Optionnel: Recharger la liste des tontines ou mettre à jour l'UI si nécessaire
        _fetchTontines(); // Recharger la liste pour refléter l'adhésion
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message'] ?? 'Échec de l\'adhésion à la tontine.',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur de connexion lors de l\'adhésion: ${e.toString()}. Vérifiez votre serveur PHP.',
          ),
        ),
      );
      print('Erreur lors de l\'adhésion à la tontine: $e');
    } finally {
      setState(() {
        isLoading = false; // Désactiver l'indicateur de chargement
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rejoindre une Tontine'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body:
          isLoading &&
              tontines
                  .isEmpty // Afficher un indicateur de chargement initial
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 60),
                    SizedBox(height: 10),
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _fetchTontines,
                      icon: Icon(Icons.refresh),
                      label: Text('Réessayer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : tontines.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey, size: 60),
                    SizedBox(height: 10),
                    Text(
                      'Aucune tontine disponible pour le moment. Revenez plus tard ou créez la première !',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: tontines.length,
              itemBuilder: (context, index) {
                final tontine = tontines[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/tontine_detail',
                        arguments: tontine['id'],
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tontine['nom_tontine'],
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            tontine['description'] ?? 'Pas de description.',
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Montant: ${tontine['montant_cotisation']} FCFA',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Fréquence: ${tontine['frequence_cotisation']}',
                                  ),
                                ],
                              ),
                              // Bouton "Rejoindre" qui appelle la fonction _joinTontine
                              ElevatedButton(
                                onPressed: () => _joinTontine(
                                  tontine['id'],
                                  tontine['nom_tontine'],
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child:
                                    isLoading &&
                                        tontine['id'] ==
                                            _currentUserId // Si en cours de chargement pour cette tontine
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Rejoindre'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
