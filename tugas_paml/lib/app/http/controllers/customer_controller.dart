import 'package:vania/vania.dart';
// ignore: implementation_imports
import 'package:vania/src/exception/validation_exception.dart';
import 'package:tugas_paml/app/models/customer.dart';

class CustomerController extends Controller {
  Future<Response> index() async {
    try {
      final customerData = await Customer().query().get();

      return Response.json({
        'status': true,
        'message': 'Data customer berhasil diambil.',
        'data': customerData
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
        'cust_name': 'required|string|max_length:100',
        'cust_address': 'required|string|max_length:255',
        'cust_city': 'required|string|max_length:50',
        'cust_state': 'required|string|max_length:50',
        'cust_zip': 'required|max_length:20',
        'cust_country': 'required|string|max_length:50',
        'cust_telp': 'required|max_length:20'
      }, {
        'cust_name.required': 'Nama customer wajib diisi.',
        'cust_name.string': 'Nama customer harus berupa teks.',
        'cust_name.max_length': 'Nama customer maksimal 100 karakter.',
        'cust_address.required': 'Alamat customer wajib diisi.',
        'cust_address.string': 'Alamat customer harus berupa teks.',
        'cust_address.max_length': 'Alamat customer maksimal 255 karakter.',
        'cust_city.required': 'Kota customer wajib diisi.',
        'cust_city.string': 'Kota customer harus berupa teks.',
        'cust_city.max_length': 'Kota customer maksimal 50 karakter.',
        'cust_state.required': 'Provinsi customer wajib diisi.',
        'cust_state.string': 'Provinsi customer harus berupa teks.',
        'cust_state.max_length': 'Provinsi customer maksimal 50 karakter.',
        'cust_zip.required': 'Kode pos customer wajib diisi.',
        'cust_zip.max_length': 'Kode pos customer maksimal 20 karakter.',
        'cust_country.required': 'Negara customer wajib diisi.',
        'cust_country.string': 'Negara customer harus berupa teks.',
        'cust_country.max_length': 'Negara customer maksimal 50 karakter.',
        'cust_telp.required': 'Nomor telepon customer wajib diisi.',
        'cust_telp.max_length': 'Nomor telepon customer maksimal 20 karakter.',
      });

      final customerData = request.input();

      final existingCustomer = await Customer()
          .query()
          .where('cust_name', '=', customerData['cust_name'])
          .first();

      if (existingCustomer != null) {
        return Response.json(
            {'message': 'Customer dengan nama ini sudah ada.'}, 409);
      }

      customerData['created_at'] = DateTime.now().toIso8601String();

      await Customer().query().insert(customerData);

      return Response.json({
        'status': true,
        'message': 'Data customer berhasil ditambahkan.',
        'data': customerData
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
      final customer =
          await Customer().query().where('cust_id', '=', id).first();

      if (customer == null) {
        return Response.json(
            {'message': 'Data customer tidak ditemukan.'}, 404);
      }

      return Response.json({
        'status': true,
        'message': 'Data customer berhasil diambil.',
        'data': customer
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
        'cust_name': 'string|max_length:100',
        'cust_address': 'string|max_length:255',
        'cust_city': 'string|max_length:50',
        'cust_state': 'string|max_length:50',
        'cust_zip': 'max_length:20',
        'cust_country': 'string|max_length:50',
        'cust_telp': 'max_length:20'
      }, {
        'cust_name.string': 'Nama customer harus berupa teks.',
        'cust_name.max_length': 'Nama customer maksimal 100 karakter.',
        'cust_address.string': 'Alamat customer harus berupa teks.',
        'cust_address.max_length': 'Alamat customer maksimal 255 karakter.',
        'cust_city.string': 'Kota customer harus berupa teks.',
        'cust_city.max_length': 'Kota customer maksimal 50 karakter.',
        'cust_state.string': 'Provinsi customer harus berupa teks.',
        'cust_state.max_length': 'Provinsi customer maksimal 50 karakter.',
        'cust_zip.required': 'Kode pos customer wajib diisi.',
        'cust_zip.max_length': 'Kode pos customer maksimal 20 karakter.',
        'cust_country.string': 'Negara customer harus berupa teks.',
        'cust_country.max_length': 'Negara customer maksimal 50 karakter.',
        'cust_telp.max_length': 'Nomor telepon customer maksimal 20 karakter.',
      });

      final customerData = request.input();

      if (customerData.containsKey('id')) {
        customerData['cust_id'] = customerData['id'];
        customerData.remove('id');
      }
      print('Data yang diterima: $customerData');

      customerData['updated_at'] = DateTime.now().toIso8601String();

      final customer =
          await Customer().query().where('cust_id', '=', id).first();
      if (customer == null) {
        return Response.json(
            {'message': 'Customer dengan ID $id tidak ditemukan.'}, 404);
      }

      await Customer().query().where('cust_id', '=', id).update(customerData);

      return Response.json({
        'status': true,
        'message': 'Data customer dengan ID $id telah berhasi diperbarui.',
        'data': customerData
      }, 200);
    } catch (e) {
      if (e is ValidationException) {
        final errorMessages = e.message;
        return Response.json({'message': errorMessages}, 400);
      } else {
        return Response.json({
          'message': 'Terjadi kesalahan di sisi server. Harap coba lagi nanti.'
        }, 500);
      }
    }
  }

  Future<Response> destroy(int id) async {
    try {
      final exixtingCustomer =
          await Customer().query().where('cust_id', '=', id).first();

      if (exixtingCustomer == null) {
        return Response.json(
            {'message': 'Customer dengan ID $id tidak ditemukan.'}, 400);
      }

      await Customer().query().where('cust_id', '=', id).delete();

      return Response.json({
        'status': true,
        'message': 'Customer dengan ID $id telah berhasil dihapus.'
      }, 200);
    } catch (e) {
      return Response.json({
        'message': 'Terjadi kesalahan saat menghapus customer.',
        'error': e.toString()
      }, 500);
    }
  }
}

final CustomerController customerController = CustomerController();
