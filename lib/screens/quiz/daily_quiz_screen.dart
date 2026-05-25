import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_notifier.dart';
import '../../core/theme.dart';
import '../../services/quiz_service.dart';
import 'widgets/quiz_already_done.dart';
import 'widgets/quiz_intro_screen.dart';
import 'widgets/quiz_question_view.dart';
import 'widgets/quiz_result_screen.dart';
import 'widgets/quiz_top_bar.dart';

enum _QuizState { loading, alreadyDone, intro, question, result }

class DailyQuizScreen extends StatefulWidget {
  const DailyQuizScreen({super.key});

  @override
  State<DailyQuizScreen> createState() => _DailyQuizScreenState();
}

class _DailyQuizScreenState extends State<DailyQuizScreen> {
  final _service = QuizService();

  _QuizState _state = _QuizState.loading;
  List<Map<String, dynamic>> _questions = [];
  Map<String, dynamic>? _existingAttempt;

  int _current = 0;
  String? _selected;
  bool _answered = false;
  int _score = 0;
  int _comboCount = 0;
  List<bool?> _answerHistory = [];

  int _expEarned = 0;
  bool _alreadyCompletedBeforeStart = false;

  // ── Timer ────────────────────────────────────────────────────────────────────
  static const _maxSeconds = 15;
  Timer? _timer;
  int _secondsLeft = _maxSeconds;

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = _maxSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_secondsLeft <= 1) {
        t.cancel();
        if (!_answered) _selectAnswer(''); // waktu habis → salah
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      final results = await Future.wait([
        _service.getTodayAttempt(),
        _service.getQuestions(),
      ]);
      if (!mounted) return;
      final attempt = results[0] as Map<String, dynamic>?;
      final questions =
          (results[1] as List).cast<Map<String, dynamic>>();
      setState(() {
        _existingAttempt = attempt;
        _questions = questions;
        _alreadyCompletedBeforeStart = attempt != null;
        _state =
            attempt != null ? _QuizState.alreadyDone : _QuizState.intro;
      });
    } catch (e) {
      // Jika ada error (misal tabel belum dibuat), tampilkan intro saja
      if (!mounted) return;
      try {
        final questions = await _service.getQuestions();
        if (!mounted) return;
        setState(() {
          _questions = questions;
          _state = _QuizState.intro;
        });
      } catch (_) {
        if (mounted) setState(() => _state = _QuizState.intro);
      }
    }
  }

  void _startQuiz() {
    setState(() {
      _state = _QuizState.question;
      _current = 0;
      _score = 0;
      _comboCount = 0;
      _selected = null;
      _answered = false;
      _answerHistory = List.filled(_questions.length, null);
    });
    _startTimer();
  }

  void _selectAnswer(String letter) {
    if (_answered) return;
    _timer?.cancel();
    final isCorrect =
        letter == (_questions[_current]['correct_answer'] as String? ?? '');

    if (isCorrect) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.heavyImpact();
    }

    setState(() {
      _selected = letter;
      _answered = true;
      if (isCorrect) {
        _score++;
        _comboCount++;
      } else {
        _comboCount = 0;
      }
      if (_current < _answerHistory.length) {
        _answerHistory[_current] = isCorrect;
      }
    });
  }

  Future<void> _next() async {
    if (_current + 1 < _questions.length) {
      setState(() {
        _current++;
        _selected = null;
        _answered = false;
      });
      _startTimer();
      return;
    }

    // Soal terakhir — submit & tampilkan hasil
    var result = <String, dynamic>{'exp_earned': 0};
    if (!_alreadyCompletedBeforeStart) {
      // submitQuiz sudah punya try-catch internal, tidak akan throw
      result = await _service.submitQuiz(
        score: _score,
        total: _questions.length,
      );
      homeRefreshNotifier.value++;
    }

    if (!mounted) return;
    setState(() {
      _expEarned = (result['exp_earned'] as num?)?.toInt() ?? 0;
      _state = _QuizState.result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F6),
      body: SafeArea(
        child: switch (_state) {
          _QuizState.loading => const Center(
              child: CircularProgressIndicator(color: AppColors.primary)),

          _QuizState.alreadyDone => Column(
              children: [
                const QuizTopBar(),
                Expanded(
                  child: QuizAlreadyDone(
                    score: (_existingAttempt?['score'] as num?)?.toInt() ?? 0,
                    total: (_existingAttempt?['total_questions'] as num?)
                            ?.toInt() ??
                        5,
                    expEarned:
                        (_existingAttempt?['exp_earned'] as num?)?.toInt() ??
                            0,
                  ),
                ),
              ],
            ),

          _QuizState.intro => Column(
              children: [
                const QuizTopBar(),
                Expanded(
                  child: QuizIntroScreen(
                    ecoFact: _questions.isNotEmpty
                        ? _questions[0]['eco_fact'] as String? ?? ''
                        : '',
                    onStart: _startQuiz,
                  ),
                ),
              ],
            ),

          _QuizState.question => Column(
              children: [
                QuizTopBar(
                  showProgress: true,
                  answerHistory: _answerHistory,
                  currentIndex: _current,
                  totalQuestions: _questions.length,
                ),
                // Timer bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Row(
                    children: [
                      Text(
                        _answered ? '✓' : '$_secondsLeft',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _secondsLeft <= 5 && !_answered
                              ? Colors.red
                              : AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 900),
                            height: 6,
                            child: LinearProgressIndicator(
                              value: _answered
                                  ? 0
                                  : _secondsLeft / _maxSeconds,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation(
                                _secondsLeft <= 5
                                    ? Colors.red
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) => SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.3, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                          parent: anim, curve: Curves.easeOutCubic)),
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: QuizQuestionView(
                      key: ValueKey('q_$_current'),
                      question: _questions[_current],
                      currentIndex: _current,
                      totalQuestions: _questions.length,
                      score: _score,
                      comboCount: _comboCount,
                      selectedAnswer: _selected,
                      answered: _answered,
                      onSelectAnswer: _selectAnswer,
                      onNext: _next,
                    ),
                  ),
                ),
              ],
            ),

          _QuizState.result => Column(
              children: [
                const QuizTopBar(),
                Expanded(
                  child: QuizResultScreen(
                    score: _score,
                    total: _questions.length,
                    expEarned: _expEarned,
                    alreadyCompletedBeforeStart: _alreadyCompletedBeforeStart,
                  ),
                ),
              ],
            ),
        },
      ),
    );
  }
}
