import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mewmory/providers/vocabulary_provider.dart';

void main() {
  test('clearing the search box removes the search filter', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(vocabularyFilterProvider.notifier);

    notifier.setSearchQuery('apple');
    expect(container.read(vocabularyFilterProvider).searchQuery, 'apple');

    notifier.setSearchQuery('');
    expect(container.read(vocabularyFilterProvider).searchQuery, isNull);

    notifier.setSearchQuery('pear');
    notifier.setSearchQuery('   ');
    expect(container.read(vocabularyFilterProvider).searchQuery, isNull);
  });
}
