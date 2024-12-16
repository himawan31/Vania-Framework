import 'package:vania/vania.dart';
// ignore: implementation_imports
import 'package:vania/src/exception/validation_exception.dart';
import 'package:tugas_paml/app/models/product.dart';
import 'package:tugas_paml/app/models/vendor.dart';

class ProductController extends Controller {
  Future<Response> index() async {
    try {
      final productData = await Product().query().get();

      return Response.json({
        'status': true,
        'message': 'Data produk berhasil diambil.',
        'data': productData
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
        'prod_name': 'required|string|max_length:100',
        'prod_desc': 'required|string|max_length:255',
        'prod_price': 'required|numeric|min:0',
        'vend_id': 'required|numeric'
      }, {
        'prod_name.required': 'Nama produk wajib diisi.',
        'prod_name.string': 'Nama produk harus berupa teks.',
        'prod_name.max_length': 'Nama produk maksimal 100 karakter.',
        'prod_desc.string': 'Deskripsi produk harus berupa teks.',
        'prod_desc.required': 'Deskripsi produk wajib diisi.',
        'prod_desc.max_length': 'Deskripsi produk maksimal 255 karakter.',
        'prod_price.required': 'Harga produk wajib diisi.',
        'prod_price.numeric': 'Harga produk harus berupa angka.',
        'prod_price.min': 'Harga produk tidak boleh kurang dari 0.',
        'vend_id.required': 'ID vendor wajib diisi.',
        'vend_id.numeric': 'ID vendor harus berupa angka.',
      });

      final productData = request.input();
      final vendId = productData['vend_id'];

      final vendorCount =
          await Vendor().query().where('vend_id', '=', vendId).count();

      final vendorExists = vendorCount > 0;

      if (!vendorExists) {
        return Response.json(
            {'message': 'Vendor dengan ID ini tidak ditemukan.'}, 400);
      }

      final existingProduct = await Product()
          .query()
          .where('prod_name', '=', productData['prod_name'])
          .first();

      if (existingProduct != null) {
        return Response.json(
            {'message': 'Produk dengan nama ini sudah ada.'}, 409);
      }

      productData['created_at'] = DateTime.now().toIso8601String();

      await Product().query().insert(productData);

      return Response.json({
        'status': true,
        'message': 'Data produk berhasil ditambahkan.',
        'data': productData
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
      final productData =
          await Product().query().where('prod_id', '=', id).first();

      if (productData == null) {
        return Response.json({'message': 'Data produk tidak ditemukan.'}, 404);
      }

      return Response.json({
        'status': true,
        'message': 'Data produk berhasil diambil.',
        'data': productData
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
        'prod_name': 'required|string|max_length:100',
        'prod_desc': 'required|string|max_length:255',
        'prod_price': 'required|numeric|min:0',
        'vend_id': 'required|numeric'
      }, {
        'prod_name.required': 'Nama produk wajib diisi.',
        'prod_name.string': 'Nama produk harus berupa teks.',
        'prod_name.max_length': 'Nama produk maksimal 100 karakter.',
        'prod_desc.string': 'Deskripsi produk harus berupa teks.',
        'prod_desc.required': 'Deskripsi produk wajib diisi.',
        'prod_desc.max_length': 'Deskripsi produk maksimal 255 karakter.',
        'prod_price.required': 'Harga produk wajib diisi.',
        'prod_price.numeric': 'Harga produk harus berupa angka.',
        'prod_price.min': 'Harga produk tidak boleh kurang dari 0.',
        'vend_id.required': 'ID vendor wajib diisi.',
        'vend_id.numeric': 'ID vendor harus berupa angka.',
      });

      final productData = request.input();

      if (productData.containsKey('id')) {
        productData['prod_id'] = productData['id'];
        productData.remove('id');
      }
      print('Data yang diterima: $productData');

      productData['updated_at'] = DateTime.now().toIso8601String();

      final product = await Product().query().where('prod_id', '=', id).first();
      if (product == null) {
        return Response.json(
            {'message': 'Produk dengan ID $id tidak ditemukan.'}, 404);
      }

      await Product().query().where('prod_id', '=', id).update(productData);

      return Response.json({
        'status': true,
        'message': 'Data produk dengan ID $id telah berhasi diperbarui.',
        'data': productData
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
      final existingProduct =
          await Product().query().where('prod_id', '=', id).first();

      if (existingProduct == null) {
        return Response.json(
            {'message': 'Produk dengan ID $id tidak ditemukan.'}, 400);
      }

      await Product().query().where('prod_id', '=', id).delete();

      return Response.json({
        'status': true,
        'message': 'Produk dengan ID $id telah berhasil dihapus.'
      }, 200);
    } catch (e) {
      return Response.json({
        'message': 'Terjadi kesalahan saat menghapus produk.',
        'error': e.toString()
      }, 500);
    }
  }
}

final ProductController productController = ProductController();
