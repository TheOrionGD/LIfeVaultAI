import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_transitions.dart';
import '../core/utils/date_formatter.dart';
import '../core/widgets/soft_panel.dart';
import '../core/widgets/empty_state_view.dart';
import '../models/vault_document.dart';
import '../state/vault_state.dart';
import 'document_detail_screen.dart';
import 'category_detail_screen.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({
    super.key,
    required this.vaultState,
    required this.onNavigateToScan,
  });

  final VaultState vaultState;
  final VoidCallback onNavigateToScan;

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  bool _isGridView = true;
  final _searchController = TextEditingController();

  static const _categories = [
    'All',
    'Identity',
    'Education',
    'Insurance',
    'Medical',
    'Vehicle',
    'Bills',
    'Warranties',
    'Receipts',
    'Voice Notes',
    'Other',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final docs = widget.vaultState.filteredDocuments;
    final allDocs = widget.vaultState.documents;
    final selectedCategory = widget.vaultState.selectedCategory;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Add Document Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Vault',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.darkText : AppColors.ink,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${allDocs.length} ${allDocs.length == 1 ? 'record' : 'records'} stored securely on-device',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkMuted : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                  FilledButton.icon(
                    onPressed: widget.onNavigateToScan,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Document'),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Search Bar & View Switcher
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => widget.vaultState.setSearchQuery(val),
                      decoration: InputDecoration(
                        hintText: 'Search vault by title, tags, or OCR text...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  widget.vaultState.setSearchQuery('');
                                  setState(() {});
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: isDark
                            ? AppColors.darkSurface
                            : AppColors.surface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Sort Order Menu
                  PopupMenuButton<VaultSortOrder>(
                    tooltip: 'Sort Records',
                    icon: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.border,
                        ),
                      ),
                      child: const Icon(Icons.sort_rounded, size: 20),
                    ),
                    onSelected: (order) => widget.vaultState.setSortOrder(order),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: VaultSortOrder.newest,
                        child: Text('Newest First'),
                      ),
                      const PopupMenuItem(
                        value: VaultSortOrder.expirySoonest,
                        child: Text('Expiring Soonest'),
                      ),
                      const PopupMenuItem(
                        value: VaultSortOrder.titleAZ,
                        child: Text('Title: A to Z'),
                      ),
                      const PopupMenuItem(
                        value: VaultSortOrder.titleZA,
                        child: Text('Title: Z to A'),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  // Grid / List Toggle
                  IconButton(
                    icon: Icon(
                      _isGridView
                          ? Icons.view_list_rounded
                          : Icons.grid_view_rounded,
                    ),
                    tooltip: _isGridView ? 'List View' : 'Grid View',
                    onPressed: () => setState(() => _isGridView = !_isGridView),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Category Filter Tabs with double-tap/long-press to open Folder Explorer
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((cat) {
                    final selected = selectedCategory.toLowerCase() ==
                        cat.toLowerCase();
                    final count = cat == 'All'
                        ? allDocs.length
                        : allDocs
                            .where((d) =>
                                d.category.toLowerCase() == cat.toLowerCase())
                            .length;
                    final accent = AppTheme.of(context).primaryAccent;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        avatar: selected && cat != 'All'
                            ? const Icon(Icons.folder_open_rounded, size: 14)
                            : null,
                        backgroundColor: selected
                            ? (isDark ? accent : AppColors.ink)
                            : null,
                        label: Text(
                          '$cat ($count)',
                          style: TextStyle(
                            color: selected
                                ? (isDark ? AppColors.ink : Colors.white)
                                : null,
                            fontWeight: selected
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                        onPressed: () {
                          if (selected && cat != 'All') {
                            // If already selected, open the deep folder explorer
                            Navigator.push(
                              context,
                              VaultFadeSlideRoute(
                                builder: (_) => CategoryDetailScreen(
                                  category: cat,
                                  vaultState: widget.vaultState,
                                ),
                              ),
                            );
                          } else {
                            widget.vaultState.setCategoryFilter(cat);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // Document Grid / List or Empty State
              if (docs.isEmpty)
                EmptyStateView(
                  icon: Icons.folder_open_outlined,
                  title: allDocs.isEmpty
                      ? 'Your Vault is Empty'
                      : 'No Records Found',
                  description: allDocs.isEmpty
                      ? 'Start building your private vault by scanning a document, receipt, or recording a voice note.'
                      : 'No documents match your current filter or search query.',
                  actionLabel: allDocs.isEmpty ? 'Scan First Document' : null,
                  onAction:
                      allDocs.isEmpty ? widget.onNavigateToScan : null,
                )
              else if (_isGridView)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    mainAxisExtent: 185,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    return _DocumentCardGrid(
                      document: docs[index],
                      onTap: () => _openDetail(docs[index]),
                    );
                  },
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return _DocumentCardList(
                      document: docs[index],
                      onTap: () => _openDetail(docs[index]),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetail(VaultDocument doc) {
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
}

class _DocumentCardGrid extends StatelessWidget {
  const _DocumentCardGrid({required this.document, required this.onTap});

  final VaultDocument document;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final catColor = AppColors.getCategoryColor(document.category);
    final catIcon = AppColors.getCategoryIcon(document.category);

    return SoftPanel(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: isDark ? 0.25 : 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(catIcon, color: catColor, size: 22),
              ),
              if (document.isFavorite)
                const Icon(
                  Icons.star_rounded,
                  color: AppColors.butter,
                  size: 20,
                ),
            ],
          ),
          const Spacer(),
          Text(
            document.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15,
              color: isDark ? AppColors.darkText : AppColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            document.category,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkMuted : AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          if (document.expiryDate != null)
            Text(
              DateFormatter.formatExpiryRelative(document.expiryDate!),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: document.isExpired
                    ? AppColors.crimson
                    : (document.urgency == DocumentUrgency.critical
                        ? AppColors.coral
                        : AppColors.mint),
              ),
            )
          else if (document.amount != null)
            Text(
              document.amount!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.mint,
              ),
            )
          else
            Text(
              DateFormatter.formatShort(document.createdAt),
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.darkMuted : AppColors.muted,
              ),
            ),
        ],
      ),
    );
  }
}

class _DocumentCardList extends StatelessWidget {
  const _DocumentCardList({required this.document, required this.onTap});

  final VaultDocument document;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final catColor = AppColors.getCategoryColor(document.category);
    final catIcon = AppColors.getCategoryIcon(document.category);

    return SoftPanel(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: isDark ? 0.25 : 0.15),
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
                  document.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: isDark ? AppColors.darkText : AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${document.category} • ${DateFormatter.formatRelativeTime(document.createdAt)}',
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
          if (document.expiryDate != null)
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: document.isExpired
                      ? AppColors.crimson.withValues(alpha: 0.15)
                      : (document.urgency == DocumentUrgency.critical
                          ? AppColors.coral.withValues(alpha: 0.15)
                          : AppColors.mint.withValues(alpha: 0.15)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  DateFormatter.formatExpiryRelative(document.expiryDate!),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: document.isExpired
                        ? AppColors.crimson
                        : (document.urgency == DocumentUrgency.critical
                            ? AppColors.coral
                            : AppColors.mint),
                  ),
                ),
              ),
            ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right_rounded,
            color: isDark ? AppColors.darkMuted : AppColors.muted,
          ),
        ],
      ),
    );
  }
}
