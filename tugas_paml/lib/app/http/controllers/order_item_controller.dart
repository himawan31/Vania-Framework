import 'package:vania/vania.dart';
// ignore: implementation_imports
import 'package:vania/src/exception/validation_exception.dart';
import 'package:tugas_paml/app/models/order.dart';
import 'package:tugas_paml/app/models/orderitem.dart';
import 'package:tugas_paml/app/models/product.dart';

class OrderItemController extends Controller {
  Future<Response> index() async {
    try {
      final orderItemData = await Orderitem().query().get();

      return Response.json({
        'status': true,
        'message': 'Data pesanan berhasil diambil.',
        'data': orderItemData
      }, 200);
    } catch (e) {
      print('Error: ${e.toString()}');
      print('Stacktrace: ${StackTrace.current}');

      return Response.json({
        'message': 'Terjadi kesalahan di sisi server. Harap coba lagi nanti.'
      }, 500);
    }
  }

  Future<Response> create() async {
    return Response.json({});
  }

  Future<Response> store(Request request) async {
    try {
      request.validate({
        'order_num': 'required|integer',
        'prod_id': 'required|integer',
        'quantity': 'required|integer',
        'size': 'required|integer',
      }, {
        'order_num.required': 'Nomor pesanan wajib diisi.',
        'order_num.integer': 'Nomor pesanan harus berupa angka.',
        'prod_id.required': 'ID produk wajib diisi.',
        'prod_id.integer': 'ID produk harus berupa angka.',
        'quantity.required': 'Jumlah wajib diisi.',
        'quantity.integer': 'Jumlah harus berupa angka.',
        'size.required': 'Ukuran wajib diisi.',
        'size.integer': 'Ukuran harus berupa angka.',
      });

      final orderItemData = request.input();

      final existingOrderItem = await Order()
          .query()
          .where('order_num', '=', orderItemData['order_num'])
          .first();

      if (existingOrderItem == null) {
        return Response.json(
            {'message': 'Pesanan dengan ID ini tidak ada.'}, 404);
      }

      final existingProduct = await Product()
          .query()
          .where('prod_id', '=', orderItemData['prod_id'])
          .first();

      if (existingProduct == null) {
        return Response.json(
            {'message': 'Produk dengan ID ini tidak ada.'}, 404);
      }

      orderItemData['created_at'] = DateTime.now().toIso8601String();

      await Orderitem().query().insert(orderItemData);

      return Response.json({
        'status': true,
        'message': 'Item pesanan berhasil ditambahkan.',
        'data': orderItemData
      }, 201);
    } catch (e) {
      if (e is ValidationException) {
        final errorMessages = e.message;
        return Response.json({
          'errors': errorMessages,
        }, 400);
      }

      print('Error: ${e.toString()}');
      print('Stacktrace: ${StackTrace.current}');

      return Response.json({
        'message': 'Terjadi kesalahan di sisi server. Harap coba lagi nanti.'
      }, 500);
    }
  }

  Future<Response> show(int id) async {
    try {
      final orderItemData =
          await Orderitem().query().where('order_num', '=', id).first();

      if (orderItemData == null) {
        return Response.json({'message': 'Data pesanan tidak ditemukan.'}, 404);
      }

      return Response.json({
        'status': true,
        'message': 'Data pesanan berhasil diambil.',
        'data': orderItemData
      }, 200);
    } catch (e) {
      print('Error: ${e.toString()}');
      print('Stacktrace: ${StackTrace.current}');

      return Response.json({
        'message': 'Terjadi kesalahan di sisi server. Harap coba lagi nanti.'
      }, 500);
    }
  }

  Future<Response> edit(int id) async {
    return Response.json({});
  }

  Future<Response> update(Request request, int id) async {
    try {
      request.validate({
        'order_num': 'integer',
        'prod_id': 'integer',
        'quantity': 'integer',
        'size': 'integer',
      }, {
        'order_num.integer': 'Nomor pesanan harus berupa angka.',
        'prod_id.integer': 'ID produk harus berupa angka.',
        'quantity.integer': 'Jumlah harus berupa angka.',
        'size.integer': 'Ukuran harus berupa angka.',
      });

      final orderItemData = request.input();

      if (orderItemData.containsKey('id')) {
        orderItemData['order_item'] = orderItemData['id'];
        orderItemData.remove('id');
      }

      final existingOrderItem =
          await Orderitem().query().where('order_item', '=', id).first();

      if (existingOrderItem == null) {
        return Response.json(
            {'message': 'Item pesanan dengan ID ini tidak ada.'}, 404);
      }

      if (orderItemData.containsKey('order_num')) {
        final existingOrder = await Order()
            .query()
            .where('order_num', '=', orderItemData['order_num'])
            .first();

        if (existingOrder == null) {
          return Response.json(
              {'message': 'Pesanan dengan ID ini tidak ada.'}, 404);
        }
      }

      if (orderItemData.containsKey('prod_id')) {
        final existingProduct = await Product()
            .query()
            .where('prod_id', '=', orderItemData['prod_id'])
            .first();

        if (existingProduct == null) {
          return Response.json(
              {'message': 'Produk dengan ID ini tidak ada.'}, 404);
        }
      }

      orderItemData['updated_at'] = DateTime.now().toIso8601String();

      await Orderitem()
          .query()
          .where('order_item', '=', id)
          .update(orderItemData);

      return Response.json({
        'status': true,
        'message': 'Item pesanan berhasil diupdate.',
        'data': orderItemData
      }, 200);
    } catch (e) {
      if (e is ValidationException) {
        final errorMessages = e.message;
        return Response.json({
          'errors': errorMessages,
        }, 400);
      }

      print('Error: ${e.toString()}');
      print('Stacktrace: ${StackTrace.current}');

      return Response.json({
        'message': 'Terjadi kesalahan di sisi server. Harap coba lagi nanti.'
      }, 500);
    }
  }

  Future<Response> destroy(int id) async {
    try {
      final existingOrderItem =
          await Orderitem().query().where('order_item', '=', id).first();

      if (existingOrderItem == null) {
        return Response.json(
            {'message': 'Item pesanan dengan ID ini tidak ada.'}, 404);
      }

      await Orderitem().query().where('order_item', '=', id).delete();

      return Response.json({
        'status': true,
        'message': 'Item pesanan berhasil dihapus.',
      }, 200);
    } catch (e) {
      print('Error: ${e.toString()}');
      print('Stacktrace: ${StackTrace.current}');

      return Response.json({
        'message': 'Terjadi kesalahan di sisi server. Harap coba lagi nanti.'
      }, 500);
    }
  }
}

final OrderItemController orderItemController = OrderItemController();
