-- ============================================================
-- Academias por área temática + Jefes de Academia con login
-- ============================================================
-- Ejecutar en Supabase SQL Editor ANTES de seed_ets_isc_iia.sql
--
-- Cuentas jefe (todas con contraseña: Password123)
--   jefe.matematicas@ipn.mx   → Matemáticas y Física
--   jefe.circuitos@ipn.mx     → Circuitos, Electrónica y Hardware
--   jefe.programacion@ipn.mx  → Programación y Software
--   jefe.sociales@ipn.mx      → Ciencias Sociales y Gestión
--   jefe.sistemas@ipn.mx      → Sistemas, Redes y Seguridad
--   jefe.ia@ipn.mx            → Inteligencia Artificial y Datos
-- ============================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ── 1. Agregar columna id_jefeacademia a academia ──────────────────────────
ALTER TABLE academia ADD COLUMN IF NOT EXISTS
  id_jefeacademia UUID REFERENCES jefeacademia(id_jefeacademia) ON DELETE SET NULL;

-- ── 2. Insertar nuevas academias por área temática ─────────────────────────
-- UUIDs fijos: a1a1... MAT, a2a2... CIRC, a3a3... PROG,
--              a4a4... SOC, a5a5... SIST, a6a6... IA
INSERT INTO academia (id_academia, nombre, acronimo, id_carrera) VALUES
  ('a1a10000-0000-0000-0000-000000000000', 'Academia de Matemáticas y Física',            'MAT',  NULL),
  ('a2a20000-0000-0000-0000-000000000000', 'Academia de Circuitos, Electrónica y Hardware','CIRC', NULL),
  ('a3a30000-0000-0000-0000-000000000000', 'Academia de Programación y Software',          'PROG', NULL),
  ('a4a40000-0000-0000-0000-000000000000', 'Academia de Ciencias Sociales y Gestión',      'SOC',  NULL),
  ('a5a50000-0000-0000-0000-000000000000', 'Academia de Sistemas, Redes y Seguridad',      'SIST', NULL),
  ('a6a60000-0000-0000-0000-000000000000', 'Academia de Inteligencia Artificial y Datos',  'IA',   NULL)
ON CONFLICT (id_academia) DO NOTHING;

-- ── 3. Reasignar carrera_materia a las nuevas academias ────────────────────

-- PROG: Programación y Software
UPDATE carrera_materia SET id_academia = 'a3a30000-0000-0000-0000-000000000000'
WHERE id_materia IN (
  '63a7672a-3f75-4c99-a9e0-275dd518fedd', -- FUNDAMENTOS DE PROGRAMACION
  'b1a915c3-f695-491e-a058-e2f61deeb9af', -- ALGORITMOS Y ESTRUCTURA DE DATOS
  '9c276f66-acaf-43b5-9e17-c1b4a29577c1', -- ALGORITMOS Y ESTRUCTURAS DE DATOS
  '9d18eac7-f105-4242-b447-641676257309', -- ANALISIS Y DISEÑO DE ALGORITMOS
  'abacbaac-d20b-488c-af7e-4917b6c36156', -- PARADIGMAS DE PROGRAMACION
  'b60f7cb8-f731-4ac1-9921-58f56940b6e5', -- COMPILADORES
  '9446f491-7714-4483-91dc-8124b6a53bd7', -- TEORIA DE LA COMPUTACION
  'f3222d4a-6b77-4e7a-be81-0ef9f667b568', -- DESARROLLO DE APLICACIONES MOVILES NATIVAS
  'e9b14350-becf-46c9-a52d-da92d60cd8cd', -- DESARROLLO DE APLICACIONES WEB
  '224fe7ac-77c0-43c9-93f0-7a9aee46f41d', -- TECNOLOGIAS PARA DESARROLLO DE APLICACIONES WEB
  'e282448d-098f-457e-aeca-b6716e11b27c', -- TECNOLOGIAS PARA EL DESARROLLO DE APLICACIONES WEB
  'd7c26bd9-c3e9-4d07-ad9c-5c086c3364ae', -- PROGRAMACION PARA CIENCIA DE DATOS
  '8dcd971a-090d-45db-a967-778337438d2a'  -- DESARROLLO DE APLICACIONES PARA ANALISIS DE DATOS
);

