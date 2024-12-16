import 'package:vania/vania.dart';
// ignore: implementation_imports
import 'package:vania/src/exception/validation_exception.dart';
import 'package:tugas_paml/app/models/vendor.dart';

class VendorController extends Controller {
  Future<Response> index() async {
    try {
      final vendorData = await Vendor().query().get();

      return Response.json({
        'status': true,
        'message': 'Data vendor berhasil diambil.',
        'data': vendorData
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
        'vend_name': 'required|string|max_length:100',
        'vend_address': 'required|string|max_length:255',
        'vend_kota': 'required|string|max_length:50',
        'vend_state': 'required|string|max_length:50',
        'vend_zip': 'required|max_length:20',
        'vend_country': 'required|string|max_length:50',
      }, {
        'vend_name.required': 'Nama vendor wajib diisi.',
        'vend_name.string': 'Nama vendor harus berupa teks.',
        'vend_name.max_length': 'Nama vendor maksimal 100 karakter.',
        'vend_address.required': 'Alamat vendor wajib diisi.',
        'vend_address.string': 'Alamat vendor harus berupa teks.',
        'vend_address.max_length': 'Alamat vendor maksimal 255 karakter.',
        'vend_kota.required': 'Kota vendor wajib diisi.',
        'vend_kota.string': 'Kota vendor harus berupa teks.',
        'vend_kota.max_length': 'Kota vendor maksimal 50 karakter.',
        'vend_state.required': 'Provinsi vendor wajib diisi.',
        'vend_state.string': 'Provinsi vendor harus berupa teks.',
        'vend_state.max_length': 'Provinsi vendor maksimal 50 karakter.',
        'vend_zip.required': 'Kode pos vendor wajib diisi.',
        'vend_zip.max_length': 'Kode pos vendor maksimal 20 karakter.',
        'vend_country.required': 'Negara vendor wajib diisi.',
        'vend_country.string': 'Negara vendor harus berupa teks.',
        'vend_country.max_length': 'Negara vendor maksimal 50 karakter.',
      });

      final vendorData = request.input();

      final existingVendor = await Vendor()
          .query()
          .where('vend_name', '=', vendorData['vend_name'])
          .first();

      if (existingVendor != null) {
        return Response.json(
            {'message': 'Data vendor dengan nama ini sudah ada.'}, 409);
      }

      vendorData['created_at'] = DateTime.now().toIso8601String();

      await Vendor().query().insert(vendorData);

      return Response.json({
        'status': true,
        'message': 'Data vendor berhasil ditambahkan.',
        'data': vendorData
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
      final vendorData =
          await Vendor().query().where('vend_id', '=', id).first();

      if (vendorData == null) {
        return Response.json({'message': 'Data vendor tidak ditemukan.'}, 404);
      }

      return Response.json({
        'status': true,
        'message': 'Data vendor berhasil diambil.',
        'data': vendorData
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
        'vend_name': 'string|max_length:100',
        'vend_address': 'string|max_length:255',
        'vend_kota': 'string|max_length:50',
        'vend_state': 'string|max_length:50',
        'vend_zip': 'max_length:20',
        'vend_country': 'string|max_length:50',
      }, {
        'vend_name.string': 'Nama vendor harus berupa teks.',
        'vend_name.max_length': 'Nama vendor maksimal 100 karakter.',
        'vend_address.string': 'Alamat vendor harus berupa teks.',
        'vend_address.max_length': 'Alamat vendor maksimal 255 karakter.',
        'vend_kota.string': 'Kota vendor harus berupa teks.',
        'vend_kota.max_length': 'Kota vendor maksimal 50 karakter.',
        'vend_state.string': 'Provinsi vendor harus berupa teks.',
        'vend_state.max_length': 'Provinsi vendor maksimal 50 karakter.',
        'vend_zip.required': 'Kode pos vendor wajib diisi.',
        'vend_zip.max_length': 'Kode pos vendor maksimal 20 karakter.',
        'vend_country.string': 'Negara vendor harus berupa teks.',
        'vend_country.max_length': 'Negara vendor maksimal 50 karakter.',
      });

      final vendorData = request.input();

      if (vendorData.containsKey('id')) {
        vendorData['vend_id'] = vendorData['id'];
        vendorData.remove('id');
      }
      print('Data yang diterima: $vendorData');

      vendorData['updated_at'] = DateTime.now().toIso8601String();

      final customer = await Vendor().query().where('vend_id', '=', id).first();
      if (customer == null) {
        return Response.json(
            {'message': 'Data vendor dengan ID $id tidak ditemukan.'}, 404);
      }

      await Vendor().query().where('vend_id', '=', id).update(vendorData);

      return Response.json({
        'status': true,
        'message': 'Data vendor dengan ID $id telah berhasi diperbarui.',
        'data': vendorData
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
      final existingVendor =
          await Vendor().query().where('vend_id', '=', id).first();

      if (existingVendor == null) {
        return Response.json(
            {'message': 'DAta vendor dengan ID $id tidak ditemukan.'}, 400);
      }

      await Vendor().query().where('vend_id', '=', id).delete();

      return Response.json({
        'status': true,
        'message': 'Data vendor dengan ID $id telah berhasil dihapus.'
      }, 200);
    } catch (e) {
      return Response.json({
        'message': 'Terjadi kesalahan saat menghapus produk.',
        'error': e.toString()
      }, 500);
    }
  }
}

final VendorController vendorController = VendorController();
