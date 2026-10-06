import 'package:flutter/material.dart';

import 'app.dart';
import 'services/storage_service.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize persistent SharedPreferences storage service
  final storageService = await StorageService.init();

  // Initialize Cloud Firestore service
  final firestoreService = FirestoreService();
  await firestoreService.initialize();

  runApp(
    CycleGoApp(
      storageService: storageService,
      firestoreService: firestoreService,
    ),
  );
}