-- MAT: Matemáticas y Física
UPDATE carrera_materia SET id_academia = 'a1a10000-0000-0000-0000-000000000000'
WHERE id_materia IN (
  'ca99d938-cb63-427f-b14e-c95308b6a231', -- CALCULO
  'd990ddc7-dc32-438f-8288-ff0cfb5353ef', -- CALCULO APLICADO
  '9dbbd00d-849b-4b7f-a62f-4a473212a2ad', -- CALCULO MULTIVARIABLE
  'a0a6830b-0e29-41b9-9ecc-5520b494aa52', -- ALGEBRA LINEAL
  '110c0683-d4db-4fa9-b000-beda2c5b2466', -- ANALISIS VECTORIAL
  'b47ae6ff-1bab-42fd-9aff-74b76cc13be9', -- MATEMATICAS DISCRETAS
  '6f876ea8-bfc7-4e05-aee2-e3123655714c', -- ECUACIONES DIFERENCIALES
  'a28a3f6c-7bfe-4923-89ec-68e5244a9ebd', -- MATEMATICAS AVANZADAS PARA LA INGENIERIA
  '11f81451-bc9f-4a37-a1a5-5e1b0a04150a', -- MATEMATICAS AVANZADAS PARA CIENCIA DE DATOS
  'aa97db28-d273-43fc-a0d1-8ef083effbd4', -- PROBABILIDAD
  'c65e3366-2f48-458b-b066-2b24cc29b438', -- PROBABILIDAD Y ESTADISTICA
  'adc8077a-0a48-4990-a353-cabe94498885', -- ESTADISTICA
  '03e06535-ad90-4d85-a0ed-a7c1e7d42d75', -- METODOS NUMERICOS
  '7012cc5a-bf64-4d16-9adc-77155ce32bd8', -- PROCESOS ESTOCASTICOS
  '431f9930-eabd-49e4-a706-f472db354c4f', -- METODOS CUANTITATIVOS PARA LA TOMA DE DECISIONES
  '10635efd-d535-4055-806d-c699e4ba89d3', -- ANALISIS DE SERIES DE TIEMPO
  '2a8f3ba6-fdd4-496c-ab14-79f9475e4df1', -- MODELOS ECONOMETRICOS
  '0a8976ef-9530-432a-9b1f-002b8415bd11'  -- MECANICA Y ELECTROMAGNETISMO
);

-- CIRC: Circuitos, Electrónica y Hardware
UPDATE carrera_materia SET id_academia = 'a2a20000-0000-0000-0000-000000000000'
WHERE id_materia IN (
  '36d882d6-666d-4c83-93c8-b771ca297183', -- CIRCUITOS ELECTRICOS
  'c5597bef-e186-429d-a7c6-5c38ade8abe9', -- ELECTRONICA ANALOGICA
  '23e9a797-75eb-412c-b591-5b7a0c804d04', -- INSTRUMENTACION Y CONTROL
  'e768da13-6a00-41e6-8545-1619cf035014', -- DISEÑO DE SISTEMAS DIGITALES
  '72bb412f-a16a-4b08-a11f-4540a9efafef', -- FUNDAMENTOS DE DISEÑO DIGITAL
  '4985f538-e79c-493e-bb87-ed9cc810c66b', -- ARQUITECTURA DE COMPUTADORAS
  '6f4e4fa2-fd84-4cfb-a144-b57b94ed0df5', -- PROCESAMIENTO DE SEÑALES
  'e483ab12-3875-4cb8-96e9-6a79fa9818b8', -- PROCESAMIENTO DIGITAL DE SEÑALES
  'da5cae27-1ff2-4bf0-b2db-92c3cd412900', -- SISTEMAS EN CHIP
  '3a370009-c811-4e85-87b6-73a6dc5b46bb', -- COMPUTO DE ALTO DESEMPEÑO
  '9e5fbaa3-6f73-4e05-84bc-3c2b3a0fcb3d'  -- COMPUTO PARALELO
);

