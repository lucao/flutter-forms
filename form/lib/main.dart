import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'custom_camera.dart';

final dio = Dio();
//late final CameraDescription mainCamera;

void main() async {
  // Fetch the available cameras before initializing the app.
  try {
    WidgetsFlutterBinding.ensureInitialized();
    //CustomCamera.cameras = await availableCameras();
  } on CameraException catch (e) {
    print(e.description);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String _title = 'Formulário simples';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(title: const Text(_title)),
            body: const MenuPrincipal()));
  }
}

class MenuItem extends StatefulWidget {
  const MenuItem(
      {super.key,
      required tag,
      required text,
      required form,
      required iconData})
      : _tag = tag,
        _form = form,
        _icon = iconData,
        _text = text;

  final String _tag;
  final Text _text;
  final Widget _form;
  final IconData _icon;

  String get tag => _tag;
  Widget get form => _form;
  Icon get icon => Icon(_icon, size: 60.0);
  Text get text => _text;

  @override
  State<StatefulWidget> createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> {
  bool _selected = false;
  bool _menuOpen = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          setState(() {
            if (!_selected) {
              _selected = true;
            }
          });
        },
        child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: AnimatedContainer(
                width: _selected ? 700.0 : 100.0,
                height: _selected ? 500.0 : 100.0,
                color: _selected ? Colors.blue[200] : Colors.blue,
                alignment: _selected
                    ? Alignment.topLeft
                    : AlignmentDirectional.topCenter,
                duration: const Duration(milliseconds: 500),
                curve: Curves.fastOutSlowIn,
                onEnd: () {
                  setState(() {
                    if (_selected) {
                      _menuOpen = true;
                    }
                  });
                },
                child: _menuOpen
                    ? Container(
                        alignment: Alignment.topLeft,
                        child: Row(children: <Widget>[
                          GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selected = false;
                                  _menuOpen = false;
                                });
                              },
                              child: const Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: Icon(Icons.account_box, size: 60.0),
                                  ))),
                          Expanded(child: widget.text),
                          Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .push(PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                              secondaryAnimation) {
                                            return Scaffold(
                                                appBar: AppBar(
                                                    title: const Text(
                                                        "Formulário")),
                                                body: widget.form);
                                          },
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            const begin = Offset(0.0, 1.0);
                                            const end = Offset.zero;
                                            const curve = Curves.ease;

                                            var tween = Tween(
                                                    begin: begin, end: end)
                                                .chain(
                                                    CurveTween(curve: curve));

                                            return SlideTransition(
                                              position: animation.drive(tween),
                                              child: child,
                                            );
                                          },
                                        ));
                                      },
                                      child: const Text("Abrir"))))
                        ]))
                    : Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: widget.icon))));
  }
}

class MenuPrincipal extends StatelessWidget {
  const MenuPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(alignment: WrapAlignment.spaceEvenly, children: <Widget>[
      MenuItem(
          tag: "simples",
          text: Text("Formulário Simples"),
          form: FormularioSimples(),
          iconData: Icons.account_box),
      MenuItem(
          tag: "complexo",
          text: Text("Formulário Complexo"),
          form: FormularioSimples(),
          iconData: Icons.account_box)
    ]);
  }
}

class FormularioSimples extends StatefulWidget {
  const FormularioSimples({super.key});

  @override
  State<FormularioSimples> createState() => _FormularioSimplesState();
}

class _FormularioSimplesState extends State<FormularioSimples> {
  final GlobalKey<FormState> _simpleFormKey = GlobalKey<FormState>();
  bool _loadingFlag = false;

  XFile? _imageFile;
  XFile? _videoFile;

  final nomeTextController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nomeTextController.dispose();
    super.dispose();
  }

  submitForm() async {
    try {
      await dio.post('https://jsonplaceholder.typicode.com/name',
          data: jsonEncode(<String, String>{'nome': nomeTextController.text}),
          options: Options(headers: {
            Headers.contentTypeHeader: 'application/json; charset=UTF-8',
          }));
    } on DioError {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao tentar enviar dados')),
      );
    } finally {
      setState(() {
        _loadingFlag = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
        constraints: const BoxConstraints(
            maxHeight: 500.0, maxWidth: 1000.0, minHeight: 400, minWidth: 800),
        child: Form(
          key: _simpleFormKey,
          child: Row(children: <Widget>[
            const Padding(
                padding: EdgeInsets.all(20), child: Icon(Icons.face_2_rounded)),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                    height: 100.0,
                    width: 200.0,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'Enter your name',
                      ),
                      controller: nomeTextController,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ))),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CustomCamera()),
                  );
                },
                child: const Icon(Icons.add_a_photo)),
            ElevatedButton(
              onPressed: _loadingFlag
                  ? null
                  : () {
                      // Validate will return true if the form is valid, or false if
                      // the form is invalid.
                      if (_simpleFormKey.currentState!.validate()) {
                        setState(() {
                          _loadingFlag = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Enviando dados')),
                        );
                        submitForm();
                      }
                    },
              child: const Text('Submit'),
            )
          ]),
        ));
  }
}
