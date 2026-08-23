import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_transitions.dart';
import '../core/utils/date_formatter.dart';
import '../core/widgets/soft_panel.dart';
import '../core/widgets/empty_state_view.dart';
import '../models/vault_document.dart';
import '../state/vault_state.dart';
import 'document_detail_screen.dart';
import 'scan_document_screen.dart';

class CategoryDetailScreen extends StatefulWidget {
  const CategoryDetailScreen({
    super.key,
    required this.category,
    required this.vaultState,
  });

  final String category;
  final VaultState vaultState;

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  String _searchQuery = '';
  String _filter = 'All'; // 'All', 'Favorites', 'Expiring Soon'

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final catColor = AppColors.getCategoryColor(widget.category);
    final catIcon = AppColors.getCategoryIcon(widget.category);

    final allCatDocs = widget.vaultState.documents
        .where((d) =>
            d.category.toLowerCase() == widget.category.toLowerCase())
        .toList();

    var docs = allCatDocs.where((d) {
      if (_filter == 'Favorites' && !d.isFavorite) return false;
      if (_filter == 'Expiring Soon' &&
          (d.expiryDate == null || d.expiresIn == null || d.expiresIn! > 30)) {
        return false;
      }
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.trim().toLowerCase();
        final matchTitle = d.title.toLowerCase().contains(q);
        final matchNotes = d.notes.toLowerCase().contains(q);
        final matchNum = d.documentNumber?.toLowerCase().contains(q) ?? false;
        return matchTitle || matchNotes || matchNum;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.canvas,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
        title: Text('${widget.category} Folder'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Header Banner
                SoftPanel(
                  color: isDark ? AppColors.darkSurface : AppColors.surface,
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: isDark ? 0.25 : 0.15),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(catIcon, color: catColor, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.category,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: isDark ? AppColors.darkText : AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${allCatDocs.length} ${allCatDocs.length == 1 ? 'record' : 'records'} stored under this folder',
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
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            VaultFadeSlideRoute(
                              builder: (_) => ScanDocumentScreen(
                                vaultState: widget.vaultState,
                              ),
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: catColor,
                          foregroundColor: AppColors.ink,
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Search Bar
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search within ${widget.category}...',
                    prefixIcon: const Icon(Icons.search_rounded),
                  ),
                ),

                const SizedBox(height: 14),

                // Filter chips (horizontally scrollable to eliminate mobile overflow)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Favorites', 'Expiring Soon'].map((f) {
                      final isSelected = _filter == f;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(f),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _filter = f),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // Document list or empty state
                if (docs.isEmpty)
                  EmptyStateView(
                    icon: catIcon,
                    iconColor: catColor,
                    title: allCatDocs.isEmpty
                        ? 'No ${widget.category} Records'
                        : 'No Matching Documents',
                    description: allCatDocs.isEmpty
                        ? 'Scan or upload your first ${widget.category.toLowerCase()} document to keep it encrypted and backed up.'
                        : 'Try adjusting your search query or filter chip above.',
                    actionLabel: allCatDocs.isEmpty ? 'Scan Document' : null,
                    onAction: allCatDocs.isEmpty
                        ? () {
                            Navigator.push(
                              context,
                              VaultFadeSlideRoute(
                                builder: (_) => ScanDocumentScreen(
                                  vaultState: widget.vaultState,
                                ),
                              ),
                            );
                          }
                        : null,
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      return SoftPanel(
                        onTap: () {
                          Navigator.push(
                            context,
                            VaultFadeSlideRoute(
                              builder: (_) => DocumentDetailScreen(
                                document: doc,
                                vaultState: widget.vaultState,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: catColor.withValues(
                                    alpha: isDark ? 0.25 : 0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(catIcon, color: catColor, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doc.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                      color: isDark
                                          ? AppColors.darkText
                                          : AppColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Added ${DateFormatter.formatShort(doc.createdAt)}${doc.documentNumber != null ? ' • #${doc.documentNumber}' : ''}',
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
                            if (doc.expiryDate != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: doc.isExpired
                                      ? AppColors.crimson.withValues(alpha: 0.15)
                                      : (doc.urgency == DocumentUrgency.critical
                                          ? AppColors.coral.withValues(alpha: 0.15)
                                          : AppColors.mint.withValues(alpha: 0.15)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  DateFormatter.formatExpiryRelative(
                                      doc.expiryDate!),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: doc.isExpired
                                        ? AppColors.crimson
                                        : (doc.urgency ==
                                                DocumentUrgency.critical
                                            ? AppColors.coral
                                            : AppColors.mint),
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 20,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