-- SOC: Ciencias Sociales y Gestión
UPDATE carrera_materia SET id_academia = 'a4a40000-0000-0000-0000-000000000000'
WHERE id_materia IN (
  'b65ed67e-6dbb-4cf2-9da2-fdc0ccacdbaa', -- COMUNICACION ORAL Y ESCRITA
  '4b217bf0-f8b7-4342-9658-b632da101773', -- ETICA Y LEGALIDAD
  '15725480-020e-41fc-889c-e29ce8bec25a', -- INGENIERIA ETICA Y SOCIEDAD
  'e475a28e-6563-4555-8738-f9153d70517e', -- LIDERAZGO PERSONAL
  '93d1a541-d5b7-49e0-b6d5-7f50c4547e7c', -- DESARROLLO DE HABILIDADES SOCIALES PARA LA ALTA DIRECCION
  '6f2f6fe9-895f-4c6d-81b8-cc7232941dd5', -- METODOLOGIA DE LA INVESTIGACION Y DIVULGACION CIENTIFICA
  'c48e0adb-49ee-4f35-9320-8e7a1808d7fc', -- FUNDAMENTOS ECONOMICOS
  '4bfb3521-cef9-4694-b7e5-79072bdf2744', -- GESTION EMPRESARIAL
  '7f32b30f-5ddf-41ce-9c4c-afb5ab5512dc', -- GESTION DE EMPRESAS DE ALTA TECNOLOGIA
  'b6214d27-776b-4576-8395-dab87fe2320c', -- FINANZAS EMPRESARIALES
  '0182819d-8e45-4c50-824b-157fe42b86f2', -- FORMULACION Y EVALUACION DE PROYECTOS INFORMATICOS
  '297f44f2-97c4-4425-be34-8034e0c7a32a'  -- ADMINISTRACION DE PROYECTOS DE TI
);

-- SIST: Sistemas, Redes y Seguridad
UPDATE carrera_materia SET id_academia = 'a5a50000-0000-0000-0000-000000000000'
WHERE id_materia IN (
  'ad9d854a-3eed-42ad-81ab-b49fc8407a26', -- REDES DE COMPUTADORAS
  '10dff321-ce91-483e-887d-cb0d6cc3b251', -- ADMINISTRACION DE SERVICIOS EN RED
  'f2b92fd4-013a-496b-94c5-9543459c8346', -- APLICACIONES PARA COMUNICACIONES EN RED
  'a86949f7-9447-4f87-8538-1f8bbb58f4eb', -- SISTEMAS DISTRIBUIDOS
  '2cf01a08-df93-4faf-b599-c1c3c204db5f', -- SISTEMAS OPERATIVOS
  '8bffb96c-0ba1-4711-995f-95b21f64b040', -- CIBERSEGURIDAD
  '8e80e9c8-c6bf-4c5a-896d-9059ce31e9a0', -- CRIPTOGRAFIA
  '681b0229-3c75-4560-885a-31179a7814d3', -- CRIPTOGRAFIA: TEMAS SELECTOS
  '382afd3f-cfcc-4a69-bee5-a0d4e4ae90fa', -- PROTECCION DE DATOS
  'd4be0421-c935-4629-860c-468c52ffec48', -- INTERNET DE LAS COSAS
  'c5f52288-678e-4645-a614-87099e716aa0', -- BASES DE DATOS
  'c84b8fa1-454b-4729-8473-d17a1d06f96f', -- BASES DE DATOS AVANZADAS
  'fe01e022-e695-46a8-95fe-1786bb11b323', -- INGENIERIA DE SOFTWARE
  'e2169593-9d8c-480c-a718-975c84db1a3b', -- INGENIERIA DE SOFTWARE PARA SISTEMAS INTELIGENTES
  'aaa19d7e-0bd5-47ef-9929-6dce1e71daca'  -- ANALISIS Y DISEÑO DE SISTEMAS
);

