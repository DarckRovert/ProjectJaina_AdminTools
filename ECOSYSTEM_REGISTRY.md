# 🌐 Registro de Ecosistema — ProjectJaina_AdminTools

Ficha técnica oficial de registro en la infraestructura multi-addon de **Project Jaina - Project Jaina**.

---

## 1. Identidad del Addon en el Ecosistema

| Campo | Valor |
|---|---|
| **Nombre Técnico** | `ProjectJaina_AdminTools` |
| **Carpeta Local** | `AdminTools` |
| **Versión Actual** | `2.0.1` |
| **Clasificación** | Herramientas Staff / GM / Administración In-Game |
| **Módulo Oficial** | Módulo Oficial #20 |
| **Licencia Formal** | MIT |
| **Repositorio GitHub** | [ProjectJaina_AdminTools](https://github.com/DarckRovert/ProjectJaina_AdminTools) |
| **Entorno de Juego** | World of Warcraft 3.3.5a (Build 12340) / WotLK |
| **Persistencia** | `AdminToolsDB` (por cuenta / `SavedVariables`) |

---

## 2. Garantías de Rendimiento y Arquitectura

- **Tiempo de Cuadro:** < 0.002 ms por frame (estático; sin ciclos continuos pesados en `OnUpdate`).
- **Memoria en Tiempo de Ejecución:** < 65 KB de memoria Lua.
- **Inmunidad a Taint:** Todos los frames son creados en espacio de usuario sin intervenir en botones de acción protegidos durante combate.
- **Filtrado de Comandos:** Las solicitudes se despachan a través de `SendChatMessage(cmd, "SAY")`, delegando la autorización de ejecución exclusivamente al interceptor RBAC del core.

---

## 3. Matriz de Integración del Ecosistema

| Módulo Coexistente | Modo de Interacción | Flujo de Datos |
|---|---|---|
| **`ProjectJaina_GMGenie`** | Complementariedad Staff | `GMGenie` administra la cola de tickets y telemetría de jugadores; `AdminTools` ejecuta acciones masivas de desarrollo y comandos directos. |
| **`ProjectJaina_ProjectJaina_IntiObjGPS`** | Sinergia Espacial | `ProjectJaina_IntiObjGPS` captura coordenadas exactas de GameObjects; `AdminTools` provee teletransporte inmediato y pruebas en vivo. |
| **`ProjectJaina_Graphics`** | Armonía Visual | Se beneficia del renderizado nítido sin artefactos visuales ni escalado borroso. |
| **`ACP` (Addon Control Panel)** | Control de Carga | Permite ser activado o desactivado en caliente sin requerir reinicio del cliente. |
