import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _showTutorial = true;
  int _timeLimit = 60;
  bool _removeAds = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: ListView(
        children: [
          _buildSection(
            title: 'General',
            children: [
              SwitchListTile(
                title: const Text('Sonidos'),
                subtitle: const Text('Efectos de sonido del juego'),
                value: _soundEnabled,
                onChanged: (value) {
                  setState(() {
                    _soundEnabled = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Vibración'),
                subtitle: const Text('Retroalimentación táctil'),
                value: _vibrationEnabled,
                onChanged: (value) {
                  setState(() {
                    _vibrationEnabled = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Tutorial'),
                subtitle: const Text('Mostrar instrucciones al inicio'),
                value: _showTutorial,
                onChanged: (value) {
                  setState(() {
                    _showTutorial = value;
                  });
                },
              ),
            ],
          ),
          _buildSection(
            title: 'Juego',
            children: [
              ListTile(
                title: const Text('Tiempo por ronda'),
                subtitle: Text('$_timeLimit segundos'),
                trailing: SizedBox(
                  width: 200,
                  child: Slider(
                    value: _timeLimit.toDouble(),
                    min: 30,
                    max: 90,
                    divisions: 4,
                    label: '$_timeLimit s',
                    onChanged: (value) {
                      setState(() {
                        _timeLimit = value.toInt();
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          _buildSection(
            title: 'Anuncios',
            children: [
              ListTile(
                title: const Text('Eliminar anuncios'),
                subtitle: const Text('Apoya el desarrollo con una donación'),
                trailing: TextButton(
                  onPressed: _removeAds ? null : _handleDonation,
                  child: Text(_removeAds ? 'Eliminados' : 'Donar'),
                ),
              ),
            ],
          ),
          _buildSection(
            title: 'Acerca de',
            children: [
              ListTile(
                title: const Text('Versión'),
                subtitle: const Text('1.0.0'),
              ),
              ListTile(
                title: const Text('Desarrollador'),
                subtitle: const Text('Desarrollado con ❤️'),
                onTap: _showAboutDialog,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  void _handleDonation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Anuncios'),
        content: const Text(
          'Al hacer una donación, apoyas el desarrollo del juego y '
          'eliminas los anuncios permanentemente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implementar donación
              setState(() {
                _removeAds = true;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('¡Gracias por tu apoyo!'),
                ),
              );
            },
            child: const Text('Donar'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Deslizas',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024',
      children: [
        const Text(
          '\nDeslizas es un juego de palabras inspirado en el clásico '
          'juego "Password" en su versión española.\n\n'
          'Desarrollado con Flutter y mucho ❤️ para la comunidad hispanohablante.',
        ),
      ],
    );
  }
} 