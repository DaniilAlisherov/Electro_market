import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'storm_auth_background.dart';

class PhoneAuthFlow extends StatefulWidget {
  final bool isSeller;
  final String title;
  final String subtitle;
  final IconData icon;
  final Future<String?> Function({
    required String phone,
    required String password,
    String? sellerCode,
  }) onComplete;
  final VoidCallback onBack;

  const PhoneAuthFlow({
    super.key,
    required this.isSeller,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onComplete,
    required this.onBack,
  });

  @override
  State<PhoneAuthFlow> createState() => _PhoneAuthFlowState();
}

class _PhoneAuthFlowState extends State<PhoneAuthFlow>
    with SingleTickerProviderStateMixin {
  static const _demoOtp = '123456';

  final _phoneCtrl = TextEditingController(text: '+996 ');
  final _otpCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _repeatPasswordCtrl = TextEditingController();
  final _sellerCodeCtrl = TextEditingController();

  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 760),
  )..forward();

  int _step = 0;
  bool _sending = false;
  bool _obscurePassword = true;
  bool _obscureRepeat = true;
  bool _obscureSellerCode = true;
  String? _error;
  int _resendSeconds = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _intro.dispose();
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    _passwordCtrl.dispose();
    _repeatPasswordCtrl.dispose();
    _sellerCodeCtrl.dispose();
    super.dispose();
  }

  Animation<double> _fade(double begin, {double end = 1}) =>
      CurvedAnimation(
        parent: _intro,
        curve: Interval(begin, end, curve: Curves.easeOutCubic),
      );

  bool get _phoneValid {
    final digits = _phoneCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length >= 9;
  }

  String _phoneDigits() =>
      _phoneCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');

  void _setStep(int step) {
    setState(() {
      _step = step;
      _error = null;
    });
    _intro
      ..reset()
      ..forward();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _resendSeconds = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_resendSeconds <= 1) {
        timer.cancel();
        setState(() => _resendSeconds = 0);
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  void _sendCode() {
    if (!_phoneValid) {
      setState(() => _error = 'Введите корректный номер телефона');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _sending = true;
      _error = null;
    });

    Future<void>.delayed(const Duration(milliseconds: 480), () {
      if (!mounted) return;
      setState(() => _sending = false);
      _startTimer();
      _setStep(1);
    });
  }

  void _verifyCode() {
    if (_otpCtrl.text.trim() != _demoOtp) {
      setState(() => _error = 'Неверный код. Для демо используйте 123456');
      return;
    }
    FocusScope.of(context).unfocus();
    _setStep(2);
  }

  void _validatePassword() {
    final password = _passwordCtrl.text;
    final repeat = _repeatPasswordCtrl.text;

    if (password.length < 6) {
      setState(() => _error = 'Пароль должен содержать минимум 6 символов');
      return;
    }
    if (password != repeat) {
      setState(() => _error = 'Пароли не совпадают');
      return;
    }

    FocusScope.of(context).unfocus();
    if (widget.isSeller) {
      _setStep(3);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final sellerCode = widget.isSeller ? _sellerCodeCtrl.text.trim() : null;
    if (widget.isSeller && sellerCode!.isEmpty) {
      setState(() => _error = 'Введите секретный код продавца');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _sending = true;
      _error = null;
    });

    final error = await widget.onComplete(
      phone: _phoneDigits(),
      password: _passwordCtrl.text,
      sellerCode: sellerCode,
    );

    if (!mounted) return;
    setState(() {
      _sending = false;
      _error = error;
    });
  }

  String get _stepLabel => switch (_step) {
        0 => 'Шаг 1 из ${widget.isSeller ? 4 : 3}',
        1 => 'Шаг 2 из ${widget.isSeller ? 4 : 3}',
        2 => 'Шаг 3 из ${widget.isSeller ? 4 : 3}',
        _ => 'Шаг 4 из 4',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF04070C),
      body: StormAuthBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeTransition(
                    opacity: _fade(0),
                    child: IconButton(
                      onPressed: widget.onBack,
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeTransition(
                    opacity: _fade(.05),
                    child: Text(
                      widget.title,
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  FadeTransition(
                    opacity: _fade(.1),
                    child: Text(
                      widget.subtitle,
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(.56),
                        fontSize: 12.5,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeTransition(
                    opacity: _fade(.15),
                    child: _ProgressHeader(
                      step: _step,
                      total: widget.isSeller ? 4 : 3,
                      label: _stepLabel,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 360),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 360),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        final slide = Tween<Offset>(
                          begin: const Offset(0, .10),
                          end: Offset.zero,
                        ).animate(animation);
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: slide,
                            child: child,
                          ),
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey(_step),
                        child: _buildStep(scheme),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    child: _error == null
                        ? const SizedBox.shrink()
                        : Container(
                            key: ValueKey(_error),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF5C6C).withOpacity(.10),
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(
                                color: const Color(0xFFFF6675).withOpacity(.25),
                              ),
                            ),
                            child: Text(
                              _error!,
                              style: GoogleFonts.inter(
                                color: const Color(0xFFFFB0B8),
                                fontSize: 11.5,
                                height: 1.35,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(ColorScheme scheme) {
    switch (_step) {
      case 0:
        return _AuthCard(
          icon: widget.icon,
          title: 'Ваш номер телефона',
          subtitle: 'На него отправим одноразовый код подтверждения.',
          child: Column(
            children: [
              _AuthField(
                controller: _phoneCtrl,
                label: 'Номер телефона',
                hint: '+996 700 123 456',
                keyboardType: TextInputType.phone,
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
              ),
              const SizedBox(height: 14),
              _PrimaryButton(
                label: _sending ? 'Отправляем код…' : 'Получить код',
                icon: Icons.arrow_forward_rounded,
                loading: _sending,
                onPressed: _sending ? null : _sendCode,
              ),
            ],
          ),
        );
      case 1:
        return _AuthCard(
          icon: Icons.mark_email_read_outlined,
          title: 'Код из SMS',
          subtitle: 'Введите 6 цифр, которые пришли на ${_phoneCtrl.text.trim()}.',
          child: Column(
            children: [
              _AuthField(
                controller: _otpCtrl,
                label: 'Код подтверждения',
                hint: '••••••',
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                fontSize: 21,
                letterSpacing: 6,
                autofocus: true,
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
              ),
              const SizedBox(height: 10),
              Text(
                'Демо-код для теста: $_demoOtp',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(.34),
                  fontSize: 10.5,
                ),
              ),
              const SizedBox(height: 14),
              _PrimaryButton(
                label: 'Подтвердить номер',
                icon: Icons.verified_rounded,
                onPressed: _verifyCode,
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _resendSeconds > 0 ? null : _sendCode,
                child: Text(
                  _resendSeconds > 0
                      ? 'Отправить повторно через ${_resendSeconds}с'
                      : 'Отправить код повторно',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF93C7FF),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      case 2:
        return _AuthCard(
          icon: Icons.lock_outline_rounded,
          title: 'Придумайте пароль',
          subtitle: 'Пароль сохранит вход в аккаунт и будет использоваться вместе с номером.',
          child: Column(
            children: [
              _AuthField(
                controller: _passwordCtrl,
                label: 'Пароль',
                hint: 'Минимум 6 символов',
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.white54,
                    size: 19,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _AuthField(
                controller: _repeatPasswordCtrl,
                label: 'Повторите пароль',
                hint: 'Ещё раз введите пароль',
                obscureText: _obscureRepeat,
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _obscureRepeat = !_obscureRepeat),
                  icon: Icon(
                    _obscureRepeat
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.white54,
                    size: 19,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _PrimaryButton(
                label: widget.isSeller ? 'Дальше' : 'Создать аккаунт',
                icon: widget.isSeller
                    ? Icons.arrow_forward_rounded
                    : Icons.check_rounded,
                onPressed: _validatePassword,
              ),
            ],
          ),
        );
      default:
        return _AuthCard(
          icon: Icons.admin_panel_settings_outlined,
          title: 'Код продавца',
          subtitle: 'Этот код подтверждает, что аккаунт принадлежит продавцу.',
          child: Column(
            children: [
              _AuthField(
                controller: _sellerCodeCtrl,
                label: 'Секретный код продавца',
                hint: 'Введите секретный код',
                obscureText: _obscureSellerCode,
                textCapitalization: TextCapitalization.characters,
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _obscureSellerCode = !_obscureSellerCode),
                  icon: Icon(
                    _obscureSellerCode
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.white54,
                    size: 19,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Демо-код: SELLER-2026',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(.30),
                    fontSize: 10.5,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _PrimaryButton(
                label: _sending ? 'Входим…' : 'Войти в аккаунт',
                icon: Icons.login_rounded,
                loading: _sending,
                onPressed: _sending ? null : _finish,
              ),
            ],
          ),
        );
    }
  }
}

class _ProgressHeader extends StatelessWidget {
  final int step;
  final int total;
  final String label;
  final Color color;

  const _ProgressHeader({
    required this.step,
    required this.total,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: List.generate(total, (index) {
              final active = index <= step;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  margin: EdgeInsets.only(right: index == total - 1 ? 0 : 5),
                  height: 4,
                  decoration: BoxDecoration(
                    color: active ? color : Colors.white.withOpacity(.10),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(.34),
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _AuthCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const _AuthCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xE809111B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(.09)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x65000000),
            blurRadius: 36,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF4B92FF).withOpacity(.11),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xFF6FAAFF).withOpacity(.12),
              ),
            ),
            child: Icon(icon, color: const Color(0xFF8DBDFF), size: 22),
          ),
          const SizedBox(height: 17),
          Text(
            title,
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w800,
              letterSpacing: -.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(.48),
              fontSize: 11.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final bool autofocus;
  final TextAlign textAlign;
  final double fontSize;
  final double letterSpacing;

  const _AuthField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.maxLength,
    this.autofocus = false,
    this.textAlign = TextAlign.start,
    this.fontSize = 14,
    this.letterSpacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      autofocus: autofocus,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      textAlign: textAlign,
      style: GoogleFonts.inter(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        letterSpacing: letterSpacing,
      ),
      cursorColor: const Color(0xFF8DBDFF),
      decoration: InputDecoration(
        counterText: '',
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon,
        labelStyle: GoogleFonts.inter(
          color: Colors.white.withOpacity(.56),
          fontSize: 11.5,
        ),
        hintStyle: GoogleFonts.inter(
          color: Colors.white.withOpacity(.21),
          fontSize: 13,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(.035),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(.10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF6EA8FF),
            width: 1.25,
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool loading;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4E8FFF),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: loading
              ? const SizedBox(
                  key: ValueKey('loading'),
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  key: const ValueKey('label'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(icon, size: 18),
                  ],
                ),
        ),
      ),
    );
  }
}
