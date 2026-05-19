import 'package:flutter/material.dart';
import 'package:myautobiography/admin/models/star_request.dart';
import 'package:myautobiography/admin/services/stargazer_service.dart';

class StarRequestsPage extends StatefulWidget {
  const StarRequestsPage({super.key, required this.filterNotifier});
  final ValueNotifier<bool> filterNotifier;

  @override
  State<StarRequestsPage> createState() => StarRequestsPageState();
}

class StarRequestsPageState extends State<StarRequestsPage> {
  final _service = StargazerService();
  late Future<List<StarRequest>> _requestsFuture;
  final _searchController = SearchController();
  String _searchQuery = '';
  DateTime? _filterStart;
  DateTime? _filterEnd;

  bool get _isFilterActive => _filterStart != null || _searchQuery.isNotEmpty;

  Future<List<StarRequest>> _loadRequests() {
    return _service.fetchStarRequests(
      searchQuery: _searchQuery,
      startDate: _filterStart,
      endDate: _filterEnd,
    );
  }

  @override
  void initState() {
    super.initState();
    _requestsFuture = _loadRequests();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
    _updateFilterNotifier();
  }

  void _updateFilterNotifier() {
    widget.filterNotifier.value = _isFilterActive;
  }

  void refresh() {
    setState(() {
      _requestsFuture = _loadRequests();
    });
  }

