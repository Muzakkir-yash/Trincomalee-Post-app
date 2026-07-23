import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../providers/office_provider.dart';
import '../models/staff.dart';
import '../models/equipment.dart';

enum EntityType { staff, equipment }

class ManageEntityScreen extends StatefulWidget {
  final String officeId;
  final EntityType entityType;
  final Staff? staff;
  final Equipment? equipment;

  const ManageEntityScreen({
    super.key,
    required this.officeId,
    required this.entityType,
    this.staff,
    this.equipment,
  });

  @override
  State<ManageEntityScreen> createState() => _ManageEntityScreenState();
}

class _ManageEntityScreenState extends State<ManageEntityScreen> {
  final _formKey = GlobalKey<FormState>();

  // Staff Form controllers & selections
  final _staffNameController = TextEditingController();
  String _selectedDesignation = 'PSO-1';
  final _staffPhoneController = TextEditingController();
  final _staffNicController = TextEditingController();
  final _staffPaySheetController = TextEditingController();
  final _staffAppointmentDateController = TextEditingController();
  final _staffAssumeDateController = TextEditingController();
  final _staffDobController = TextEditingController();

  // Equipment Form controllers & selections
  final _equipNameController = TextEditingController();
  String _selectedCategory = 'Postal Tools';
  final _equipQtyController = TextEditingController();
  String _selectedStatus = 'Working';

  final List<String> _designations = [
    'PSO-1',
    'PSO-2',
    'PSO-3',
    'PA-1',
    'PA-2',
    'PA-3',
    'Sub -Pm',
    'Reg-Sub',
    'C-Sub',
  ];

  final List<String> _categories = [
    'IT Equipment',
    'Logistics',
    'Office Furniture',
    'Postal Tools',
  ];

  final List<String> _statuses = [
    'Working',
    'Maintenance',
    'Damaged',
  ];

  bool get _isEditing =>
      widget.entityType == EntityType.staff ? widget.staff != null : widget.equipment != null;

  @override
  void initState() {
    super.initState();
    _initializeFormValues();
  }

  void _initializeFormValues() {
    if (widget.entityType == EntityType.staff) {
      if (widget.staff != null) {
        final s = widget.staff!;
        _staffNameController.text = s.name;
        _staffPhoneController.text = s.phone;
        _staffNicController.text = s.nic;
        _staffPaySheetController.text = s.paySheetNumber;
        _staffAppointmentDateController.text = s.appointmentDate;
        _staffAssumeDateController.text = s.assumeDate;
        _staffDobController.text = s.dob;
        if (_designations.contains(s.designation)) {
          _selectedDesignation = s.designation;
        } else {
          // Map legacy designations cleanly to allowed list
          final lower = s.designation.toLowerCase();
          if (lower.contains('sub')) {
            _selectedDesignation = 'Sub -Pm';
          } else if (lower.contains('assistant') || lower.contains('pa')) {
            _selectedDesignation = 'PA-1';
          } else {
            _selectedDesignation = 'PSO-1';
          }
        }
      } else {
        _staffAppointmentDateController.text = DateTime.now().toString().split(' ')[0];
        _staffAssumeDateController.text = DateTime.now().toString().split(' ')[0];
        _staffDobController.text = '1990-01-01';
      }
    } else {
      if (widget.equipment != null) {
        final e = widget.equipment!;
        _equipNameController.text = e.name;
        _equipQtyController.text = e.quantity.toString();
        if (_categories.contains(e.category)) {
          _selectedCategory = e.category;
        }
        if (_statuses.contains(e.status)) {
          _selectedStatus = e.status;
        }
      } else {
        _equipQtyController.text = '1';
      }
    }
  }

