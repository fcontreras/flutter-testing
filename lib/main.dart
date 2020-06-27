import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testing_example/blocs/calculador_de_productos_bloc.dart';
import 'package:testing_example/blocs/lista_de_productos_bloc.dart';
import 'package:testing_example/modelos/detalle_de_orden.dart';
import 'package:testing_example/repositorios/productos_repositorio.dart';

import 'modelos/producto.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => CalculadorDeProductosBloc(),
          ),
          BlocProvider(
            create: (context) => ListaDeProductosBloc(ProductosRepositorio()),
          )
        ],
        child: MyHomePage(title: 'Flutter Demo Home Page')),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  CalculadorDeProductosBloc _calculadorDeProductosBloc;
  ListaDeProductosBloc _listaDeProductosBloc;

  @override
  void initState() {
    super.initState();

    _calculadorDeProductosBloc = BlocProvider.of<CalculadorDeProductosBloc>(context);
    _calculadorDeProductosBloc.add(IniciarCalculador());

    _listaDeProductosBloc = BlocProvider.of<ListaDeProductosBloc>(context);
    _listaDeProductosBloc.add(CargarLista());
  }

  @override
  Widget build(BuildContext context) {
    var t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: BlocBuilder<CalculadorDeProductosBloc, EstadoDeCalculadorDeProductos>(
        builder: (context, state) {
          if (state is CalculadoraNoInicializada) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (state.detallesDeOrden.length > 0) {
              var detalles = <Widget>[];
              state.detallesDeOrden.forEach((element) {
                detalles.add(DetalleDeOrdenWidget(detalleDeOrden: element,));
              });

              return Stack(
                children: <Widget>[
                  Column(
                      children:
                      detalles +
                          [
                            SizedBox(height: 30),
                            Center(
                              child: IconButton(
                                icon: Icon(Icons.add_circle_outline, size: 40),
                                onPressed: () {
                                  if (_listaDeProductosBloc.state is ListaCargada) {
                                    _agregarDetalleDeOrden(_listaDeProductosBloc.state.productos);
                                  }
                                },
                              ),
                            )
                          ]
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.black38, width: 1)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Table(
                                columnWidths: {
                                  0: FixedColumnWidth(100),
                                  1: FixedColumnWidth(80)
                                },
                                children: [
                                  TableRow(
                                    children: [
                                      Text('Sub total', style: t.headline6.copyWith(color: Colors.black54),),
                                      Text(state.subTotal.toString(), style: t.headline6.copyWith(color: Colors.black54), textAlign: TextAlign.right,)
                                    ]
                                  ),
                                  TableRow(
                                      children: [
                                        Text('Impuestos', style: t.headline6.copyWith(color: Colors.black54),),
                                        Text(state.impuestos.toString(), style: t.headline6.copyWith(color: Colors.black54), textAlign: TextAlign.right,)
                                      ]
                                  ),
                                  TableRow(
                                      children: [
                                        Text('Gran total', style: t.headline6,),
                                        Text(state.granTotal.toString(), style: t.headline6, textAlign: TextAlign.right,)
                                      ]
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      )
                    ),
                  )
                ],
              );
            } else {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text("Tu lista esta vacia, agrega un producto"),
                    SizedBox(height: 40,),
                    Center(
                      child: IconButton(
                        icon: Icon(Icons.add_circle_outline, size: 40,),
                        onPressed: () {
                          if (_listaDeProductosBloc.state is ListaCargada) {
                            _agregarDetalleDeOrden(_listaDeProductosBloc.state.productos);
                          }
                        },
                      ),
                    )
                  ],
                ),
              );
            }
          }
        },
      )
    );
  }

  void _agregarDetalleDeOrden(List<Producto> productos) async {
    var detalleDeOrden = await showDialog<DetalleDeOrden>(
        context: context,
      builder: (context) {
          return AgregarProductoForm(productos: productos,);
      }
    );

    if (detalleDeOrden != null) {
      _calculadorDeProductosBloc.add(AgregarProducto(detalleDeOrden));
    }
  }
}

class DetalleDeOrdenWidget extends StatelessWidget {

  final DetalleDeOrden detalleDeOrden;

  const DetalleDeOrdenWidget({Key key, this.detalleDeOrden}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.computer, size: 40,),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(detalleDeOrden.producto.descripcion),
          Text(detalleDeOrden.producto.precio.toString()),
          Text(detalleDeOrden.cantidad.toString())
        ],
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete),
      ),
    );
  }

}

class AgregarProductoForm extends StatefulWidget {

  final List<Producto> productos;

  const AgregarProductoForm({Key key, this.productos}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AgregarProductosFormState();

}

class _AgregarProductosFormState extends State<AgregarProductoForm> {

  Producto producto;
  int cantidad;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Agregar detalle de orden"),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          DropdownButton<Producto>(
            value: this.producto,
            items: widget.productos.map<DropdownMenuItem<Producto>>((e) => DropdownMenuItem<Producto>(value: e, child: Text(e.descripcion),)).toList(),
            onChanged: (producto) {
              print(producto.descripcion);
              setState(() {
                this.producto = producto;
              });
            },
          ),

          DropdownButton<int>(
            value: this.cantidad,
            items: [1, 2, 3, 4, 5].map<DropdownMenuItem<int>>((e) => DropdownMenuItem<int>(value: e, child: Text(e.toString()),)).toList(),
            onChanged: (q) {
              setState(() {
                this.cantidad = q;
              });
            },
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Cancelar"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text("Agregar"),
          onPressed: () {
            Navigator.of(context).pop(DetalleDeOrden(producto, cantidad));
          },
        )
      ],
    );
  }

}