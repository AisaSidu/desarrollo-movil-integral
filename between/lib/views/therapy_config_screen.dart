import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/therapy_view_model.dart';

class TherapyConfigScreen extends StatefulWidget {
  @override
  _TherapyConfigScreenState createState() => _TherapyConfigScreenState();
}

class _TherapyConfigScreenState extends State<TherapyConfigScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedFrequency = 'ninguna';

  final List<String> _frequencies = ['ninguna', 'semanal', 'quincenal', 'mensual'];

  @override
  void initState() {
    super.initState();
    // Cargamos los datos actuales cuando se abre la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<TherapyViewModel>(context, listen: false);
      setState(() {
        _selectedFrequency = vm.frequency;
        if (vm.nextSessionDate != null) {
          _selectedDate = vm.nextSessionDate;
          _selectedTime = TimeOfDay.fromDateTime(vm.nextSessionDate!);
        } else {
          _selectedDate = DateTime.now();
          _selectedTime = TimeOfDay.now();
        }
      });
    });
  }

  // --- SELECTOR DE FECHA (Calendario Nativo) ---
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(), // No permitimos fechas en el pasado
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Colors.deepPurple), // Tema clínico/calmante
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  // --- SELECTOR DE HORA (Reloj Nativo) ---
  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  // --- GUARDAR CONFIGURACIÓN ---
  void _saveSettings() {
    if (_selectedDate == null || _selectedTime == null) return;

    // Combinamos la fecha y la hora en un solo objeto DateTime
    final DateTime finalDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // Llamamos al ViewModel para guardar en SQLite y programar la alarma
    Provider.of<TherapyViewModel>(context, listen: false)
        .setTherapySchedule(finalDateTime, _selectedFrequency);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Agenda actualizada correctamente 🧠"),
        backgroundColor: Colors.green,
      ),
    );
    
    Navigator.pop(context); // Regresamos a la pantalla anterior
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configurar Terapia"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- TARJETA DE INSTRUCCIONES ---
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.deepPurple, size: 30),
                    SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        "Configura tu próxima sesión. Between te enviará una notificación 24 horas antes para que revises tu diario.",
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),

            Text("Detalles de la Cita", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),

            // --- SELECTOR DE FECHA Y HORA ---
            Card(
              elevation: 0,
              color: Colors.grey.shade100,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.calendar_today, color: Colors.deepPurple),
                    title: Text("Día de la sesión"),
                    subtitle: Text(_selectedDate != null 
                        ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}" 
                        : "Seleccionar fecha"),
                    trailing: Icon(Icons.edit, size: 18),
                    onTap: () => _pickDate(context),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.access_time, color: Colors.deepPurple),
                    title: Text("Hora de la sesión"),
                    subtitle: Text(_selectedTime != null 
                        ? _selectedTime!.format(context) 
                        : "Seleccionar hora"),
                    trailing: Icon(Icons.edit, size: 18),
                    onTap: () => _pickTime(context),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            Text("Frecuencia", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),

            // --- SELECTOR DE FRECUENCIA ---
            DropdownButtonFormField<String>(
              value: _selectedFrequency,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade100,
                prefixIcon: Icon(Icons.autorenew, color: Colors.deepPurple),
              ),
              items: _frequencies.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.toUpperCase()),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedFrequency = newValue!;
                });
              },
            ),
            
            SizedBox(height: 40),

            // --- BOTÓN DE GUARDADO ---
            ElevatedButton.icon(
              icon: Icon(Icons.save),
              label: Text("Guardar Agenda", style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _saveSettings,
            ),
          ],
        ),
      ),
    );
  }
}