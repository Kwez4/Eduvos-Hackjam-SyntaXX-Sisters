import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'home_screen.dart';
import 'seller_dashboard.dart';
import 'supabase_service.dart';

bool isAllowedLoginEmail(String email) {
  return RegExp(
    r'^(?:EDUV[0-9]{7}@vossie\.net|[A-Z]+\.[A-Z]+@eduvos\.com)$',
    caseSensitive: false,
  ).hasMatch(email.trim());
}

bool isValidLoginPassword(String password) {
  return password.length >= 8 &&
      RegExp(r'[A-Z]').hasMatch(password) &&
      RegExp(r'[^A-Za-z0-9\s]').hasMatch(password);
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSeller = false;
  bool _isCreatingAccount = false;
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final email = _identifierController.text.trim();
      final response = _isCreatingAccount
          ? await SupabaseService.signUp(
              email: email,
              password: _passwordController.text,
              isSeller: _isSeller,
            )
          : await SupabaseService.signIn(
              email: email,
              password: _passwordController.text,
            );

      if (_isCreatingAccount && response.session == null) {
        _showMessage(
          'Account created. Check your email to confirm it, then sign in.',
        );
        if (mounted) {
          setState(() {
            _isCreatingAccount = false;
            _passwordController.clear();
            _confirmPasswordController.clear();
          });
        }
        return;
      }

      final accountType = response.user?.userMetadata?['account_type'];
      final selectedType = _isSeller ? 'seller' : 'customer';
      if (accountType != null && accountType != selectedType) {
        await SupabaseService.signOut();
        _showMessage(
          'This account is registered as a ${accountType.toString()}. '
          'Choose that account type and try again.',
        );
        return;
      }

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil<void>(
        MaterialPageRoute<void>(
          builder: (_) =>
              _isSeller ? const SellerDashboard() : const HomeScreen(),
        ),
        (route) => false,
      );
    } on AuthException catch (error) {
      _showMessage(error.message);
    } on StateError catch (error) {
      _showMessage(error.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = _identifierController.text.trim();
    if (!isAllowedLoginEmail(email)) {
      _showMessage('Enter your Eduvos email address first.');
      return;
    }

    try {
      await SupabaseService.resetPassword(email);
      _showMessage('Password reset instructions sent to $email.');
    } on AuthException catch (error) {
      _showMessage(error.message);
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              _buildWordmark(),
              const SizedBox(height: 8),
              Text(
                'Your campus. Your people.\nYour marketplace.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 15,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 28),
              _buildRoleSelector(),
              const SizedBox(height: 24),
              _buildLoginForm(),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _isSubmitting
                    ? null
                    : () => setState(() {
                        _isCreatingAccount = !_isCreatingAccount;
                        _confirmPasswordController.clear();
                      }),
                child: Text(
                  _isCreatingAccount
                      ? 'Already have an account? Sign in'
                      : 'New here? Create an account',
                ),
              ),
              const SizedBox(height: 28),
              Center(
                child: Text(
                  'Same campus. New opportunities. ♥',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _identifierController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Email address',
              prefixIcon: Icon(Icons.mail_outline),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter your email address';
              }
              if (!isAllowedLoginEmail(value)) {
                return 'Error: You must use a valid @vossie.net/@eduvos.com email.';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              helperText:
                  'At least 8 characters, 1 capital letter, and 1 symbol '
                  '(e.g. @, #, *, !).',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (value) {
              if (!isValidLoginPassword(value ?? '')) {
                return 'Password needs 8+ characters, a capital letter, '
                    'and a symbol (e.g. @, #, *, !)';
              }
              return null;
            },
          ),
          if (_isCreatingAccount) ...[
            const SizedBox(height: 14),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Confirm password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              validator: (value) {
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _isSubmitting ? null : _sendPasswordReset,
              child: Text(
                'Forgot password?',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    '${_isCreatingAccount ? 'Create account' : 'Sign in'} '
                    'as ${_isSeller ? 'Seller' : 'Customer'}',
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordmark() {
    // NOTE: this recreates the layout with system fonts. For a pixel-exact
    // match of your hand-drawn logo, drop your exported PNG/SVG into
    // assets/ and swap this for an Image.asset(...).
    return Column(
      children: [
        Icon(
          Icons.emoji_events_outlined,
          color: Theme.of(context).colorScheme.primary,
          size: 32,
        ),
        const SizedBox(height: 4),
        Text(
          'VOSSIE VIBE',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment<bool>(
          value: false,
          label: Text('Customer'),
          icon: Icon(Icons.shopping_bag_outlined),
        ),
        ButtonSegment<bool>(
          value: true,
          label: Text('Seller'),
          icon: Icon(Icons.storefront_outlined),
        ),
      ],
      selected: {_isSeller},
      onSelectionChanged: (selection) {
        setState(() => _isSeller = selection.first);
      },
    );
  }
}
