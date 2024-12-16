import 'package:vania/vania.dart';
import 'package:tugas_paml/app/http/controllers/auth_controller.dart';
import 'package:tugas_paml/app/http/controllers/customer_controller.dart';
import 'package:tugas_paml/app/http/controllers/order_controller.dart';
import 'package:tugas_paml/app/http/controllers/order_item_controller.dart';
import 'package:tugas_paml/app/http/controllers/product_controller.dart';
import 'package:tugas_paml/app/http/controllers/product_note_controller.dart';
import 'package:tugas_paml/app/http/controllers/vendor_controller.dart';
import 'package:tugas_paml/app/http/middleware/authenticate.dart';

class ApiRoute implements Route {
  @override
  void register() {
    Router.basePrefix('api');

    Router.group(() {
      Router.post('/register', authController.register);
      Router.post('/login', authController.login);
    }, prefix: 'auth');

    Router.group(() {
      Router.patch('/update-password', authController.updatePassword);
      Router.get('/get-user', authController.getUser);
    }, prefix: 'user', middleware: [AuthenticateMiddleware()]);

    Router.group(() {
      Router.get('/get-customer', customerController.index);
      Router.get('/get-customer/{id}', customerController.show);
      Router.post('/create-customer', customerController.store);
      Router.put('/update-customer/{id}', customerController.update);
      Router.delete('/delete-customer/{id}', customerController.destroy);
    }, prefix: 'customer', middleware: [AuthenticateMiddleware()]);

    Router.group(() {
      Router.get('/get-product', productController.index);
      Router.get('/get-product/{id}', productController.show);
      Router.post('/create-product', productController.store);
      Router.put('/update-product/{id}', productController.update);
      Router.delete('/delete-product/{id}', productController.destroy);
    }, prefix: 'product', middleware: [AuthenticateMiddleware()]);

    Router.group(() {
      Router.get('/get-vendor', vendorController.index);
      Router.get('/get-vendor/{id}', vendorController.show);
      Router.post('/create-vendor', vendorController.store);
      Router.put('/update-vendor/{id}', vendorController.update);
      Router.delete('/delete-vendor/{id}', vendorController.destroy);
    }, prefix: 'vendor', middleware: [AuthenticateMiddleware()]);

    Router.group(() {
      Router.get('/get-productnote', productNoteController.index);
      Router.get('/get-productnote/{id}', productNoteController.show);
      Router.post('/create-productnote', productNoteController.store);
      Router.put('/update-productnote/{id}', productNoteController.update);
      Router.delete('/delete-productnote/{id}', productNoteController.destroy);
    }, prefix: 'product-note', middleware: [AuthenticateMiddleware()]);

    Router.group(() {
      Router.get('/get-order', orderController.index);
      Router.get('/get-order/{id}', orderController.show);
      Router.post('/create-order', orderController.store);
      Router.put('/update-order/{id}', orderController.update);
      Router.delete('/delete-order/{id}', orderController.destroy);
    }, prefix: 'order', middleware: [AuthenticateMiddleware()]);

    Router.group(() {
      Router.get('/get-order-item', orderItemController.index);
      Router.get('/get-order-item/{id}', orderItemController.show);
      Router.post('/create-order-item', orderItemController.store);
      Router.put('/update-order-item/{id}', orderItemController.update);
      Router.delete('/delete-order-item/{id}', orderItemController.destroy);
    }, prefix: 'order-item', middleware: [AuthenticateMiddleware()]);
  }
}
