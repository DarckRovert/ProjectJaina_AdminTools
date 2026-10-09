# 📝 Registro de Cambios — Wanos_AdminTools

Todas las modificaciones notables a este proyecto se documentan en este archivo.  
El formato se basa en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/) y sigue [SemVer](https://semver.org/).

---

## [2.0.1] — 2026-10-07

### 🌐 Integración con el Ecosistema Project Jaina
- **Acoplamiento Oficial (#20):** Incorporación formal de AdminTools como el Módulo Oficial #20 del ecosistema multi-addon de Project Jaina - Project Jaina.
- **Nuevos Slash Commands Oficiales:** Registrados alias `/wpadm`, `/wpgm` y `/admintools` manteniendo compatibilidad total con `/admin` y `/adt`.
- **Branding y Cabecera Oficial:** Implementada cabecera visual estilizada (`|cFFFFD700Project Jaina|r |cFF00FFCCAdmin Tools|r |cFF888888v2.0.1|r`) y formateo de mensajes de chat con prefijo `[Project Jaina Admin]`.
- **Saneamiento Tipográfico y Erradicación de Glifos Corruptos:** Sustituidas las secuencias de escape octales `\226\150\188` (`▼`) y `\226\128\148` (`—`) por caracteres estándar legibles (`v` y `-`), evitando que la fuente nativa `FRIZQT__.TTF` de Blizzard 3.3.5a dibuje signos de interrogación `?` en botones y desplegables.
- **Suite Documental y de Pruebas:** Incorporación de la suite Gold Standard de 10 artefactos (`API.md`, `AGENTS.md`, `INSTALL.md`, `SECURITY.md`, `NOTICE.md`, `ECOSYSTEM_REGISTRY.md`, etc.) y suite de pruebas automatizada `Tests/test_sanity.py`.

---

## [2.0.0] — 2026-09-16

### ✨ Añadido
- **Pestaña Summon:** Invocación de PNJs temporales oficiales de Blizzard al lado del personaje: Vendedor general, Vendedor de comida y bebida, Subastador y Banquero con versiones separadas para Alianza y Horda.
- **Desplegable de Instructores de Clase:** Soporte de aprendizaje para las 9 clases clásicas según facción.
- **Botón Despedir Ayudante (Dismiss Helper):** Despawn inmediato con `.npc delete` sin necesidad de reiniciar el servidor.
- **Ampliación de Ventana:** Ajuste dimensional para acomodar la 8ª pestaña de la suite.

### 🐛 Corregido
- **Capa Visual del Cuadro de Comandos:** Aumentado el estrato de renderizado a `HIGH` en la barra inferior para evitar que el contenido de pestañas densas (Tele, Travel) oculte el texto escrito.

---

## [1.0.0] — 2026-08-31

### ✨ Lanzamiento Público Inicial (Por valdrea)
- Panel con pestañas: Tele, Travel, Self, Char, Party, Server, Custom.
- Teletransportes por facción con confirmación de capital enemiga.
- Menús desplegables de mazmorras y bandas por nivel.
- Controles de estado GM, trucos, velocidad y monturas.
- Barra de comandos siempre visible y persistencia en `AdminToolsDB`.
