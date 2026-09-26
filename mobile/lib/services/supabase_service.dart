import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tarea.dart';

/// Centraliza el acceso a Supabase: autenticación y consultas de tareas.
/// Reemplaza SUPABASE_URL y SUPABASE_ANON_KEY por las de tu proyecto real
/// (idealmente vía variables de entorno, no hardcodeadas).
class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  static Future<void> init() async {
    await Supabase.initialize(
      url: 'SUPABASE_URL',
      anonKey: 'SUPABASE_ANON_KEY',
    );
  }

  /// Crea una nueva tarea publicada por el solicitante.
  static Future<Tarea> crearTarea(Tarea tarea) async {
    final response = await client
        .from('tarea')
        .insert(tarea.toJson())
        .select()
        .single();
    return Tarea.fromJson(response);
  }

  /// Llama a la función SQL prestadores_cercanos() para encontrar
  /// prestadores dentro del radio configurado para una tarea dada.
  static Future<List<Map<String, dynamic>>> prestadoresCercanos(
      String tareaId) async {
    final response = await client
        .rpc('prestadores_cercanos', params: {'tarea_id_param': tareaId});
    return List<Map<String, dynamic>>.from(response);
  }

  /// El prestador acepta una tarea: se asigna y cambia de estado.
  static Future<void> aceptarTarea(String tareaId, String prestadorId) async {
    await client.from('tarea').update({
      'prestador_id': prestadorId,
      'estado': 'asignada',
    }).eq('id', tareaId);
  }
}
