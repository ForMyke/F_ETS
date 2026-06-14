-- ============================================================
-- Usuarios de prueba — un alumno por carrera
-- ============================================================
-- Contraseña para todos: Password123
--
-- Cuentas generadas:
--   ISC → jgarciar2021@alumno.ipn.mx   boleta: 2021630001
--   LCD → mlopezh2021@alumno.ipn.mx    boleta: 2021580001
--   IIA → crodriguezm2021@alumno.ipn.mx boleta: 2021760001
-- ============================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
DECLARE
  uid_isc UUID := gen_random_uuid();
  uid_lcd UUID := gen_random_uuid();
  uid_iia UUID := gen_random_uuid();
BEGIN

  -- ── 1. Auth users (login con Supabase Auth) ──────────────────────────────
  INSERT INTO auth.users (
    id, instance_id, email, encrypted_password,
    email_confirmed_at, aud, role,
    raw_app_meta_data, raw_user_meta_data,
    created_at, updated_at, is_super_admin,
    confirmation_token, email_change, email_change_token_new, recovery_token
  ) VALUES
    (
      uid_isc,
      '00000000-0000-0000-0000-000000000000',
      'jgarciar2021@alumno.ipn.mx',
      crypt('Password123', gen_salt('bf')),
      NOW(), 'authenticated', 'authenticated',
      '{"provider":"email","providers":["email"]}', '{}',
      NOW(), NOW(), false, '', '', '', ''
    ),
    (
      uid_lcd,
      '00000000-0000-0000-0000-000000000000',
      'mlopezh2021@alumno.ipn.mx',
      crypt('Password123', gen_salt('bf')),
      NOW(), 'authenticated', 'authenticated',
      '{"provider":"email","providers":["email"]}', '{}',
      NOW(), NOW(), false, '', '', '', ''
    ),
    (
      uid_iia,
      '00000000-0000-0000-0000-000000000000',
      'crodriguezm2021@alumno.ipn.mx',
      crypt('Password123', gen_salt('bf')),
      NOW(), 'authenticated', 'authenticated',
      '{"provider":"email","providers":["email"]}', '{}',
      NOW(), NOW(), false, '', '', '', ''
    );

  -- ── 2. Tabla usuario (perfil público) ────────────────────────────────────
  INSERT INTO public.usuario (id_usuario, correo, nombre, apellidopaterno, apellidomaterno, activo)
  VALUES
    (uid_isc, 'jgarciar2021@alumno.ipn.mx', 'Juan',   'Garcia',    'Ramirez',   true),
    (uid_lcd, 'mlopezh2021@alumno.ipn.mx',  'Maria',  'Lopez',     'Hernandez', true),
    (uid_iia, 'crodriguezm2021@alumno.ipn.mx', 'Carlos', 'Rodriguez', 'Mendoza', true);

  -- ── 3. Tabla alumno (vincula con carrera y plan — IDs obtenidos dinámicamente) ──
  INSERT INTO public.alumno (id_alumno, boleta, id_carrera, id_plan, id_usuario)
  VALUES
    (uid_isc, '2021630001',
     (SELECT id_carrera FROM public.carrera WHERE acronimo = 'ISC' LIMIT 1),
     (SELECT DISTINCT id_plan FROM public.carrera_materia WHERE id_carrera = (SELECT id_carrera FROM public.carrera WHERE acronimo = 'ISC' LIMIT 1) LIMIT 1),
     uid_isc),
    (uid_lcd, '2021580001',
     (SELECT id_carrera FROM public.carrera WHERE acronimo = 'LCD' LIMIT 1),
     (SELECT DISTINCT id_plan FROM public.carrera_materia WHERE id_carrera = (SELECT id_carrera FROM public.carrera WHERE acronimo = 'LCD' LIMIT 1) LIMIT 1),
     uid_lcd),
    (uid_iia, '2021760001',
     (SELECT id_carrera FROM public.carrera WHERE acronimo = 'IIA' LIMIT 1),
     (SELECT DISTINCT id_plan FROM public.carrera_materia WHERE id_carrera = (SELECT id_carrera FROM public.carrera WHERE acronimo = 'IIA' LIMIT 1) LIMIT 1),
     uid_iia);

END $$;
