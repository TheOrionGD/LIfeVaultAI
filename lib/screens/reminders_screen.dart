import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_transitions.dart';
import '../core/utils/date_formatter.dart';
import '../core/widgets/soft_panel.dart';
import '../core/widgets/empty_state_view.dart';
import '../models/vault_document.dart';
import '../models/vault_reminder.dart';
import '../state/vault_state.dart';
import 'document_detail_screen.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({
    super.key,
    required this.vaultState,
    required this.onNavigateToScan,
  });

  final VaultState vaultState;
  final VoidCallback onNavigateToScan;

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  bool _notificationsEnabled = true;
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allReminders = widget.vaultState.reminders;

    // Filter reminders by category
    final reminders = _selectedFilter == 'All'
        ? allReminders
        : allReminders
            .where((r) =>
                r.category.toLowerCase() == _selectedFilter.toLowerCase())
            .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Reminders & Alerts',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.darkText : AppColors.ink,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Proactive countdowns computed from your active document expiration dates.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.darkMuted : AppColors.muted,
                ),
              ),

              const SizedBox(height: 20),

              // Notification Policy Card
              SoftPanel(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.of(context).primaryAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.notifications_active_outlined,
                        color: AppTheme.of(context).primaryAccent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Expiry Alerts (30, 7, & 1 Day Prior)',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: isDark ? AppColors.darkText : AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Local alerts scheduled privately on-device',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.darkMuted
                                  : AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _notificationsEnabled,
                      activeThumbColor: AppTheme.of(context).primaryAccent,
                      onChanged: (val) =>
                          setState(() => _notificationsEnabled = val),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Category Filter Pills (if reminders exist)
              if (allReminders.isNotEmpty) ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      'All',
                      'Identity',
                      'Insurance',
                      'Vehicle',
                      'Warranties',
                      'Bills',
                      'Medical',
                    ].map((cat) {
                      final selected = _selectedFilter == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat),
                          selected: selected,
                          onSelected: (_) =>
                              setState(() => _selectedFilter = cat),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Reminders List or Empty State
              if (reminders.isEmpty)
                EmptyStateView(
                  icon: Icons.event_available_outlined,
                  iconColor: AppColors.mint,
                  title: allReminders.isEmpty
                      ? 'No Expiry Reminders Active'
                      : 'No Reminders in "$_selectedFilter"',
                  description: allReminders.isEmpty
                      ? 'When you scan documents or warranties with expiration dates, proactive countdown alerts will automatically appear here.'
                      : 'Try switching categories or add a new record with an expiry date.',
                  actionLabel:
                      allReminders.isEmpty ? 'Scan / Add Document' : null,
                  onAction:
                      allReminders.isEmpty ? widget.onNavigateToScan : null,
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reminders.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final rem = reminders[index];
                    return _ReminderCard(
                      reminder: rem,
                      onTap: () {
                        final doc = widget.vaultState.documents
                            .where((d) => d.id == rem.documentId)
                            .firstOrNull;
                        if (doc != null) {
                          Navigator.push(
                            context,
                            VaultFadeSlideRoute(
                              builder: (_) => DocumentDetailScreen(
                                document: doc,
                                vaultState: widget.vaultState,
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.reminder, required this.onTap});

  final VaultReminder reminder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final catColor = AppColors.getCategoryColor(reminder.category);
    final catIcon = AppColors.getCategoryIcon(reminder.category);

    Color badgeBg;
    Color badgeTextColor;
    String badgeText;

    if (reminder.urgency == DocumentUrgency.expired) {
      badgeBg = AppColors.crimson.withValues(alpha: 0.15);
      badgeTextColor = AppColors.crimson;
      badgeText = 'EXPIRED';
    } else if (reminder.urgency == DocumentUrgency.critical) {
      badgeBg = AppColors.coral.withValues(alpha: 0.18);
      badgeTextColor = AppColors.coral;
      badgeText = 'URGENT (${reminder.daysRemaining}d)';
    } else if (reminder.urgency == DocumentUrgency.impending) {
      badgeBg = AppColors.butter.withValues(alpha: 0.25);
      badgeTextColor = isDark ? AppColors.butter : const Color(0xFFB45309);
      badgeText = '${reminder.daysRemaining} DAYS LEFT';
    } else {
      badgeBg = AppColors.mint.withValues(alpha: 0.15);
      badgeTextColor = AppColors.mint;
      badgeText = '${reminder.daysRemaining} DAYS';
    }

    return SoftPanel(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: isDark ? 0.25 : 0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(catIcon, color: catColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.documentTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkText : AppColors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${reminder.category} • Expires ${DateFormatter.formatShort(reminder.expiryDate)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkMuted : AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: badgeTextColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.chevron_right_rounded,
            color: isDark ? AppColors.darkMuted : AppColors.muted,
          ),
        ],
      ),
    );
  }
}
