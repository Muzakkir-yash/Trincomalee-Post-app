import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_office.dart';
import '../models/staff.dart';
import '../models/equipment.dart';

class OfficeProvider with ChangeNotifier {
  // Master lists
  final List<PostOffice> _postOffices = [];
  final List<Staff> _staffList = [];
  final List<Equipment> _equipmentList = [];

  // Search/Filter state
  String _searchQuery = '';
  String _selectedTypeFilter = 'All'; // 'All', 'Main', 'Sub'

  // Firebase integration fields
  FirebaseFirestore? _dbInstance;
  bool _isUsingFirestore = false;

  FirebaseFirestore get _db {
    _dbInstance ??= FirebaseFirestore.instance;
    return _dbInstance!;
  }

  OfficeProvider() {
    _initialize();
  }

  void _initialize() {
    try {
      _initializeFirestoreListeners();
      _isUsingFirestore = true;
      debugPrint("OfficeProvider: Successfully initialized Firestore sync.");
    } catch (e) {
      debugPrint("OfficeProvider: Firebase not initialized or unavailable ($e). Falling back to offline local registry.");
      _isUsingFirestore = false;
      _initializeLocalData();
    }
  }

  void _initializeLocalData() {
    _initializeDefaultPostOffices();
    _initializeDefaultStaff();
    _initializeDefaultEquipment();
  }

  void _initializeFirestoreListeners() {
    // 1. Listen to Post Offices in real-time
    _db.collection('post_offices').snapshots().listen((snapshot) {
      if (snapshot.docs.isEmpty) {
        debugPrint("Firestore: post_offices empty, seeding default post offices...");
        _uploadDefaultPostOffices();
      } else {
        _postOffices.clear();
        for (var doc in snapshot.docs) {
          _postOffices.add(PostOffice.fromMap(doc.id, doc.data()));
        }
        notifyListeners();
      }
    }, onError: (e) {
      debugPrint("Firestore Error (post_offices): $e. Using local registry data.");
      if (_postOffices.isEmpty) {
        _initializeDefaultPostOffices();
        notifyListeners();
      }
    });

    // 2. Listen to Staff in real-time
    _db.collection('staff').snapshots().listen((snapshot) {
      if (snapshot.docs.isEmpty) {
        debugPrint("Firestore: staff empty, seeding default staff registry...");
        _uploadDefaultStaff();
      } else {
        _staffList.clear();
        for (var doc in snapshot.docs) {
          _staffList.add(Staff.fromMap(doc.id, doc.data()));
        }
        notifyListeners();
      }
    }, onError: (e) {
      debugPrint("Firestore Error (staff): $e. Using local registry data.");
      if (_staffList.isEmpty) {
        _initializeDefaultStaff();
        notifyListeners();
      }
    });

    // 3. Listen to Equipment in real-time
    _db.collection('equipment').snapshots().listen((snapshot) {
      if (snapshot.docs.isEmpty) {
        debugPrint("Firestore: equipment empty, seeding default equipment inventory...");
        _uploadDefaultEquipment();
      } else {
        _equipmentList.clear();
        for (var doc in snapshot.docs) {
          _equipmentList.add(Equipment.fromMap(doc.id, doc.data()));
        }
        notifyListeners();
      }
    }, onError: (e) {
      debugPrint("Firestore Error (equipment): $e. Using local registry data.");
      if (_equipmentList.isEmpty) {
        _initializeDefaultEquipment();
        notifyListeners();
      }
    });
  }

  // Getters
  List<PostOffice> get postOffices => _postOffices;
  List<Staff> get staffList => _staffList;
  List<Equipment> get equipmentList => _equipmentList;
  String get searchQuery => _searchQuery;
  String get selectedTypeFilter => _selectedTypeFilter;

  // Filtered Post Offices
  List<PostOffice> get filteredPostOffices {
    return _postOffices.where((office) {
      final matchesSearch = office.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          office.code.contains(_searchQuery) ||
          office.address.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesType = _selectedTypeFilter == 'All' || office.type == _selectedTypeFilter;

      return matchesSearch && matchesType;
    }).toList();
  }

