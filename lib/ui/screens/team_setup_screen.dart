import 'package:flutter/material.dart';
import 'team_transition_screen.dart';
import '../../core/models/team.dart';

class TeamSetupScreen extends StatefulWidget {
  const TeamSetupScreen({super.key});

  @override
  State<TeamSetupScreen> createState() => _TeamSetupScreenState();
}

class _TeamSetupScreenState extends State<TeamSetupScreen> {
  final List<Team> teams = [
    Team(name: 'Equipo 1', color: Colors.red),
    Team(name: 'Equipo 2', color: Colors.blue),
  ];
  
  int rounds = 3;
  int timeLimit = 60;
  String selectedCategory = 'mixed';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Equipos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTeamsList(),
            const SizedBox(height: 20),
            _buildGameSettings(),
            const Spacer(),
            ElevatedButton(
              onPressed: _startGame,
              child: const Text('Comenzar Juego'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTeam,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTeamsList() {
    return Expanded(
      child: ListView.builder(
        itemCount: teams.length,
        itemBuilder: (context, index) {
          final team = teams[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: team.color,
                child: Text('${index + 1}'),
              ),
              title: Text(team.name),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _removeTeam(index),
              ),
              onTap: () => _editTeam(index),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Configuración del Juego',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        _buildSlider(
          label: 'Rondas: $rounds',
          value: rounds.toDouble(),
          min: 1,
          max: 5,
          onChanged: (value) {
            setState(() {
              rounds = value.toInt();
            });
          },
        ),
        _buildSlider(
          label: 'Tiempo por ronda: $timeLimit segundos',
          value: timeLimit.toDouble(),
          min: 30,
          max: 90,
          onChanged: (value) {
            setState(() {
              timeLimit = value.toInt();
            });
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Categoría',
            border: OutlineInputBorder(),
          ),
          value: selectedCategory,
          items: const [
            DropdownMenuItem(
              value: 'mixed',
              child: Text('Mixta'),
            ),
            DropdownMenuItem(
              value: 'animales',
              child: Text('Animales'),
            ),
            DropdownMenuItem(
              value: 'objetos',
              child: Text('Objetos'),
            ),
            DropdownMenuItem(
              value: 'comida',
              child: Text('Comida'),
            ),
            DropdownMenuItem(
              value: 'profesiones',
              child: Text('Profesiones'),
            ),
            DropdownMenuItem(
              value: 'deportes',
              child: Text('Deportes'),
            ),
            DropdownMenuItem(
              value: 'colores',
              child: Text('Colores'),
            ),
            DropdownMenuItem(
              value: 'emociones',
              child: Text('Emociones'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedCategory = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _addTeam() {
    if (teams.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Máximo 6 equipos permitidos'),
        ),
      );
      return;
    }

    setState(() {
      teams.add(Team(
        name: 'Equipo ${teams.length + 1}',
        color: _getNextColor(),
      ));
    });
  }

  void _removeTeam(int index) {
    if (teams.length <= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mínimo 2 equipos requeridos'),
        ),
      );
      return;
    }

    setState(() {
      teams.removeAt(index);
    });
  }

  void _editTeam(int index) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _TeamNameDialog(
        initialName: teams[index].name,
      ),
    );

    if (result != null) {
      setState(() {
        teams[index] = teams[index].copyWith(name: result);
      });
    }
  }

  Color _getNextColor() {
    const colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    return colors[teams.length % colors.length];
  }

  void _startGame() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TeamTransitionScreen(
          team: teams[0],
          currentRound: 1,
          totalRounds: rounds,
          timeLimit: timeLimit,
          category: selectedCategory,
        ),
      ),
    );
  }
}

class _TeamNameDialog extends StatefulWidget {
  final String initialName;

  const _TeamNameDialog({
    required this.initialName,
  });

  @override
  State<_TeamNameDialog> createState() => _TeamNameDialogState();
}

class _TeamNameDialogState extends State<_TeamNameDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Nombre'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Nombre del equipo',
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            final name = _controller.text.trim();
            if (name.isNotEmpty) {
              Navigator.pop(context, name);
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
} 