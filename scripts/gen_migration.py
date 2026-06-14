#!/usr/bin/env python3
"""Generate full SQL migration for ESCOM ETS Supabase account."""

import uuid
import unicodedata
import re

def gen():
    return str(uuid.uuid4())

def esc(s):
    return str(s).replace("'", "''")

def normalize(s):
    """Strip accents and normalize for email/slug."""
    s = unicodedata.normalize('NFD', s)
    return ''.join(c for c in s if unicodedata.category(c) != 'Mn')

def email_from_name(full_name):
    slug = normalize(full_name.lower())
    slug = re.sub(r'[^a-z0-9\s]', '', slug)
    parts = slug.split()
    return (parts[0] + '.' + ''.join(parts[1:]) + '@escom.ipn.mx') if len(parts) >= 2 else (parts[0] + '@escom.ipn.mx')

def split_name(full):
    parts = full.strip().split()
    if len(parts) >= 3:
        return parts[0], parts[1], ' '.join(parts[2:])
    elif len(parts) == 2:
        return parts[0], '', parts[1]
    return parts[0] if parts else '', '', ''

# ── Raw schedule data ─────────────────────────────────────────────────────────
# Format: (materia_nombre, profesor_nombre, edificio_num, salon_num)
# 'X' edificio/salon → placeholder for rooms not yet assigned.
# Excluded subjects must NOT appear here:
#   ESTANCIA PROFESIONAL, TRABAJO TERMINAL I, TRABAJO TERMINAL II

