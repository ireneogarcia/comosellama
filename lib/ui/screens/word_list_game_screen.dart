import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../blocs/round_bloc.dart';
import 'team_transition_screen.dart';
import 'team_results_screen.dart';
import '../../core/models/team.dart';
import '../../core/models/game_mode.dart';
import '../../core/services/feedback_service.dart';

class WordListGameScreen extends StatefulWidget {
  final String category;
  final Team? team;
  final int? currentRound;
  final int? totalRounds;
  final List<Team>? allTeams;
  final int timeLimit;
  final GameMode gameMode;
  
  const WordListGameScreen({
    super.key,
    required this.category,
    this.team,
    this.currentRound,
    this.totalRounds,
    this.allTeams,
    this.timeLimit = 60,
    this.gameMode = GameMode.wordList,
  });

  @override
  State<WordListGameScreen> createState() => _WordListGameScreenState();
}

class _WordListGameScreenState extends State<WordListGameScreen> {
  final Map<int, bool?> wordAnswers = {}; // null = no respondida, true = acierto, false = fallo
  int timeRemaining = 0;
  bool isGameActive = false;

  @override
  void initState() {
    super.initState();
    timeRemaining = widget.timeLimit;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final roundBloc = Provider.of<RoundBloc>(context, listen: false);
      roundBloc.resetState();
      _startRound(roundBloc);
    });
  }

  void _startRound(RoundBloc roundBloc) {
    Future.microtask(() {
      roundBloc.startNewRound(
        category: widget.category,
        timeLimit: widget.timeLimit,
      );
      setState(() {
        isGameActive = true;
      });
      _startTimer();
    });
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !isGameActive) return false;
      
      setState(() {
        timeRemaining--;
      });
      
      if (timeRemaining <= 0) {
        _finishGame();
        return false;
      }
      
      return true;
    });
  }

  void _finishGame() {
    if (!isGameActive) return;
    
    setState(() {
      isGameActive = false;
    });
    
    final roundBloc = Provider.of<RoundBloc>(context, listen: false);
    final words = roundBloc.state.round?.words ?? [];
    
    // Calcular puntuación basada en las respuestas (solo aciertos)
    int score = 0;
    for (int i = 0; i < words.length; i++) {
      if (wordAnswers[i] == true) {
        score++;
      }
    }
    
    // Finalizar el juego con la puntuación calculada
    roundBloc.finishRoundWithScore(score);
    
    _navigateAfterRound();
  }

  void _navigateAfterRound() {
    if (widget.team != null && widget.allTeams != null) {
      // Modo por equipos
      final roundBloc = Provider.of<RoundBloc>(context, listen: false);
      final roundScore = roundBloc.state.round?.score ?? 0;
      if (widget.team != null) {
        widget.team!.score += roundScore;
      }
      
      // Calcular siguiente equipo y ronda
      final currentTeamIndex = widget.allTeams!.indexOf(widget.team!);
      final nextTeamIndex = (currentTeamIndex + 1) % widget.allTeams!.length;
      final nextTeam = widget.allTeams![nextTeamIndex];
      
      // Si volvemos al primer equipo, incrementamos la ronda
      final nextRound = nextTeamIndex == 0 ? widget.currentRound! + 1 : widget.currentRound!;

      if (nextRound <= widget.totalRounds!) {
        // Continuar con el siguiente turno
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TeamTransitionScreen(
              team: nextTeam,
              currentRound: nextRound,
              totalRounds: widget.totalRounds!,
              timeLimit: widget.timeLimit,
              category: widget.category,
              allTeams: widget.allTeams!,
              gameMode: widget.gameMode,
            ),
          ),
        );
      } else {
        // Juego terminado - ir a resultados
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TeamResultsScreen(
              teams: widget.allTeams!,
              onPlayAgain: () {
                // Reiniciar puntuaciones
                for (final team in widget.allTeams!) {
                  team.score = 0;
                }
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TeamTransitionScreen(
                      team: widget.allTeams![0],
                      currentRound: 1,
                      totalRounds: widget.totalRounds!,
                      timeLimit: widget.timeLimit,
                      category: widget.category,
                      allTeams: widget.allTeams!,
                      gameMode: widget.gameMode,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }
    } else {
      // Modo individual - volver al menú
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<RoundBloc>(
          builder: (context, roundBloc, child) {
            final state = roundBloc.state;
            
            if (state.status == RoundStatus.loading || state.round == null) {
              return const Center(child: CircularProgressIndicator());
            }
            
            return _buildGameView(state.round!.words);
          },
        ),
      ),
    );
  }

  Widget _buildGameView(List<dynamic> words) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            widget.team?.color.withOpacity(0.1) ?? Theme.of(context).primaryColor.withOpacity(0.1),
            Colors.white,
          ],
        ),
      ),
      child: Column(
        children: [
          if (widget.team != null) _buildTeamHeader(),
          _buildTimer(),
          const SizedBox(height: 20),
          _buildScore(),
          const SizedBox(height: 20),
          Expanded(
            child: _buildWordsList(words),
          ),
          _buildFinishButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTeamHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.team!.color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 25,
              child: Text(
                widget.team!.name[0],
                style: TextStyle(
                  color: widget.team!.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              widget.team!.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimer() {
    final isLowTime = timeRemaining <= 10;
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      decoration: BoxDecoration(
        color: isLowTime ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLowTime ? Colors.red : Colors.blue,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            timeRemaining.toString(),
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: isLowTime ? Colors.red : Colors.blue,
            ),
          ).animate(
            target: isLowTime ? 1 : 0,
          ).shake(duration: const Duration(milliseconds: 500)),
          Text(
            'segundos restantes',
            style: TextStyle(
              fontSize: 16,
              color: isLowTime ? Colors.red : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScore() {
    final score = wordAnswers.values.where((answer) => answer == true).length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green, width: 1),
      ),
      child: Text(
        'Puntuación: $score',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }

  Widget _buildWordsList(List<dynamic> words) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const Text(
            'Marca las palabras que aciertes:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: words.length,
              itemBuilder: (context, index) {
                final word = words[index];
                final isChecked = wordAnswers[index] == true;
                
                return _SwipeableWordCard(
                  word: word.text,
                  isChecked: isChecked,
                  isGameActive: isGameActive,
                  onToggle: () {
                    FeedbackService().correctAnswerFeedback();
                    setState(() {
                      wordAnswers[index] = isChecked ? null : true;
                    });
                  },
                  index: index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinishButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isGameActive ? _finishGame : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.team?.color ?? Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: const Text(
            'FINALIZAR RONDA',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _SwipeableWordCard extends StatefulWidget {
  final String word;
  final bool isChecked;
  final bool isGameActive;
  final VoidCallback onToggle;
  final int index;

  const _SwipeableWordCard({
    required this.word,
    required this.isChecked,
    required this.isGameActive,
    required this.onToggle,
    required this.index,
  });

  @override
  State<_SwipeableWordCard> createState() => _SwipeableWordCardState();
}

class _SwipeableWordCardState extends State<_SwipeableWordCard>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _checkController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _checkAnimation;
  double _dragOffset = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.0, 0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
    
    _checkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (!widget.isGameActive) return;
    
    setState(() {
      _isDragging = true;
      _dragOffset += details.delta.dx;
      _dragOffset = _dragOffset.clamp(-100.0, 100.0);
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    if (!widget.isGameActive) return;
    
    setState(() {
      _isDragging = false;
    });

    // Si el deslizamiento es suficiente hacia la derecha Y no está ya marcado, marcar como acierto
    if (_dragOffset > 50 && !widget.isChecked) {
      _animateCheck();
      widget.onToggle();
    }
    
    // Resetear la posición
    _dragOffset = 0;
  }

  void _animateCheck() {
    _slideController.forward().then((_) {
      _slideController.reverse();
      _checkController.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _checkController.reverse();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Stack(
        children: [
          // Fondo con indicador de deslizamiento
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: _dragOffset > 30 ? Colors.green.withOpacity(0.3) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: _dragOffset > 30
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 30,
                        ),
                      ),
                    ],
                  )
                : null,
          ),
          // Tarjeta principal
          Transform.translate(
            offset: Offset(_isDragging ? _dragOffset : 0, 0),
            child: SlideTransition(
              position: _slideAnimation,
              child: GestureDetector(
                onPanUpdate: _handlePanUpdate,
                onPanEnd: _handlePanEnd,
                onTap: widget.isGameActive ? widget.onToggle : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.isChecked 
                          ? Colors.green 
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.word.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: widget.isChecked ? Colors.green : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: widget.isChecked ? Colors.green : Colors.grey.shade400,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.check,
                              color: widget.isChecked ? Colors.white : Colors.grey.shade600,
                              size: 24,
                            ),
                          ),
                          // Animación de check
                          ScaleTransition(
                            scale: _checkAnimation,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.8),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(delay: Duration(milliseconds: widget.index * 100))
      .slideX(begin: 0.3);
  }
} 