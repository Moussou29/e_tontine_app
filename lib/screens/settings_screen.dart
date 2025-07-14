import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Préférences',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.language, color: Colors.green),
              title: const Text('Langue'),
              subtitle: const Text('Français'),
              onTap: () {
                // Action pour changer la langue
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.green),
              title: const Text('Profil'),
              subtitle: const Text('Voir ou modifier votre profil'),
              onTap: () {
                // Action pour accéder au profil
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.green),
              title: const Text('Déconnexion'),
              onTap: () {
                // Action de déconnexion
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