-- IA: Inteligencia Artificial y Datos
UPDATE carrera_materia SET id_academia = 'a6a60000-0000-0000-0000-000000000000'
WHERE id_materia IN (
  '04fc8054-43f7-4529-8a04-cceea7343870', -- INTELIGENCIA ARTIFICIAL
  '1fc3f912-ab2f-4c98-a681-4724b0f924b2', -- FUNDAMENTOS DE INTELIGENCIA ARTIFICIAL
  '8fbe9f00-5baf-480a-a0b4-710fb986da40', -- APRENDIZAJE DE MAQUINA
  '11f76746-5267-4084-9631-cbec55188dd9', -- APRENDIZAJE DE MAQUINA E INTELIGENCIA ARTIFICIAL
  'db07d6b1-5d5f-44b1-9f6c-1e84e8d1b73a', -- REDES NEURONALES Y APRENDIZAJE PROFUNDO
  '93a44b74-3612-47ed-b4b4-e71c2c5a6bc2', -- ALGORITMOS BIOINSPIRADOS
  '87084d29-131e-4a80-b746-3b6d0848c9ac', -- VISION ARTIFICIAL
  '906ebaa1-2e6e-4bfe-b2e7-70b8eba020c2', -- PROCESAMIENTO DE LENGUAJE NATURAL
  '932b67cd-ec37-4f77-9b91-637f06955d60', -- APLICACIONES DE LENGUAJE NATURAL
  'dd2c507d-4e2e-48d4-8c75-e80d60af77ac', -- TECNOLOGIAS DE LENGUAJE NATURAL
  'c46d07cd-0442-46d9-9c9f-cc6550c579fa', -- PROCESAMIENTO DIGITAL DE IMAGENES
  '01116eab-37bb-43b5-9096-8241f5b2c0e8', -- ANALITICA AVANZADA DE DATOS
  'd830f074-05f0-43c9-9535-2d9d2ca0d5be', -- ANALITICA Y VISUALIZACION DE DATOS
  '266dffe9-9962-4f40-82d7-6ad8d1263a6d', -- MINERIA DE DATOS
  '03a7f71a-2778-4cc4-8ccc-017556d2c1e0', -- BIG DATA
  '49227e48-908d-4c4a-b94d-8e22ede2eb52', -- MODELADO PREDICTIVO
  'f6e7b321-12cc-4bf0-8966-b1d30f99e8ee', -- APLICACIONES DE INTELIGENCIA ARTIFICIAL EN SISTEMAS EMBEBIDOS
  'b0df1fdf-d462-42b5-810c-393549688be7', -- TEMAS SELECTOS DE APRENDIZAJE PROFUNDO
  '5354782b-4d01-4aa8-9dae-f226f48118e5'  -- SISTEMAS DE INFORMACION GEOGRAFICA
);

-- ── 4. Eliminar academias genéricas (ya sin FK dependientes) ───────────────
DELETE FROM academia WHERE id_academia IN (
  '33a589be-7503-46c4-bc1b-5f0b761d867b',
  '93e61441-e952-4757-99cc-74fa72a54e47',
  '9efe7c52-4e28-4466-b0aa-35ebcd37cc55'
);

-- ── 5. Crear auth.users para los 6 jefes ───────────────────────────────────
-- UUID jefe = auth.users.id = jefeacademia.id_jefeacademia
-- b1b1... MAT, b2b2... CIRC, b3b3... PROG,
-- b4b4... SOC, b5b5... SIST, b6b6... IA

INSERT INTO auth.users (
  id, instance_id, email, encrypted_password,
  email_confirmed_at, aud, role,
  raw_app_meta_data, raw_user_meta_data,
  created_at, updated_at, is_super_admin,
  confirmation_token, email_change, email_change_token_new, recovery_token
) VALUES
  ('b1b10000-0000-0000-0000-000000000000','00000000-0000-0000-0000-000000000000',
   'jefe.matematicas@ipn.mx', crypt('Password123', gen_salt('bf')),
   NOW(),'authenticated','authenticated',
   '{"provider":"email","providers":["email"]}','{}',
   NOW(),NOW(),false,'','','',''),
  ('b2b20000-0000-0000-0000-000000000000','00000000-0000-0000-0000-000000000000',
   'jefe.circuitos@ipn.mx', crypt('Password123', gen_salt('bf')),
   NOW(),'authenticated','authenticated',
   '{"provider":"email","providers":["email"]}','{}',
   NOW(),NOW(),false,'','','',''),
  ('b3b30000-0000-0000-0000-000000000000','00000000-0000-0000-0000-000000000000',
   'jefe.programacion@ipn.mx', crypt('Password123', gen_salt('bf')),
   NOW(),'authenticated','authenticated',
   '{"provider":"email","providers":["email"]}','{}',
   NOW(),NOW(),false,'','','',''),
  ('b4b40000-0000-0000-0000-000000000000','00000000-0000-0000-0000-000000000000',
   'jefe.sociales@ipn.mx', crypt('Password123', gen_salt('bf')),
   NOW(),'authenticated','authenticated',
   '{"provider":"email","providers":["email"]}','{}',
   NOW(),NOW(),false,'','','',''),
  ('b5b50000-0000-0000-0000-000000000000','00000000-0000-0000-0000-000000000000',
   'jefe.sistemas@ipn.mx', crypt('Password123', gen_salt('bf')),
   NOW(),'authenticated','authenticated',
   '{"provider":"email","providers":["email"]}','{}',
   NOW(),NOW(),false,'','','',''),
  ('b6b60000-0000-0000-0000-000000000000','00000000-0000-0000-0000-000000000000',
   'jefe.ia@ipn.mx', crypt('Password123', gen_salt('bf')),
   NOW(),'authenticated','authenticated',
   '{"provider":"email","providers":["email"]}','{}',
   NOW(),NOW(),false,'','','','')