  // Statistics
  int get totalPostOffices => _postOffices.length;
  int get mainPostOfficesCount => _postOffices.where((o) => o.type == 'Main').length;
  int get subPostOfficesCount => _postOffices.where((o) => o.type == 'Sub').length;
  int get totalStaffCount => _staffList.length;
  int get totalEquipmentCount {
    return _equipmentList.fold(0, (total, item) => total + item.quantity);
  }

  // Search and Filter updates
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void updateTypeFilter(String filter) {
    _selectedTypeFilter = filter;
    notifyListeners();
  }

  // Get children details for specific Post Office
  List<Staff> getStaffForOffice(String officeId) {
    return _staffList.where((staff) => staff.postOfficeId == officeId).toList();
  }

  List<Equipment> getEquipmentForOffice(String officeId) {
    return _equipmentList.where((equip) => equip.postOfficeId == officeId).toList();
  }

  // Post Office CRUD Operations
  void updatePostOffice(PostOffice updatedOffice) {
    if (_isUsingFirestore) {
      _db.collection('post_offices').doc(updatedOffice.id).update(updatedOffice.toMap()).catchError((e) {
        debugPrint("Firestore: Failed to update post office details: $e");
      });
    } else {
      final index = _postOffices.indexWhere((o) => o.id == updatedOffice.id);
      if (index != -1) {
        _postOffices[index] = updatedOffice;
        notifyListeners();
      }
    }
  }

  // Staff CRUD Operations
  void addStaff(Staff staff) {
    if (_isUsingFirestore) {
      _db.collection('staff').doc(staff.id).set(staff.toMap()).catchError((e) {
        debugPrint("Firestore: Failed to add staff member: $e");
      });
    } else {
      _staffList.add(staff);
      notifyListeners();
    }
  }

  void updateStaff(Staff updatedStaff) {
    if (_isUsingFirestore) {
      _db.collection('staff').doc(updatedStaff.id).update(updatedStaff.toMap()).catchError((e) {
        debugPrint("Firestore: Failed to update staff details: $e");
      });
    } else {
      final index = _staffList.indexWhere((s) => s.id == updatedStaff.id);
      if (index != -1) {
        _staffList[index] = updatedStaff;
        notifyListeners();
      }
    }
  }

  void deleteStaff(String staffId) {
    if (_isUsingFirestore) {
      _db.collection('staff').doc(staffId).delete().catchError((e) {
        debugPrint("Firestore: Failed to delete staff member: $e");
      });
    } else {
      _staffList.removeWhere((s) => s.id == staffId);
      notifyListeners();
    }
  }

  // Equipment CRUD Operations
  void addEquipment(Equipment equipment) {
    if (_isUsingFirestore) {
      _db.collection('equipment').doc(equipment.id).set(equipment.toMap()).catchError((e) {
        debugPrint("Firestore: Failed to add equipment asset: $e");
      });
    } else {
      _equipmentList.add(equipment);
      notifyListeners();
    }
  }

  void updateEquipment(Equipment updatedEquipment) {
    if (_isUsingFirestore) {
      _db.collection('equipment').doc(updatedEquipment.id).update(updatedEquipment.toMap()).catchError((e) {
        debugPrint("Firestore: Failed to update equipment asset: $e");
      });
    } else {
      final index = _equipmentList.indexWhere((e) => e.id == updatedEquipment.id);
      if (index != -1) {
        _equipmentList[index] = updatedEquipment;
        notifyListeners();
      }
    }
  }

  void deleteEquipment(String equipmentId) {
    if (_isUsingFirestore) {
      _db.collection('equipment').doc(equipmentId).delete().catchError((e) {
        debugPrint("Firestore: Failed to delete equipment asset: $e");
      });
    } else {
      _equipmentList.removeWhere((e) => e.id == equipmentId);
      notifyListeners();
    }
  }

  // Seeding Helpers & Defaults
  void _initializeDefaultPostOffices() {
    _postOffices.clear();
    _postOffices.addAll(_getDefaultPostOffices());
  }

  void _initializeDefaultStaff() {
    _staffList.clear();
    _staffList.addAll(_getDefaultStaff());
  }

  void _initializeDefaultEquipment() {
    _equipmentList.clear();
    _equipmentList.addAll(_getDefaultEquipment());
  }

