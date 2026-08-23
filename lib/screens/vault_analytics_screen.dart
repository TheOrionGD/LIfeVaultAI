import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/soft_panel.dart';
import '../models/vault_document.dart';
import '../state/vault_state.dart';

class VaultAnalyticsScreen extends StatelessWidget {
  const VaultAnalyticsScreen({super.key, required this.vaultState});

  final VaultState vaultState;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalSpend = vaultState.totalVaultSpend;
    final receipts = vaultState.receipts;
    final documents = vaultState.documents;
    final voiceNotes = vaultState.voiceNotes;
    final categoryCounts = vaultState.categoryCounts;
    final categorySpend = vaultState.categorySpendTotals;
    final reminders = vaultState.reminders;

    // Expiry Forecast Buckets
    final expiredCount =
        reminders.where((r) => r.urgency == DocumentUrgency.expired).length;
    final urgentCount =
        reminders.where((r) => r.urgency == DocumentUrgency.critical).length;
    final impendingCount =
        reminders.where((r) => r.urgency == DocumentUrgency.impending).length;
    final safeCount =
        reminders.where((r) => r.urgency == DocumentUrgency.normal).length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.canvas,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
        title: const Text('Vault Analytics & Spend'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Financial Hero Overview
                SoftPanel(
                  color: isDark ? AppColors.darkSurface : AppColors.mintLight,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.mint.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'TOTAL VAULT RECORD VALUE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.mint,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              vaultState.formatSpend(totalSpend, decimals: 2),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? AppColors.darkText
                                    : AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tracked across ${receipts.length} receipts and ${documents.where((d) => d.amount != null).length} billed records',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.darkMuted
                                    : AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: AppColors.mint.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.query_stats_rounded,
                          color: AppColors.mint,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Expiration Timeline Forecast
                SoftPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Document Expiration Vigil Forecast',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Distribution of upcoming renewals and expiration deadlines.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkMuted
                              : AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _ForecastBox(
                            title: 'Expired',
                            count: expiredCount,
                            color: AppColors.crimson,
                          ),
                          const SizedBox(width: 8),
                          _ForecastBox(
                            title: '< 7 Days',
                            count: urgentCount,
                            color: AppColors.coral,
                          ),
                          const SizedBox(width: 8),
                          _ForecastBox(
                            title: '< 30 Days',
                            count: impendingCount,
                            color: AppColors.butter,
                          ),
                          const SizedBox(width: 8),
                          _ForecastBox(
                            title: 'Safe (>30d)',
                            count: safeCount,
                            color: AppColors.mint,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Category Distribution & Spend Bar Gauges
                SoftPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Category Item & Spend Distribution',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (categoryCounts.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              'No documents stored yet to compute category distribution.',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkMuted
                                    : AppColors.muted,
                              ),
                            ),
                          ),
                        )
                      else
                        ...categoryCounts.entries.map((entry) {
                          final cat = entry.key;
                          final count = entry.value;
                          final spend = categorySpend[cat] ?? 0.0;
                          final percent = (count / documents.length).clamp(0.0, 1.0);
                          final catColor = AppColors.getCategoryColor(cat);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          AppColors.getCategoryIcon(cat),
                                          size: 16,
                                          color: catColor,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          cat,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '$count docs ${spend > 0 ? '• ${vaultState.formatSpend(spend, decimals: 2)}' : ''}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? AppColors.darkMuted
                                            : AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: percent,
                                    minHeight: 8,
                                    backgroundColor: isDark
                                        ? AppColors.darkBorder
                                        : AppColors.border,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(catColor),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Vault Assets Breakdown Counters
                Row(
                  children: [
                    Expanded(
                      child: SoftPanel(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.folder_copy_outlined,
                              color: AppColors.coral,
                              size: 24,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${documents.length}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Text(
                              'Total Vault Docs',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SoftPanel(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.receipt_long_outlined,
                              color: AppColors.mint,
                              size: 24,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${receipts.length}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Text(
                              'Stored Receipts',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SoftPanel(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.mic_none_rounded,
                              color: AppColors.butter,
                              size: 24,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${voiceNotes.length}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Text(
                              'Voice Notes',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
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
    );
  }
}

class _ForecastBox extends StatelessWidget {
  const _ForecastBox({
    required this.title,
    required this.count,
    required this.color,
  });

  final String title;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
