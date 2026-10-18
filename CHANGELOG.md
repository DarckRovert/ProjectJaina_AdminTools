# 📋 Registro de Cambios — ProjectJaina_AdminTools

Todos los cambios notables de este proyecto están documentados en este archivo siguiendo el estándar [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/).

---

## [3.0.0] — 2026-10-18
### Supreme GM Suite (Armería en Vivo, Nivel, Economía Real & Trampas Divinas)
- **Armería & Inspector de Equipamiento en Vivo (`AdminToolsArmory.lua`):**
  - Panel interactivo de 19 casillas con disposición Paperdoll oficial.
  - Sincronización en tiempo real de inspección (`PLAYER_TARGET_CHANGED`, `INSPECT_READY`) para jugadores humanos y bots.
  - Renderizado de texturas de ítems, bordes de calidad dinámica (verde, azul, épico, legendario), iLvl y tooltips nativos.
  - Clic izquierdo para copiar ID al formulario de entrega, Clic derecho para retirar ítems con `.additem <id> -1`.
  - Entrega de ítems por ID numérico o mediante enlaces Shift-Click (`[ItemLink]`).
  - Regear automático de bots a conjuntos épicos completos (Nivel 80, 70 y 60) mediante `.playerbots regear`.
  - Menú desplegable oficial de Conjuntos Tier 7, 8, 9, 10 y PvP Season 8 (Gladiador Colérico) mediante `.additemset`.
- **Manipulación Instantánea de Nivel (Pestaña "Char"):**
  - Botones directos para fijar nivel en 80, 70, 60 y 1 para el objetivo seleccionado (jugador o bot) o el GM.
  - Incrementos y decrementos rápidos (+1, +5, +10, -1) y formulario para fijar cualquier nivel entre 1 y 80.
- **Economía y Oro en Unidades Reales (Pestaña "Char"):**
  - Botones rápidos de +/- 100g, +/- 1,000g, +500g, +5,000g, +10,000g, Max Oro (214k) y Vaciar Oro (0g).
  - Formulario de oro personalizado en unidades reales con conversión matemática automática a cobre (`oro * 10000`).
- **Autoridad Divina & Trampas (Pestaña "God"):**
  - Modo Dios (`.cheat god`), Cooldowns cero (`.cheat cd`), Cast instantáneo (`.cheat cast`), Poder/Maná infinito (`.cheat power`).
  - Vuelo instantáneo (`.gm fly on/off`), Invisibilidad suprema (`.gm visible off/on`), Caminar sobre agua (`.cheat waterwalk`).
  - Modificadores de velocidad (1x a 25x), escala (0.25x a 5.0x), metamorfosis legendarias (Lich King, Jaina, Illidan, Sylvanas, Ragnaros).
- **Gestión Táctica de Bots (Pestaña "Bots"):**
  - Llenado automatizado de escuadrón RDF de 5 integrantes (`.rdf bots`).
  - Invocador individual por rol y clase (Tanques, Healers, DPS).
  - Órdenes de combate y movimiento (seguir, quedarse, atacar, huir, reset).
- **Ejecución Silenciosa de Comandos:**
  - Migración a `ChatEdit_SendText` para evitar que comandos rechazados por sintaxis o permisos se filtren al canal `/say`.
- **Expansión de Ventana a 670x520:**
  - Soporte para 11 pestañas (`Tele`, `Travel`, `Mundo`, `God`, `Armería`, `Char`, `Party`, `Bots`, `Summon`, `Server`, `Custom`).

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
