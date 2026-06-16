import 'package:supabase_flutter/supabase_flutter.dart';

class NotificacionItem {
  final String id;
  final String tipo;
  final String mensaje;
  final bool leida;
  final DateTime fecha;

  const NotificacionItem({
    required this.id,
    required this.tipo,
    required this.mensaje,
    required this.leida,
    required this.fecha,
  });

  factory NotificacionItem.fromJson(Map<String, dynamic> json) =>
      NotificacionItem(
        id: json['id_notificacion'] as String,
        tipo: json['tipo'] as String,
        mensaje: json['mensaje'] as String,
        leida: json['leida'] as bool? ?? false,
        fecha: DateTime.parse(json['fecha'] as String),
      );
}

class NotificacionesDataSource {
  final SupabaseClient client;
  static const _table = 'notificacion';

  const NotificacionesDataSource({required this.client});

  Future<List<NotificacionItem>> getMisNotificaciones(String receptorId) async {
    final res = await client
        .from(_table)
        .select()
        .eq('receptor_id', receptorId)
        .eq('eliminada', false)
        .order('fecha', ascending: false);

    return (res as List)
        .map((e) => NotificacionItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<NotificacionItem>> getNotificacionesAdmin() async {
    final res = await client
        .from(_table)
        .select()
        .eq('para_admin', true)
        .eq('eliminada', false)
        .order('fecha', ascending: false);

    return (res as List)
        .map((e) => NotificacionItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> getUnreadCount(String receptorId) async {
    final res = await client
        .from(_table)
        .select('id_notificacion')
        .eq('receptor_id', receptorId)
        .eq('leida', false)
        .eq('eliminada', false);

    return (res as List).length;
  }

  Future<int> getAdminUnreadCount() async {
    final res = await client
        .from(_table)
        .select('id_notificacion')
        .eq('para_admin', true)
        .eq('leida', false)
        .eq('eliminada', false);

    return (res as List).length;
  }

  Future<void> marcarLeida(String id) async {
    await client
        .from(_table)
        .update({'leida': true})
        .eq('id_notificacion', id);
  }

  Future<void> marcarTodasLeidas({
    String? receptorId,
    bool paraAdmin = false,
  }) async {
    if (receptorId != null) {
      await client
          .from(_table)
          .update({'leida': true})
          .eq('receptor_id', receptorId)
          .eq('leida', false)
          .eq('eliminada', false);
    } else if (paraAdmin) {
      await client
          .from(_table)
          .update({'leida': true})
          .eq('para_admin', true)
          .eq('leida', false)
          .eq('eliminada', false);
    }
  }

  Future<void> eliminarNotificacion(String id) async {
    await client
        .from(_table)
        .update({'eliminada': true})
        .eq('id_notificacion', id);
  }

  Future<void> restaurarNotificacion(String id) async {
    await client
        .from(_table)
        .update({'eliminada': false})
        .eq('id_notificacion', id);
  }
}

// Helper standalone para crear notificaciones desde cualquier datasource.
// Falla silenciosamente para no bloquear la acción principal.
Future<void> crearNotificacion(
  SupabaseClient client, {
  String? receptorId,
  bool paraAdmin = false,
  required String tipo,
  required String mensaje,
  String? refId,
}) async {
  try {
    await client.from('notificacion').insert({
      'id_notificacion': 'NOTIF${DateTime.now().millisecondsSinceEpoch}',
      if (receptorId != null) 'receptor_id': receptorId,
      'para_admin': paraAdmin,
      'tipo': tipo,
      'mensaje': mensaje,
      'leida': false,
      'eliminada': false,
      if (refId != null) 'ref_id': refId,
    });
  } catch (_) {}
}