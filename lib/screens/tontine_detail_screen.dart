import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Pour formater les dates

class TontineDetailScreen extends StatefulWidget {
  final int tontineId;

  const TontineDetailScreen({super.key, required this.tontineId});

  @override
  State<TontineDetailScreen> createState() => _TontineDetailScreenState();
}

class _TontineDetailScreenState extends State<TontineDetailScreen> {
  Map<String, dynamic>? tontineDetails;
  List<dynamic> contributions = []; // Nouvelle liste pour les contributions
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchTontineDetailsAndContributions(); // Appelle une nouvelle fonction pour tout charger
  }

  // Fonction pour charger les détails de la tontine ET ses contributions
  Future<void> _fetchTontineDetailsAndContributions() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // 1. Récupérer les détails de la tontine
      final tontineResponse = await http.get(
        Uri.parse(
          'http://localhost/api/get_tontine_by_id.php?id=${widget.tontineId}',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      final tontineData = jsonDecode(tontineResponse.body);

      if (tontineData['status'] == 'success') {
        tontineDetails = tontineData['tontine'];
      } else {
        errorMessage =
            tontineData['message'] ??
            'Erreur inconnue lors de la récupération des détails de la tontine.';
        isLoading = false;
        return; // Arrête si les détails ne peuvent pas être chargés
      }

      // 2. Récupérer les contributions de la tontine
      final contributionsResponse = await http.get(
        Uri.parse(
          'http://localhost/api/get_tontine_contributions.php?tontine_id=${widget.tontineId}',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      final contributionsData = jsonDecode(contributionsResponse.body);

      if (contributionsData['status'] == 'success') {
        contributions = contributionsData['contributions'];
      } else {
        errorMessage =
            contributionsData['message'] ??
            'Erreur inconnue lors de la récupération des contributions.';
      }
    } catch (e) {
      errorMessage =
          'Erreur de connexion: ${e.toString()}. Vérifiez votre serveur PHP.';
      print('Erreur lors du chargement des détails/contributions: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tontineDetails?['nom_tontine'] ?? 'Détails de la Tontine'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: isLoading
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
                      onPressed: _fetchTontineDetailsAndContributions,
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
          : tontineDetails == null
          ? const Center(
              child: Text(
                'Détails de la tontine non disponibles.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tontineDetails!['nom_tontine'],
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    tontineDetails!['description'] ??
                        'Aucune description fournie.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow(
                    context,
                    'Montant de cotisation',
                    '${tontineDetails!['montant_cotisation']} FCFA',
                  ),
                  _buildDetailRow(
                    context,
                    'Fréquence de cotisation',
                    tontineDetails!['frequence_cotisation'],
                  ),
                  _buildDetailRow(
                    context,
                    'Membres maximum',
                    tontineDetails!['nombre_membres_max'].toString(),
                  ),

                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Passe le montant de cotisation attendu à la page de contribution
                        Navigator.pushNamed(
                          context,
                          '/contribute',
                          arguments:
                              tontineDetails!['montant_cotisation'], // Passe le montant
                        );
                      },
                      icon: const Icon(Icons.money, color: Colors.white),
                      label: const Text(
                        'Contribuer à la tontine',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        minimumSize: const Size(250, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implémenter la logique pour rejoindre cette tontine spécifique
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Fonctionnalité "Rejoindre ${tontineDetails!['nom_tontine']}" à implémenter si l\'utilisateur n\'est pas encore membre.',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.group_add, color: Colors.white),
                      label: const Text(
                        'Rejoindre la tontine (si pas membre)',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        minimumSize: const Size(250, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                  Text(
                    'Historique des contributions :',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 10),

                  contributions.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Text(
                              'Aucune contribution enregistrée pour cette tontine.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap:
                              true, // Important pour ListView imbriquée dans SingleChildScrollView
                          physics:
                              const NeverScrollableScrollPhysics(), // Empêche le défilement de la liste
                          itemCount: contributions.length,
                          itemBuilder: (context, index) {
                            final contribution = contributions[index];
                            // Formater la date
                            final DateTime date = DateTime.parse(
                              contribution['date_contribution'],
                            );
                            final String formattedDate = DateFormat(
                              'dd/MM/yyyy HH:mm',
                            ).format(date);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10.0),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Montant: ${contribution['montant']} FCFA',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[700],
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Par: ${contribution['utilisateur_nom'] ?? 'Inconnu'}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                    Text(
                                      'Le: $formattedDate',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label :',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
