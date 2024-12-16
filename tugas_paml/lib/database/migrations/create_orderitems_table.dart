import 'package:vania/vania.dart';

class CreateOrderitemsTable extends Migration {
  @override
  Future<void> up() async {
    super.up();
    await createTableNotExists('orderitems', () {
      bigIncrements('order_item');
      primary('order_item');
      bigInt('order_num', unsigned: true);
      bigInt('prod_id', unsigned: true);
      integer('quantity');
      integer('size');
      timeStamps();

      foreign('order_num', 'orders', 'order_num',
          constrained: true, onDelete: 'CASCADE');
      foreign('prod_id', 'products', 'prod_id',
          constrained: true, onDelete: 'CASCADE');
    });
  }

  @override
  Future<void> down() async {
    super.down();
    await dropIfExists('orderitems');
  }
}
