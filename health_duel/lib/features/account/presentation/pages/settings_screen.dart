import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_duel/core/bloc/effect/dialog/config/dialog_action_config.dart';
import 'package:health_duel/core/presentation/widgets/widgets.dart';
import 'package:health_duel/core/theme/theme.dart';
import 'package:health_duel/data/session/data/models/user_model.dart';
import 'package:health_duel/features/account/presentation/bloc/settings_bloc.dart';
import 'package:health_duel/features/account/presentation/bloc/settings_event.dart';
import 'package:health_duel/features/account/presentation/bloc/settings_state.dart';
import 'package:url_launcher/url_launcher.dart';

/// Settings screen — profile display, sign out, privacy policy link, and
/// permanent account deletion (M2.4 in the MVP launch plan).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _privacyUrl = 'https://health-duel.web.app/privacy';

  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(const SettingsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return EffectListener<SettingsBloc, SettingsState>(
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) => switch (state) {
            SettingsLoaded() => _SettingsBody(
                state: state,
                onOpenPrivacyPolicy: () => _openUrl(context, _privacyUrl),
              ),
            SettingsError(:final message) => _ErrorView(
                message: message,
                onRetry: () => context
                    .read<SettingsBloc>()
                    .add(const SettingsLoadRequested()),
              ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $url')),
      );
    }
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody({required this.state, required this.onOpenPrivacyPolicy});

  final SettingsLoaded state;
  final VoidCallback onOpenPrivacyPolicy;

  bool get _isBusy => state.isSigningOut || state.isDeleting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _ProfileHeader(user: state.user),
            const SizedBox(height: AppSpacing.xl),

            const _SectionHeader(title: 'Legal'),
            const SizedBox(height: AppSpacing.sm),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: _isBusy ? null : onOpenPrivacyPolicy,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            const _SectionHeader(title: 'Account'),
            const SizedBox(height: AppSpacing.sm),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: const Text('Sign Out'),
                onTap: _isBusy
                    ? null
                    : () => context
                        .read<SettingsBloc>()
                        .add(const SettingsSignOutRequested()),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            _SectionHeader(title: 'Danger Zone', color: theme.colorScheme.error),
            const SizedBox(height: AppSpacing.sm),
            Card(
              margin: EdgeInsets.zero,
              color: appColors.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.3)),
              ),
              child: ListTile(
                leading: Icon(Icons.delete_forever_outlined, color: theme.colorScheme.error),
                title: Text('Delete Account', style: TextStyle(color: theme.colorScheme.error)),
                subtitle: const Text('Permanently removes your profile, friends, and streak.'),
                onTap: _isBusy ? null : () => _handleDeleteAccount(context),
              ),
            ),
          ],
        ),
        if (_isBusy)
          const ColoredBox(
            color: Colors.black38,
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    final confirmed = await AppDialogs.confirm(
      context: context,
      title: 'Delete your account?',
      message: 'This permanently removes your profile, friends list, and streak. '
          "Duels you completed stay in your opponents' history but are no longer "
          "linked to you. This can't be undone.",
      confirmLabel: 'Delete',
      isDestructive: true,
      icon: DialogIcon.warning,
    );
    if (!confirmed) return;

    String? password;
    if (state.requiresPasswordReauth) {
      if (!context.mounted) return;
      password = await _promptPassword(context);
      if (password == null || password.isEmpty) return;
    }

    if (!context.mounted) return;
    context
        .read<SettingsBloc>()
        .add(SettingsDeleteAccountRequested(password: password));
  }

  Future<String?> _promptPassword(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm your password'),
        content: PasswordTextField(
          controller: controller,
          helperText: 'Required to confirm this is really you.',
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (value) => Navigator.of(dialogContext).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photoUrl = user.photoUrl;
    final name = user.name;
    final email = user.email;

    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundImage: (photoUrl != null && photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null,
          child: (photoUrl == null || photoUrl.isEmpty)
              ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: theme.textTheme.headlineSmall)
              : null,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: theme.textTheme.titleLarge),
              if (email.isNotEmpty)
                Text(email, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.color});
  final String title;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title.toUpperCase(),
      style: theme.textTheme.labelMedium?.copyWith(
        color: color ?? theme.colorScheme.onSurfaceVariant,
        letterSpacing: 0.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
