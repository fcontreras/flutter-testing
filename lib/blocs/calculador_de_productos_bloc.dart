import 'package:bloc/bloc.dart';
import 'package:testing_example/modelos/detalle_de_orden.dart';
import 'package:testing_example/modelos/producto.dart';

class CalculadorDeProductosBloc extends Bloc<EventoDeCalculadorDeProductos, EstadoDeCalculadorDeProductos>{

  @override
  EstadoDeCalculadorDeProductos get initialState => CalculadoraNoInicializada();

  @override
  Stream<EstadoDeCalculadorDeProductos> mapEventToState(EventoDeCalculadorDeProductos evento) async* {
    if (evento is AgregarProducto) {
      yield* _agregarProducto(evento.detalleDeOrden);
    } else if (evento is IniciarCalculador) {
      yield* _inicializarCalculador();
    }
  }

  Stream<EstadoDeCalculadorDeProductos>  _inicializarCalculador() async* {
    this.state.detallesDeOrden = [];
    yield* _hacerCalculos();
  }

  Stream<EstadoDeCalculadorDeProductos> _agregarProducto(DetalleDeOrden detalleDeOrden) async* {
    this.state.detallesDeOrden.add(detalleDeOrden);
    yield* _hacerCalculos();
  }

  Stream<EstadoDeCalculadorDeProductos> _hacerCalculos() async* {
    var subTotal = _calcularSubTotal();
    var impuestos = _calcularImpuestos(subTotal);
    var granTotal = _calcularTotal(subTotal, impuestos);

    yield CalculosCompletados(this.state.detallesDeOrden, subTotal, impuestos, granTotal);
  }

  double _calcularSubTotal() {
    var subTotal = 0.0;
    this.state.detallesDeOrden.forEach((element) => subTotal += element.producto.precio * element.cantidad);

    return subTotal;
  }

  double _calcularImpuestos(double subTotal) {
    return subTotal * 0.15;
  }

  double _calcularTotal(double subTotal, double impuestos) {
    return subTotal + impuestos;
  }

}

abstract class EventoDeCalculadorDeProductos {}
class IniciarCalculador extends EventoDeCalculadorDeProductos {}
class AgregarProducto extends EventoDeCalculadorDeProductos {
  final DetalleDeOrden detalleDeOrden;

  AgregarProducto(this.detalleDeOrden);
}

abstract class EstadoDeCalculadorDeProductos {
  List<DetalleDeOrden> detallesDeOrden;
  double subTotal;
  double impuestos;
  double granTotal;
}
class CalculadoraNoInicializada extends EstadoDeCalculadorDeProductos {}
class CalculosCompletados extends EstadoDeCalculadorDeProductos {

  CalculosCompletados(List<DetalleDeOrden> detallesDeOrden, double subTotal, double impuestos, double granTotal) {
    this.detallesDeOrden = detallesDeOrden;
    this.subTotal = subTotal;
    this.impuestos = impuestos;
    this.granTotal = granTotal;
  }

}