ISC = {
    1: [
        ('FUNDAMENTOS DE PROGRAMACION', 'RESENDIZ MUÑOZ ROCIO', '1', '206'),
        ('MATEMATICAS DISCRETAS', 'HERRERA YAÑEZ CRISPIN', '1', '206'),
        ('CALCULO', 'DORANTES VILLA CLAUDIA JISELA', '1', '206'),
        ('ANALISIS VECTORIAL', 'GUZMAN AGUILAR FLORENCIO', '1', '206'),
        ('COMUNICACION ORAL Y ESCRITA', 'SANCHEZ MORENO ADRIANA DE LA P', '1', '206'),
    ],
    2: [
        ('ALGORITMOS Y ESTRUCTURA DE DATOS', 'TECLA PARRA ROBERTO', '1', '007'),
        ('ALGEBRA LINEAL', 'GUZMAN AGUILAR FLORENCIO', '1', '007'),
        ('CALCULO APLICADO', 'VIVEROS VELA KARINA', '3', '111'),
        ('MECANICA Y ELECTROMAGNETISMO', 'SALINAS HERNANDEZ ENCARNACION', '1', '007'),
        ('INGENIERIA ETICA Y SOCIEDAD', 'ARREDONDO SANCHEZ ANA LAURA', '1', '007'),
        ('FUNDAMENTOS ECONOMICOS', 'CASTILLO MARRUFO JUAN ANTONIO', '1', '007'),
    ],
    3: [
        ('ANALISIS Y DISEÑO DE ALGORITMOS', 'DIAZ SANTIAGO RICARDO FELIPE', '2', '206'),
        ('PARADIGMAS DE PROGRAMACION', 'DAVALOS LOPEZ JOSE CARLOS', '2', '206'),
        ('ECUACIONES DIFERENCIALES', 'SILVA MARTINEZ JORGE JAVIER', '2', '206'),
        ('FUNDAMENTOS DE DISEÑO DIGITAL', 'DIAZ TOALA IVAN', '2', '206'),
        ('CIRCUITOS ELECTRICOS', 'ALCANTARA MENDEZ ALBERTO JESUS', '2', '206'),
        ('BASES DE DATOS', 'CHAVARRIA BAEZ LORENA', '2', '206'),
        ('FINANZAS EMPRESARIALES', 'GALIÑANES RODRIGUEZ MARIA GABRIELA', '2', '206'),
    ],
    4: [
        ('TEORIA DE LA COMPUTACION', 'JUAREZ MARTINEZ GENARO', '2', '003'),
        ('PROBABILIDAD Y ESTADISTICA', 'CHAVEZ LIMA EDUARDO', '2', '203'),
        ('MATEMATICAS AVANZADAS PARA LA INGENIERIA', 'CERVANTES ESPINOSA LUIS MOCTEZUMA', '2', '202'),
        ('DISEÑO DE SISTEMAS DIGITALES', 'TESTA NAVA ALEXIS', '2', '003'),
        ('ELECTRONICA ANALOGICA', 'DURAN CAMARILLO EDMUNDO RENE', '2', '003'),
        ('TECNOLOGIAS PARA DESARROLLO DE APLICACIONES WEB', 'BAUTISTA ROSALES SANDRA IVETTE', '2', '003'),
        ('SISTEMAS OPERATIVOS', 'CORTES GALICIA JORGE', '2', '003'),
    ],
    5: [
        ('COMPILADORES', 'ORTIGOZA CAMPOS ANDRES', '3', '108'),
        ('PROCESAMIENTO DIGITAL DE SEÑALES', 'MUJICA ASCENCIO CESAR', '3', '108'),
        ('ARQUITECTURA DE COMPUTADORAS', 'GOMEZ MAYORGA MARGARITA ELIZABETH', '3', '108'),
        ('INSTRUMENTACION Y CONTROL', 'ORTEGA GONZALEZ RUBEN', '3', '108'),
        ('ANALISIS Y DISEÑO DE SISTEMAS', 'PEREDO VALDERRAMA RUBEN', '3', '108'),
        ('FORMULACION Y EVALUACION DE PROYECTOS INFORMATICOS', 'RODRIGUEZ FLORES EDUARDO', '3', '108'),
        ('REDES DE COMPUTADORAS', 'ALCARAZ TORRES JUAN JESUS', '3', '108'),
    ],
    6: [
        ('INTELIGENCIA ARTIFICIAL', 'ROMAN GODINEZ RODRIGO FRANCISCO', '3', '210'),
        ('SISTEMAS EN CHIP', 'AGUILAR SANCHEZ FERNANDO', '3', '210'),
        ('METODOS CUANTITATIVOS PARA LA TOMA DE DECISIONES', 'MARQUEZ ARREGUIN GUILLERMO', '3', '210'),
        ('CRIPTOGRAFIA', 'CORTEZ DUARTE NIDIA ASUNCION', '3', '010'),
        ('GESTION DE EMPRESAS DE ALTA TECNOLOGIA', 'LOPEZ ROJAS ARIEL', '3', '210'),
        ('INGENIERIA DE SOFTWARE', 'ROJAS MEXICANO ISMAEL', '3', '210'),
        ('APLICACIONES PARA COMUNICACIONES EN RED', 'MORENO CERVANTES AXEL ERNESTO', '3', '210'),
    ],
    7: [
        ('SISTEMAS DISTRIBUIDOS', 'CARRETO ARELLANO CHADWICK', '4', '011'),
        ('INTERNET DE LAS COSAS', 'LERMA MAGANA CARLOS', '4', '011'),
        ('CRIPTOGRAFIA: TEMAS SELECTOS', 'DIAZ SANTIAGO SANDRA', '4', '011'),
        ('DESARROLLO DE APLICACIONES MOVILES NATIVAS', 'RIVERA DE LA ROSA MONICA', '4', '011'),
        ('ADMINISTRACION DE SERVICIOS EN RED', 'MARTINEZ ROSALES RICARDO', '4', '011'),
    ],
    8: [
        ('LIDERAZGO PERSONAL', 'CENTENO ARRAZOLA MARIA SOLEDAD', '4', '209'),
        ('GESTION EMPRESARIAL', 'MALDONADO MUÑOZ MIGUEL ANGEL', '4', '209'),
        ('DESARROLLO DE HABILIDADES SOCIALES PARA LA ALTA DIRECCION', 'DORANTES CORDERO MARTHA MARGARITA', '4', '209'),
    ],
}

