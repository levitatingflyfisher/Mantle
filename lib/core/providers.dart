import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mantle/core/db/database.dart';
import 'package:mantle/features/content/data/content_repository.dart';

/// The single app-wide [MantleDatabase] instance.
///
/// Override in tests with [MantleDatabase.forTesting]:
/// ```dart
/// databaseProvider.overrideWithValue(MantleDatabase.forTesting(NativeDatabase.memory()))
/// ```
final databaseProvider = Provider<MantleDatabase>((ref) {
  final db = MantleDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Convenience accessor for [MembersDao].
final membersDaoProvider = Provider<MembersDao>(
  (ref) => ref.watch(databaseProvider).membersDao,
);

/// Convenience accessor for [RoundsDao].
final roundsDaoProvider = Provider<RoundsDao>(
  (ref) => ref.watch(databaseProvider).roundsDao,
);

/// Convenience accessor for [SessionsDao].
final sessionsDaoProvider = Provider<SessionsDao>(
  (ref) => ref.watch(databaseProvider).sessionsDao,
);

/// Convenience accessor for [MatchesDao].
final matchesDaoProvider = Provider<MatchesDao>(
  (ref) => ref.watch(databaseProvider).matchesDao,
);

/// Convenience accessor for [ChartersDao].
final chartersDaoProvider = Provider<ChartersDao>(
  (ref) => ref.watch(databaseProvider).chartersDao,
);

/// The shared [ContentRepository] for loading bundled JSON assets.
final contentRepositoryProvider = Provider<ContentRepository>(
  (_) => ContentRepository(),
);

/// Convenience accessor for [ReadProgressDao].
final readProgressDaoProvider = Provider<ReadProgressDao>(
  (ref) => ref.watch(databaseProvider).readProgressDao,
);

/// Convenience accessor for [SpotProgressDao].
final spotProgressDaoProvider = Provider<SpotProgressDao>(
  (ref) => ref.watch(databaseProvider).spotProgressDao,
);

/// Convenience accessor for [DiscoveredThroughlinesDao].
final discoveredThroughlinesDaoProvider = Provider<DiscoveredThroughlinesDao>(
  (ref) => ref.watch(databaseProvider).discoveredThroughlinesDao,
);
