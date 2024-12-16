import 'package:vania/vania.dart';
// ignore: implementation_imports
import 'package:vania/src/exception/validation_exception.dart';
import 'package:tugas_paml/app/models/user.dart';

class AuthController extends Controller {
  Future<Response> getUser() async {
    Map? userData = Auth().user();

    if (userData != null) {
      userData.remove('password');
      return Response.json({
        'status': true,
        'message': 'Data pengguna berhasil diambil.',
        'data': userData
      }, 200);
    } else {
      return Response.json(
          {'status': 'error', 'message': 'Pengguna tidak teratentikasi.'}, 401);
    }
  }

  Future<Response> register(Request request) async {
    try {
      request.validate({
        'name': 'required|string',
        'email': 'required|email',
        'password': 'required|string|min_length:8|confirmed'
      }, {
        'name.required': 'Kolom nama wajib diisi.',
        'name.string': 'Inputan nama harus berupa teks.',
        'email.required': 'Kolom email wajib diisi.',
        'email.email': 'Inputan email harus berisi email yang valid.',
        'password.required': 'Kolom password wajib diisi.',
        'password.string': 'Inputan password harus berupa teks',
        'password.min_length': 'Inputan password minimal 8 karakter.',
        'password.confirmed': 'Konfirmasi password tidak sesuai.'
      });

      final name = request.input('name');
      final email = request.input('email');
      final password = request.input('password');

      var userData = await User().query().where('email', '=', email).first();
      if (userData != null) {
        return Response.json(
            {'message': 'Email yang Anda masukan sudah ada.'}, 409);
      }

      final hashedPassword = Hash().make(password);

      await User().query().insert({
        'name': name,
        'email': email,
        'password': hashedPassword,
        'created_at': DateTime.now(),
        'updated_at': DateTime.now(),
      });

      return Response.json(
          {'status': true, 'message': 'Registrasi telah berhasil.'}, 201);
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

  Future<Response> login(
    Request request,
  ) async {
    try {
      request.validate({
        'email': 'required|email',
        'password': 'required|min_length:8'
      }, {
        'email.required': 'Kolom email wajib diisi.',
        'email.email': 'Email yang diinputkan harus email yang valid.',
        'password.required': 'Kolom password wajib diisi.',
        'password.min_length': 'Inputan password minimal 8 karakter.'
      });

      final email = request.input('email');
      final password = request.input('password');

      var userData = await User().query().where('email', '=', email).first();
      if (userData == null) {
        return Response.json({'message': 'User belum terdaftar.'}, 409);
      }

      if (!Hash().verify(password, userData['password'])) {
        return Response.json(
            {'message': 'Password yang Anda masukan salah.'}, 401);
      }

      final auth = Auth().login(userData);
      final token = await auth.createToken(expiresIn: Duration(days: 30));

      return Response.json(
          {'status': true, 'message': 'Login berhasil', 'token': token});
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

  Future<Response> updatePassword(Request request) async {
    try {
      request.validate({
        'current_password': 'required',
        'password': 'required|min_length:8|confirmed'
      }, {
        'current_password.required': 'Kolom password saat ini wajib diisi.',
        'password.required': 'Kolom password baru wajib diisi.',
        'password.min_length': 'Inputan password minimal 8 karakter.',
        'password.confirmed': 'Konfirmasi password tidak sesuai.'
      });

      String currentPassword = request.string('current_password');

      Map<String, dynamic>? userData = Auth().user();

      if (userData != null) {
        if (Hash().verify(currentPassword, userData['password'])) {
          await User()
              .query()
              .where('id', '=', Auth().id())
              .update({'password': Hash().make(request.string('password'))});
          return Response.json(
              {'status': 'success', 'massage': 'Password berhasil diperbarui.'},
              200);
        } else {
          return Response.json(
              {'status': 'error', 'message': 'Password saat ini tidak cocok.'},
              401);
        }
      } else {
        return Response.json(
            {'status': 'error', 'message': 'Pengguna tidak tersedia'}, 404);
      }
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
}

final AuthController authController = AuthController();
