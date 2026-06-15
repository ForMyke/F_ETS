-- ============================================================
-- Flujo de Revisión de ETS
-- Ejecutar en Supabase SQL Editor
-- ============================================================
--
-- Nuevos estados en revisionets.estado:
--   solicitada  → alumno solicitó revisión
--   asignada    → jefe de academia asignó fecha, hora y lugar
--   calificada  → jefe calificó la revisión
--
-- ============================================================

CREATE TABLE IF NOT EXISTS revisionets (
  id_revision    TEXT PRIMARY KEY,
  id_inscripcion TEXT UNIQUE
    REFERENCES inscripcionets(id_inscripcionets) ON DELETE CASCADE,
  estado         TEXT NOT NULL DEFAULT 'solicitada',
  fecha_solicitud DATE NOT NULL,
  fecha_revision TIMESTAMPTZ,
  lugar          TEXT,
  calificacion   NUMERIC
);

-- Habilitar RLS
ALTER TABLE revisionets ENABLE ROW LEVEL SECURITY;

-- Alumno: puede insertar (solicitar) revisión para sus propias inscripciones
DROP POLICY IF EXISTS "revision_insert_own" ON revisionets;
CREATE POLICY "revision_insert_own" ON revisionets
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM inscripcionets i
      WHERE i.id_inscripcionets = revisionets.id_inscripcion
        AND i.id_alumno = auth.uid()
    )
  );

-- Cualquier usuario autenticado (alumno/jefe/admin) puede leer revisiones
DROP POLICY IF EXISTS "revision_select_auth" ON revisionets;
CREATE POLICY "revision_select_auth" ON revisionets
  FOR SELECT USING (auth.role() = 'authenticated');

-- Cualquier usuario autenticado (jefe/admin) puede actualizar revisiones
DROP POLICY IF EXISTS "revision_update_auth" ON revisionets;
CREATE POLICY "revision_update_auth" ON revisionets
  FOR UPDATE USING (auth.role() = 'authenticated');
