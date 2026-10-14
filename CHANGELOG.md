# 📋 Registro de Cambios — ProjectJaina_AdminTools

Todos los cambios notables de este proyecto están documentados en este archivo siguiendo el estándar [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/).

---

## [2.1.0] — 2026-10-13
### Living World Edition (Baluartes & Galeón de Desertores)
- **Pestaña "Mundo" Exclusiva:** Incorporación de panel dedicado para supervisión y operación de los 6 Baluartes de Hermandad y el Galeón Dinámico de Theramore.
- **Controles Baluartes:** Botones rápidos de censo (.outpost list), reseteo masivo (.outpost reset all), 6 teletransportes instantáneos a los enclaves, y formulario para asignación y reseteo por ID.
- **Controles Galeón:** Consulta de fase y estado (.galleon status), disparo forzado de alarma costera (.galleon alert), reseteo a calma (.galleon reset), prueba de artillería de cubierta (.galleon testcannon) y teletransportes tácticos (Cubierta, Escala de Agua y Campamento de Playa).
- **Diseño de 9 Pestañas Compacto:** Recalibración del ancho de pestaña a 55px con paso de 57px para integración estética perfecta sin solapamientos.

---

## [1.0.1] — 2026-10-10
### Estabilización de Ecosistema y Gobernanza Oficial (Project Jaina)
- **Normalización de UI y Gráficos:** Sustitución mandatoria de `.reload all` por `.reload ale` para prevenir caídas de C++ con bots activos, integración de comandos rápidos para HeroBot Jaina y aislamiento estricto fuera del paquete público.
- **Homologación Documental:** Incorporación y actualización formal de `GOVERNANCE.md`, `LICENSE`, `NOTICE.md` y `SECURITY.md`.
- **Licencia Canónica:** Consolidación de licencia MIT 2026 bajo titularidad de DarckRovert & Project Jaina Team.
- **Validación de Runtime:** Verificado al 100% con compilador sintáctico `lua52_compiler.exe -p` con 0 errores y 0 warnings.

---

## [1.0.0] — 2026-10-04
### Lanzamiento Inicial — Ecosistema Project Jaina WotLK 3.3.5a
- Implementación de la arquitectura base para Project Jaina Admin Tools.
- Registro de comandos slash: `/adm, /pjadmin`.
- Persistencia de configuración en `ProjectJaina_AdminDB`.
- Compatibilidad certificada con cliente WotLK 3.3.5a (Build 12340) y directiva `Interface: 30300`.
