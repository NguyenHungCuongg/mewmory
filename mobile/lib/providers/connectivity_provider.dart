import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();

  // Yield initial connectivity state immediately
  try {
    final initialResults = await connectivity.checkConnectivity();
    yield initialResults.any((r) => r != ConnectivityResult.none);
  } catch (_) {
    // Default to true if unable to check initially
    yield true;
  }

  // Listen and yield on connectivity changes
  yield* connectivity.onConnectivityChanged.map((results) {
    return results.any((r) => r != ConnectivityResult.none);
  });
});
