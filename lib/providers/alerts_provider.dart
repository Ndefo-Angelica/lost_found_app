import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/alert_model.dart';

class AlertsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<AlertModel> _alerts = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<QuerySnapshot>? _alertsSubscription;

  List<AlertModel> get alerts => _alerts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _alerts.where((a) => !a.read).length;

  AlertsProvider() {
    _subscribeToAlerts();
  }

  void _subscribeToAlerts() {
    _alertsSubscription = _firestore
        .collection('alerts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _alerts = snapshot.docs
          .map((doc) => AlertModel.fromFirestore(doc))
          .toList();
      notifyListeners();
    }, onError: (error) {
      _error = error.toString();
      notifyListeners();
    });
  }

  Future<void> loadUserAlerts(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('alerts')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _alerts = snapshot.docs
          .map((doc) => AlertModel.fromFirestore(doc))
          .toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> markAsRead(String alertId) async {
    try {
      await _firestore.collection('alerts').doc(alertId).update({
        'read': true,
      });
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final snapshot = await _firestore
          .collection('alerts')
          .where('userId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();

      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'read': true});
      }

      await batch.commit();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<void> createAlert(AlertModel alert) async {
    try {
      await _firestore.collection('alerts').doc(alert.id).set(alert.toMap());
    } catch (e) {
      _error = e.toString();
    }
  }

  @override
  void dispose() {
    _alertsSubscription?.cancel();
    super.dispose();
  }
}