LCD = {
    2: [
        ('ALGORITMOS Y ESTRUCTURAS DE DATOS', 'SUAREZ CASTANON MIGUEL SANTIAGO', '1', '111'),
        ('ALGEBRA LINEAL', 'GONZALEZ CISNEROS ALEJANDRO', '1', '111'),
        ('ETICA Y LEGALIDAD', 'RAMIREZ GUZMAN ALICIA MARCELA', '1', '111'),
        ('CALCULO MULTIVARIABLE', 'MARTINEZ GARCIA CESAR ROMAN', '1', '111'),
        ('FUNDAMENTOS ECONOMICOS', 'RAMIREZ TENORIO RAFAEL', '1', '111'),
    ],
    3: [
        ('ANALISIS Y DISEÑO DE ALGORITMOS', 'SANCHEZ GARCIA LUZ MARIA', '2', '202'),
        ('PROGRAMACION PARA CIENCIA DE DATOS', 'RAMIREZ MORALES MARIO AUGUSTO', '2', '202'),
        ('BASES DE DATOS', 'VELEZ SALDANA ULISES', '2', '003'),
        ('PROBABILIDAD', 'CRUZ ROJAS JORGE ALBERTO', '2', '202'),
        ('METODOS NUMERICOS', 'GUTIERREZ ALDANA EDUARDO', '2', '202'),
        ('FINANZAS EMPRESARIALES', 'RODRIGUEZ FLORES EDUARDO', '2', '110'),
    ],
    4: [
        ('DESARROLLO DE APLICACIONES WEB', 'BAUTISTA ROSALES SANDRA IVETTE', '2', '213'),
        ('COMPUTO DE ALTO DESEMPEÑO', 'CRUZ TORRES BENJAMIN', '2', '213'),
        ('DESARROLLO DE APLICACIONES PARA ANALISIS DE DATOS', 'LOPEZ GOMEZ ALEJANDRO', '2', '213'),
        ('BASES DE DATOS AVANZADAS', 'PORTILLO CEDILLO MANUEL', '2', '213'),
        ('ESTADISTICA', 'GARCIA BLANQUEL CLAUDIA', '2', '109'),
        ('LIDERAZGO PERSONAL', 'CENTENO ARRAZOLA MARIA SOLEDAD', '2', '213'),
    ],
    5: [
        ('APRENDIZAJE DE MAQUINA E INTELIGENCIA ARTIFICIAL', 'REYES VERA ABDIEL', '3', '008'),
        ('ANALITICA Y VISUALIZACION DE DATOS', 'LOPEZ GOMEZ ALEJANDRO', '3', '008'),
        ('MINERIA DE DATOS', 'OCAMPO BOTELLO FABIOLA', '3', '008'),
        ('PROCESOS ESTOCASTICOS', 'RANGEL NAHUM CARLOS ALEXIS', '3', '009'),
        ('MATEMATICAS AVANZADAS PARA CIENCIA DE DATOS', 'DIAZ SANCHEZ HUGO', '3', '008'),
        ('METODOLOGIA DE LA INVESTIGACION Y DIVULGACION CIENTIFICA', 'SALDIVAR ALMOREJO MARIA MAGDALENA', '3', '008'),
    ],
    6: [
        ('PROCESAMIENTO DE LENGUAJE NATURAL', 'ORTIZ CASTILLO MARCO ANTONIO', '3', '113'),
        ('ANALITICA AVANZADA DE DATOS', 'NUNEZ PRADO CESAR JESUS', '3', '113'),
        ('MODELADO PREDICTIVO', 'GARCIA BLANQUEL CLAUDIA', '3', '113'),
        ('ANALISIS DE SERIES DE TIEMPO', 'GARCIA BLANQUEL CLAUDIA', '3', '113'),
        ('SISTEMAS DE INFORMACION GEOGRAFICA', 'TORRES RUIZ MIGUEL JESUS', '3', '113'),
        ('CIBERSEGURIDAD', 'GARCIA CORTES ROCIO', '3', '113'),
    ],
    7: [
        ('BIG DATA', 'RODRIGUEZ SARABIA TANIA', '4', '008'),
        ('MODELOS ECONOMETRICOS', 'REYES VERA ABDIEL', '4', '008'),
        ('ADMINISTRACION DE PROYECTOS DE TI', 'GUZMAN FLORES JESSIE PAULINA', '4', '008'),
        ('TEMAS SELECTOS DE APRENDIZAJE PROFUNDO', 'GARCIA SALAS HORACIO ALBERTO', '4', '008'),
        ('PROTECCION DE DATOS', 'RODRIGUEZ SARABIA TANIA', '4', '008'),
    ],
    8: [
        ('DESARROLLO DE HABILIDADES SOCIALES PARA LA ALTA DIRECCION', 'RAMIREZ MARTINEZ ELIA TZINDEJHE', '4', '209'),
        ('GESTION EMPRESARIAL', 'MENDOZA MACIAS ELBA', '4', '209'),
        # ESTANCIA PROFESIONAL excluded
    ],
}

