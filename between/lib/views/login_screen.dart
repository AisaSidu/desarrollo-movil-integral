import 'package:between/view_models/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_view_model.dart';
import 'mood_screen.dart';

// ─── Paleta Between ────────────────────────────────────────────────────────────
class BetweenColors {
  static const Color deepPurple    = Color(0xFF6B4FA0);
  static const Color softPurple    = Color(0xFF9B7FD4);
  static const Color lavender      = Color(0xFFC9B8EE);
  static const Color teal          = Color(0xFF3DBFB8);
  static const Color lightTeal     = Color(0xFF7FD9D4);
  static const Color mintFog       = Color(0xFFE8F7F6);
  static const Color lilacFog      = Color(0xFFF3EEFF);
  static const Color textDark      = Color(0xFF2D2640);
  static const Color textMuted     = Color(0xFF8A7FA8);
  static const Color white         = Color(0xFFFFFFFF);
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController    = TextEditingController();
  final _passController     = TextEditingController();
  bool _isLogin             = true;
  bool _obscurePass         = true;
  late AnimationController _animCtrl;
  late Animation<double>    _fadeAnim;
  late Animation<Offset>    _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    _animCtrl.reset();
    setState(() => _isLogin = !_isLogin);
    _animCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: BetweenColors.lilacFog,
      body: Stack(
        children: [
          // ── Fondo con burbujas decorativas ───────────────────────────────
          _BackgroundDecoration(size: size),

          // ── Contenido principal ──────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: size.height * 0.07),

                  // Logo / Identidad
                  _BrandHeader(),

                  SizedBox(height: size.height * 0.06),

                  // Tarjeta del formulario
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: _FormCard(
                        isLogin:           _isLogin,
                        emailController:   _emailController,
                        passController:    _passController,
                        obscurePass:       _obscurePass,
                        onToggleObscure:   () => setState(() => _obscurePass = !_obscurePass),
                        onSubmit:          () => _handleSubmit(authViewModel),
                        onToggleMode:      _toggleMode,
                        onPrivacy:         () => _showPrivacyDialog(context),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit(AuthViewModel authViewModel) async {
    bool success;
    if (_isLogin) {
      success = await authViewModel.login(
        _emailController.text, _passController.text);
    } else {
      success = await authViewModel.signup(
        _emailController.text, _passController.text);
    }

    if (success) {
      Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => MoodScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isLogin
                ? "Credenciales incorrectas. Intenta de nuevo."
                : "Este correo ya está en uso.",
            style: const TextStyle(color: BetweenColors.white),
          ),
          backgroundColor: BetweenColors.deepPurple,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}

// ─── Fondo decorativo ─────────────────────────────────────────────────────────
class _BackgroundDecoration extends StatelessWidget {
  final Size size;
  const _BackgroundDecoration({required this.size});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Círculo superior izquierdo (morado suave)
        Positioned(
          top: -60,
          left: -60,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  BetweenColors.softPurple.withOpacity(0.30),
                  BetweenColors.softPurple.withOpacity(0.00),
                ],
              ),
            ),
          ),
        ),
        // Círculo inferior derecho (teal)
        Positioned(
          bottom: -80,
          right: -80,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  BetweenColors.lightTeal.withOpacity(0.35),
                  BetweenColors.lightTeal.withOpacity(0.00),
                ],
              ),
            ),
          ),
        ),
        // Pequeño acento teal arriba a la derecha
        Positioned(
          top: size.height * 0.12,
          right: 20,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: BetweenColors.lightTeal.withOpacity(0.18),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Cabecera de marca ────────────────────────────────────────────────────────
class _BrandHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Ícono personalizado: dos formas conectadas (el "puente")
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [BetweenColors.deepPurple, BetweenColors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: BetweenColors.deepPurple.withOpacity(0.30),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.favorite_border_rounded,
            color: BetweenColors.white,
            size: 36,
          ),
        ),

        const SizedBox(height: 16),

        // Nombre de la app
        const Text(
          "Between",
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: BetweenColors.textDark,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 6),

        // Tagline
        const Text(
          "Tu espacio entre sesiones",
          style: TextStyle(
            fontSize: 14,
            color: BetweenColors.textMuted,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

// ─── Tarjeta del formulario ───────────────────────────────────────────────────
class _FormCard extends StatelessWidget {
  final bool     isLogin;
  final TextEditingController emailController;
  final TextEditingController passController;
  final bool     obscurePass;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;
  final VoidCallback onToggleMode;
  final VoidCallback onPrivacy;

  const _FormCard({
    required this.isLogin,
    required this.emailController,
    required this.passController,
    required this.obscurePass,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.onToggleMode,
    required this.onPrivacy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: BetweenColors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: BetweenColors.deepPurple.withOpacity(0.08),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: BetweenColors.teal.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del formulario
          Text(
            isLogin ? "Bienvenido/a de nuevo" : "Crea tu cuenta",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: BetweenColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isLogin
                ? "Tu espacio te está esperando."
                : "Empieza a registrar tu bienestar.",
            style: const TextStyle(
              fontSize: 13,
              color: BetweenColors.textMuted,
            ),
          ),

          const SizedBox(height: 28),

          // Campo: Correo
          _BetweenTextField(
            controller: emailController,
            label:      "Correo electrónico",
            icon:       Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 16),

          // Campo: Contraseña
          _BetweenTextField(
            controller:    passController,
            label:         "Contraseña",
            icon:          Icons.lock_outline_rounded,
            obscureText:   obscurePass,
            suffixIcon: IconButton(
              icon: Icon(
                obscurePass
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: BetweenColors.textMuted,
                size: 20,
              ),
              onPressed: onToggleObscure,
            ),
          ),

          const SizedBox(height: 28),

          // Botón principal
          _PrimaryButton(
            label:     isLogin ? "Entrar" : "Registrarse",
            onPressed: onSubmit,
          ),

          const SizedBox(height: 20),

          // Divider sutil
          Row(
            children: [
              Expanded(child: Divider(color: BetweenColors.lavender.withOpacity(0.6))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "o",
                  style: TextStyle(
                    fontSize: 12,
                    color: BetweenColors.textMuted.withOpacity(0.7),
                  ),
                ),
              ),
              Expanded(child: Divider(color: BetweenColors.lavender.withOpacity(0.6))),
            ],
          ),

          const SizedBox(height: 16),

          // Toggle login/signup
          GestureDetector(
            onTap: onToggleMode,
            child: Center(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: BetweenColors.textMuted),
                  children: [
                    TextSpan(
                      text: isLogin
                          ? "¿No tienes cuenta? "
                          : "¿Ya tienes cuenta? ",
                    ),
                    TextSpan(
                      text: isLogin ? "Regístrate" : "Inicia sesión",
                      style: const TextStyle(
                        color: BetweenColors.deepPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Aviso de privacidad
          Center(
            child: GestureDetector(
              onTap: onPrivacy,
              child: const Text(
                "Aviso de Privacidad",
                style: TextStyle(
                  fontSize: 12,
                  color: BetweenColors.textMuted,
                  decoration: TextDecoration.underline,
                  decorationColor: BetweenColors.textMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── TextField personalizado ──────────────────────────────────────────────────
class _BetweenTextField extends StatelessWidget {
  final TextEditingController controller;
  final String               label;
  final IconData             icon;
  final bool                 obscureText;
  final TextInputType?       keyboardType;
  final Widget?              suffixIcon;

  const _BetweenTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText  = false,
    this.keyboardType,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller:   controller,
      obscureText:  obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 15,
        color: BetweenColors.textDark,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: BetweenColors.textMuted,
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: BetweenColors.softPurple, size: 20),
        suffixIcon: suffixIcon,
        filled:     true,
        fillColor:  BetweenColors.lilacFog,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: BetweenColors.softPurple,
            width: 1.8,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }
}

// ─── Botón principal con gradiente ────────────────────────────────────────────
class _PrimaryButton extends StatelessWidget {
  final String       label;
  final VoidCallback onPressed;

  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [BetweenColors.deepPurple, BetweenColors.teal],
          begin: Alignment.centerLeft,
          end:   Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:  BetweenColors.deepPurple.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:         onPressed,
          borderRadius:  BorderRadius.circular(16),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color:       BetweenColors.white,
                fontSize:    16,
                fontWeight:  FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Dialog de privacidad ─────────────────────────────────────────────────────
void _showPrivacyDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: BetweenColors.lilacFog,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: BetweenColors.deepPurple,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Tu privacidad importa",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: BetweenColors.textDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Ítems de privacidad
              _PrivacyItem(
                icon:  Icons.phone_android_rounded,
                color: BetweenColors.deepPurple,
                title: "Solo en tu dispositivo",
                body:  "Tus notas y emociones nunca salen de tu teléfono. No hay servidores externos.",
              ),
              const SizedBox(height: 14),
              _PrivacyItem(
                icon:  Icons.lock_rounded,
                color: BetweenColors.teal,
                title: "Cifrado AES-256",
                body:  "Tu información sensible está protegida con el mismo estándar que usa la banca.",
              ),
              const SizedBox(height: 14),
              _PrivacyItem(
                icon:  Icons.handshake_outlined,
                color: BetweenColors.softPurple,
                title: "Tú decides",
                body:  "Al registrarte aceptas usar la app para monitoreo personal de bienestar.",
              ),

              const SizedBox(height: 24),

              // Botón cerrar
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: BetweenColors.lilacFog,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    "Entendido",
                    style: TextStyle(
                      color: BetweenColors.deepPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _PrivacyItem extends StatelessWidget {
  final IconData icon;
  final Color    color;
  final String   title;
  final String   body;

  const _PrivacyItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: BetweenColors.textDark,
                )),
              const SizedBox(height: 2),
              Text(body,
                style: const TextStyle(
                  fontSize: 12,
                  color: BetweenColors.textMuted,
                  height: 1.4,
                )),
            ],
          ),
        ),
      ],
    );
  }
}