  Future<void> _uploadDefaultPostOffices() async {
    try {
      final batch = _db.batch();
      for (var office in _getDefaultPostOffices()) {
        final docRef = _db.collection('post_offices').doc(office.id);
        batch.set(docRef, office.toMap());
      }
      await batch.commit();
      debugPrint("Firestore Seeding: Successfully seeded Post Offices.");
    } catch (e) {
      debugPrint("Firestore Seeding Error (post_offices): $e");
    }
  }

  Future<void> _uploadDefaultStaff() async {
    try {
      final batch = _db.batch();
      for (var staff in _getDefaultStaff()) {
        final docRef = _db.collection('staff').doc(staff.id);
        batch.set(docRef, staff.toMap());
      }
      await batch.commit();
      debugPrint("Firestore Seeding: Successfully seeded Staff registry.");
    } catch (e) {
      debugPrint("Firestore Seeding Error (staff): $e");
    }
  }

  Future<void> _uploadDefaultEquipment() async {
    try {
      final batch = _db.batch();
      for (var equip in _getDefaultEquipment()) {
        final docRef = _db.collection('equipment').doc(equip.id);
        batch.set(docRef, equip.toMap());
      }
      await batch.commit();
      debugPrint("Firestore Seeding: Successfully seeded Equipment inventory.");
    } catch (e) {
      debugPrint("Firestore Seeding Error (equipment): $e");
    }
  }

  List<PostOffice> _getDefaultPostOffices() {
    return [
      PostOffice(
        id: 'PO-1',
        name: 'Trincomalee Head Post Office',
        code: '31000',
        type: 'Main',
        address: 'Dockyard Road, Trincomalee HPO',
        phone: '026-2222250',
        email: 'trincohpo@slpost.lk',
        latitude: 8.5714,
        longitude: 81.2335,
        password: 'trinco123',
      ),
      PostOffice(
        id: 'PO-2',
        name: 'Kantalai Post Office',
        code: '31300',
        type: 'Main',
        address: 'Main Street, Kantalai',
        phone: '026-2234250',
        email: 'kantalai_po@slpost.lk',
        latitude: 8.3688,
        longitude: 81.0118,
        password: 'kantalai123',
      ),
      PostOffice(
        id: 'PO-3',
        name: 'Kinniya Post Office',
        code: '31040',
        type: 'Main',
        address: 'Post Office Junction, Kinniya',
        phone: '026-2236250',
        email: 'kinniya_po@slpost.lk',
        latitude: 8.4862,
        longitude: 81.1895,
        password: 'kinniya123',
      ),
      PostOffice(
        id: 'PO-4',
        name: 'Mutur Post Office',
        code: '31200',
        type: 'Main',
        address: 'Main Street, Mutur',
        phone: '026-2238250',
        email: 'mutur_po@slpost.lk',
        latitude: 8.4485,
        longitude: 81.2661,
        password: 'mutur123',
      ),
      PostOffice(
        id: 'PO-5',
        name: 'China Bay Sub Post Office',
        code: '31002',
        type: 'Sub',
        address: 'Airport Road, China Bay',
        phone: '026-2244102',
        email: 'chinabay_spo@slpost.lk',
        latitude: 8.5414,
        longitude: 81.1868,
        password: 'chinabay123',
      ),
      PostOffice(
        id: 'PO-6',
        name: 'Nilaveli Sub Post Office',
        code: '31010',
        type: 'Sub',
        address: 'Nilaveli Beach Road, Nilaveli',
        phone: '026-2244210',
        email: 'nilaveli_spo@slpost.lk',
        latitude: 8.6833,
        longitude: 81.1833,
        password: 'nilaveli123',
      ),
      PostOffice(
        id: 'PO-7',
        name: 'Pulmoddai Sub Post Office',
        code: '31080',
        type: 'Sub',
        address: 'Pulmoddai Bazaar, Pulmoddai',
        phone: '026-2248080',
        email: 'pulmoddai_spo@slpost.lk',
        latitude: 8.9482,
        longitude: 80.9902,
        password: 'pulmoddai123',
      ),
      PostOffice(
        id: 'PO-8',
        name: 'Kuchchaveli Sub Post Office',
        code: '31020',
        type: 'Sub',
        address: 'Trincomalee-Pulmoddai Road, Kuchchaveli',
        phone: '026-2244302',
        email: 'kuchchaveli_spo@slpost.lk',
        latitude: 8.8167,
        longitude: 81.1000,
        password: 'kuchchaveli123',
      ),
    ];
  }

