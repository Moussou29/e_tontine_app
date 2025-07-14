import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardScreen extends StatefulWidget {
  final String nomUtilisateur;
  final bool isNewUser;

  const DashboardScreen({
    super.key,
    required this.nomUtilisateur,
    this.isNewUser = false,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> _userTontines = [];
  bool _isLoadingTontines = true;
  String _tontinesErrorMessage = '';

  // TODO: Pour une application réelle, l'ID de l'utilisateur devrait être récupéré
  // depuis la session de l'utilisateur (ex: SharedPreferences après la connexion).
  // Pour le test, nous utilisons un ID fixe.
  final int _currentUserId =
      2; // REMPLACER PAR L'ID DE L'UTILISATEUR RÉELLEMENT CONNECTÉ

  @override
  void initState() {
    super.initState();
    if (!widget.isNewUser) {
      _fetchUserTontines();
    } else {
      _isLoadingTontines = false;
    }
  }

  Future<void> _fetchUserTontines() async {
    setState(() {
      _isLoadingTontines = true;
      _tontinesErrorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse(
          'http://localhost/api/get_user_tontines.php?user_id=$_currentUserId',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _userTontines = data['tontines'];
            _isLoadingTontines = false;
          });
        } else {
          setState(() {
            _tontinesErrorMessage =
                data['message'] ??
                'Erreur inconnue lors de la récupération de vos tontines.';
            _isLoadingTontines = false;
          });
        }
      } else {
        setState(() {
          _tontinesErrorMessage = 'Erreur serveur: ${response.statusCode}.';
          _isLoadingTontines = false;
        });
      }
    } catch (e) {
      setState(() {
        _tontinesErrorMessage =
            'Erreur de connexion: ${e.toString()}. Vérifiez votre serveur PHP.';
        _isLoadingTontines = false;
      });
      print(
        'Erreur lors de la récupération des tontines de l\'utilisateur: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          // Bouton pour accéder aux paramètres
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/settings',
              ); // Navigue vers la page des paramètres
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenue, ${widget.nomUtilisateur} !',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 20),

            if (widget.isNewUser)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Félicitations pour la création de votre compte !',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Commencez votre aventure E-tontine en créant ou en rejoignant une tontine :',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/create_tontine');
                    },
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Créer une nouvelle tontine',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/join_tontine');
                    },
                    icon: const Icon(Icons.group_add, color: Colors.white),
                    label: const Text(
                      'Rejoindre une tontine existante',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                  ),
                ],
              )
            else
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vos tontines actives :',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(height: 10),

                    _isLoadingTontines
                        ? const Center(child: CircularProgressIndicator())
                        : _tontinesErrorMessage.isNotEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 60,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    _tontinesErrorMessage,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    onPressed: _fetchUserTontines,
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
                        : _userTontines.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.0),
                              child: Text(
                                'Vous n\'avez pas encore rejoint de tontine. Rejoignez-en une ou créez la vôtre !',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        : Expanded(
                            child: ListView.builder(
                              itemCount: _userTontines.length,
                              itemBuilder: (context, index) {
                                final tontine = _userTontines[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12.0),
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tontine['nom_tontine'],
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green[700],
                                                ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            'Montant: ${tontine['montant_cotisation']} FCFA | Fréquence: ${tontine['frequence_cotisation']}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/create_tontine');
                      },
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Créer une nouvelle tontine',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/join_tontine');
                      },
                      icon: const Icon(Icons.group_add, color: Colors.white),
                      label: const Text(
                        'Rejoindre une tontine existante',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