IIA = {
    2: [
        ('ALGORITMOS Y ESTRUCTURAS DE DATOS', 'RUEDA MELENDEZ JOSE MARCO ANTONIO', '1', '113'),
        ('ALGEBRA LINEAL', 'VAZQUEZ ARREGUIN ROBERTO', '1', '113'),
        ('FUNDAMENTOS DE DISEÑO DIGITAL', 'AGUILAR SANCHEZ FERNANDO', '1', '113'),
        ('CALCULO MULTIVARIABLE', 'HERNANDEZ VASQUEZ CESAR', '1', '113'),
        ('INGENIERIA ETICA Y SOCIEDAD', 'MARTINEZ ACOSTA LILIAN', '1', '113'),
        ('FINANZAS EMPRESARIALES', 'RODRIGUEZ FLORES EDUARDO', '1', '113'),
    ],
    3: [
        ('ANALISIS Y DISEÑO DE ALGORITMOS', 'RODRIGUEZ CASTILLO MIGUEL ANGEL', '2', '004'),
        ('PARADIGMAS DE PROGRAMACION', 'GARCIA SALES JUAN VICENTE', '2', '204'),
        ('ECUACIONES DIFERENCIALES', 'CARBALLO JIMENEZ JUAN MANUEL', '2', '204'),
        ('BASES DE DATOS', 'HERNANDEZ RUBIO ERIKA', '2', '204'),
        ('DISEÑO DE SISTEMAS DIGITALES', 'LOPEZ RODRIGUEZ CLAUDIA ALEJANDRA', '2', '204'),
        ('LIDERAZGO PERSONAL', 'GONZALEZ ALBARRAN GISELA', '2', '204'),
    ],
    4: [
        ('FUNDAMENTOS DE INTELIGENCIA ARTIFICIAL', 'SALAZAR URBINA ALVARO', '2', '202'),
        ('PROBABILIDAD Y ESTADISTICA', 'RUIZ LEDESMA ELENA FABIOLA', '2', '110'),
        ('MATEMATICAS AVANZADAS PARA LA INGENIERIA', 'CRUZ ROJAS JORGE ALBERTO', '2', '002'),
        ('TECNOLOGIAS PARA EL DESARROLLO DE APLICACIONES WEB', 'PEREDO VALDERRAMA RUBEN', '2', '110'),
        ('ANALISIS Y DISEÑO DE SISTEMAS', 'MELARA ABARCA REYNA ELIA', '2', '110'),
        ('PROCESAMIENTO DIGITAL DE IMAGENES', 'CRUZ MEZA MARIA ELENA', '2', '110'),
    ],
    5: [
        ('APRENDIZAJE DE MAQUINA', 'MARTINEZ HERNANDEZ GUADALUPE ANA GABRIELA', 'X', 'X'),
        ('VISION ARTIFICIAL', 'SERRANO TALAMANTES JOSE FELIX', 'X', 'X'),
        ('TEORIA DE LA COMPUTACION', 'LUNA BENOSO BENJAMIN', 'X', 'X'),
        ('PROCESAMIENTO DE SEÑALES', 'DIAZ TOALA IVAN', 'X', 'X'),
        ('ALGORITMOS BIOINSPIRADOS', 'URIARTE ARCIA ABRIL VALERIA', 'X', 'X'),
        ('TECNOLOGIAS DE LENGUAJE NATURAL', 'MORENO GALVAN ELIZABETH', 'X', 'X'),
    ],
    6: [
        ('COMPUTO PARALELO', 'GUTIERREZ ALDANA EDUARDO', 'X', 'X'),
        ('REDES NEURONALES Y APRENDIZAJE PROFUNDO', 'GARCIA SALAS HORACIO ALBERTO', 'X', 'X'),
        ('INGENIERIA DE SOFTWARE PARA SISTEMAS INTELIGENTES', 'CARRETO ARELLANO CHADWICK', 'X', 'X'),
        ('METODOLOGIA DE LA INVESTIGACION Y DIVULGACION CIENTIFICA', 'CELIS DOMINGUEZ ADRIANA BERENICE', 'X', 'X'),
        ('APLICACIONES DE LENGUAJE NATURAL', 'GARCIA SALAS HORACIO ALBERTO', 'X', 'X'),
        ('MINERIA DE DATOS', 'PORTILLO CEDILLO MANUEL', 'X', 'X'),
    ],
    7: [
        # TRABAJO TERMINAL I excluded
        ('FORMULACION Y EVALUACION DE PROYECTOS INFORMATICOS', 'RODRIGUEZ ORDAZ MARISOL', 'X', 'X'),
        ('BIG DATA', 'ROMAN GODINEZ RODRIGO FRANCISCO', 'X', 'X'),
        ('APLICACIONES DE INTELIGENCIA ARTIFICIAL EN SISTEMAS EMBEBIDOS', 'CASTILLO MARTINEZ MIGUEL ANGEL', 'X', 'X'),
    ],
    8: [
        # TRABAJO TERMINAL II excluded
        ('GESTION EMPRESARIAL', 'CANCINO MOSQUEDA ODETTE BERENICE', 'X', 'X'),
        ('DESARROLLO DE HABILIDADES SOCIALES PARA LA ALTA DIRECCION', 'LOYOLA ESPINOSA ARACELI', 'X', 'X'),
    ],
}

