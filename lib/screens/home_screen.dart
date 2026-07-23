import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../providers/office_provider.dart';
import '../providers/theme_provider.dart';
import '../models/post_office.dart';
import '../theme/app_theme.dart';
import 'detail_screen.dart';
import 'excel_table_screen.dart';
import 'package:google_fonts/google_fonts.dart';

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double screenWidth = constraints.maxWidth;
              final bool isDesktop = screenWidth >= 1100;
              final bool isTablet = screenWidth >= 700 && screenWidth < 1100;
              final int gridColumns = isDesktop ? 3 : (isTablet ? 2 : 1);

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Premium Custom Header / AppBar
                      _buildAppBar(theme, themeProvider, isDark, isDesktop),

                      // Scrollable content area
                      Expanded(
                        child: CustomScrollView(
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            // Stats Dashboard section (Glassmorphic)
                            SliverToBoxAdapter(
                              child: _buildStatsDashboard(officeProvider, theme, isDark, isDesktop),
                            ),

                            // Search and Filter section
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Directory Lookup',
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontSize: isDesktop ? 22 : 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${officeProvider.filteredPostOffices.length} offices found',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
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
                                          color: isDark ? const Color(0xFFEF5350) : theme.colorScheme.primary,
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
                            // List / Grid of Post Offices
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                              sliver: officeProvider.filteredPostOffices.isEmpty
                                  ? SliverToBoxAdapter(child: _buildEmptyState(theme))
                                  : (gridColumns > 1
                                      ? SliverGrid(
                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: gridColumns,
                                            mainAxisSpacing: 16,
                                            crossAxisSpacing: 16,
                                            mainAxisExtent: 220,
                                          ),
                                          delegate: SliverChildBuilderDelegate(
                                            (context, index) {
                                              final office = officeProvider.filteredPostOffices[index];
                                              return _buildOfficeCard(context, office, officeProvider, theme, isDark, index);
                                            },
                                            childCount: officeProvider.filteredPostOffices.length,
                                          ),
                                        )
                                      : SliverList(
                                          delegate: SliverChildBuilderDelegate(
                                            (context, index) {
                                              final office = officeProvider.filteredPostOffices[index];
                                              return _buildOfficeCard(context, office, officeProvider, theme, isDark, index);
                                            },
                                            childCount: officeProvider.filteredPostOffices.length,
                                          ),
                                        )),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme, ThemeProvider themeProvider, bool isDark, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
          Row(
            children: [
              // Official App Logo Emblem
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF151C2C) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: isDark 
                          ? const Color(0xFFEF5350).withAlpha(15) 
                          : theme.colorScheme.primary.withAlpha(15),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TRINCOMALEE DIVISION',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w800,
                      color: isDark ? const Color(0xFFEF5350) : theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Postal Hub Registry',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Theme Switcher Button styled to be more premium
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? LucideIcons.sun : LucideIcons.moon,
                color: isDark ? Colors.amber : const Color(0xFF475569),
                size: 18,
              ),
              onPressed: () {
                themeProvider.toggleTheme(!themeProvider.isDarkMode);
              },
              style: IconButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsDashboard(OfficeProvider provider, ThemeData theme, bool isDark, bool isDesktop) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF991B1B), const Color(0xFF450A0A), const Color(0xFF0F0404)]
              : [const Color(0xFFC62828), const Color(0xFFB71C1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isDark ? const Color(0xFFF87171).withAlpha(40) : Colors.transparent,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0xFFDC2626).withAlpha(30) : const Color(0xFFC62828).withAlpha(40),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              icon: LucideIcons.building,
              value: provider.totalPostOffices.toString(),
              label: 'Offices',
              color: isDark ? const Color(0xFFF87171) : Colors.white,
              theme: theme,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ExcelTableScreen(tableType: ExcelTableType.offices),
                  ),
                );
              },
            ),
            Container(
              height: 38,
              width: 1,
              color: Colors.white.withAlpha(45),
            ),
            _buildStatItem(
              icon: LucideIcons.users,
              value: provider.totalStaffCount.toString(),
              label: 'Staff Registry',
              color: isDark ? const Color(0xFFF87171) : Colors.white,
              theme: theme,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ExcelTableScreen(tableType: ExcelTableType.staff),
                  ),
                );
              },
            ),
            Container(
              height: 38,
              width: 1,
              color: Colors.white.withAlpha(45),
            ),
            _buildStatItem(
              icon: LucideIcons.package_check,
              value: provider.totalEquipmentCount.toString(),
              label: 'Inventory',
              color: isDark ? const Color(0xFFF87171) : Colors.white,
              theme: theme,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ExcelTableScreen(tableType: ExcelTableType.inventory),
                  ),
                );
              },
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
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withAlpha(210),
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
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
              selectedColor: isDark ? const Color(0xFFDC2626) : theme.colorScheme.primary,
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
                    : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
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
          border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: isDark
              ? [
                  BoxShadow(
                    color: const Color(0xFF38BDF8).withAlpha(8),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ]
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
                          ? (isDark ? const Color(0xFF0284C7).withAlpha(30) : theme.colorScheme.primary.withAlpha(16))
                          : (isDark ? const Color(0xFFD97706).withAlpha(30) : const Color(0xFFC62828).withAlpha(12)),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isMain 
                            ? (isDark ? const Color(0xFF38BDF8).withAlpha(60) : theme.colorScheme.primary.withAlpha(40)) 
                            : (isDark ? const Color(0xFFFBBF24).withAlpha(60) : const Color(0xFFC62828).withAlpha(30)),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        isMain ? LucideIcons.building : LucideIcons.store,
                        color: isMain 
                            ? (isDark ? const Color(0xFF38BDF8) : theme.colorScheme.primary) 
                            : (isDark ? const Color(0xFFFBBF24) : const Color(0xFFC62828)),
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
                                    ? (isDark ? const Color(0xFF0284C7).withAlpha(40) : theme.colorScheme.primary.withAlpha(16))
                                    : (isDark ? const Color(0xFFD97706).withAlpha(40) : const Color(0xFFC62828).withAlpha(12)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                office.type.toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9,
                                  letterSpacing: 0.5,
                                  color: isMain 
                                      ? (isDark ? const Color(0xFF38BDF8) : theme.colorScheme.primary) 
                                      : (isDark ? const Color(0xFFFBBF24) : const Color(0xFFC62828)),
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
