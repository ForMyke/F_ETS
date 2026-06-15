-- ============================================================
-- Flujo de confirmación de inscripciones
-- Ejecutar en Supabase SQL Editor
-- ============================================================
--
-- Nuevos estados en inscripcionets.estado:
--   pendiente        → alumno se inscribió, espera confirmación admin
--   confirmada       → admin confirmó la inscripción (oficial)
--   rechazada        → admin rechazó la inscripción
--   baja_solicitada  → alumno solicitó darse de baja
--   baja_aprobada    → admin aprobó la baja
--   aprobado         → alumno aprobó el ETS (post-examen)
--   reprobado        → alumno reprobó el ETS (post-examen)
--   calificado       → calificación registrada
--
-- No se requiere cambio de esquema (estado es TEXT sin CHECK constraint).
--
-- Si aún no aplicaste seed_admin_jefe.sql, ejecuta primero ese script
-- para que las políticas RLS de update en inscripcionets existan.
-- ============================================================

-- Política que permite al alumno actualizar su propia inscripción
-- (necesaria para solicitar baja desde la app)
DROP POLICY IF EXISTS "inscripcion_update_own" ON inscripcionets;

CREATE POLICY "inscripcion_update_own" ON inscripcionets
  FOR UPDATE
  USING (auth.uid() = id_alumno)
  WITH CHECK (auth.uid() = id_alumno);
