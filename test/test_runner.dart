// test/test_runner.dart
import 'package:flutter_test/flutter_test.dart';

// Import all test files
import 'unit/usecases/auth/sign_in_test.dart' as sign_in_test;
import 'unit/usecases/auth/register_test.dart' as register_test;
import 'unit/usecases/catalog/fetch_products_test.dart' as fetch_products_test;
import 'unit/usecases/catalog/fetch_product_test.dart' as fetch_product_test;
import 'unit/viewmodels/auth/login_vm_test.dart' as login_vm_test;
import 'unit/viewmodels/catalog/catalog_vm_test.dart' as catalog_vm_test;
import 'widget/auth/login_page_test.dart' as login_page_test;
import 'widget/catalog/product_card_test.dart' as product_card_test;
import 'integration/auth_flow_test.dart' as auth_flow_test;

void main() {
  group('Unit Tests - Use Cases', () {
    sign_in_test.main();
    register_test.main();
    fetch_products_test.main();
    fetch_product_test.main();
  });

  group('Unit Tests - ViewModels', () {
    login_vm_test.main();
    catalog_vm_test.main();
  });

  group('Widget Tests', () {
    login_page_test.main();
    product_card_test.main();
  });

  group('Integration Tests', () {
    auth_flow_test.main();
  });
}