ALL_CAREER_DATA = {
    'ISC': ('Ingeniería en Sistemas Computacionales', 'ISC', ISC),
    'LCD': ('Licenciatura en Ciencia de Datos', 'LCD', LCD),
    'IIA': ('Ingeniería en Inteligencia Artificial', 'IIA', IIA),
}

# ── Collect unique entities ───────────────────────────────────────────────────

# Professors: name → uuid
prof_uuid = {}   # canonical_name → uuid
prof_email = {}  # canonical_name → email (check duplicates)

# Materias: nombre → uuid
mat_uuid = {}

# Salones: (edificio_num, salon_num) → uuid
salon_uuid = {}

# Edificios: numero → uuid
edif_uuid = {}

for carrera_key, (cname, cacro, semdata) in ALL_CAREER_DATA.items():
    for sem, rows in semdata.items():
        for (materia, profesor, edif, salon_num) in rows:
            if profesor not in prof_uuid:
                prof_uuid[profesor] = gen()
                # generate unique email
                base = email_from_name(profesor)
                email = base
                count = 2
                while email in prof_email.values():
                    email = base.replace('@', f'{count}@')
                    count += 1
                prof_email[profesor] = email
            if materia not in mat_uuid:
                mat_uuid[materia] = gen()
            if edif not in edif_uuid:
                edif_uuid[edif] = gen()
            # salon code = combined edificio+salon_num (or "X" for unassigned)
            if edif == 'X' or salon_num == 'X':
                salon_code = 'X'
                salon_key = ('X', 'X')
            else:
                salon_code = edif + salon_num
                salon_key = (edif, salon_num)
            if salon_key not in salon_uuid:
                salon_uuid[salon_key] = gen()

# Carreras
carrera_uuid = {k: gen() for k in ALL_CAREER_DATA}
plan_uuid = {k: gen() for k in ALL_CAREER_DATA}
academia_uuid = {k: gen() for k in ALL_CAREER_DATA}
jefe_uuid = {prof: gen() for prof in prof_uuid}   # jefeacademia uuid per prof
periodo_uuid = gen()

