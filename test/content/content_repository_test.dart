import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/features/content/data/content_repository.dart';
import 'package:mantle/features/content/domain/domain.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final repo = ContentRepository();

  test('loads 20 canon items', () async => expect((await repo.canon()).length, 20));

  test('canon item maps fields', () async {
    final ws = (await repo.canon()).firstWhere((c) => c.id == 'waist-suppression');
    expect(ws.domain, Domain.tailoring);
    expect(ws.throughlines, contains('interval'));
  });

  test('deck has 24 images', () async => expect((await repo.deck()).length, 24));

  test('throughlines returns 4 items and known key has non-empty label',
      () async {
    final items = await repo.throughlines();
    expect(items.length, 4);
    final mh = items.firstWhere((t) => t.key == 'material-honesty');
    expect(mh.label, isNotEmpty);
  });

  test('spotQuestions first item maps all fields correctly', () async {
    final questions = await repo.spotQuestions();
    expect(questions, isNotEmpty);
    final first = questions.first;
    expect(first.id, isNotEmpty);
    expect(Domain.values, contains(first.domain));
    expect(first.featureId, isNotEmpty);
    expect(['A', 'B'], contains(first.correctSide));
  });
}
