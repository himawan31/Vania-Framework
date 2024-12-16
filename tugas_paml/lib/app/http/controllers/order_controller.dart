import 'package:vania/vania.dart';
// ignore: implementation_imports
import 'package:vania/src/exception/validation_exception.dart';
import 'package:tugas_paml/app/models/customer.dart';
import 'package:tugas_paml/app/models/order.dart';

class OrderController extends Controller {
  Future<Response> index() async {
    try {
      final orderData = await Order().query().get();

      return Response.json({
        'status': true,
        'message': 'Data pesanan berhasil diambil.',
        'data': orderData
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
        'order_date': 'required|date',
        'cust_id': 'required|integer',
      }, {
        'order_date.required': 'Tanggal pesanan wajib diisi.',
        'order_date.date': 'Tanggal pesanan harus berupa tanggal.',
        'cust_id.required': 'ID pelanggan wajib diisi.',
        'cust_id.integer': 'ID pelanggan harus berupa angka.',
      });

      final orderData = request.input();

      final existingCustomer = await Customer()
          .query()
          .where('cust_id', '=', orderData['cust_id'])
          .first();

      if (existingCustomer == null) {
        return Response.json(
            {'message': 'Pelanggan dengan ID ini tidak ada.'}, 404);
      }

      orderData['created_at'] = DateTime.now().toIso8601String();

      await Order().query().insert(orderData);

      return Response.json({
        'status': true,
        'message': 'Pesanan berhasil ditambahkan.',
        'data': orderData
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
      final orderData =
          await Order().query().where('order_num', '=', id).first();

      if (orderData == null) {
        return Response.json({'message': 'Data pesanan tidak ditemukan.'}, 404);
      }

      return Response.json({
        'status': true,
        'message': 'Data pesanan berhasil diambil.',
        'data': orderData
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
        'order_date': 'date',
        'cust_id': 'integer',
      }, {
        'order_date.date': 'Tanggal pesanan harus berupa tanggal.',
        'cust_id.integer': 'ID pelanggan harus berupa angka.',
      });

      final orderData = request.input();

      if (orderData.containsKey('id')) {
        orderData['order_num'] = orderData['id'];
        orderData.remove('id');
      }

      final existingOrder =
          await Order().query().where('order_num', '=', id).first();

      if (existingOrder == null) {
        return Response.json(
            {'message': 'Pesanan dengan ID ini tidak ada.'}, 404);
      }

      if (orderData.containsKey('cust_id')) {
        final existingCustomer = await Customer()
            .query()
            .where('cust_id', '=', orderData['cust_id'])
            .first();

        if (existingCustomer == null) {
          return Response.json(
              {'message': 'Pelanggan dengan ID ini tidak ada.'}, 404);
        }
      }

      orderData['updated_at'] = DateTime.now().toIso8601String();

      await Order().query().where('order_num', '=', id).update(orderData);

      return Response.json({
        'status': true,
        'message': 'Pesanan berhasil diupdate.',
        'data': orderData
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
      final existingOrder =
          await Order().query().where('order_num', '=', id).first();

      if (existingOrder == null) {
        return Response.json(
            {'message': 'Pesanan dengan ID ini tidak ada.'}, 404);
      }

      await Order().query().where('order_num', '=', id).delete();

      return Response.json({
        'status': true,
        'message': 'Pesanan berhasil dihapus.',
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

final OrderController orderController = OrderController();