# carrera_materia uuid: (carrera_key, sem, materia) → uuid
cm_uuid = {}
# ets uuid: same key → uuid
ets_uuid_map = {}

for carrera_key, (cname, cacro, semdata) in ALL_CAREER_DATA.items():
    for sem, rows in semdata.items():
        for idx, (materia, profesor, edif, salon_num) in enumerate(rows):
            key = (carrera_key, sem, materia)
            if key not in cm_uuid:
                cm_uuid[key] = gen()
                ets_uuid_map[key] = gen()

# ── SQL OUTPUT ────────────────────────────────────────────────────────────────

out = []

def emit(s=''):
    out.append(s)

emit("-- ============================================================")
emit("-- ESCOM ETS — Migración completa")
emit("-- Generado automáticamente. Ejecutar en Supabase SQL Editor.")
emit("-- ============================================================")
emit()
emit("-- Habilitar extensión UUID")
emit('CREATE EXTENSION IF NOT EXISTS "uuid-ossp";')
emit()

# ── DDL ───────────────────────────────────────────────────────────────────────
emit("-- ============================================================")
emit("-- DDL — Creación de tablas")
emit("-- ============================================================")
emit()

emit("""CREATE TABLE IF NOT EXISTS usuario (
  id_usuario      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  correo          TEXT UNIQUE NOT NULL,
  nombre          TEXT NOT NULL,
  apellidopaterno TEXT NOT NULL,
  apellidomaterno TEXT NOT NULL DEFAULT '',
  passwordhash    TEXT NOT NULL DEFAULT '',
  activo          BOOLEAN NOT NULL DEFAULT TRUE
);
""")

emit("""CREATE TABLE IF NOT EXISTS carrera (
  id_carrera UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre     TEXT NOT NULL,
  acronimo   TEXT NOT NULL,
  activo     BOOLEAN NOT NULL DEFAULT TRUE
);
""")

emit("""CREATE TABLE IF NOT EXISTS planestudios (
  id_plan UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre  TEXT NOT NULL
);
""")

emit("""CREATE TABLE IF NOT EXISTS academia (
  id_academia UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre      TEXT NOT NULL,
  acronimo    TEXT NOT NULL,
  id_carrera  UUID REFERENCES carrera(id_carrera) ON DELETE SET NULL
);
""")

emit("""CREATE TABLE IF NOT EXISTS edificio (
  id_edificio UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  numero      TEXT NOT NULL
);
""")

emit("""CREATE TABLE IF NOT EXISTS salon (
  id_salon    UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  codigo      TEXT NOT NULL,
  piso        TEXT NOT NULL DEFAULT '',
  id_edificio UUID REFERENCES edificio(id_edificio) ON DELETE SET NULL
);
""")

emit("""CREATE TABLE IF NOT EXISTS materia (
  id_materia UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre     TEXT NOT NULL
);
""")

emit("""CREATE TABLE IF NOT EXISTS carrera_materia (
  id_carrera_materia UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  id_carrera         UUID REFERENCES carrera(id_carrera) ON DELETE CASCADE,
  id_plan            UUID REFERENCES planestudios(id_plan) ON DELETE CASCADE,
  id_materia         UUID REFERENCES materia(id_materia) ON DELETE CASCADE,
  semestre           INTEGER NOT NULL,
  id_academia        UUID REFERENCES academia(id_academia) ON DELETE SET NULL
);
""")

emit("""CREATE TABLE IF NOT EXISTS jefeacademia (
  id_jefeacademia UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  id_usuario      UUID REFERENCES usuario(id_usuario) ON DELETE CASCADE
);
""")

emit("""CREATE TABLE IF NOT EXISTS periodoets (
  id_periodoets UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre        TEXT NOT NULL
);
""")