  void clearFiltersAndRefresh() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _filterStart = null;
      _filterEnd = null;
    });
    widget.filterNotifier.value = false;
  }

  Future<void> _openDateRangePicker() async {
    final cs = Theme.of(context).colorScheme;
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _filterStart != null
          ? DateTimeRange(
              start: _filterStart!,
              end: _filterEnd ?? _filterStart!,
            )
          : null,
      initialEntryMode: DatePickerEntryMode.calendar,
      saveText: 'Search',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: cs.onPrimaryContainer,
              backgroundColor: cs.primaryContainer,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        child: child!,
      ),
    );
    if (result == null) return;
    setState(() {
      _filterStart = result.start;
      _filterEnd = result.end;
    });
    _updateFilterNotifier();
  }

  Future<void> _deleteRequest(String id) async {
    await _service.deleteStarRequest(id);
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<List<StarRequest>>(
      future: _requestsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  'Loading star requests…',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cloud_off_rounded,
                      size: 40,
                      color: colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Unable to load star requests',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check your connection and try again.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: refresh,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try Again'),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final all = snapshot.data!;
        final requests = all.where((r) {
          final matchesSearch =
              _searchQuery.isEmpty ||
              r.stargazer.fullName.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              r.stargazer.email.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              r.stargazer.displayName.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );
          if (_filterStart == null) return matchesSearch;
          final end = _filterEnd ?? _filterStart!;
          final endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59);
          final created = DateTime(
            r.createdAt.year,
            r.createdAt.month,
            r.createdAt.day,
          );
          final matchesDate =
              !created.isBefore(_filterStart!) && !created.isAfter(endOfDay);
          return matchesSearch && matchesDate;
        }).toList();

        return CustomScrollView(
          slivers: [
            // Stats header
            SliverToBoxAdapter(child: _StatsHeader(total: all.length)),

            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: SearchBar(
                  controller: _searchController,
                  hintText: 'Search by name, email or username…',
                  leading: Icon(
                    Icons.search_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  trailing: [
                    if (_searchQuery.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                          _updateFilterNotifier();
                        },
                      ),
                    IconButton(
                      icon: Icon(
                        Icons.calendar_month_rounded,
                        color: _filterStart != null
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                      tooltip: 'Filter by requested date',
                      onPressed: _openDateRangePicker,
                    ),
                  ],
                  onChanged: _onSearchChanged,
                  elevation: const WidgetStatePropertyAll(0),
                  backgroundColor: WidgetStatePropertyAll(
                    colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            ),

            // Result count
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 16, bottom: 8),
                child: Text(
                  requests.isEmpty
                      ? 'No results'
                      : _isFilterActive
                      ? 'Filtered Records: ${requests.length}'
                      : 'Full Records: ${requests.length}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),

            // List
            if (requests.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 48,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No star requests match your search',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
                sliver: SliverList.separated(
                  itemCount: requests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _StarRequestCard(
                    request: requests[index],
                    onDelete: () => _deleteRequest(requests[index].id),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─── Stats Header ─────────────────────────────────────────────────────────────

class _StatsHeader extends StatelessWidget {
  const _StatsHeader({required this.total});
  final int total;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.secondary, colorScheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colorScheme.secondary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Star Requests',
                  style: TextStyle(
                    color: colorScheme.onSecondary.withOpacity(0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$total',
                  style: TextStyle(
                    color: colorScheme.onSecondary,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.onSecondary.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Pending requests',
                    style: TextStyle(
                      color: colorScheme.onSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colorScheme.onSecondary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star_rounded,
              size: 32,
              color: colorScheme.onSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Star Request Card ────────────────────────────────────────────────────────

const _avatarColors = [
  Color(0xFF6750A4),
  Color(0xFF00696D),
  Color(0xFF8B4000),
  Color(0xFF006A6A),
  Color(0xFF7D5260),
  Color(0xFF0062A1),
];

class _StarRequestCard extends StatefulWidget {
  const _StarRequestCard({required this.request, required this.onDelete});
  final StarRequest request;
  final Future<void> Function() onDelete;

  @override
  State<_StarRequestCard> createState() => _StarRequestCardState();
}

class _StarRequestCardState extends State<_StarRequestCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnim;
  bool _isDeleting = false;

  Future<void> _confirmDelete() async {
    final sg = widget.request.stargazer;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Star Request'),
        content: Text(
          'Are you sure you want to delete the star request from "${sg.fullName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      await widget.onDelete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _controller.forward() : _controller.reverse();
  }

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _formatDate(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = _months[dt.month - 1];
    final year = dt.year;
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$day $month $year, ${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sg = widget.request.stargazer;
    final initials =
        '${sg.firstName[0]}${sg.lastName.isNotEmpty ? sg.lastName[0] : ''}'
            .toUpperCase();
    final avatarColor =
        _avatarColors[sg.firstName.codeUnitAt(0) % _avatarColors.length];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.6)),
      ),
      color: colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _toggle,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar with gradient ring
                  Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [avatarColor, avatarColor.withOpacity(0.4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 26,
                      backgroundColor: avatarColor,
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sg.fullName,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              '@${sg.displayName}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: colorScheme.secondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            _StatusBadge(status: widget.request.status),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                sg.email,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _isDeleting
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.error,
                              ),
                            )
                          : IconButton(
                              icon: Icon(
                                Icons.delete_outline_rounded,
                                color: colorScheme.error,
                              ),
                              onPressed: _confirmDelete,
                              tooltip: 'Delete',
                              visualDensity: VisualDensity.compact,
                            ),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Expandable detail section
            SizeTransition(
              sizeFactor: _expandAnim,
              child: Column(
                children: [
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: colorScheme.outlineVariant,
                  ),
                  Container(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Column(
                      children: [
                        _DetailTile(
                          icon: Icons.tag_rounded,
                          title: 'Status',
                          value: widget.request.status,
                          iconColor: Colors.orange,
                        ),
                        const SizedBox(height: 10),
                        _DetailTile(
                          icon: Icons.calendar_month_outlined,
                          title: 'Requested On',
                          value: _formatDate(widget.request.createdAt),
                          iconColor: colorScheme.secondary,
                        ),
                        // const SizedBox(height: 10),
                        // _DetailTile(
                        //   icon: Icons.update_rounded,
                        //   title: 'Last Updated',
                        //   value: _formatDate(widget.request.updatedAt),
                        //   iconColor: colorScheme.tertiary,
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPending = status.toLowerCase() == 'pending';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isPending
            ? Colors.orange.withOpacity(0.15)
            : colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          color: isPending
              ? Colors.orange.shade800
              : colorScheme.onTertiaryContainer,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.iconColor,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurface),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
