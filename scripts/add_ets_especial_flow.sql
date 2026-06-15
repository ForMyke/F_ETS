-- ============================================================
-- Flujo de ETS Especial
-- Ejecutar en Supabase SQL Editor DESPUÉS de add_revision_flow.sql
-- ============================================================
--
-- Estados en etsespecial.estado:
--   pendiente       → alumno solicitó ETS especial, espera confirmación admin
--   confirmada      → admin confirmó (inscripción oficial)
--   rechazada       → admin rechazó
--   baja_solicitada → alumno solicitó baja
--   baja_aprobada   → admin aprobó la baja
--   calificado      → jefe de academia registró calificación
--
-- Estados en revisionetsespecial.estado:
--   solicitada  → alumno solicitó revisión del ETS especial
--   asignada    → jefe asignó fecha y lugar
--   calificada  → jefe calificó la revisión
--
-- ============================================================

CREATE TABLE IF NOT EXISTS etsespecial (
  id_ets_especial    TEXT PRIMARY KEY,
  id_inscripcion_orig TEXT UNIQUE
    REFERENCES inscripcionets(id_inscripcionets) ON DELETE CASCADE,
  estado             TEXT NOT NULL DEFAULT 'pendiente',
  fecha_solicitud    DATE NOT NULL,
  calificacion       NUMERIC,
  resultado          TEXT
);

ALTER TABLE etsespecial ENABLE ROW LEVEL SECURITY;

-- Alumno: insertar ETS especial para sus propias inscripciones
DROP POLICY IF EXISTS "etsesp_insert_own" ON etsespecial;
CREATE POLICY "etsesp_insert_own" ON etsespecial
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM inscripcionets i
      WHERE i.id_inscripcionets = etsespecial.id_inscripcion_orig
        AND i.id_alumno = auth.uid()
    )
  );

-- Cualquier autenticado: leer
DROP POLICY IF EXISTS "etsesp_select_auth" ON etsespecial;
CREATE POLICY "etsesp_select_auth" ON etsespecial
  FOR SELECT USING (auth.role() = 'authenticated');

-- Cualquier autenticado (alumno baja / admin confirma / jefe califica): actualizar
DROP POLICY IF EXISTS "etsesp_update_auth" ON etsespecial;
CREATE POLICY "etsesp_update_auth" ON etsespecial
  FOR UPDATE USING (auth.role() = 'authenticated');

-- ─── Revisiones del ETS Especial ─────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS revisionetsespecial (
  id_revision_esp  TEXT PRIMARY KEY,
  id_ets_especial  TEXT UNIQUE
    REFERENCES etsespecial(id_ets_especial) ON DELETE CASCADE,
  estado           TEXT NOT NULL DEFAULT 'solicitada',
  fecha_solicitud  DATE NOT NULL,
  fecha_revision   TIMESTAMPTZ,
  lugar            TEXT,
  calificacion     NUMERIC
);

ALTER TABLE revisionetsespecial ENABLE ROW LEVEL SECURITY;

-- Alumno: insertar revisión para su propio ETS especial
DROP POLICY IF EXISTS "revisionetsesp_insert_own" ON revisionetsespecial;
CREATE POLICY "revisionetsesp_insert_own" ON revisionetsespecial
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM etsespecial e
      JOIN inscripcionets i ON i.id_inscripcionets = e.id_inscripcion_orig
      WHERE e.id_ets_especial = revisionetsespecial.id_ets_especial
        AND i.id_alumno = auth.uid()
    )
  );

-- Cualquier autenticado: leer y actualizar
DROP POLICY IF EXISTS "revisionetsesp_select_auth" ON revisionetsespecial;
CREATE POLICY "revisionetsesp_select_auth" ON revisionetsespecial
  FOR SELECT USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "revisionetsesp_update_auth" ON revisionetsespecial;
CREATE POLICY "revisionetsesp_update_auth" ON revisionetsespecial
  FOR UPDATE USING (auth.role() = 'authenticated');
