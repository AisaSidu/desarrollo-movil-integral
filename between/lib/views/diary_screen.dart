import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/notes_view_model.dart';
import 'add_note_screen.dart'; // Importamos el formulario

class DiaryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mi Diario Personal"),
        backgroundColor: Colors.teal, // Un color relajante
      ),
      // Usamos Consumer para escuchar los cambios en las notas
      body: Consumer<NotesViewModel>(
        builder: (context, notesVM, child) {
          // Si la lista está vacía, mostramos un mensaje amigable
          if (notesVM.notes.isEmpty) {
            return Center(
              child: Text(
                "Aún no tienes notas.\n¡Escribe cómo te sientes hoy!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // Si hay notas, construimos la lista
          return ListView.builder(
            itemCount: notesVM.notes.length,
            itemBuilder: (context, index) {
              final note = notesVM.notes[index];
              
              // Extraemos solo la fecha (YYYY-MM-DD) para que se vea limpio
              final dateString = note.date.toString().substring(0, 10);

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade100,
                    child: Icon(Icons.book, color: Colors.teal),
                  ),
                  title: Text(
                    note.title, 
                    style: TextStyle(fontWeight: FontWeight.bold)
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      Text(
                        note.content,
                        maxLines: 2, // Solo mostramos 2 líneas para no saturar
                        overflow: TextOverflow.ellipsis, // Pone "..." si es muy largo
                      ),
                      SizedBox(height: 5),
                      Text(
                        dateString, 
                        style: TextStyle(fontSize: 12, color: Colors.blueGrey)
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
      // Movimos el botón flotante aquí, tiene más sentido en la sección del diario
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => AddNoteScreen())
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}