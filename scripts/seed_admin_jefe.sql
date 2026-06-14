-- ============================================================
-- Usuarios de prueba — Admin y Jefe de Academia
-- ============================================================
-- Contraseña para todos: Password123
--
-- Cuentas generadas:
--   ADMIN → admin@ipn.mx
--   JEFE  → rgodinezr@ipn.mx  (Rodrigo Roman Godinez — ISC sem6)
--
-- Notas:
--   • Admin solo necesita auth.users con @ipn.mx.
--     El sistema lo detecta como admin cuando NO encuentra registro en jefeacademia.
--   • Jefe necesita auth.users + usuario + jefeacademia,
--     donde id_jefeacademia = id_usuario = auth.users.id (mismo UUID).
-- ============================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
DECLARE
  uid_admin UUID := gen_random_uuid();
  uid_jefe  UUID := gen_random_uuid();
BEGIN

  -- ── 1. Auth users ─────────────────────────────────────────────────────────
  INSERT INTO auth.users (
    id, instance_id, email, encrypted_password,
    email_confirmed_at, aud, role,
    raw_app_meta_data, raw_user_meta_data,
    created_at, updated_at, is_super_admin,
    confirmation_token, email_change, email_change_token_new, recovery_token
  ) VALUES
    (
      uid_admin,
      '00000000-0000-0000-0000-000000000000',
      'admin@ipn.mx',
      crypt('Password123', gen_salt('bf')),
      NOW(), 'authenticated', 'authenticated',
      '{"provider":"email","providers":["email"]}', '{}',
      NOW(), NOW(), false, '', '', '', ''
    ),
    (
      uid_jefe,
      '00000000-0000-0000-0000-000000000000',
      'rgodinezr@ipn.mx',
      crypt('Password123', gen_salt('bf')),
      NOW(), 'authenticated', 'authenticated',
      '{"provider":"email","providers":["email"]}', '{}',
      NOW(), NOW(), false, '', '', '', ''
    );

  -- ── 2. usuario (solo el jefe necesita perfil en la tabla usuario) ─────────
  INSERT INTO public.usuario (id_usuario, correo, nombre, apellidopaterno, apellidomaterno, activo)
  VALUES (uid_jefe, 'rgodinezr@ipn.mx', 'Rodrigo Francisco', 'Roman', 'Godinez', true);

  -- ── 3. jefeacademia (id_jefeacademia debe coincidir con auth.users.id) ────
  INSERT INTO public.jefeacademia (id_jefeacademia, id_usuario)
  VALUES (uid_jefe, uid_jefe);

END $$;

-- ============================================================
-- RLS adicional para Jefe y Admin
-- ============================================================

-- Jefe: leer alumno e inscripciones de sus exámenes
DROP POLICY IF EXISTS "jefe_read_alumno"        ON alumno;
DROP POLICY IF EXISTS "jefe_read_inscripciones" ON inscripcionets;
DROP POLICY IF EXISTS "jefe_update_inscripciones" ON inscripcionets;
DROP POLICY IF EXISTS "admin_all_ets"            ON ets;
DROP POLICY IF EXISTS "admin_all_salon"          ON salon;
DROP POLICY IF EXISTS "admin_all_edificio"       ON edificio;
DROP POLICY IF EXISTS "admin_all_carrera"        ON carrera;
DROP POLICY IF EXISTS "admin_all_carrera_materia" ON carrera_materia;
DROP POLICY IF EXISTS "admin_all_materia"        ON materia;
DROP POLICY IF EXISTS "admin_all_jefeacademia"   ON jefeacademia;
DROP POLICY IF EXISTS "admin_all_usuario"        ON usuario;

CREATE POLICY "jefe_read_alumno" ON alumno
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "jefe_read_inscripciones" ON inscripcionets
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "jefe_update_inscripciones" ON inscripcionets
  FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "admin_all_ets" ON ets
  FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "admin_all_salon" ON salon
  FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "admin_all_edificio" ON edificio
  FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "admin_all_carrera" ON carrera
  FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "admin_all_carrera_materia" ON carrera_materia
  FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "admin_all_materia" ON materia
  FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "admin_all_jefeacademia" ON jefeacademia
  FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "admin_all_usuario" ON usuario
  FOR ALL USING (auth.role() = 'authenticated');
