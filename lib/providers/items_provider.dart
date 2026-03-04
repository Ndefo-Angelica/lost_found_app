import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../models/item_model.dart';

class ItemsProvider extends ChangeNotifier {
  // Using default Firestore instance (no databaseId needed)
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  List<ItemModel> _items = [];
  List<ItemModel> _userItems = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<QuerySnapshot>? _itemsSubscription;

  List<ItemModel> get items => _items;
  List<ItemModel> get userItems => _userItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ItemsProvider() {
    _subscribeToItems();
    _checkConnection();
  }

  void _checkConnection() async {
    try {
      debugPrint('🔌 Testing Firestore connection...');
      await _firestore.collection('items').limit(1).get();
      debugPrint('✅ Firestore connected to default database');
    } catch (e) {
      debugPrint('❌ Firestore connection error: $e');
      _error = e.toString();
    }
  }

  void _subscribeToItems() {
    try {
      _itemsSubscription = _firestore
          .collection('items')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((snapshot) {
        _items = snapshot.docs
            .map((doc) => ItemModel.fromFirestore(doc))
            .toList();
        notifyListeners();
        debugPrint('📦 Loaded ${_items.length} items from default database');
      }, onError: (error) {
        _error = error.toString();
        debugPrint('❌ Firestore subscription error: $error');
        notifyListeners();
      });
    } catch (e) {
      debugPrint('❌ Error subscribing to items: $e');
      _error = e.toString();
    }
  }

  Future<void> loadUserItems(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('🔍 Loading items for user: $userId');
      
      final snapshot = await _firestore
          .collection('items')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _userItems = snapshot.docs
          .map((doc) => ItemModel.fromFirestore(doc))
          .toList();
      
      _error = null;
      debugPrint('✅ Loaded ${_userItems.length} items for user');
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error loading user items: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<ItemModel?> getItemById(String id) async {
    try {
      debugPrint('🔍 Fetching item with ID: $id');
      
      final doc = await _firestore.collection('items').doc(id).get();
      if (doc.exists) {
        debugPrint('✅ Item found');
        return ItemModel.fromFirestore(doc);
      } else {
        debugPrint('❌ Item not found with ID: $id');
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error getting item by ID: $e');
    }
    return null;
  }

  Future<String?> uploadImage(XFile image) async {
    try {
      debugPrint('📸 Uploading image: ${image.name}');
      
      final fileName = 'items/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(fileName);
      final bytes = await image.readAsBytes();
      
      await ref.putData(bytes);
      final downloadUrl = await ref.getDownloadURL();
      
      debugPrint('✅ Image uploaded successfully');
      return downloadUrl;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error uploading image: $e');
      return null;
    }
  }

  Future<bool> createItem(ItemModel item) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('📝 Creating new item: ${item.title}');
      
      await _firestore.collection('items').doc(item.id).set(item.toMap());
      
      _error = null;
      debugPrint('✅ Item created successfully with ID: ${item.id}');
      
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error creating item: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateItem(ItemModel item) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('📝 Updating item: ${item.id}');
      
      await _firestore.collection('items').doc(item.id).update(item.toMap());
      
      _error = null;
      debugPrint('✅ Item updated successfully');
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error updating item: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteItem(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('🗑️ Deleting item: $id');
      
      await _firestore.collection('items').doc(id).delete();
      
      _error = null;
      debugPrint('✅ Item deleted successfully');
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Error deleting item: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ItemModel> getFilteredItems({String? status, String? city}) {
    return _items.where((item) {
      if (status != null && status != 'all' && item.status != status) return false;
      if (city != null && city.isNotEmpty && !item.location.contains(city)) return false;
      return true;
    }).toList();
  }

  @override
  void dispose() {
    _itemsSubscription?.cancel();
    super.dispose();
  }
}