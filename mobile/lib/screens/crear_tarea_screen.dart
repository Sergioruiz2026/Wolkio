import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/tarea.dart';
import '../services/supabase_service.dart';

class CrearTareaScreen extends StatefulWidget {
  final String solicitanteId;
  const CrearTareaScreen({super.key, required this.solicitanteId});

  @override
  State<CrearTareaScreen> createState() => _CrearTareaScreenState();
}

class _CrearTareaScreenState extends State<CrearTareaScreen> {
  CategoriaTarea _categoria = CategoriaTarea.patio;
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  bool _publicando = false;

  Future<Position> _obtenerUbicacion() async {
    final permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
    return Geolocator.getCurrentPosition();
  }

  Future<void> _publicarTarea() async {
    setState(() => _publicando = true);
    try {
      final posicion = await _obtenerUbicacion();
      final tarea = Tarea(
        id: '', // lo genera Supabase
        solicitanteId: widget.solicitanteId,
        categoria: _categoria,
        descripcion: _descripcionController.text,
        latitud: posicion.latitude,
        longitud: posicion.longitude,
        precioOfrecido: double.tryParse(_precioController.text) ?? 0,
      );
      await SupabaseService.crearTarea(tarea);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _publicando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva tarea')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<CategoriaTarea>(
              value: _categoria,
              decoration: const InputDecoration(labelText: 'Categoría'),
              items: CategoriaTarea.values
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                  .toList(),
              onChanged: (v) => setState(() => _categoria = v!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descripcionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _precioController,
              decoration: const InputDecoration(labelText: 'Precio ofrecido (CLP)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _publicando ? null : _publicarTarea,
              child: _publicando
                  ? const CircularProgressIndicator()
                  : const Text('Publicar tarea'),
            ),
          ],
        ),
      ),
    );
  }
}