emit("""CREATE TABLE IF NOT EXISTS ets (
  id_ets             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  fechahorainicio    TIMESTAMPTZ NOT NULL,
  fechahorafin       TIMESTAMPTZ NOT NULL,
  turno              TEXT NOT NULL,
  estado             TEXT NOT NULL DEFAULT 'activo',
  id_periodoets      UUID REFERENCES periodoets(id_periodoets) ON DELETE SET NULL,
  id_salon           UUID REFERENCES salon(id_salon) ON DELETE SET NULL,
  id_carrera_materia UUID REFERENCES carrera_materia(id_carrera_materia) ON DELETE CASCADE,
  id_jefeacademia    UUID REFERENCES jefeacademia(id_jefeacademia) ON DELETE SET NULL
);
""")

emit("""CREATE TABLE IF NOT EXISTS alumno (
  id_alumno  UUID PRIMARY KEY,
  boleta     TEXT UNIQUE NOT NULL,
  id_carrera UUID REFERENCES carrera(id_carrera),
  id_plan    UUID REFERENCES planestudios(id_plan),
  id_usuario UUID REFERENCES usuario(id_usuario)
);
""")

emit("""CREATE TABLE IF NOT EXISTS inscripcionets (
  id_inscripcionets TEXT PRIMARY KEY,
  id_ets            UUID REFERENCES ets(id_ets) ON DELETE CASCADE,
  id_alumno         UUID REFERENCES alumno(id_alumno) ON DELETE CASCADE,
  estado            TEXT NOT NULL DEFAULT 'pendiente',
  calificacion      NUMERIC,
  resultado         TEXT,
  fechainscripcion  DATE
);
""")

# ── DATA ──────────────────────────────────────────────────────────────────────
emit()
emit("-- ============================================================")
emit("-- DATOS — Catálogos base")
emit("-- ============================================================")
emit()

# Edificios
emit("-- Edificios")
emit("INSERT INTO edificio (id_edificio, numero) VALUES")
edif_rows = []
for num, uid in sorted(edif_uuid.items()):
    edif_rows.append(f"  ('{uid}', '{esc(num)}')")
emit(',\n'.join(edif_rows) + ';')
emit()

# Salones
emit("-- Salones")
emit("INSERT INTO salon (id_salon, codigo, piso, id_edificio) VALUES")
salon_rows = []
for (edif_num, salon_num), uid in sorted(salon_uuid.items(), key=lambda x: x[0]):
    if edif_num == 'X' or salon_num == 'X':
        code = 'X'
        piso = ''
        edif_id = edif_uuid.get('X', '')
    else:
        code = edif_num + salon_num
        piso = salon_num[0] if salon_num else ''
        edif_id = edif_uuid[edif_num]
    salon_rows.append(f"  ('{uid}', '{esc(code)}', '{esc(piso)}', '{edif_id}')")
emit(',\n'.join(salon_rows) + ';')
emit()

# Carreras
emit("-- Carreras")
emit("INSERT INTO carrera (id_carrera, nombre, acronimo, activo) VALUES")
carrera_rows = []
for key, (cname, cacro, _) in ALL_CAREER_DATA.items():
    carrera_rows.append(f"  ('{carrera_uuid[key]}', '{esc(cname)}', '{esc(cacro)}', TRUE)")
emit(',\n'.join(carrera_rows) + ';')
emit()

# Planes de estudio
emit("-- Planes de estudio")
emit("INSERT INTO planestudios (id_plan, nombre) VALUES")
plan_rows = []
for key in ALL_CAREER_DATA:
    plan_rows.append(f"  ('{plan_uuid[key]}', 'Plan 2021')")
emit(',\n'.join(plan_rows) + ';')
emit()

# Academias
emit("-- Academias")
emit("INSERT INTO academia (id_academia, nombre, acronimo, id_carrera) VALUES")
acad_rows = []
for key, (cname, cacro, _) in ALL_CAREER_DATA.items():
    acad_rows.append(f"  ('{academia_uuid[key]}', 'Academia de {esc(cacro)}', '{esc(cacro)}', '{carrera_uuid[key]}')")
emit(',\n'.join(acad_rows) + ';')
emit()

# Usuarios (profesores)
emit("-- Usuarios (profesores)")
emit("INSERT INTO usuario (id_usuario, correo, nombre, apellidopaterno, apellidomaterno, activo) VALUES")
usr_rows = []
for prof, uid in prof_uuid.items():
    ap, am, nm = split_name(prof)
    email = prof_email[prof]
    usr_rows.append(f"  ('{uid}', '{esc(email)}', '{esc(nm)}', '{esc(ap)}', '{esc(am)}', TRUE)")
