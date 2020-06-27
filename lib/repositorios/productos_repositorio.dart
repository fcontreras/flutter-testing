import 'package:testing_example/modelos/producto.dart';

class ProductosRepositorio {

  List<Producto> productos = [];

  ProductosRepositorio() {
    productos.add(Producto(id: 'p123', descripcion: 'Procesador', precio: 600.0));
    productos.add(Producto(id: 'm123', descripcion: 'Monitor', precio: 120.0));
    productos.add(Producto(id: 't123', descripcion: 'Teclado', precio: 40.0));
    productos.add(Producto(id: 'm234', descripcion: 'Mouse', precio: 60.0));
    productos.add(Producto(id: 'a123', descripcion: 'Auriculares', precio: 230.0));
  }

  Future<List<Producto>> obtenerTodosLosProductos() async {
    return productos;
  }

}