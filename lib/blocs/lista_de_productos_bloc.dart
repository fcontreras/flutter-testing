import 'package:bloc/bloc.dart';
import 'package:testing_example/modelos/producto.dart';
import 'package:testing_example/repositorios/productos_repositorio.dart';

class ListaDeProductosBloc extends Bloc<EventoDeLista, EstadoDeLista> {

  final ProductosRepositorio _repositorio;

  ListaDeProductosBloc(this._repositorio);

  @override
  // TODO: implement initialState
  EstadoDeLista get initialState => ListaNoInicializada();

  @override
  Stream<EstadoDeLista> mapEventToState(EventoDeLista event) async* {
    if (event is CargarLista) {
      yield* _cargarLista();
    }
  }

  Stream<EstadoDeLista> _cargarLista() async* {
    List<Producto> productos = await _repositorio.obtenerTodosLosProductos();
    yield ListaCargada(productos);
  }

}

abstract class EventoDeLista {}
class CargarLista extends EventoDeLista {}

abstract class EstadoDeLista {

  List<Producto> productos = [];

}
class ListaNoInicializada extends EstadoDeLista {}
class ListaCargada extends EstadoDeLista {

  ListaCargada(List<Producto> productos){
    this.productos = productos;
  }
}