emit(',\n'.join(usr_rows) + ';')
emit()

# Jefeacademia
emit("-- Jefeacademia")
emit("INSERT INTO jefeacademia (id_jefeacademia, id_usuario) VALUES")
jefe_rows = []
for prof, uid in prof_uuid.items():
    jefe_rows.append(f"  ('{jefe_uuid[prof]}', '{uid}')")
emit(',\n'.join(jefe_rows) + ';')
emit()

# Materias
emit("-- Materias")
emit("INSERT INTO materia (id_materia, nombre) VALUES")
mat_rows = []
for nombre, uid in sorted(mat_uuid.items()):
    mat_rows.append(f"  ('{uid}', '{esc(nombre)}')")
emit(',\n'.join(mat_rows) + ';')
emit()

# Periodo ETS
emit("-- Periodo ETS")
emit(f"INSERT INTO periodoets (id_periodoets, nombre) VALUES")
emit(f"  ('{periodo_uuid}', 'Periodo ETS Julio-Agosto 2026');")
emit()

# Carrera_materia
emit("-- Carrera_materia")
emit("INSERT INTO carrera_materia (id_carrera_materia, id_carrera, id_plan, id_materia, semestre, id_academia) VALUES")
cm_rows = []
for (ck, sem, materia), uid in cm_uuid.items():
    cm_rows.append(
        f"  ('{uid}', '{carrera_uuid[ck]}', '{plan_uuid[ck]}', '{mat_uuid[materia]}', {sem}, '{academia_uuid[ck]}')"
    )
emit(',\n'.join(cm_rows) + ';')
emit()

# ETS records
emit("-- ETS records (exámenes programados)")
emit("INSERT INTO ets (id_ets, fechahorainicio, fechahorafin, turno, estado, id_periodoets, id_salon, id_carrera_materia, id_jefeacademia) VALUES")

# Assign dates: week based on semestre pair
# Sem 1-2 → week 1 (Jul 6), sem 3-4 → week 2 (Jul 13), etc.
# Monday of each week, 07:00 local (UTC-6 → 13:00 UTC)
base_dates = {
    (1, 2): '2026-07-06',
    (3, 4): '2026-07-13',
    (5, 6): '2026-07-20',
    (7, 8): '2026-07-27',
}

def sem_to_date(sem):
    for (lo, hi), d in base_dates.items():
        if lo <= sem <= hi:
            return d
    return '2026-07-06'

ets_rows = []
for carrera_key, (cname, cacro, semdata) in ALL_CAREER_DATA.items():
    for sem, rows in semdata.items():
        d = sem_to_date(sem)
        for idx, (materia, profesor, edif, salon_num) in enumerate(rows):
            key = (carrera_key, sem, materia)
            ets_id = ets_uuid_map[key]
            cm_id = cm_uuid[key]
            jefe_id = jefe_uuid[profesor]
            # salon
            if edif == 'X' or salon_num == 'X':
                salon_id = salon_uuid[('X', 'X')]
            else:
                salon_id = salon_uuid[(edif, salon_num)]
            # time offset by idx (one exam per 2-hour block)
            hour = 7 + (idx % 6) * 2  # 07:00, 09:00, 11:00, ...
            fi = f"{d}T{hour:02d}:00:00-06:00"
            ff = f"{d}T{hour+2:02d}:00:00-06:00"
            turno = 'Matutino' if hour < 14 else 'Vespertino'
            ets_rows.append(
                f"  ('{ets_id}', '{fi}', '{ff}', '{turno}', 'activo', "
                f"'{periodo_uuid}', '{salon_id}', '{cm_id}', '{jefe_id}')"
            )
emit(',\n'.join(ets_rows) + ';')
emit()

emit("-- ============================================================")
emit("-- FIN DE MIGRACIÓN")
emit("-- ============================================================")

sql = '\n'.join(out)
print(sql)
