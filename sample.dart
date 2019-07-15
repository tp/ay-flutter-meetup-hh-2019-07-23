import 'package:aym/state-helpers/state_queue.dart';
import 'package:aym/utils/page_source.dart';
import 'package:aym/widgets/with_bloc/with_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'pages/article-detail-page-widget/article_detail_page_loader.dart';
import 'pages/page_test_utils.dart';

Future<void> main() async {
  testWidgets('Renders ADP', (tester) async {
    await tester.runAsync(
      () async {
        final testSetup = await wrapInMockedProviders(
          ArticleDetailPageLoader(
            productId: 123456,
            pageSource: DeeplinkPageSource(),
          ),
          lastSeenProducts: [4072105, 3938478],
          mocksPath: './pages/adp/api-mocks/product-1',
        );

        await tester.pumpWidget(testSetup.widget);

        await testSetup.pumpAndSettleIncludingHttpCalls(tester);

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile(
            'goldens/article_detail_page_widget_test_product1.png',
          ),
        );

        expect(testSetup.deleteUnusedRequestsFromDisk(), 0);
      },
    );
  });
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<String>.value(
      value: 'Flutter Devs',
      child: Greeter(),
    );
  }
}

class Greeter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final name = Provider.of<String>(context);

    return Text('Hello $name');
  }
}

class MainNavigation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class AppRoot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<BasketBloc>(
      builder: (_) => BasketBloc(),
      child: MainNavigation(),
    );
  }
}

// [...]

class BasketIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final basketState = Provider.of<BasketBloc>(context).value;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.shopping_cart,
          color: Colors.black,
        ),
        SizedBox(width: 5),
        Text(
          '${basketState.productCount}',
        )
      ],
    );
  }
}

class BasketItem {
  String key;

  int quantity;
}

class Basket {
  final productCount = 0;

  BasketItem exisitingItem(int productId) {
    return null;
  }
}

class BasketLoading extends Basket {}

Future<Basket> basketWithNewProduct(int productId) async {
  return null;
}

Future<Basket> basketWithUpdatedQuantities(
  String itemKey,
  int quantity,
) async {
  return null;
}

class BasketBloc extends StateQueue<Basket> {
  BasketBloc() : super(BasketLoading());

  /// Adds the produ t to the basket or increases its quantity by 1 if it exists
  void addOrUpdateProductInBasket(int productId) {
    run((state) async* {
      yield BasketLoading();

      final existingItem = state.exisitingItem(productId);

      if (existingItem == null) {
        yield await basketWithNewProduct(productId);
      } else {
        yield await basketWithUpdatedQuantities(
          existingItem.key,
          existingItem.quantity + 1,
        );
      }
    });
  }
}

class CounterBloc extends StateQueue<int> {
  CounterBloc() : super(0);

  void increment() {
    run((state) async* {
      yield state + 1;
    });
  }
}

class Counter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WithBloc<CounterBloc, int>(
      createBloc: (_) => CounterBloc(),
      builder: (context, bloc, state, _) {
        return MaterialButton(
          child: Text('Count = $state'),
          onPressed: bloc.increment,
        );
      },
    );
  }
}
