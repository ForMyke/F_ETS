# Cuentas de prueba — ETS ESCOM

Contraseña universal: `Password123`

---

## Admin

| Correo | Contraseña | Rol |
|--------|-----------|-----|
| `admin@ipn.mx` | `Password123` | Administrador |

---

## Jefes de Academia

Creados por `seed_academias_jefes.sql`. Cada jefe ve los ETS de las materias de su academia.

| Academia | Correo | Contraseña | Nombre |
|----------|--------|-----------|--------|
| Matemáticas | `jefe.matematicas@ipn.mx` | `Password123` | GUZMAN AGUILAR FLORENCIO |
| Circuitos / Electrónica | `jefe.circuitos@ipn.mx` | `Password123` | ALCANTARA MENDEZ ALBERTO JESUS |
| Programación | `jefe.programacion@ipn.mx` | `Password123` | RESENDIZ MUÑOZ ROCIO |
| Sociales | `jefe.sociales@ipn.mx` | `Password123` | SANCHEZ MORENO ADRIANA |
| Sistemas / Redes | `jefe.sistemas@ipn.mx` | `Password123` | ALCARAZ TORRES JUAN JESUS |
| Inteligencia Artificial | `jefe.ia@ipn.mx` | `Password123` | ROMAN GODINEZ RODRIGO FRANCISCO |

### Materias por academia

| Academia | Materias |
|----------|---------|
| **Matemáticas** | Matemáticas Discretas, Cálculo, Análisis Vectorial, Álgebra Lineal, Cálculo Aplicado, Ecuaciones Diferenciales, Probabilidad y Estadística, Matemáticas Avanzadas para la Ingeniería, Métodos Cuantitativos para la Toma de Decisiones, Cálculo Multivariable |
| **Circuitos / Electrónica** | Mecánica y Electromagnetismo, Fundamentos de Diseño Digital, Circuitos Eléctricos, Diseño de Sistemas Digitales, Electrónica Analógica, Procesamiento Digital de Señales, Arquitectura de Computadoras, Instrumentación y Control, Sistemas en Chip, Procesamiento de Señales, Cómputo Paralelo |
| **Programación** | Fundamentos de Programación, Algoritmos y Estructura de Datos, Análisis y Diseño de Algoritmos, Paradigmas de Programación, Teoría de la Computación, Tecnologías para Desarrollo de Aplicaciones Web, Compiladores, Desarrollo de Aplicaciones Móviles Nativas, Algoritmos y Estructuras de Datos (IIA) |
| **Sociales** | Comunicación Oral y Escrita, Ingeniería Ética y Sociedad, Fundamentos Económicos, Finanzas Empresariales, Formulación y Evaluación de Proyectos Informáticos, Gestión de Empresas de Alta Tecnología, Liderazgo Personal, Gestión Empresarial, Desarrollo de Habilidades Sociales, Metodología de la Investigación |
| **Sistemas / Redes** | Bases de Datos, Sistemas Operativos, Análisis y Diseño de Sistemas, Redes de Computadoras, Criptografía, Ingeniería de Software, Aplicaciones para Comunicaciones en Red, Sistemas Distribuidos, Internet de las Cosas, Criptografía: Temas Selectos, Administración de Servicios en Red, Ingeniería de Software para Sistemas Inteligentes |
| **Inteligencia Artificial** | Inteligencia Artificial, Fundamentos de IA, Procesamiento Digital de Imágenes, Aprendizaje de Máquina, Visión Artificial, Algoritmos Bioinspirados, Tecnologías de Lenguaje Natural, Redes Neuronales y Aprendizaje Profundo, Aplicaciones de Lenguaje Natural, Minería de Datos, Big Data, Aplicaciones de IA en Sistemas Embebidos |

---

## Alumnos

Creados por `seed_usuarios.sql`.

| Carrera | Correo | Contraseña | Boleta | Nombre |
|---------|--------|-----------|--------|--------|
| ISC | `jgarciar2021@alumno.ipn.mx` | `Password123` | 2021630001 | Juan Garcia Ramirez |
| LCD | `mlopezh2021@alumno.ipn.mx` | `Password123` | 2021580001 | Maria Lopez Hernandez |
| IIA | `crodriguezm2021@alumno.ipn.mx` | `Password123` | 2021760001 | Carlos Rodriguez Mendoza |

---

## Orden de ejecución de scripts

```
1. migration.sql              — DDL + datos base (carreras, salones, materias, LCD completo)
2. seed_academias_jefes.sql   — 6 academias por área + 6 cuentas de jefe
3. seed_carrera_materia_isc_iia.sql — planes de estudio e ISC/IIA en carrera_materia
4. seed_ets_isc_iia.sql       — ETS de ISC (sems 1–8) e IIA (sems 2–8)
5. seed_usuarios.sql          — 3 alumnos de prueba
6. seed_admin_jefe.sql        — admin@ipn.mx + RLS
```
