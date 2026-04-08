import 'package:between/views/session_summary_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/mood_view_model.dart';
import 'diary_screen.dart';
import 'graph_screen.dart';

// ─── Paleta Between (misma del login) ────────────────────────────────────────
class BetweenColors {
  static const Color deepPurple  = Color(0xFF6B4FA0);
  static const Color softPurple  = Color(0xFF9B7FD4);
  static const Color lavender    = Color(0xFFC9B8EE);
  static const Color teal        = Color(0xFF3DBFB8);
  static const Color lightTeal   = Color(0xFF7FD9D4);
  static const Color mintFog     = Color(0xFFE8F7F6);
  static const Color lilacFog    = Color(0xFFF3EEFF);
  static const Color textDark    = Color(0xFF2D2640);
  static const Color textMuted   = Color(0xFF8A7FA8);
  static const Color white       = Color(0xFFFFFFFF);
}

// ─── Configuración de cada estado de ánimo ────────────────────────────────────
class _MoodConfig {
  final String emoji;
  final String label;
  final Color  color;
  final Color  bgColor;

  const _MoodConfig({
    required this.emoji,
    required this.label,
    required this.color,
    required this.bgColor,
  });
}

const List<_MoodConfig> _moodConfigs = [
  _MoodConfig(emoji: "😡", label: "Enojado",   color: Color(0xFFD85A30), bgColor: Color(0xFFFAECE7)),
  _MoodConfig(emoji: "😢", label: "Triste",    color: Color(0xFF378ADD), bgColor: Color(0xFFE6F1FB)),
  _MoodConfig(emoji: "😐", label: "Neutro",    color: Color(0xFF888780), bgColor: Color(0xFFF1EFE8)),
  _MoodConfig(emoji: "🙂", label: "Bien",      color: Color(0xFF3DBFB8), bgColor: Color(0xFFE8F7F6)),
  _MoodConfig(emoji: "😄", label: "Feliz",     color: Color(0xFF6B4FA0), bgColor: Color(0xFFF3EEFF)),
];

// ─── Pantalla principal ────────────────────────────────────────────────────────
class MoodScreen extends StatelessWidget {
  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Buenos días";
    if (hour < 19) return "Buenas tardes";
    return "Buenas noches";
  }

  @override
  Widget build(BuildContext context) {
    final moodViewModel = Provider.of<MoodViewModel>(context);

    return Scaffold(
      backgroundColor: BetweenColors.lilacFog,
      body: Stack(
        children: [
          // ── Blob decorativo superior ──────────────────────────────────────
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    BetweenColors.lightTeal.withOpacity(0.28),
                    BetweenColors.lightTeal.withOpacity(0.00),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Header ────────────────────────────────────────────────
                _Header(greeting: _greeting()),

                // ── Tarjeta de selección de ánimo ─────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _MoodPickerCard(vm: moodViewModel),
                ),

                const SizedBox(height: 20),

                // ── Título del historial ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      const Text(
                        "Mis registros",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: BetweenColors.textDark,
                        ),
                      ),
                      const Spacer(),
                      if (moodViewModel.moods.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: BetweenColors.lavender.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${moodViewModel.moods.length} entradas",
                            style: const TextStyle(
                              fontSize: 12,
                              color: BetweenColors.deepPurple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Lista de registros ────────────────────────────────────
                Expanded(
                  child: moodViewModel.moods.isEmpty
                      ? _EmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 4),
                          itemCount: moodViewModel.moods.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final mood = moodViewModel.moods[
                                moodViewModel.moods.length - 1 - index];
                            final cfg = _moodConfigs
                                .firstWhere((c) => c.emoji == mood.emoji,
                                    orElse: () => _moodConfigs[2]);
                            return _MoodHistoryCard(mood: mood, config: cfg);
                          },
                        ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),

      // ── Bottom Navigation ──────────────────────────────────────────────────
      bottomNavigationBar: BetweenBottomNav(context: context),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final String greeting;
  const _Header({required this.greeting});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 16, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo pequeño
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [BetweenColors.deepPurple, BetweenColors.teal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              color: BetweenColors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  fontSize: 13,
                  color: BetweenColors.textMuted,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Text(
                "Between",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: BetweenColors.textDark,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Acciones compactas
          _HeaderAction(
            icon: Icons.insights_rounded,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => GraphScreen())),
          ),
          const SizedBox(width: 8),
          _HeaderAction(
            icon: Icons.assignment_ind_outlined,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => SessionSummaryScreen())),
          ),
          const SizedBox(width: 8),
          _HeaderAction(
            icon: Icons.menu_book_rounded,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => DiaryScreen())),
          ),
        ],
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: BetweenColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: BetweenColors.deepPurple.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: BetweenColors.softPurple, size: 20),
      ),
    );
  }
}

