import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

  final List<CategoryOption> categories = [
    CategoryOption(value: 'mixed', name: 'Mixta', icon: '🎲', color: Colors.grey),
    CategoryOption(value: 'animales', name: 'Animales', icon: '🐾', color: Colors.brown),
    CategoryOption(value: 'objetos', name: 'Objetos', icon: '🏠', color: Colors.blue),
    CategoryOption(value: 'comida', name: 'Comida', icon: '🍎', color: Colors.red),
    CategoryOption(value: 'profesiones', name: 'Profesiones', icon: '👨‍⚕️', color: Colors.purple),
    CategoryOption(value: 'deportes', name: 'Deportes', icon: '⚽', color: Colors.orange),
    CategoryOption(value: 'colores', name: 'Colores', icon: '🎨', color: Colors.green),
    CategoryOption(value: 'emociones', name: 'Emociones', icon: '😊', color: Colors.pink),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTeamsSection(),
                      const SizedBox(height: 30),
                      _buildGameSettingsSection(),
                      const SizedBox(height: 30),
                      _buildCategorySection(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              _buildStartButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Expanded(
                child: Text(
                  'Configuración de Equipos',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 48), // Para balancear el botón de atrás
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Personaliza tu juego y ¡que comience la diversión!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: const Duration(milliseconds: 600))
      .slideY(begin: -0.3);
  }

  Widget _buildTeamsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.groups, color: Colors.blue, size: 28),
            const SizedBox(width: 12),
            const Text(
              'Equipos',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const Spacer(),
            if (teams.length < 6)
              FloatingActionButton.small(
                onPressed: _addTeam,
                backgroundColor: Colors.blue,
                child: const Icon(Icons.add, color: Colors.white),
              ),
          ],
        ),
        const SizedBox(height: 16),
        ...teams.asMap().entries.map((entry) {
          final index = entry.key;
          final team = entry.value;
          return _buildTeamCard(team, index);
        }).toList(),
      ],
    ).animate()
      .fadeIn(duration: const Duration(milliseconds: 800))
      .slideX(begin: -0.2);
  }

  Widget _buildTeamCard(Team team, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: team.color,
          radius: 25,
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          team.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          'Toca para editar',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        trailing: teams.length > 2
            ? IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                onPressed: () => _removeTeam(index),
              )
            : null,
        onTap: () => _editTeam(index),
      ),
    ).animate(delay: Duration(milliseconds: 100 * index))
      .fadeIn(duration: const Duration(milliseconds: 500))
      .slideX(begin: 0.3);
  }

  Widget _buildGameSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.settings, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            const Text(
              'Configuración del Juego',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSettingCard(
          icon: Icons.repeat,
          title: 'Rondas por equipo',
          value: '$rounds',
          color: Colors.blue,
          child: Slider(
            value: rounds.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            activeColor: Colors.blue,
            onChanged: (value) {
              setState(() {
                rounds = value.toInt();
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildSettingCard(
          icon: Icons.timer,
          title: 'Tiempo por ronda',
          value: '$timeLimit seg',
          color: Colors.orange,
          child: Slider(
            value: timeLimit.toDouble(),
            min: 30,
            max: 90,
            divisions: 6,
            activeColor: Colors.orange,
            onChanged: (value) {
              setState(() {
                timeLimit = value.toInt();
              });
            },
          ),
        ),
      ],
    ).animate()
      .fadeIn(duration: const Duration(milliseconds: 1000))
      .slideX(begin: 0.2);
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.category, color: Colors.purple, size: 28),
            const SizedBox(width: 12),
            const Text(
              'Categoría',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedCategory == category.value;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory = category.value;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? category.color : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? category.color : Colors.grey.shade300,
                    width: 2,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: category.color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      category.icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category.name,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate(delay: Duration(milliseconds: 50 * index))
              .fadeIn(duration: const Duration(milliseconds: 400))
              .scale(begin: const Offset(0.8, 0.8));
          },
        ),
      ],
    ).animate()
      .fadeIn(duration: const Duration(milliseconds: 1200))
      .slideY(begin: 0.2);
  }

  Widget _buildStartButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: _startGame,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_arrow, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Comenzar Juego',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: const Duration(milliseconds: 1400))
      .slideY(begin: 0.3);
  }

  void _addTeam() {
    if (teams.length >= 6) {
      _showSnackBar('Máximo 6 equipos permitidos', Colors.orange);
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
      _showSnackBar('Mínimo 2 equipos requeridos', Colors.red);
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
        teamColor: teams[index].color,
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
          allTeams: teams,
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class CategoryOption {
  final String value;
  final String name;
  final String icon;
  final Color color;

  CategoryOption({
    required this.value,
    required this.name,
    required this.icon,
    required this.color,
  });
}

class _TeamNameDialog extends StatefulWidget {
  final String initialName;
  final Color teamColor;

  const _TeamNameDialog({
    required this.initialName,
    required this.teamColor,
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: widget.teamColor,
            child: const Icon(Icons.edit, color: Colors.white),
          ),
          const SizedBox(width: 16),
          const Text('Editar Equipo'),
        ],
      ),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: 'Nombre del equipo',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          prefixIcon: const Icon(Icons.group),
        ),
        autofocus: true,
        maxLength: 20,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _controller.text.trim();
            if (name.isNotEmpty) {
              Navigator.pop(context, name);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.teamColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
} 