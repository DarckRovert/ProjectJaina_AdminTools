# 🔌 Especificación Técnica y API — AdminTools

[![GitHub](https://img.shields.io/badge/GitHub-DarckRovert%2FWanos__AdminTools-black?logo=github)](https://github.com/DarckRovert/Wanos_AdminTools)
[![Ecosistema](https://img.shields.io/badge/Ecosistema-WoW%20Per%C3%BA%20(M%C3%B3dulo%20%2320)-gold.svg)](https://projectjaina.com/)

## 📌 Resumen Arquitectónico
Panel gráfico por pestañas para Game Masters y administradores de servidores 3.3.5a (TrinityCore / AzerothCore). Intercepta y emite comandos del servidor mediante `SendChatMessage` en el canal `SAY`.

- **Rol en el Ecosistema:** Módulo Oficial #20 — Panel de Administración & Game Master
- **Archivo Principal TOC:** `AdminTools.toc`
- **Compatibilidad del Motor:** World of Warcraft 3.3.5a (Build 12340)

---

## ⌨️ Comandos de Consola (Slash Commands)
- `/admin`: Alterna la visibilidad del marco principal. Si se acompaña de argumentos (`/admin .tele dalaran`), despacha el comando directamente.
- `/adt`: Alias corto idéntico a `/admin`.
- `/wpadm`: Prefijo oficial de administración de Project Jaina.
- `/wpgm`: Prefijo oficial para Game Masters de Project Jaina.
- `/admintools`: Comando largo alternativo.

---

## 🔧 Funciones Internas Clave

### `RunCmd(cmd)`
- **Parámetros:** `cmd` *(string)* — Comando a ejecutar.
- **Descripción:** Sanea la cadena de entrada, añade el punto inicial `.` si no está presente, limita la longitud a 255 caracteres y despacha mediante `SendChatMessage(cmd, "SAY")`. Emite telemetría local a `DEFAULT_CHAT_FRAME` si `AdminToolsDB.echo ~= false`.

### `ConfirmCmd(cmd)`
- **Parámetros:** `cmd` *(string)* — Comando crítico.
- **Descripción:** Muestra un diálogo de confirmación `StaticPopupDialogs["ADMINTOOLS_CONFIRM"]` antes de ejecutar comandos destructivos (`.server restart`, `.server shutdown`).

### `BuildMenu(globalName, dataTable)`
- **Parámetros:** `globalName` *(string)*, `dataTable` *(table)*.
- **Descripción:** Genera un menú desplegable jerárquico multinivel utilizando `UIDropDownMenuTemplate` de Blizzard para categorías como monturas, mazmorras y bandas.

### `RefreshCustom()`
- **Descripción:** Reconstruye dinámicamente los botones definidos por el usuario en la pestaña *Custom* a partir de la tabla persistente `AdminToolsDB.custom`.

---

## 💾 Persistencia de Datos (SavedVariables)
- `AdminToolsDB`: Tabla global guardada en disco por cuenta:
  - `AdminToolsDB.pos`: Posición anclada de la ventana `(point, relativePoint, x, y)`.
  - `AdminToolsDB.tab`: Última pestaña visualizada (`Tele`, `Travel`, `Self`, `Char`, `Party`, `Summon`, `Server`, `Custom`).
  - `AdminToolsDB.echo`: Booleano para activar o silenciar el eco local en el chat.
  - `AdminToolsDB.custom`: Lista de objetos `{ label = "Nombre", cmd = "Comando" }`.
