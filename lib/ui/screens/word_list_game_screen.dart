import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/dopamine_theme.dart';
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              DopamineColors.backgroundDark,
              Color(0xFF374151),
              DopamineColors.primaryPurple,
            ],
            stops: [0.0, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Consumer<RoundBloc>(
            builder: (context, roundBloc, child) {
              final state = roundBloc.state;
              
              if (state.status == RoundStatus.loading || state.round == null) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: DopamineColors.cardWhite,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: DopamineColors.primaryPurple.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [DopamineColors.primaryPurple, DopamineColors.secondaryPink],
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Preparando palabras...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: DopamineColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              return _buildGameView(state.round!.words);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGameView(List<dynamic> words) {
    return Column(
      children: [
        if (widget.team != null) _buildTeamHeader(),
        _buildTimerAndScore(),
        const SizedBox(height: 20),
        Expanded(
          child: _buildWordsList(words),
        ),
        _buildFinishButton(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTeamHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.team!.color,
            widget.team!.color.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: widget.team!.color.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: DopamineColors.cardWhite,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.team!.name[0],
                style: TextStyle(
                  color: widget.team!.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
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
    ).animate()
      .fadeIn(duration: const Duration(milliseconds: 600))
      .slideY(begin: -0.3);
  }

  Widget _buildTimerAndScore() {
    final isLowTime = timeRemaining <= 10;
    final score = wordAnswers.values.where((answer) => answer == true).length;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLowTime 
              ? [DopamineColors.errorRed, DopamineColors.accent1]
              : [DopamineColors.electricBlue, DopamineColors.accent2],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isLowTime ? DopamineColors.errorRed : DopamineColors.electricBlue).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Timer
          Expanded(
            child: Column(
              children: [
                Text(
                  timeRemaining.toString(),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate(
                  target: isLowTime ? 1 : 0,
                ).shake(duration: const Duration(milliseconds: 500)),
                Text(
                  'segundos',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // Separador
          Container(
            width: 2,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          
          // Score
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    Text(
                      score.toString(),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'aciertos',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordsList(List<dynamic> words) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [DopamineColors.secondaryPink, DopamineColors.primaryPurple],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.touch_app,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Desliza → o toca para marcar aciertos',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
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
      ),
    );
  }

  Widget _buildFinishButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [DopamineColors.warningOrange, DopamineColors.accent3],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: DopamineColors.warningOrange.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isGameActive ? _finishGame : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.flag,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'FINALIZAR RONDA',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
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
      margin: const EdgeInsets.only(bottom: 8),
      child: Stack(
        children: [
          // Fondo con indicador de deslizamiento
          Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: _dragOffset > 30 
                  ? const LinearGradient(
                      colors: [DopamineColors.successGreen, DopamineColors.accent2],
                    )
                  : null,
              borderRadius: BorderRadius.circular(20),
            ),
            child: _dragOffset > 30
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 25),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '¡Acierto!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: widget.isChecked
                        ? const LinearGradient(
                            colors: [DopamineColors.successGreen, DopamineColors.accent2],
                          )
                        : const LinearGradient(
                            colors: [DopamineColors.cardWhite, Color(0xFFF8FAFC)],
                          ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: widget.isChecked 
                          ? DopamineColors.successGreen
                          : DopamineColors.electricBlue.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.isChecked 
                            ? DopamineColors.successGreen.withOpacity(0.3)
                            : DopamineColors.electricBlue.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.word.toUpperCase(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: widget.isChecked 
                                ? Colors.white 
                                : DopamineColors.textDark,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              gradient: widget.isChecked 
                                  ? const LinearGradient(
                                      colors: [Colors.white, Color(0xFFF0F9FF)],
                                    )
                                  : const LinearGradient(
                                      colors: [DopamineColors.electricBlue, DopamineColors.primaryPurple],
                                    ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.isChecked 
                                      ? Colors.white.withOpacity(0.5)
                                      : DopamineColors.electricBlue.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.isChecked ? Icons.check_circle : Icons.add_circle_outline,
                              color: widget.isChecked 
                                  ? DopamineColors.successGreen 
                                  : Colors.white,
                              size: 24,
                            ),
                          ),
                          // Animación de check
                          ScaleTransition(
                            scale: _checkAnimation,
                            child: Container(
                              width: 65,
                              height: 65,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [DopamineColors.successGreen, DopamineColors.accent2],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: DopamineColors.successGreen.withOpacity(0.5),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 35,
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
      .fadeIn(delay: Duration(milliseconds: widget.index * 150))
      .slideX(begin: 0.5)
      .scale(begin: const Offset(0.8, 0.8));
  }
} 