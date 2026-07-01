import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

QueryExecutor openMantleConnection() {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'mantle',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    if (result.missingFeatures.isNotEmpty) {
      // Some browser features are unavailable; the best available
      // storage backend has been selected automatically.
    }
    return result.resolvedExecutor;
  });
}
