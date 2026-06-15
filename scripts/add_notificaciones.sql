-- ============================================================
-- Tabla de Notificaciones
-- Ejecutar en Supabase SQL Editor
-- ============================================================

CREATE TABLE IF NOT EXISTS notificacion (
  id_notificacion TEXT PRIMARY KEY,
  receptor_id     UUID REFERENCES usuario(id_usuario) ON DELETE CASCADE,
  para_admin      BOOLEAN NOT NULL DEFAULT FALSE,
  tipo            TEXT NOT NULL,
  mensaje         TEXT NOT NULL,
  leida           BOOLEAN NOT NULL DEFAULT FALSE,
  fecha           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  ref_id          TEXT
);

-- Al menos uno de los dos campos debe estar activo
ALTER TABLE notificacion ADD CONSTRAINT chk_receptor
  CHECK (receptor_id IS NOT NULL OR para_admin = TRUE);

ALTER TABLE notificacion ENABLE ROW LEVEL SECURITY;

-- Leer: propias o admin
DROP POLICY IF EXISTS "notif_select" ON notificacion;
CREATE POLICY "notif_select" ON notificacion
  FOR SELECT USING (receptor_id = auth.uid() OR para_admin = TRUE);

-- Insertar: cualquier autenticado
DROP POLICY IF EXISTS "notif_insert" ON notificacion;
CREATE POLICY "notif_insert" ON notificacion
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Actualizar (marcar leída): propias o admin
DROP POLICY IF EXISTS "notif_update" ON notificacion;
CREATE POLICY "notif_update" ON notificacion
  FOR UPDATE USING (receptor_id = auth.uid() OR para_admin = TRUE);
