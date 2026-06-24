import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vynema/features/discover/presentation/providers/search_provider.dart';

void main() {
  group('SearchQueryNotifier', () {
    test('initial state is empty string', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(searchQueryProvider), '');
    });

    test('clear() resets state immediately', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(searchQueryProvider.notifier).clear();
      expect(container.read(searchQueryProvider), '');
    });

    test('update() trims whitespace before setting state', () {
      fakeAsync((async) {
        final container = ProviderContainer();

        container.read(searchQueryProvider.notifier).update('  flutter  ');
        async.elapse(const Duration(milliseconds: 400));

        expect(container.read(searchQueryProvider), 'flutter');
        container.dispose();
      });
    });

    test('update() does not fire before 350ms debounce window', () {
      fakeAsync((async) {
        final container = ProviderContainer();

        container.read(searchQueryProvider.notifier).update('pending');
        async.elapse(const Duration(milliseconds: 200));

        expect(container.read(searchQueryProvider), '');
        container.dispose();
      });
    });

    test('rapid updates only apply last value after debounce', () {
      fakeAsync((async) {
        final container = ProviderContainer();

        container.read(searchQueryProvider.notifier).update('a');
        async.elapse(const Duration(milliseconds: 100));
        container.read(searchQueryProvider.notifier).update('ab');
        async.elapse(const Duration(milliseconds: 100));
        container.read(searchQueryProvider.notifier).update('abc');
        async.elapse(const Duration(milliseconds: 400));

        expect(container.read(searchQueryProvider), 'abc');
        container.dispose();
      });
    });

    test('clear() cancels pending debounced update', () {
      fakeAsync((async) {
        final container = ProviderContainer();

        container.read(searchQueryProvider.notifier).update('cancelled');
        async.elapse(const Duration(milliseconds: 100));
        container.read(searchQueryProvider.notifier).clear();
        async.elapse(const Duration(milliseconds: 400));

        expect(container.read(searchQueryProvider), '');
        container.dispose();
      });
    });

    test('update() with empty string trims to empty', () {
      fakeAsync((async) {
        final container = ProviderContainer();

        container.read(searchQueryProvider.notifier).update('   ');
        async.elapse(const Duration(milliseconds: 400));

        expect(container.read(searchQueryProvider), '');
        container.dispose();
      });
    });
  });
}