  List<Staff> _getDefaultStaff() {
    return [
      Staff(
        id: 'S-1',
        postOfficeId: 'PO-1',
        name: 'Mr. A. R. Mohamed Hilmy',
        designation: 'PSO-1',
        phone: '077-1234567',
        appointmentDate: '2010-06-12',
        assumeDate: '2010-06-15',
        nic: '198012345671',
        dob: '1975-04-12',
        paySheetNumber: 'PS-8731',
      ),
      Staff(
        id: 'S-2',
        postOfficeId: 'PO-1',
        name: 'Mrs. S. Priyadharshani',
        designation: 'PSO-2',
        phone: '071-9876543',
        appointmentDate: '2015-08-20',
        assumeDate: '2015-09-01',
        nic: '198852345672',
        dob: '1988-11-20',
        paySheetNumber: 'PS-8732',
      ),
      Staff(
        id: 'S-3',
        postOfficeId: 'PO-1',
        name: 'Mr. K. Loganathan',
        designation: 'PA-1',
        phone: '075-5556667',
        appointmentDate: '2012-03-01',
        assumeDate: '2012-03-05',
        nic: '198212345673',
        dob: '1982-08-15',
        paySheetNumber: 'PS-8733',
      ),
      Staff(
        id: 'S-4',
        postOfficeId: 'PO-1',
        name: 'Mr. M. S. Farook',
        designation: 'PA-2',
        phone: '077-2223334',
        appointmentDate: '2018-11-15',
        assumeDate: '2018-11-20',
        nic: '199212345674',
        dob: '1992-05-10',
        paySheetNumber: 'PS-8734',
      ),
      Staff(
        id: 'S-5',
        postOfficeId: 'PO-1',
        name: 'Ms. F. Rinosha',
        designation: 'PA-3',
        phone: '072-4445556',
        appointmentDate: '2021-04-10',
        assumeDate: '2021-04-12',
        nic: '199812345675',
        dob: '1998-09-02',
        paySheetNumber: 'PS-8735',
      ),
      Staff(
        id: 'S-6',
        postOfficeId: 'PO-2',
        name: 'Mr. Bandara Wickramasinghe',
        designation: 'PSO-1',
        phone: '077-3456789',
        appointmentDate: '2008-01-15',
        assumeDate: '2008-01-20',
        nic: '197512345676',
        dob: '1975-02-14',
        paySheetNumber: 'PS-8736',
      ),
      Staff(
        id: 'S-7',
        postOfficeId: 'PO-2',
        name: 'Mr. T. Jeyakumar',
        designation: 'Reg-Sub',
        phone: '076-7890123',
        appointmentDate: '2017-05-22',
        assumeDate: '2017-06-01',
        nic: '199012345677',
        dob: '1990-10-12',
        paySheetNumber: 'PS-8737',
      ),
      Staff(
        id: 'S-8',
        postOfficeId: 'PO-3',
        name: 'Mr. M. N. M. Nafeel',
        designation: 'PSO-1',
        phone: '077-4567890',
        appointmentDate: '2011-09-18',
        assumeDate: '2011-10-01',
        nic: '198112345678',
        dob: '1981-06-25',
        paySheetNumber: 'PS-8738',
      ),
      Staff(
        id: 'S-9',
        postOfficeId: 'PO-3',
        name: 'Mrs. R. Fathima',
        designation: 'C-Sub',
        phone: '070-1234567',
        appointmentDate: '2020-02-14',
        assumeDate: '2020-02-16',
        nic: '199512345679',
        dob: '1995-12-05',
        paySheetNumber: 'PS-8739',
      ),
      Staff(
        id: 'S-10',
        postOfficeId: 'PO-5',
        name: 'Mrs. G. L. A. S. Sandamali',
        designation: 'Sub -Pm',
        phone: '077-5678901',
        appointmentDate: '2016-10-05',
        assumeDate: '2016-10-10',
        nic: '198612345680',
        dob: '1986-07-28',
        paySheetNumber: 'PS-8740',
      ),
      Staff(
        id: 'S-11',
        postOfficeId: 'PO-5',
        name: 'Mr. S. Sivanesan',
        designation: 'Reg-Sub',
        phone: '075-8901234',
        appointmentDate: '2019-07-30',
        assumeDate: '2019-08-01',
        nic: '199312345681',
        dob: '1993-03-18',
        paySheetNumber: 'PS-8741',
      ),
      Staff(
        id: 'S-12',
        postOfficeId: 'PO-6',
        name: 'Mr. V. Tharmarajah',
        designation: 'Sub -Pm',
        phone: '077-6789012',
        appointmentDate: '2014-04-12',
        assumeDate: '2014-04-15',
        nic: '198412345682',
        dob: '1984-01-09',
        paySheetNumber: 'PS-8742',
      ),
    ];
  }

