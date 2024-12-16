import 'package:vania/vania.dart';
// ignore: implementation_imports
import 'package:vania/src/exception/validation_exception.dart';
import 'package:tugas_paml/app/models/product.dart';
import 'package:tugas_paml/app/models/productnote.dart';

class ProductNoteController extends Controller {
  Future<Response> index() async {
    try {
      final productNoteData = await Productnote().query().get();

      return Response.json({
        'status': true,
        'message': 'Data catatan produk berhasil diambil.',
        'data': productNoteData
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
        'prod_id': 'required|integer',
        'note_date': 'required|date',
        'note_text': 'required|string',
      }, {
        'prod_id.required': 'ID produk wajib diisi.',
        'prod_id.integer': 'ID produk harus berupa angka.',
        'note_date.required': 'Tanggal catatan wajib diisi.',
        'note_date.date': 'Tanggal catatan harus berupa tanggal.',
        'note_text.required': 'Teks catatan wajib diisi.',
        'note_text.string': 'Teks catatan harus berupa teks.',
      });

      final productNoteData = request.input();

      final existingProduct = await Product()
          .query()
          .where('prod_id', '=', productNoteData['prod_id'])
          .first();

      if (existingProduct == null) {
        return Response.json(
            {'message': 'Data catatan produk dengan ID ini tidak ada.'}, 404);
      }

      productNoteData['created_at'] = DateTime.now().toIso8601String();

      await Productnote().query().insert(productNoteData);

      return Response.json({
        'status': true,
        'message': 'Data catatan produk berhasil ditambahkan.',
        'data': productNoteData
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
      final productNoteData =
          await Productnote().query().where('note_id', '=', id).first();

      if (productNoteData == null) {
        return Response.json(
            {'message': 'Data catatan produk tidak ditemukan.'}, 404);
      }

      return Response.json({
        'status': true,
        'message': 'Data catatan produk berhasil diambil.',
        'data': productNoteData
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
        'prod_id': 'integer',
        'note_date': 'date',
        'note_text': 'string',
      }, {
        'prod_id.integer': 'ID produk harus berupa angka.',
        'note_date.date': 'Tanggal catatan harus berupa tanggal.',
        'note_text.string': 'Teks catatan harus berupa teks.',
      });

      final productNoteData = request.input();

      if (productNoteData.containsKey('id')) {
        productNoteData['note_id'] = productNoteData['id'];
        productNoteData.remove('id');
      }

      productNoteData['updated_at'] = DateTime.now().toIso8601String();

      final existingProductNote =
          await Productnote().query().where('note_id', '=', id).first();

      if (existingProductNote == null) {
        return Response.json(
            {'message': 'Data catatan produk dengan ID ini tidak ada.'}, 404);
      }

      if (productNoteData.containsKey('prod_id')) {
        final existingProduct = await Product()
            .query()
            .where('prod_id', '=', productNoteData['prod_id'])
            .first();

        if (existingProduct == null) {
          return Response.json(
              {'message': 'Data catatan produk dengan ID ini tidak ada.'}, 404);
        }
      }

      await Productnote()
          .query()
          .where('note_id', '=', id)
          .update(productNoteData);

      return Response.json({
        'status': true,
        'message': 'data catatan produk berhasil diupdate.',
        'data': productNoteData
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
      final existingProductNote =
          await Productnote().query().where('note_id', '=', id).first();

      if (existingProductNote == null) {
        return Response.json(
            {'message': 'Data catatan produk dengan ID ini tidak ada.'}, 404);
      }

      await Productnote().query().where('note_id', '=', id).delete();

      return Response.json({
        'status': true,
        'message': 'Data catatan produk berhasil dihapus.',
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

final ProductNoteController productNoteController = ProductNoteController();
