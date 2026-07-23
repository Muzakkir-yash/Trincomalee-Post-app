import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/office_provider.dart';
import 'detail_screen.dart';

enum ExcelTableType { offices, staff, inventory }

class ExcelTableScreen extends StatefulWidget {
  final ExcelTableType tableType;

  const ExcelTableScreen({
    super.key,
    this.tableType = ExcelTableType.offices,
  });

  @override
  State<ExcelTableScreen> createState() => _ExcelTableScreenState();
}

class _ExcelTableScreenState extends State<ExcelTableScreen> {
  late ExcelTableType _currentType;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _currentType = widget.tableType;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getPostOfficeName(OfficeProvider provider, String officeId) {
    try {
      final office = provider.postOffices.firstWhere((o) => o.id == officeId);
      return office.name;
    } catch (_) {
      return officeId;
    }
  }

  Future<void> _downloadCsvFile(OfficeProvider provider) async {
    final StringBuffer csv = StringBuffer();
    String fileName = 'Trincomalee_Offices_Sheet.csv';

    if (_currentType == ExcelTableType.offices) {
      fileName = 'Trincomalee_Offices_Sheet.csv';
      csv.writeln('No,Office Name,Code,Type,Phone,Email,Address,Staff Count,Equipment Count');
      final list = provider.postOffices.where((o) {
        return o.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            o.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            o.address.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();

      for (int i = 0; i < list.length; i++) {
        final o = list[i];
        final staffCount = provider.getStaffForOffice(o.id).length;
        final equipCount = provider.getEquipmentForOffice(o.id).fold(0, (sum, item) => sum + item.quantity);
        csv.writeln('${i + 1},"${o.name}","${o.code}","${o.type}","${o.phone}","${o.email}","${o.address}",$staffCount,$equipCount');
      }
    } else if (_currentType == ExcelTableType.staff) {
      fileName = 'Trincomalee_Staff_Registry_Sheet.csv';
      csv.writeln('No,Full Name,Designation,Post Office,Pay Sheet No,Contact Number,NIC Number,Appointment Date,Assume Date,Date of Birth');
      final list = provider.staffList.where((s) {
        final officeName = _getPostOfficeName(provider, s.postOfficeId);
        return s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            s.designation.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            s.nic.contains(_searchQuery) ||
            s.paySheetNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            officeName.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();

      list.sort((a, b) {
        final idxA = provider.postOffices.indexWhere((o) => o.id == a.postOfficeId);
        final idxB = provider.postOffices.indexWhere((o) => o.id == b.postOfficeId);
        final officeAIndex = idxA == -1 ? 999 : idxA;
        final officeBIndex = idxB == -1 ? 999 : idxB;
        if (officeAIndex != officeBIndex) {
          return officeAIndex.compareTo(officeBIndex);
        }
        return a.name.compareTo(b.name);
      });

      for (int i = 0; i < list.length; i++) {
        final s = list[i];
        final officeName = _getPostOfficeName(provider, s.postOfficeId);
        csv.writeln('${i + 1},"${s.name}","${s.designation}","$officeName","${s.paySheetNumber}","${s.phone}","${s.nic}","${s.appointmentDate}","${s.assumeDate}","${s.dob}"');
      }
    } else {
      fileName = 'Trincomalee_Inventory_Sheet.csv';
      csv.writeln('No,Asset Name,Category,Quantity,Status,Post Office');
      final list = provider.equipmentList.where((e) {
        final officeName = _getPostOfficeName(provider, e.postOfficeId);
        return e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            e.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            e.status.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            officeName.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();

      list.sort((a, b) {
        final idxA = provider.postOffices.indexWhere((o) => o.id == a.postOfficeId);
        final idxB = provider.postOffices.indexWhere((o) => o.id == b.postOfficeId);
        final officeAIndex = idxA == -1 ? 999 : idxA;
        final officeBIndex = idxB == -1 ? 999 : idxB;
        if (officeAIndex != officeBIndex) {
          return officeAIndex.compareTo(officeBIndex);
        }
        return a.name.compareTo(b.name);
      });

      for (int i = 0; i < list.length; i++) {
        final e = list[i];
        final officeName = _getPostOfficeName(provider, e.postOfficeId);
        csv.writeln('${i + 1},"${e.name}","${e.category}",${e.quantity},"${e.status}","$officeName"');
      }
    }

    String savedPath = '';
    try {
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
        if (!downloadsDir.existsSync()) {
          downloadsDir = await getExternalStorageDirectory();
        }
      } else {
        downloadsDir = await getDownloadsDirectory();
        downloadsDir ??= await getApplicationDocumentsDirectory();
      }

      if (downloadsDir != null) {
        final file = File('${downloadsDir.path}/$fileName');
        await file.writeAsString(csv.toString());
        savedPath = file.path;
      }
    } catch (e) {
      debugPrint('File download write error: $e');
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.file_check, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Downloaded $fileName!',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    savedPath.isNotEmpty
                        ? 'Saved to Downloads folder'
                        : 'File saved successfully.',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.white.withAlpha(210)),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF107C41),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = Provider.of<OfficeProvider>(context);

    String sheetTitle = 'Offices Master Sheet';
    String recordLabel = '${provider.postOffices.length} Offices';
    if (_currentType == ExcelTableType.staff) {
      sheetTitle = 'Staff Registry Master Sheet';
      recordLabel = '${provider.staffList.length} Staff Members';
    } else if (_currentType == ExcelTableType.inventory) {
      sheetTitle = 'Inventory Assets Master Sheet';
      recordLabel = '${provider.totalEquipmentCount} Total Units';
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090D16) : const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFF107C41),
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 8,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(35),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(LucideIcons.file_spreadsheet, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    sheetTitle,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Trincomalee Division Sheet',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: Colors.white.withAlpha(200),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () => _downloadCsvFile(provider),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF107C41) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(30),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.download,
                      size: 15,
                      color: isDark ? Colors.white : const Color(0xFF107C41),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Download',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? Colors.white : const Color(0xFF107C41),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Sheet Selector Bar
          Container(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // Sheet Type Tabs
                Row(
                  children: [
                    Expanded(
                      child: _buildSheetTab(
                        type: ExcelTableType.offices,
                        icon: LucideIcons.building,
                        label: 'Offices (${provider.postOffices.length})',
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSheetTab(
                        type: ExcelTableType.staff,
                        icon: LucideIcons.users,
                        label: 'Staff (${provider.staffList.length})',
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSheetTab(
                        type: ExcelTableType.inventory,
                        icon: LucideIcons.package_check,
                        label: 'Inventory (${provider.equipmentList.length})',
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Table Search Input
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim();
                    });
                  },
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search inside spreadsheet table...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    ),
                    prefixIcon: Icon(
                      LucideIcons.search,
                      size: 18,
                      color: isDark ? const Color(0xFF107C41) : const Color(0xFF107C41),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(LucideIcons.x, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark ? const Color(0xFF151C2C) : const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? const Color(0xFF263248) : const Color(0xFFCBD5E1),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? const Color(0xFF263248) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF107C41), width: 1.8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Spreadsheet Grid Status Ribbon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            color: isDark ? const Color(0xFF131927) : const Color(0xFFE2E8F0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF107C41),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Excel View Mode • Realtime Sync',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
                Text(
                  recordLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF107C41),
                  ),
                ),
              ],
            ),
          ),

          // Main Table Grid Area
          Expanded(
            child: _buildSpreadsheetTable(context, provider, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildSheetTab({
    required ExcelTableType type,
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    final isSelected = _currentType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _currentType = type;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF107C41)
              : (isDark ? const Color(0xFF151C2C) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF107C41)
                : (isDark ? const Color(0xFF263248) : const Color(0xFFCBD5E1)),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Colors.white : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpreadsheetTable(BuildContext context, OfficeProvider provider, bool isDark) {
    if (_currentType == ExcelTableType.offices) {
      return _buildOfficesTable(context, provider, isDark);
    } else if (_currentType == ExcelTableType.staff) {
      return _buildStaffTable(context, provider, isDark);
    } else {
      return _buildInventoryTable(context, provider, isDark);
    }
  }

  // --- 1. OFFICES TABLE ---
  Widget _buildOfficesTable(BuildContext context, OfficeProvider provider, bool isDark) {
    final offices = provider.postOffices.where((o) {
      return o.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          o.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          o.address.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    if (offices.isEmpty) {
      return _buildEmptyTableState('No matching post offices found.');
    }

    final headerColor = isDark ? const Color(0xFF1E293B) : const Color(0xFF107C41);
    final gridLineColor = isDark ? const Color(0xFF263248) : const Color(0xFFCBD5E1);

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(headerColor),
          headingRowHeight: 46,
          dataRowMinHeight: 48,
          dataRowMaxHeight: double.infinity,
          horizontalMargin: 16,
          columnSpacing: 28,
          border: TableBorder.all(color: gridLineColor, width: 1),
          columns: [
            _buildColumnHeader('#', minWidth: 36),
            _buildColumnHeader('Office Name'),
            _buildColumnHeader('Code', minWidth: 86),
            _buildColumnHeader('Type', minWidth: 66),
            _buildColumnHeader('Phone'),
            _buildColumnHeader('Email'),
            _buildColumnHeader('Address'),
            _buildColumnHeader('Staff Count'),
            _buildColumnHeader('Equipment Count'),
            _buildColumnHeader('Action'),
          ],
          rows: List.generate(offices.length, (index) {
            final o = offices[index];
            final staffCount = provider.getStaffForOffice(o.id).length;
            final equipCount = provider.getEquipmentForOffice(o.id).fold(0, (sum, item) => sum + item.quantity);
            final rowColor = index.isEven
                ? (isDark ? const Color(0xFF0F172A) : Colors.white)
                : (isDark ? const Color(0xFF151C2C) : const Color(0xFFF8FAFC));

            return DataRow(
              color: WidgetStateProperty.all(rowColor),
              cells: [
                DataCell(SizedBox(width: 36, child: Center(child: Text('${index + 1}', softWrap: false, style: _cellStyle(isDark, isBold: true))))),
                DataCell(Text(o.name, style: _cellStyle(isDark, isBold: true))),
                DataCell(
                  SizedBox(
                    width: 86,
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF107C41).withAlpha(50) : const Color(0xFF107C41).withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isDark ? const Color(0xFF4ADE80).withAlpha(80) : const Color(0xFF107C41).withAlpha(40),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        o.code,
                        softWrap: false,
                        overflow: TextOverflow.visible,
                        style: GoogleFonts.spaceMono(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF107C41),
                        ),
                      ),
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 66,
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: o.type == 'Main' 
                            ? (isDark ? Colors.blue.withAlpha(50) : Colors.blue.withAlpha(30)) 
                            : (isDark ? Colors.amber.withAlpha(50) : Colors.amber.withAlpha(30)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        o.type,
                        softWrap: false,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: o.type == 'Main' 
                              ? (isDark ? const Color(0xFF60A5FA) : Colors.blue) 
                              : (isDark ? const Color(0xFFFBBF24) : Colors.amber.shade800),
                        ),
                      ),
                    ),
                  ),
                ),
                DataCell(Text(o.phone.isEmpty ? '-' : o.phone, softWrap: false, style: _cellStyle(isDark))),
                DataCell(Text(o.email.isEmpty ? '-' : o.email, softWrap: false, style: _cellStyle(isDark))),
                DataCell(Text(o.address, style: _cellStyle(isDark))),
                DataCell(Text('$staffCount staff', softWrap: false, style: _cellStyle(isDark, isBold: true))),
                DataCell(Text('$equipCount units', softWrap: false, style: _cellStyle(isDark, isBold: true))),
                DataCell(IconButton(
                  icon: Icon(LucideIcons.external_link, size: 16, color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF107C41)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(office: o),
                      ),
                    );
                  },
                )),
              ],
            );
          }),
        ),
      ),
    );
  }

  // --- 2. STAFF TABLE ---
  Widget _buildStaffTable(BuildContext context, OfficeProvider provider, bool isDark) {
    final staffList = provider.staffList.where((s) {
      final officeName = _getPostOfficeName(provider, s.postOfficeId);
      return s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.designation.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.nic.contains(_searchQuery) ||
          s.paySheetNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          officeName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    staffList.sort((a, b) {
      final idxA = provider.postOffices.indexWhere((o) => o.id == a.postOfficeId);
      final idxB = provider.postOffices.indexWhere((o) => o.id == b.postOfficeId);
      final officeAIndex = idxA == -1 ? 999 : idxA;
      final officeBIndex = idxB == -1 ? 999 : idxB;
      if (officeAIndex != officeBIndex) {
        return officeAIndex.compareTo(officeBIndex);
      }
      return a.name.compareTo(b.name);
    });

    if (staffList.isEmpty) {
      return _buildEmptyTableState('No matching staff members found.');
    }

    final headerColor = isDark ? const Color(0xFF1E293B) : const Color(0xFF107C41);
    final gridLineColor = isDark ? const Color(0xFF263248) : const Color(0xFFCBD5E1);

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(headerColor),
          headingRowHeight: 46,
          dataRowMinHeight: 48,
          dataRowMaxHeight: double.infinity,
          horizontalMargin: 16,
          columnSpacing: 28,
          border: TableBorder.all(color: gridLineColor, width: 1),
          columns: [
            _buildColumnHeader('#', minWidth: 36),
            _buildColumnHeader('Full Name'),
            _buildColumnHeader('Designation'),
            _buildColumnHeader('Post Office'),
            _buildColumnHeader('Pay Sheet No'),
            _buildColumnHeader('Contact Number'),
            _buildColumnHeader('NIC Number'),
            _buildColumnHeader('Appointment Date'),
            _buildColumnHeader('Assume Date'),
            _buildColumnHeader('Date of Birth'),
          ],
          rows: List.generate(staffList.length, (index) {
            final s = staffList[index];
            final officeName = _getPostOfficeName(provider, s.postOfficeId);
            final rowColor = index.isEven
                ? (isDark ? const Color(0xFF0F172A) : Colors.white)
                : (isDark ? const Color(0xFF151C2C) : const Color(0xFFF8FAFC));

            return DataRow(
              color: WidgetStateProperty.all(rowColor),
              cells: [
                DataCell(SizedBox(width: 36, child: Center(child: Text('${index + 1}', softWrap: false, style: _cellStyle(isDark, isBold: true))))),
                DataCell(Text(s.name, style: _cellStyle(isDark, isBold: true))),
                DataCell(Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.blue.withAlpha(50) : Colors.blue.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    s.designation,
                    softWrap: false,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF60A5FA) : Colors.blue,
                    ),
                  ),
                )),
                DataCell(Text(officeName, style: _cellStyle(isDark, isBold: true))),
                DataCell(Text(
                  s.paySheetNumber.isEmpty ? '-' : s.paySheetNumber,
                  softWrap: false,
                  style: GoogleFonts.spaceMono(fontSize: 12, color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF334155)),
                )),
                DataCell(Text(s.phone.isEmpty ? '-' : s.phone, softWrap: false, style: _cellStyle(isDark))),
                DataCell(Text(s.nic.isEmpty ? '-' : s.nic, softWrap: false, style: _cellStyle(isDark))),
                DataCell(Text(s.appointmentDate.isEmpty ? '-' : s.appointmentDate, softWrap: false, style: _cellStyle(isDark))),
                DataCell(Text(s.assumeDate.isEmpty ? '-' : s.assumeDate, softWrap: false, style: _cellStyle(isDark))),
                DataCell(Text(s.dob.isEmpty ? '-' : s.dob, softWrap: false, style: _cellStyle(isDark))),
              ],
            );
          }),
        ),
      ),
    );
  }

  // --- 3. INVENTORY TABLE ---
  Widget _buildInventoryTable(BuildContext context, OfficeProvider provider, bool isDark) {
    final equipList = provider.equipmentList.where((e) {
      final officeName = _getPostOfficeName(provider, e.postOfficeId);
      return e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.status.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          officeName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    equipList.sort((a, b) {
      final idxA = provider.postOffices.indexWhere((o) => o.id == a.postOfficeId);
      final idxB = provider.postOffices.indexWhere((o) => o.id == b.postOfficeId);
      final officeAIndex = idxA == -1 ? 999 : idxA;
      final officeBIndex = idxB == -1 ? 999 : idxB;
      if (officeAIndex != officeBIndex) {
        return officeAIndex.compareTo(officeBIndex);
      }
      return a.name.compareTo(b.name);
    });

    if (equipList.isEmpty) {
      return _buildEmptyTableState('No matching inventory items found.');
    }

    final headerColor = isDark ? const Color(0xFF1E293B) : const Color(0xFF107C41);
    final gridLineColor = isDark ? const Color(0xFF263248) : const Color(0xFFCBD5E1);

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(headerColor),
          headingRowHeight: 46,
          dataRowMinHeight: 48,
          dataRowMaxHeight: double.infinity,
          horizontalMargin: 16,
          columnSpacing: 28,
          border: TableBorder.all(color: gridLineColor, width: 1),
          columns: [
            _buildColumnHeader('#', minWidth: 36),
            _buildColumnHeader('Asset / Item Name'),
            _buildColumnHeader('Category'),
            _buildColumnHeader('Quantity'),
            _buildColumnHeader('Status'),
            _buildColumnHeader('Assigned Post Office'),
          ],
          rows: List.generate(equipList.length, (index) {
            final e = equipList[index];
            final officeName = _getPostOfficeName(provider, e.postOfficeId);
            final rowColor = index.isEven
                ? (isDark ? const Color(0xFF0F172A) : Colors.white)
                : (isDark ? const Color(0xFF151C2C) : const Color(0xFFF8FAFC));

            Color statusColor = isDark ? const Color(0xFF4ADE80) : Colors.green;
            if (e.status == 'Maintenance') statusColor = isDark ? const Color(0xFFFBBF24) : Colors.orange;
            if (e.status == 'Damaged') statusColor = isDark ? const Color(0xFFF87171) : Colors.red;

            return DataRow(
              color: WidgetStateProperty.all(rowColor),
              cells: [
                DataCell(SizedBox(width: 36, child: Center(child: Text('${index + 1}', softWrap: false, style: _cellStyle(isDark, isBold: true))))),
                DataCell(Text(e.name, style: _cellStyle(isDark, isBold: true))),
                DataCell(Text(e.category, softWrap: false, style: _cellStyle(isDark))),
                DataCell(Text('${e.quantity}', softWrap: false, style: _cellStyle(isDark, isBold: true))),
                DataCell(Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    e.status,
                    softWrap: false,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                )),
                DataCell(Text(officeName, style: _cellStyle(isDark, isBold: true))),
              ],
            );
          }),
        ),
      ),
    );
  }

  DataColumn _buildColumnHeader(String label, {double? minWidth}) {
    Widget child = Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 0.2,
      ),
    );
    if (minWidth != null) {
      child = SizedBox(width: minWidth, child: Center(child: child));
    }
    return DataColumn(label: child);
  }

  TextStyle _cellStyle(bool isDark, {bool isBold = false}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 13,
      fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
      color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
    );
  }

  Widget _buildEmptyTableState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.file_search, size: 48, color: Color(0xFF64748B)),
          const SizedBox(height: 12),
          Text(
            message,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
