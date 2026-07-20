import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../providers/office_provider.dart';
import '../models/post_office.dart';
import '../models/staff.dart';
import '../models/equipment.dart';
import '../theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'manage_entity_screen.dart';

class DetailScreen extends StatefulWidget {
  final PostOffice office;
  const DetailScreen({super.key, required this.office});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild to update floating action button label/action
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showActionSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Future<void> _launchCall(String phone) async {
    final String cleanPhone = phone.replaceAll(RegExp(r'\s+|-'), '');
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanPhone,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } else {
        _showActionSnackbar('Could not launch dialer for $phone');
      }
    } catch (e) {
      _showActionSnackbar('Error launching call: $e');
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email.trim(),
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } else {
        _showActionSnackbar('Could not launch email client for $email');
      }
    } catch (e) {
      _showActionSnackbar('Error launching email: $e');
    }
  }

  Future<void> _launchMap(String name, double lat, double lng) async {
    final String query = '$lat,$lng(${name.replaceAll(RegExp(r'[()]'), '')})';
    final Uri googleMapsUri = Uri.parse('https://maps.google.com/?q=${Uri.encodeComponent(query)}');
    try {
      if (await canLaunchUrl(googleMapsUri)) {
        await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
      } else {
        _showActionSnackbar('Could not launch maps');
      }
    } catch (e) {
      _showActionSnackbar('Error launching maps: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final officeProvider = Provider.of<OfficeProvider>(context);

    final office = officeProvider.postOffices.firstWhere(
      (o) => o.id == widget.office.id,
      orElse: () => widget.office,
    );

    final staffList = officeProvider.getStaffForOffice(office.id);
    final equipmentList = officeProvider.getEquipmentForOffice(office.id);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // SliverAppBar with visual depth and glowing red shades
            SliverAppBar(
              expandedHeight: 280.0,
              floating: false,
              pinned: true,
              backgroundColor: isDark ? const Color(0xFF0F1326) : theme.colorScheme.primary,
              leading: Container(
                margin: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(50),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(LucideIcons.arrow_left, color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              actions: office.type == 'Main'
                  ? [
                      Container(
                        margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(50),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(LucideIcons.pencil, color: Colors.white, size: 18),
                          onPressed: () {
                            _authenticateAction(() {
                              _showEditOfficeDialog(context, office);
                            });
                          },
                        ),
                      ),
                    ]
                  : null,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Gradient Backdrop
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [const Color(0xFF060814), const Color(0xFF0F1326), const Color(0xFF1E2640)]
                              : [theme.colorScheme.primary, const Color(0xFF90111D), const Color(0xFF4C0519)],
                        ),
                      ),
                    ),
                    // Ambient Glow Rings
                    Positioned(
                      top: -50,
                      right: -50,
                      child: CircleAvatar(
                        radius: 110,
                        backgroundColor: Colors.white.withAlpha(isDark ? 8 : 15),
                      ),
                    ),
                    Positioned(
                      bottom: -40,
                      left: -40,
                      child: CircleAvatar(
                        radius: 90,
                        backgroundColor: Colors.white.withAlpha(isDark ? 5 : 10),
                      ),
                    ),
                    // Banner Information overlay
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(40),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  office.type.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'ZIP: ${office.code}',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(200),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            office.name,
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(LucideIcons.map_pin, size: 14, color: Colors.white.withAlpha(180)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                    office.address,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withAlpha(210),
                                      fontSize: 13,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            // Premium Circle Action Buttons (Glassmorphic)
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: [
                                  _buildActionCircle(
                                    icon: LucideIcons.phone,
                                    text: 'Call Office',
                                    onTap: () => _launchCall(office.phone),
                                  ),
                                  const SizedBox(width: 10),
                                  _buildActionCircle(
                                    icon: LucideIcons.mail,
                                    text: 'Email Office',
                                    onTap: () => _launchEmail(office.email),
                                  ),
                                  const SizedBox(width: 10),
                                  _buildActionCircle(
                                    icon: LucideIcons.map,
                                    text: 'Map View',
                                    onTap: () => _launchMap(office.name, office.latitude, office.longitude),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Custom TabBar inside Persistent Header
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorWeight: 3,
                    labelStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 15),
                    unselectedLabelStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, fontSize: 15),
                    tabs: const [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.users, size: 16),
                            SizedBox(width: 8),
                            Text('Staff Directory'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.package_check, size: 16),
                            SizedBox(width: 8),
                            Text('Equipment Assets'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  theme,
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildStaffTab(staffList, officeProvider, theme),
              _buildEquipmentTab(equipmentList, officeProvider, theme),
            ],
          ),
        ),
        floatingActionButton: office.type == 'Main'
            ? FloatingActionButton.extended(
                icon: const Icon(LucideIcons.plus, size: 18),
                label: Text(_tabController.index == 0 ? 'Register Staff' : 'Log Asset'),
                onPressed: () {
                  _authenticateAction(() {
                    if (_tabController.index == 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManageEntityScreen(
                            officeId: office.id,
                            entityType: EntityType.staff,
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManageEntityScreen(
                            officeId: office.id,
                            entityType: EntityType.equipment,
                          ),
                        ),
                      );
                    }
                  });
                },
              )
            : null,
      );
    }

  void _authenticateAction(VoidCallback onSuccess) {
    final office = Provider.of<OfficeProvider>(context, listen: false).postOffices.firstWhere(
      (o) => o.id == widget.office.id,
      orElse: () => widget.office,
    );
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isObscured = true;

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: theme.cardTheme.color,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFFFDA4AF).withAlpha(20) : theme.colorScheme.primary.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.lock,
                      color: isDark ? const Color(0xFFFDA4AF) : theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Authorization Required', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Please enter the unique password for ${office.name} to perform this administrative task.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withAlpha(180),
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: controller,
                      obscureText: isObscured,
                      autofocus: true,
                      style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15),
                      decoration: InputDecoration(
                        labelText: 'Office Password',
                        prefixIcon: const Icon(LucideIcons.key_round, size: 18),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isObscured ? LucideIcons.eye_off : LucideIcons.eye,
                            size: 18,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              isObscured = !isObscured;
                            });
                          },
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please enter the password';
                        }
                        if (val != office.password) {
                          return 'Incorrect password. Access denied.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.textTheme.bodyMedium?.color?.withAlpha(120),
                  ),
                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context); // Close dialog
                      onSuccess(); // Run action
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFFEF4444) : theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: const Text('Authorize', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditOfficeDialog(BuildContext context, PostOffice office) {
    final nameController = TextEditingController(text: office.name);
    final zipController = TextEditingController(text: office.code);
    final phoneController = TextEditingController(text: office.phone);
    final emailController = TextEditingController(text: office.email);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: theme.cardTheme.color,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFFFDA4AF).withAlpha(20) : theme.colorScheme.primary.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.pencil,
                      color: isDark ? const Color(0xFFFDA4AF) : theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Edit Office Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Update the core details for ${office.name}.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withAlpha(180),
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: nameController,
                        style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15),
                        decoration: const InputDecoration(
                          labelText: 'Office Name',
                          prefixIcon: Icon(LucideIcons.building, size: 18),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter the office name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: zipController,
                        keyboardType: TextInputType.number,
                        style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15),
                        decoration: const InputDecoration(
                          labelText: 'ZIP Code',
                          prefixIcon: Icon(LucideIcons.binary, size: 18),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter a ZIP code';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15),
                        decoration: const InputDecoration(
                          labelText: 'Call Office (Phone)',
                          prefixIcon: Icon(LucideIcons.phone, size: 18),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter a contact number';
                          }
                          if (!RegExp(r'^[0-9+ -]{7,15}$').hasMatch(val.trim())) {
                            return 'Please enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15),
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(LucideIcons.mail, size: 18),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter an email address';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.textTheme.bodyMedium?.color?.withAlpha(120),
                  ),
                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final updatedOffice = office.copyWith(
                        name: nameController.text.trim(),
                        code: zipController.text.trim(),
                        phone: phoneController.text.trim(),
                        email: emailController.text.trim(),
                      );
                      Provider.of<OfficeProvider>(context, listen: false).updatePostOffice(updatedOffice);
                      Navigator.pop(context); // Close dialog
                      _showActionSnackbar('Office details updated successfully.');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFFEF4444) : theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildActionCircle({
      required IconData icon,
      required String text,
      required VoidCallback onTap,
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(30),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withAlpha(25), width: 1.2),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 13),
              const SizedBox(width: 6),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildStaffTab(List<Staff> staff, OfficeProvider provider, ThemeData theme) {
      final isDark = theme.brightness == Brightness.dark;

      if (staff.isEmpty) {
        return _buildEmptyTabState(
          icon: LucideIcons.users,
          title: 'No Staff Enrolled',
          subtitle: 'Add staff members to this post office to keep track of their details, designation, and contacts.',
          theme: theme,
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
        physics: const BouncingScrollPhysics(),
        itemCount: staff.length,
        itemBuilder: (context, index) {
          final member = staff[index];
          final initial = member.name.split(' ').last.substring(0, 1).toUpperCase();

          return Container(
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
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Double-ring avatar container
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? const Color(0xFFFDA4AF).withAlpha(70) : theme.colorScheme.primary.withAlpha(40),
                            width: 2.0,
                          ),
                        ),
                        padding: const EdgeInsets.all(3),
                        child: CircleAvatar(
                          backgroundColor: isDark ? const Color(0xFF1E2640) : theme.colorScheme.primary.withAlpha(15),
                          child: Text(
                            initial,
                            style: TextStyle(
                              color: isDark ? const Color(0xFFFDA4AF) : theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              fontFamily: GoogleFonts.spaceGrotesk().fontFamily,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Role Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E2640) : theme.colorScheme.primary.withAlpha(14),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                member.designation.toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isDark ? const Color(0xFFFDA4AF) : theme.colorScheme.primary,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Joined: ${member.joinDate}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 12.5,
                                  color: theme.textTheme.bodyMedium?.color?.withAlpha(160),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 28, thickness: 0.5),
                    // Footer Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _buildCardIconButton(
                              icon: LucideIcons.phone,
                              onPressed: () => _showActionSnackbar('Dialing ${member.phone}...'),
                              theme: theme,
                              isDark: isDark,
                            ),
                            const SizedBox(width: 8),
                            _buildCardIconButton(
                              icon: LucideIcons.mail,
                              onPressed: () => _showActionSnackbar('Emailing ${member.email}...'),
                              theme: theme,
                              isDark: isDark,
                            ),
                          ],
                        ),
                        // Admin Actions
                        if (widget.office.type == 'Main')
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  _authenticateAction(() {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ManageEntityScreen(
                                          officeId: widget.office.id,
                                          entityType: EntityType.staff,
                                          staff: member,
                                        ),
                                      ),
                                    );
                                  });
                                },
                                icon: const Icon(LucideIcons.pencil, size: 13),
                                label: const Text('Edit'),
                                style: TextButton.styleFrom(
                                  foregroundColor: isDark ? const Color(0xFFFDA4AF) : theme.colorScheme.primary,
                                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                              const SizedBox(width: 4),
                              TextButton.icon(
                                onPressed: () {
                                  _authenticateAction(() {
                                    _confirmDeleteStaff(member, provider);
                                  });
                                },
                                icon: const Icon(LucideIcons.trash_2, size: 13),
                                label: const Text('Delete'),
                                style: TextButton.styleFrom(
                                  foregroundColor: theme.colorScheme.error,
                                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            ],
                          )
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      }

      Widget _buildCardIconButton({
        required IconData icon,
        required VoidCallback onPressed,
        required ThemeData theme,
        required bool isDark,
      }) {
        return IconButton(
          icon: Icon(icon, size: 16),
          onPressed: onPressed,
          constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
          style: IconButton.styleFrom(
            backgroundColor: isDark ? const Color(0xFF1E2640) : theme.colorScheme.primary.withAlpha(14),
            foregroundColor: isDark ? const Color(0xFFFDA4AF) : theme.colorScheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }

      Widget _buildEquipmentTab(List<Equipment> equipment, OfficeProvider provider, ThemeData theme) {
        if (equipment.isEmpty) {
          return _buildEmptyTabState(
            icon: LucideIcons.package_check,
            title: 'No Equipment Registered',
            subtitle: 'Log and manage equipment inventory items for this post office location.',
            theme: theme,
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: widget.office.type == 'Main' ? 0.72 : 0.95,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemCount: equipment.length,
          itemBuilder: (context, index) {
            final item = equipment[index];
            final isDark = theme.brightness == Brightness.dark;

            // Color coding status
            Color statusColor;
            switch (item.status) {
              case 'Working':
                statusColor = AppTheme.success;
                break;
              case 'Maintenance':
                statusColor = AppTheme.warning;
                break;
              case 'Damaged':
              default:
                statusColor = AppTheme.danger;
                break;
            }

            return Container(
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
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Glowing Dot
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.category.toUpperCase(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                              letterSpacing: 0.5,
                              color: theme.textTheme.bodyMedium?.color?.withAlpha(120),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Glow Dot
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withAlpha(120),
                                blurRadius: 4,
                                spreadRadius: 1,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Equipment Name
                    Expanded(
                      child: Text(
                        item.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Quantity count & Status label
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'QTY',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              '${item.quantity}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: isDark ? const Color(0xFFFDA4AF) : theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.status,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (widget.office.type == 'Main') ...[
                      const Divider(height: 20, thickness: 0.5),
                      // Grid Card Operations
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(LucideIcons.pencil, size: 13),
                            onPressed: () {
                              _authenticateAction(() {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ManageEntityScreen(
                                      officeId: widget.office.id,
                                      entityType: EntityType.equipment,
                                      equipment: item,
                                    ),
                                  ),
                                );
                              });
                            },
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            style: IconButton.styleFrom(
                              foregroundColor: isDark ? const Color(0xFFFDA4AF) : theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(LucideIcons.trash_2, size: 13),
                            onPressed: () {
                              _authenticateAction(() {
                                _confirmDeleteEquipment(item, provider);
                              });
                            },
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            style: IconButton.styleFrom(
                              foregroundColor: theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ]
                  ],
                ),
              ),
            );
          },
        );
      }

      Widget _buildEmptyTabState({
        required IconData icon,
        required String title,
        required String subtitle,
        required ThemeData theme,
      }) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: theme.dividerColor.withAlpha(35),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  color: theme.textTheme.bodyMedium?.color?.withAlpha(140),
                ),
              ),
            ],
          ),
        );
      }

      void _confirmDeleteStaff(Staff staffMember, OfficeProvider provider) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Staff Member'),
            content: Text('Are you sure you want to remove ${staffMember.name} from the records?'),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  provider.deleteStaff(staffMember.id);
                  Navigator.pop(context);
                  _showActionSnackbar('Staff member removed successfully.');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      }

      void _confirmDeleteEquipment(Equipment equip, OfficeProvider provider) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Equipment Item'),
            content: Text('Are you sure you want to delete the inventory record for ${equip.name}?'),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  provider.deleteEquipment(equip.id);
                  Navigator.pop(context);
                  _showActionSnackbar('Equipment record deleted.');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      }
    }

    class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
      final TabBar _tabBar;
      final ThemeData theme;

      _SliverAppBarDelegate(this._tabBar, this.theme);

      @override
      double get minExtent => _tabBar.preferredSize.height;
      @override
      double get maxExtent => _tabBar.preferredSize.height;

      @override
      Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
        final isDark = theme.brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF060814) : theme.scaffoldBackgroundColor,
            border: Border(
              bottom: BorderSide(
                color: isDark ? const Color(0xFF1E2640) : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
          ),
          child: _tabBar,
        );
      }

      @override
      bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
        return false;
      }
    }