// ─── Tarjeta de selección de ánimo ────────────────────────────────────────────
class _MoodPickerCard extends StatelessWidget {
  final MoodViewModel vm;
  const _MoodPickerCard({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        color: BetweenColors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: BetweenColors.deepPurple.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: BetweenColors.teal.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pregunta
          const Text(
            "¿Cómo te sientes hoy?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: BetweenColors.textDark,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Toca el ánimo que mejor te describa ahora mismo.",
            style: TextStyle(
              fontSize: 12,
              color: BetweenColors.textMuted,
            ),
          ),
          const SizedBox(height: 20),

          // Botones de ánimo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              _moodConfigs.length,
              (i) => _MoodButton(
                config: _moodConfigs[i],
                value: i + 1,
                vm: vm,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Botón de ánimo ───────────────────────────────────────────────────────────
class _MoodButton extends StatelessWidget {
  final _MoodConfig config;
  final int         value;
  final MoodViewModel vm;

  const _MoodButton({
    required this.config,
    required this.value,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => vm.addMood(config.emoji, value),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: config.bgColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: config.color.withOpacity(0.20),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                config.emoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            config.label,
            style: TextStyle(
              fontSize: 11,
              color: config.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tarjeta de historial ─────────────────────────────────────────────────────
class _MoodHistoryCard extends StatelessWidget {
  final dynamic      mood;
  final _MoodConfig  config;
  const _MoodHistoryCard({required this.mood, required this.config});

  String _formatDate(DateTime date) {
    const months = [
      "ene", "feb", "mar", "abr", "may", "jun",
      "jul", "ago", "sep", "oct", "nov", "dic"
    ];
    final h   = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return "${date.day} ${months[date.month - 1]} · $h:$min";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: BetweenColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: config.color.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Acento de color lateral
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              color: config.color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 14),

          // Emoji en círculo
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: config.bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                mood.emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: BetweenColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(mood.date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: BetweenColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Indicador de nivel
          _MoodLevelDots(value: mood.moodValue, color: config.color),
        ],
      ),
    );
  }
}

// ─── Indicador de nivel con puntos ────────────────────────────────────────────
class _MoodLevelDots extends StatelessWidget {
  final int   value;
  final Color color;
  const _MoodLevelDots({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(left: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i < value
                ? color
                : color.withOpacity(0.15),
          ),
        );
      }),
    );
  }
}

// ─── Estado vacío ─────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: BetweenColors.lavender.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: BetweenColors.softPurple,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Aún no hay registros",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: BetweenColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Toca un ánimo arriba para\nempezar tu registro de hoy.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: BetweenColors.textMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Navigation ────────────────────────────────────────────────────────
// ─── Bottom Navigation ────────────────────────────────────────────────────────
class BetweenBottomNav extends StatelessWidget {
  final BuildContext context;
  final String activeTab;

  const BetweenBottomNav({
    Key? key,
    required this.context,
    this.activeTab = "Ánimo",
  }) : super(key: key);

  // --- MAGIA DE NAVEGACIÓN INSTANTÁNEA ---
  // Reemplaza la pantalla actual sin apilarla y elimina la animación de "deslizamiento"
  void _navigateInstant(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => screen,
        transitionDuration: Duration.zero, // Hace que el cambio sea instantáneo
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BetweenColors.white,
        boxShadow: [
          BoxShadow(
            color: BetweenColors.deepPurple.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon:  Icons.favorite_border_rounded,
                label: "Ánimo",
                // Aquí es donde se evalúa si debe iluminarse o no
                active: activeTab == "Ánimo", 
                onTap: () {
                  // Solo navega si NO estamos ya en esta pantalla
                  if (activeTab != "Ánimo") _navigateInstant(context, MoodScreen());
                },
              ),
              _NavItem(
                icon:  Icons.menu_book_rounded,
                label: "Diario",
                active: activeTab == "Diario",
                onTap: () {
                  if (activeTab != "Diario") _navigateInstant(context, DiaryScreen());
                },
              ),
              _NavItem(
                icon:  Icons.insights_rounded,
                label: "Progreso",
                active: activeTab == "Progreso",
                onTap: () {
                  if (activeTab != "Progreso") _navigateInstant(context, GraphScreen());
                },
              ),
              _NavItem(
                icon:  Icons.assignment_ind_outlined,
                label: "Sesión",
                active: activeTab == "Sesión",
                onTap: () {
                  if (activeTab != "Sesión") _navigateInstant(context, SessionSummaryScreen());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final bool         active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: active
                    ? BetweenColors.deepPurple.withOpacity(0.10)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 22,
                color: active
                    ? BetweenColors.deepPurple
                    : BetweenColors.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    active ? FontWeight.w600 : FontWeight.w400,
                color: active
                    ? BetweenColors.deepPurple
                    : BetweenColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}