  @override
  void dispose() {
    _staffNameController.dispose();
    _staffPhoneController.dispose();
    _staffNicController.dispose();
    _staffPaySheetController.dispose();
    _staffAppointmentDateController.dispose();
    _staffAssumeDateController.dispose();
    _staffDobController.dispose();
    _equipNameController.dispose();
    _equipQtyController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller,
      {DateTime? initialDate, DateTime? firstDate, DateTime? lastDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: Color(0xFFEF5350),
                    onPrimary: Colors.white,
                    surface: Color(0xFF1E293B),
                  )
                : const ColorScheme.light(
                    primary: Color(0xFFC62828),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.toString().split(' ')[0];
      });
    }
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<OfficeProvider>(context, listen: false);

    if (widget.entityType == EntityType.staff) {
      if (_isEditing) {
        final updatedStaff = widget.staff!.copyWith(
          name: _staffNameController.text.trim(),
          designation: _selectedDesignation,
          phone: _staffPhoneController.text.trim(),
          nic: _staffNicController.text.trim(),
          paySheetNumber: _staffPaySheetController.text.trim(),
          appointmentDate: _staffAppointmentDateController.text,
          assumeDate: _staffAssumeDateController.text,
          dob: _staffDobController.text,
        );
        provider.updateStaff(updatedStaff);
      } else {
        final newStaff = Staff(
          id: 'S-${DateTime.now().millisecondsSinceEpoch}',
          postOfficeId: widget.officeId,
          name: _staffNameController.text.trim(),
          designation: _selectedDesignation,
          phone: _staffPhoneController.text.trim(),
          nic: _staffNicController.text.trim(),
          paySheetNumber: _staffPaySheetController.text.trim(),
          appointmentDate: _staffAppointmentDateController.text,
          assumeDate: _staffAssumeDateController.text,
          dob: _staffDobController.text,
        );
        provider.addStaff(newStaff);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Staff details saved.' : 'Staff registry entry created.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      final qty = int.tryParse(_equipQtyController.text) ?? 1;

      if (_isEditing) {
        final updatedEquip = widget.equipment!.copyWith(
          name: _equipNameController.text.trim(),
          category: _selectedCategory,
          quantity: qty,
          status: _selectedStatus,
        );
        provider.updateEquipment(updatedEquip);
      } else {
        final newEquip = Equipment(
          id: 'E-${DateTime.now().millisecondsSinceEpoch}',
          postOfficeId: widget.officeId,
          name: _equipNameController.text.trim(),
          category: _selectedCategory,
          quantity: qty,
          status: _selectedStatus,
        );
        provider.addEquipment(newEquip);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Asset details updated.' : 'Asset logged in registry.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isStaff = widget.entityType == EntityType.staff;

    String titleText = '';
    if (isStaff) {
      titleText = _isEditing ? 'Modify Staff Registry' : 'Register New Staff';
    } else {
      titleText = _isEditing ? 'Modify Asset Details' : 'Log New Asset';
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(titleText),
        leading: IconButton(
          icon: const Icon(LucideIcons.x, size: 20),
          onPressed: () => Navigator.pop(context),
          style: IconButton.styleFrom(
            backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Adaptable Form Container
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(24),
                    border: theme.cardTheme.shape is RoundedRectangleBorder
                        ? Border.fromBorderSide((theme.cardTheme.shape as RoundedRectangleBorder).side)
                        : Border.all(color: isDark ? const Color(0xFF222C44) : const Color(0xFFE2E8F0)),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withAlpha(4),
                              blurRadius: 15,
                              offset: const Offset(0, 10),
                            )
                          ],
                  ),
                  child: isStaff ? _buildStaffForm(theme, isDark) : _buildEquipmentForm(theme, isDark),
                ),
                const SizedBox(height: 28),
                // Gradient Save Button
                ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFFD32F2F), const Color(0xFFB71C1C)]
                            : [theme.colorScheme.primary, const Color(0xFFB71C1C)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      height: 56,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.save, size: 18, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            _isEditing ? 'Save Changes' : 'Confirm Registry Entry',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
);
}

  Widget _buildStaffForm(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              LucideIcons.user, 
              color: isDark ? const Color(0xFFEF5350) : theme.colorScheme.primary, 
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Personal Details',
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 16),
            ),
          ],
        ),
        const Divider(height: 28, thickness: 0.5),
        
        // Name
        TextFormField(
          controller: _staffNameController,
          style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15),
          decoration: const InputDecoration(
            labelText: 'Full Name',
            hintText: 'e.g. Mr. K. Loganathan',
            prefixIcon: Icon(LucideIcons.user_check, size: 18),
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Please enter the full name';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Designation Dropdown
        DropdownButtonFormField<String>(
          initialValue: _selectedDesignation,
          style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15),
          items: _designations.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                _selectedDesignation = newValue;
              });
            }
          },
          decoration: const InputDecoration(
            labelText: 'Designation / Role',
            prefixIcon: Icon(LucideIcons.briefcase, size: 18),
          ),
        ),
        const SizedBox(height: 20),

        // Phone
        TextFormField(
          controller: _staffPhoneController,
          keyboardType: TextInputType.phone,
          style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15),
          decoration: const InputDecoration(
            labelText: 'Contact Number',
            hintText: 'e.g. 077-1234567',
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
        const SizedBox(height: 20),

        // NIC
        TextFormField(
          controller: _staffNicController,
          style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15),
          decoration: const InputDecoration(
            labelText: 'NIC Number',
            hintText: 'e.g. 199012345678 or 901234567V',
            prefixIcon: Icon(LucideIcons.credit_card, size: 18),
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Please enter NIC number';
            }
            if (!RegExp(r'^([0-9]{9}[vVxX]|[0-9]{12})$').hasMatch(val.trim())) {
              return 'Please enter a valid NIC (9 digits + V/X or 12 digits)';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Pay Sheet Number
        TextFormField(
          controller: _staffPaySheetController,
          style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15),
          decoration: const InputDecoration(
            labelText: 'Pay Sheet Number',
            hintText: 'e.g. PS-1234',
            prefixIcon: Icon(LucideIcons.receipt, size: 18),
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Please enter Pay Sheet Number';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // DOB
        TextFormField(
          controller: _staffDobController,
          readOnly: true,
          onTap: () => _selectDate(
            context,
            _staffDobController,
            initialDate: DateTime(1990),
            firstDate: DateTime(1940),
            lastDate: DateTime.now(),
          ),
          style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15),
          decoration: const InputDecoration(
            labelText: 'Date of Birth (DOB)',
            prefixIcon: Icon(LucideIcons.cake, size: 18),
            suffixIcon: Icon(LucideIcons.calendar_days, size: 18),
          ),
        ),
        const SizedBox(height: 20),

        // Date of Appointment
        TextFormField(
          controller: _staffAppointmentDateController,
          readOnly: true,
          onTap: () => _selectDate(context, _staffAppointmentDateController),
          style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15),
          decoration: const InputDecoration(
            labelText: 'Date of Appointment',
            prefixIcon: Icon(LucideIcons.calendar, size: 18),
            suffixIcon: Icon(LucideIcons.calendar_days, size: 18),
          ),
        ),
        const SizedBox(height: 20),

        // Date of assume this office
        TextFormField(
          controller: _staffAssumeDateController,
          readOnly: true,
          onTap: () => _selectDate(context, _staffAssumeDateController),
          style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15),
          decoration: const InputDecoration(
            labelText: 'Date of assume this office',
            prefixIcon: Icon(LucideIcons.calendar_clock, size: 18),
            suffixIcon: Icon(LucideIcons.calendar_days, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildEquipmentForm(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              LucideIcons.package, 
              color: isDark ? const Color(0xFFEF5350) : theme.colorScheme.primary, 
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Asset Inventory Details',
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 16),
            ),
          ],
        ),
        const Divider(height: 28, thickness: 0.5),

        // Name
        TextFormField(
          controller: _equipNameController,
          style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15),
          decoration: const InputDecoration(
            labelText: 'Asset Item Name',
            hintText: 'e.g. Electronic Weighing Scale',
            prefixIcon: Icon(LucideIcons.keyboard, size: 18),
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Please enter the equipment name';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Category Dropdown
        DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15),
          items: _categories.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                _selectedCategory = newValue;
              });
            }
          },
          decoration: const InputDecoration(
            labelText: 'Asset Category',
            prefixIcon: Icon(LucideIcons.tag, size: 18),
          ),
        ),
        const SizedBox(height: 20),

        // Quantity
        TextFormField(
          controller: _equipQtyController,
          keyboardType: TextInputType.number,
          style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15),
          decoration: const InputDecoration(
            labelText: 'Quantity Registered',
            hintText: 'e.g. 5',
            prefixIcon: Icon(LucideIcons.hash, size: 18),
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Please specify quantity';
            }
            final n = int.tryParse(val);
            if (n == null || n <= 0) {
              return 'Quantity must be a positive integer';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Status Dropdown
        DropdownButtonFormField<String>(
          initialValue: _selectedStatus,
          style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15),
          items: _statuses.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                _selectedStatus = newValue;
              });
            }
          },
          decoration: const InputDecoration(
            labelText: 'Asset Condition Status',
            prefixIcon: Icon(LucideIcons.heart_pulse, size: 18),
          ),
        ),
      ],
    );
  }
}
