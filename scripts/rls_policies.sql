-- ============================================================
-- RLS Policies para ESCOM ETS
-- Ejecutar en Supabase SQL Editor después de migration.sql
-- ============================================================

-- Tablas de catálogo: lectura pública (anon puede leer)
ALTER TABLE edificio       ENABLE ROW LEVEL SECURITY;
ALTER TABLE salon          ENABLE ROW LEVEL SECURITY;
ALTER TABLE carrera        ENABLE ROW LEVEL SECURITY;
ALTER TABLE planestudios   ENABLE ROW LEVEL SECURITY;
ALTER TABLE academia       ENABLE ROW LEVEL SECURITY;
ALTER TABLE materia        ENABLE ROW LEVEL SECURITY;
ALTER TABLE carrera_materia ENABLE ROW LEVEL SECURITY;
ALTER TABLE periodoets     ENABLE ROW LEVEL SECURITY;
ALTER TABLE ets            ENABLE ROW LEVEL SECURITY;
ALTER TABLE usuario        ENABLE ROW LEVEL SECURITY;
ALTER TABLE jefeacademia   ENABLE ROW LEVEL SECURITY;
ALTER TABLE alumno         ENABLE ROW LEVEL SECURITY;
ALTER TABLE inscripcionets ENABLE ROW LEVEL SECURITY;

-- ── Lectura pública (catálogos y exámenes) ─────────────────
CREATE POLICY "public_read" ON edificio        FOR SELECT USING (true);
CREATE POLICY "public_read" ON salon           FOR SELECT USING (true);
CREATE POLICY "public_read" ON carrera         FOR SELECT USING (true);
CREATE POLICY "public_read" ON planestudios    FOR SELECT USING (true);
CREATE POLICY "public_read" ON academia        FOR SELECT USING (true);
CREATE POLICY "public_read" ON materia         FOR SELECT USING (true);
CREATE POLICY "public_read" ON carrera_materia FOR SELECT USING (true);
CREATE POLICY "public_read" ON periodoets      FOR SELECT USING (true);
CREATE POLICY "public_read" ON ets             FOR SELECT USING (true);
CREATE POLICY "public_read" ON usuario         FOR SELECT USING (true);
CREATE POLICY "public_read" ON jefeacademia    FOR SELECT USING (true);

-- ── Alumno: solo puede ver su propio perfil ────────────────
CREATE POLICY "alumno_read_own" ON alumno
  FOR SELECT USING (auth.uid() = id_alumno);

CREATE POLICY "alumno_insert_own" ON alumno
  FOR INSERT WITH CHECK (auth.uid() = id_alumno);

-- ── Inscripciones: solo las propias ───────────────────────
CREATE POLICY "inscripcion_read_own" ON inscripcionets
  FOR SELECT USING (auth.uid() = id_alumno);

CREATE POLICY "inscripcion_insert_own" ON inscripcionets
  FOR INSERT WITH CHECK (auth.uid() = id_alumno);

-- ── Usuario: inserción al registrarse ─────────────────────
CREATE POLICY "usuario_insert_own" ON usuario
  FOR INSERT WITH CHECK (auth.uid() = id_usuario);