ON CONFLICT (id) DO NOTHING;

-- ── 6. Crear registros en usuario para los jefes ──────────────────────────
INSERT INTO public.usuario (id_usuario, correo, nombre, apellidopaterno, apellidomaterno, activo)
VALUES
  ('b1b10000-0000-0000-0000-000000000000','jefe.matematicas@ipn.mx','FLORENCIO','GUZMAN','AGUILAR',true),
  ('b2b20000-0000-0000-0000-000000000000','jefe.circuitos@ipn.mx','ALBERTO JESUS','ALCANTARA','MENDEZ',true),
  ('b3b30000-0000-0000-0000-000000000000','jefe.programacion@ipn.mx','ROCIO','RESENDIZ','MUÑOZ',true),
  ('b4b40000-0000-0000-0000-000000000000','jefe.sociales@ipn.mx','ADRIANA DE LA P','SANCHEZ','MORENO',true),
  ('b5b50000-0000-0000-0000-000000000000','jefe.sistemas@ipn.mx','JUAN JESUS','ALCARAZ','TORRES',true),
  ('b6b60000-0000-0000-0000-000000000000','jefe.ia@ipn.mx','RODRIGO FRANCISCO','ROMAN','GODINEZ',true)
ON CONFLICT (id_usuario) DO NOTHING;

-- ── 7. Crear jefeacademia (id_jefeacademia = auth.users.id) ───────────────
INSERT INTO public.jefeacademia (id_jefeacademia, id_usuario)
VALUES
  ('b1b10000-0000-0000-0000-000000000000','b1b10000-0000-0000-0000-000000000000'),
  ('b2b20000-0000-0000-0000-000000000000','b2b20000-0000-0000-0000-000000000000'),
  ('b3b30000-0000-0000-0000-000000000000','b3b30000-0000-0000-0000-000000000000'),
  ('b4b40000-0000-0000-0000-000000000000','b4b40000-0000-0000-0000-000000000000'),
  ('b5b50000-0000-0000-0000-000000000000','b5b50000-0000-0000-0000-000000000000'),
  ('b6b60000-0000-0000-0000-000000000000','b6b60000-0000-0000-0000-000000000000')
ON CONFLICT (id_jefeacademia) DO NOTHING;

-- ── 8. Vincular cada academia con su jefe ─────────────────────────────────
UPDATE academia SET id_jefeacademia = 'b1b10000-0000-0000-0000-000000000000'
  WHERE id_academia = 'a1a10000-0000-0000-0000-000000000000'; -- MAT

UPDATE academia SET id_jefeacademia = 'b2b20000-0000-0000-0000-000000000000'
  WHERE id_academia = 'a2a20000-0000-0000-0000-000000000000'; -- CIRC

UPDATE academia SET id_jefeacademia = 'b3b30000-0000-0000-0000-000000000000'
  WHERE id_academia = 'a3a30000-0000-0000-0000-000000000000'; -- PROG

UPDATE academia SET id_jefeacademia = 'b4b40000-0000-0000-0000-000000000000'
  WHERE id_academia = 'a4a40000-0000-0000-0000-000000000000'; -- SOC

UPDATE academia SET id_jefeacademia = 'b5b50000-0000-0000-0000-000000000000'
  WHERE id_academia = 'a5a50000-0000-0000-0000-000000000000'; -- SIST

UPDATE academia SET id_jefeacademia = 'b6b60000-0000-0000-0000-000000000000'
  WHERE id_academia = 'a6a60000-0000-0000-0000-000000000000'; -- IA

-- ── Verificación ───────────────────────────────────────────────────────────
SELECT a.nombre AS academia, u.nombre || ' ' || u.apellidopaterno AS jefe
FROM academia a
JOIN jefeacademia j ON j.id_jefeacademia = a.id_jefeacademia
JOIN usuario u ON u.id_usuario = j.id_usuario
ORDER BY a.nombre;
