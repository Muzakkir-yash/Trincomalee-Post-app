import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../providers/office_provider.dart';
import '../providers/theme_provider.dart';
import '../models/post_office.dart';
import '../theme/app_theme.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final officeProvider = Provider.of<OfficeProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Premium Custom Header / AppBar
              _buildAppBar(theme, themeProvider, isDark),

              // Scrollable content area
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Stats Dashboard section (Glassmorphic)
                    SliverToBoxAdapter(
                      child: _buildStatsDashboard(officeProvider, theme, isDark),
                    ),

                    // Search and Filter section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Directory Lookup',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _searchController,
                              onChanged: (val) => officeProvider.updateSearchQuery(val),
                              style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15),
                              decoration: InputDecoration(
                                hintText: 'Search office name, postal code, region...',
                                prefixIcon: Icon(
                                  LucideIcons.search,
                                  color: isDark ? const Color(0xFFFDA4AF) : theme.colorScheme.primary,
                                  size: 20,
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(LucideIcons.x, size: 16),
                                        onPressed: () {
                                          _searchController.clear();
                                          officeProvider.updateSearchQuery('');
                                        },
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildCategoryFilters(officeProvider, theme, isDark),
                          ],
                        ),
                      ),
                    ),

                    // List of Post Offices
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      sliver: officeProvider.filteredPostOffices.isEmpty
                          ? SliverToBoxAdapter(child: _buildEmptyState(theme))
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final office = officeProvider.filteredPostOffices[index];
                                  return _buildOfficeCard(context, office, officeProvider, theme, isDark, index);
                                },
                                childCount: officeProvider.filteredPostOffices.length,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme, ThemeProvider themeProvider, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF1E2640) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFFFDA4AF) : theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'TRINCOMALEE DIVISION',
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Postal Hub Registry',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? LucideIcons.sun : LucideIcons.moon,
              color: isDark ? Colors.amber : theme.colorScheme.primary,
            ),
            onPressed: () {
              themeProvider.toggleTheme(!themeProvider.isDarkMode);
            },
            style: IconButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFF151B2C) : const Color(0xFFF1F5F9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsDashboard(OfficeProvider provider, ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      height: 140,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Premium Gradient Backplate
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF0F1326), const Color(0xFF060814)]
                      : [theme.colorScheme.primary, const Color(0xFF90111D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Background Ambient Glowing Circle 1
            Positioned(
              top: -60,
              left: -60,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isDark ? const Color(0xFFFDA4AF) : Colors.white).withAlpha(isDark ? 12 : 30),
                ),
              ),
            ),
            // Background Ambient Glowing Circle 2
            Positioned(
              bottom: -40,
              right: 60,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isDark ? const Color(0xFFFDA4AF) : Colors.white).withAlpha(isDark ? 8 : 18),
                ),
              ),
            ),
            // Floating background icon
            Positioned(
              right: -15,
              bottom: -15,
              child: Icon(
                LucideIcons.mail,
                size: 140,
                color: Colors.white.withAlpha(isDark ? 6 : 14),
              ),
            ),
            // Dashboard Stats Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    icon: LucideIcons.building,
                    value: provider.totalPostOffices.toString(),
                    label: 'Offices',
                    color: isDark ? const Color(0xFFFDA4AF) : Colors.white,
                    theme: theme,
                  ),
                  Container(
                    height: 44,
                    width: 1,
                    color: Colors.white.withAlpha(45),
                  ),
                  _buildStatItem(
                    icon: LucideIcons.users,
                    value: provider.totalStaffCount.toString(),
                    label: 'Staff Registry',
                    color: isDark ? const Color(0xFFFDA4AF) : Colors.white,
                    theme: theme,
                  ),
                  Container(
                    height: 44,
                    width: 1,
                    color: Colors.white.withAlpha(45),
                  ),
                  _buildStatItem(
                    icon: LucideIcons.package_check,
                    value: provider.totalEquipmentCount.toString(),
                    label: 'Inventory',
                    color: isDark ? const Color(0xFFFDA4AF) : Colors.white,
                    theme: theme,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required ThemeData theme,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(20),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withAlpha(180),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilters(OfficeProvider provider, ThemeData theme, bool isDark) {
    final filters = ['All', 'Main', 'Sub'];
    final labels = ['All Offices', 'Main POs', 'Sub POs'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filters.length, (index) {
          final filter = filters[index];
          final label = labels[index];
          final isSelected = provider.selectedTypeFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  provider.updateTypeFilter(filter);
                }
              },
              selectedColor: isDark ? const Color(0xFFE11D48) : theme.colorScheme.primary,
              checkmarkColor: Colors.white,
              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected 
                    ? Colors.white 
                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              side: BorderSide(
                color: isSelected
                    ? Colors.transparent
                    : (isDark ? const Color(0xFF1E2640) : const Color(0xFFE2E8F0)),
                width: 1.2,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildOfficeCard(BuildContext context, PostOffice office, OfficeProvider provider, ThemeData theme, bool isDark, int index) {
    final staffCount = provider.getStaffForOffice(office.id).length;
    final officeEquip = provider.getEquipmentForOffice(office.id);
    final workingEquip = officeEquip.where((e) => e.status == 'Working').fold<int>(0, (sum, e) => sum + e.quantity);
    final totalEquipCount = officeEquip.fold<int>(0, (sum, e) => sum + e.quantity);
    final double healthPercent = totalEquipCount > 0 ? (workingEquip / totalEquipCount) : 1.0;
    
    final isMain = office.type == 'Main';

    // Premium Staggered Entry Animation wrapper
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 70).clamp(0, 450)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 24 * (1.0 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? const Color(0xFF1E2640) : const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(office: office),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Stamp icon container (postal visual!)
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: isMain
                          ? theme.colorScheme.primary.withAlpha(16)
                          : (isDark ? const Color(0xFFFDA4AF).withAlpha(16) : const Color(0xFF90111D).withAlpha(16)),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isMain 
                            ? theme.colorScheme.primary.withAlpha(40) 
                            : (isDark ? const Color(0xFFFDA4AF).withAlpha(40) : const Color(0xFF90111D).withAlpha(40)),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        isMain ? LucideIcons.building : LucideIcons.store,
                        color: isMain 
                            ? theme.colorScheme.primary 
                            : (isDark ? const Color(0xFFFDA4AF) : const Color(0xFFC01F2F)),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Card details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                office.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Type Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isMain
                                    ? theme.colorScheme.primary.withAlpha(16)
                                    : (isDark ? const Color(0xFFFDA4AF).withAlpha(16) : const Color(0xFF90111D).withAlpha(16)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                office.type.toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9,
                                  letterSpacing: 0.5,
                                  color: isMain 
                                      ? theme.colorScheme.primary 
                                      : (isDark ? const Color(0xFFFDA4AF) : const Color(0xFFC01F2F)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Location & Code
                        Row(
                          children: [
                            Icon(
                              LucideIcons.map_pin, 
                              size: 13, 
                              color: theme.textTheme.bodyMedium?.color?.withAlpha(100),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${office.code} • ${office.address}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 12.5,
                                  color: theme.textTheme.bodyMedium?.color?.withAlpha(170),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Statistics Badges
                        Row(
                          children: [
                            _buildMiniBadge(
                              icon: LucideIcons.users,
                              text: '$staffCount Staff',
                              theme: theme,
                            ),
                            const SizedBox(width: 14),
                            _buildMiniBadge(
                              icon: LucideIcons.package_check,
                              text: '$totalEquipCount Units',
                              theme: theme,
                            ),
                          ],
                        ),
                        
                        // Premium Asset Health Progress Indicator
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Asset Operational Rate',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: theme.textTheme.bodyMedium?.color?.withAlpha(100),
                                        ),
                                      ),
                                      Text(
                                        '${(healthPercent * 100).toInt()}%',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: healthPercent > 0.8
                                              ? AppTheme.success
                                              : (healthPercent > 0.5 ? AppTheme.warning : AppTheme.danger),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: healthPercent,
                                      minHeight: 5,
                                      backgroundColor: isDark ? const Color(0xFF1E2640) : const Color(0xFFE2E8F0),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        healthPercent > 0.8
                                            ? AppTheme.success
                                            : (healthPercent > 0.5 ? AppTheme.warning : AppTheme.danger),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    LucideIcons.chevron_right,
                    size: 18,
                    color: theme.textTheme.bodyMedium?.color?.withAlpha(80),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniBadge({
    required IconData icon,
    required String text,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 13,
          color: theme.textTheme.bodyMedium?.color?.withAlpha(90),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: theme.textTheme.bodyMedium?.color?.withAlpha(190),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.search_x,
              size: 64,
              color: theme.dividerColor.withAlpha(35),
            ),
            const SizedBox(height: 16),
            Text(
              'No Post Offices Found',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'We couldn\'t find any post office matching your search query. Try typing another name or zip code.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 13.5,
                  color: theme.textTheme.bodyMedium?.color?.withAlpha(150),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
