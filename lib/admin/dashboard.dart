import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myautobiography/main.dart' show isAdminLoggedIn;
import 'models/stargazer.dart';
import 'services/stargazer_service.dart';
import 'services/admin_auth_service.dart';
import 'star_requests_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _stargazersKey = GlobalKey<_StargazersTabState>();
  final _starRequestsKey = GlobalKey<StarRequestsPageState>();
  final _stargazersFilterNotifier = ValueNotifier<bool>(false);
  final _starRequestsFilterNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _stargazersFilterNotifier.dispose();
    _starRequestsFilterNotifier.dispose();
    super.dispose();
  }

  void _refresh() {
    _stargazersKey.currentState?.clearFiltersAndRefresh();
    _starRequestsKey.currentState?.clearFiltersAndRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.admin_panel_settings_rounded,
                size: 18,
                color: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'MAB Admin',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ],
        ),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people_alt_rounded), text: 'Stargazers'),
            Tab(icon: Icon(Icons.star_rounded), text: 'Star Requests'),
          ],
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          indicatorSize: TabBarIndicatorSize.tab,
        ),
        actions: [
          ListenableBuilder(
            listenable: Listenable.merge([
              _stargazersFilterNotifier,
              _starRequestsFilterNotifier,
            ]),
            builder: (context, _) {
              final isActive =
                  _stargazersFilterNotifier.value ||
                  _starRequestsFilterNotifier.value;
              return isActive
                  ? TextButton(
                      onPressed: _refresh,
                      child: Text(
                        'Reset',
                        style: TextStyle(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () async {
              await AdminAuthService.logout();
              isAdminLoggedIn = false;
              if (context.mounted) context.go('/hvr/admin');
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _StargazersTab(
            key: _stargazersKey,
            filterNotifier: _stargazersFilterNotifier,
          ),
          StarRequestsPage(
            key: _starRequestsKey,
            filterNotifier: _starRequestsFilterNotifier,
          ),
        ],
      ),
    );
  }
}

// ─── Stargazers Tab ───────────────────────────────────────────────────────────

class _StargazersTab extends StatefulWidget {
  const _StargazersTab({super.key, required this.filterNotifier});
  final ValueNotifier<bool> filterNotifier;

  @override
  State<_StargazersTab> createState() => _StargazersTabState();
}

class _StargazersTabState extends State<_StargazersTab> {
  final _service = StargazerService();
  late Future<List<Stargazer>> _stargazersFuture;
  final _searchController = SearchController();
  String _searchQuery = '';
  DateTime? _filterStart;
  DateTime? _filterEnd;

  bool get _isFilterActive => _filterStart != null || _searchQuery.isNotEmpty;

  Future<List<Stargazer>> _loadStargazers() {
    return _service.fetchStargazers(
      searchQuery: _searchQuery,
      startDate: _filterStart,
      endDate: _filterEnd,
    );
  }

  @override
  void initState() {
    super.initState();
    _stargazersFuture = _loadStargazers();
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
      _stargazersFuture = _loadStargazers();
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

  Future<void> _deleteStargazer(String id) async {
    await _service.deleteStargazer(id);
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FutureBuilder<List<Stargazer>>(
      future: _stargazersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  'Loading stargazers…',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          final errorText = snapshot.error.toString();
          final isAuthError =
              errorText.contains('Auth token missing') ||
              errorText.contains('401') ||
              errorText.contains('403');

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
                    'Unable to load stargazers',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isAuthError
                        ? 'Your session expired. Please login again.'
                        : 'Check your connection and try again.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (isAuthError)
                    FilledButton.icon(
                      onPressed: () async {
                        await AdminAuthService.logout();
                        isAdminLoggedIn = false;
                        if (context.mounted) context.go('/hvr/admin');
                      },
                      icon: const Icon(Icons.login_rounded),
                      label: const Text('Login Again'),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    )
                  else
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
        final stargazers = all.where((s) {
          final matchesSearch =
              _searchQuery.isEmpty ||
              s.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              s.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              s.displayName.toLowerCase().contains(_searchQuery.toLowerCase());
          if (_filterStart == null) return matchesSearch;
          final end = _filterEnd ?? _filterStart!;
          final endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59);
          final joined = DateTime(
            s.createdAt.year,
            s.createdAt.month,
            s.createdAt.day,
          );
          final matchesDate =
              !joined.isBefore(_filterStart!) && !joined.isAfter(endOfDay);
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
                      tooltip: 'Filter by joined date',
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
                  stargazers.isEmpty
                      ? 'No results'
                      : _isFilterActive
                      ? 'Filtered Records: ${stargazers.length}'
                      : 'Full Records: ${stargazers.length}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),

            // List
            if (stargazers.isEmpty)
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
                        'No stargazers match your search',
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
                  itemCount: stargazers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _StargazerCard(
                    stargazer: stargazers[index],
                    onDelete: () => _deleteStargazer(stargazers[index].id),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─── Stats Header ────────────────────────────────────────────────────────────

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
          colors: [colorScheme.primary, colorScheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
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
                  'Total Stargazers',
                  style: TextStyle(
                    color: colorScheme.onPrimary.withOpacity(0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$total',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
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
                    color: colorScheme.onPrimary.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Active members',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
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
              color: colorScheme.onPrimary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_alt_rounded,
              size: 32,
              color: colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stargazer Card ───────────────────────────────────────────────────────────

const _avatarColors = [
  Color(0xFF6750A4),
  Color(0xFF00696D),
  Color(0xFF8B4000),
  Color(0xFF006A6A),
  Color(0xFF7D5260),
  Color(0xFF0062A1),
];

class _StargazerCard extends StatefulWidget {
  const _StargazerCard({required this.stargazer, required this.onDelete});
  final Stargazer stargazer;
  final Future<void> Function() onDelete;

  @override
  State<_StargazerCard> createState() => _StargazerCardState();
}

class _StargazerCardState extends State<_StargazerCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnim;
  bool _isDeleting = false;

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Stargazer'),
        content: Text(
          'Are you sure you want to delete "${widget.stargazer.fullName}"? This action cannot be undone.',
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

  String _formatDateOnly(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = _months[dt.month - 1];
    return '$day $month ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final s = widget.stargazer;
    final initials =
        '${s.firstName[0]}${s.lastName.isNotEmpty ? s.lastName[0] : ''}'
            .toUpperCase();
    final avatarColor =
        _avatarColors[s.firstName.codeUnitAt(0) % _avatarColors.length];

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
                          s.fullName,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              '@${s.displayName}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            _RoleBadge(role: s.role),
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
                                s.email,
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
                          icon: Icons.phone_outlined,
                          title: 'Phone',
                          value: s.phone,
                          iconColor: Colors.green,
                        ),
                        const SizedBox(height: 10),
                        _DetailTile(
                          icon: Icons.cake_outlined,
                          title: 'Date of Birth',
                          value: _formatDateOnly(s.dob),
                          iconColor: Colors.orange,
                        ),
                        const SizedBox(height: 10),
                        _DetailTile(
                          icon: Icons.calendar_month_outlined,
                          title: 'Joined On',
                          value: _formatDate(s.createdAt),
                          iconColor: colorScheme.primary,
                        ),
                        // const SizedBox(height: 10),
                        // _DetailTile(
                        //   icon: Icons.fingerprint_rounded,
                        //   title: 'ID',
                        //   value: s.id,
                        //   iconColor: colorScheme.tertiary,
                        //   mono: true,
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

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});
  final String role;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role,
        style: TextStyle(
          fontSize: 10,
          color: colorScheme.onTertiaryContainer,
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
