import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/notes_view_model.dart';

class AddNoteScreen extends StatefulWidget {
  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  // Esta llave es vital para que Flutter sepa que es un "Formulario" validable
  final _formKey = GlobalKey<FormState>(); 
  
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nueva Nota del Diario")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form( // <-- La estructura oficial de formulario
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Título (Ej. Día estresante en la UT)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                // Validación para que no guarden notas sin título
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor ingresa un título";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: "¿Qué sentiste hoy o qué pasó?",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 6, // Lo hace más grande, como un área de texto
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "El contenido del diario no puede estar vacío";
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text("Guardar en el Diario", style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 15)),
                onPressed: () {
                  // Si el formulario pasa las validaciones...
                  if (_formKey.currentState!.validate()) {
                    // 1. Guardamos la nota usando el ViewModel
                    Provider.of<NotesViewModel>(context, listen: false).addNote(
                      _titleController.text, 
                      _contentController.text
                    );
                    
                    // 2. Cerramos el formulario
                    Navigator.pop(context);
                    
                    // 3. Mostramos un mensaje de éxito
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Nota guardada correctamente"), backgroundColor: Colors.green,)
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}