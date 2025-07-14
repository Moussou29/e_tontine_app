import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ContributeScreen extends StatefulWidget {
  // Changement: tontineId n'est plus le seul argument.
  // Nous passons un Map qui contient l'ID de la tontine ET le montant attendu.
  final Map<String, dynamic> args;

  const ContributeScreen({super.key, required this.args});

  @override
  State<ContributeScreen> createState() => _ContributeScreenState();
}

class _ContributeScreenState extends State<ContributeScreen> {
  bool _contributionSuccess = false;
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;

  late int _tontineId; // L'ID de la tontine
  late double _expectedAmount; // Le montant attendu

  // TODO: Pour une application réelle, l'ID de l'utilisateur devrait être récupéré
  // depuis la session de l'utilisateur (ex: SharedPreferences après la connexion).
  // Pour le test, nous utilisons un ID fixe.
  final int _currentUserId =
      2; // REMPLACER PAR L'ID DE L'UTILISATEUR RÉELLEMENT CONNECTÉ

  @override
  void initState() {
    super.initState();
    _tontineId = widget.args['tontineId'] as int;
    _expectedAmount = (widget.args['expectedAmount'] as num)
        .toDouble(); // Convertir en double
    _amountController.text = _expectedAmount.toString(); // Pré-remplir le champ
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submitContribution() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un montant.')),
      );
      return;
    }

    final double amount = double.tryParse(_amountController.text) ?? 0.0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un montant valide et positif.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _contributionSuccess = false;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost/api/contribute.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'tontine_id': _tontineId, // Utilise l'ID de la tontine
          'utilisateur_id': _currentUserId,
          'montant': amount,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        setState(() {
          _contributionSuccess = true;
          // _amountController.clear(); // Ne pas effacer si on veut que l'utilisateur voit le montant qu'il a entré
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['message'])));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Échec de la contribution.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur de connexion: ${e.toString()}. Vérifiez votre serveur PHP.',
          ),
        ),
      );
      print('Erreur lors de l\'envoi de la contribution: $e');
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
        title: Text('Contribuer à la Tontine #${_tontineId}'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Montant de cotisation attendu : ${_expectedAmount} FCFA',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Votre contribution actuelle', // Changé le texte
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Entrez le montant (FCFA)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            if (_contributionSuccess)
              Column(
                children: const [
                  Icon(Icons.check_circle, color: Colors.green, size: 60),
                  SizedBox(height: 10),
                  Text(
                    'Contribution réussie !',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitContribution,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Contribuer à la tontine'),
                  ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Retour aux détails de la tontine'),
            ),
          ],
        ),
      ),
    );
  }
}