  List<Equipment> _getDefaultEquipment() {
    return [
      Equipment(
        id: 'E-1',
        postOfficeId: 'PO-1',
        name: 'Desktop Computers',
        category: 'IT Equipment',
        quantity: 8,
        status: 'Working',
      ),
      Equipment(
        id: 'E-2',
        postOfficeId: 'PO-1',
        name: 'Electronic Weighing Scale',
        category: 'Postal Tools',
        quantity: 4,
        status: 'Working',
      ),
      Equipment(
        id: 'E-3',
        postOfficeId: 'PO-1',
        name: 'Digital Franking Machine',
        category: 'Postal Tools',
        quantity: 2,
        status: 'Working',
      ),
      Equipment(
        id: 'E-4',
        postOfficeId: 'PO-1',
        name: 'Heavy Duty Metal Safe',
        category: 'Office Furniture',
        quantity: 2,
        status: 'Working',
      ),
      Equipment(
        id: 'E-5',
        postOfficeId: 'PO-1',
        name: 'Delivery Motorcycles (Bajaj)',
        category: 'Logistics',
        quantity: 5,
        status: 'Working',
      ),
      Equipment(
        id: 'E-6',
        postOfficeId: 'PO-1',
        name: 'Delivery Motorcycles (Yamaha)',
        category: 'Logistics',
        quantity: 2,
        status: 'Maintenance',
      ),
      Equipment(
        id: 'E-7',
        postOfficeId: 'PO-1',
        name: 'Mail Sorting Racks',
        category: 'Office Furniture',
        quantity: 6,
        status: 'Working',
      ),
      Equipment(
        id: 'E-8',
        postOfficeId: 'PO-1',
        name: 'Barcode Scanners',
        category: 'IT Equipment',
        quantity: 5,
        status: 'Damaged',
      ),
      Equipment(
        id: 'E-9',
        postOfficeId: 'PO-2',
        name: 'Desktop Computers',
        category: 'IT Equipment',
        quantity: 3,
        status: 'Working',
      ),
      Equipment(
        id: 'E-10',
        postOfficeId: 'PO-2',
        name: 'Electronic Weighing Scale',
        category: 'Postal Tools',
        quantity: 2,
        status: 'Working',
      ),
      Equipment(
        id: 'E-11',
        postOfficeId: 'PO-2',
        name: 'Delivery Motorcycles (Bajaj)',
        category: 'Logistics',
        quantity: 2,
        status: 'Working',
      ),
      Equipment(
        id: 'E-12',
        postOfficeId: 'PO-3',
        name: 'Desktop Computers',
        category: 'IT Equipment',
        quantity: 2,
        status: 'Working',
      ),
      Equipment(
        id: 'E-13',
        postOfficeId: 'PO-3',
        name: 'Electronic Weighing Scale',
        category: 'Postal Tools',
        quantity: 2,
        status: 'Maintenance',
      ),
      Equipment(
        id: 'E-14',
        postOfficeId: 'PO-5',
        name: 'Desktop Computer',
        category: 'IT Equipment',
        quantity: 1,
        status: 'Working',
      ),
      Equipment(
        id: 'E-15',
        postOfficeId: 'PO-5',
        name: 'Manual Weighing Scale',
        category: 'Postal Tools',
        quantity: 1,
        status: 'Working',
      ),
      Equipment(
        id: 'E-16',
        postOfficeId: 'PO-5',
        name: 'Delivery Bicycle',
        category: 'Logistics',
        quantity: 2,
        status: 'Working',
      ),
    ];
  }
}
