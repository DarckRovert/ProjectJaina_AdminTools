# 🛡️ Project Jaina — AdminTools (Panel Game Master & Administración)

[![WoW Version](https://img.shields.io/badge/WoW-3.3.5a%20(12340)-blue.svg)](https://projectjaina.com/)
[![Core Compatibility](https://img.shields.io/badge/Core-AzerothCore%20%7C%20TrinityCore-red.svg)](https://github.com/azerothcore)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![GitHub](https://img.shields.io/badge/GitHub-DarckRovert%2FWanos__AdminTools-black?logo=github)](https://github.com/DarckRovert/Wanos_AdminTools)
[![Ecosistema](https://img.shields.io/badge/Ecosistema-WoW%20Per%C3%BA%20(M%C3%B3dulo%20%2320)-gold.svg)](https://projectjaina.com/)

Suite administrativa in-game de comandos y herramientas para **Game Masters (GMs)** y administradores de servidores privados de **World of Warcraft 3.3.5a (WotLK Build 12340)**, adaptada e integrada oficialmente en el ecosistema de **Project Jaina — Project Jaina**.

Permite ejecutar de forma inmediata teletransportes masivos, invocación de PNJs temporales, gestión de personajes, trucos de desarrollo y control del servidor mediante una interfaz de pestañas, sin necesidad de teclear comandos de punto (`.tele`, `.additem`, `.server`, etc.) manualmente en la consola.

---

## 📑 Tabla de Contenidos

- [Características Principales](#-características-principales)
- [Pestañas y Funcionalidades](#-pestañas-y-funcionalidades)
- [Comandos de Consola (Slash Commands)](#-comandos-de-consola-slash-commands)
- [Instalación y Requisitos](#-instalación-y-requisitos)
- [Arquitectura y Seguridad](#-arquitectura-y-seguridad)
- [Integración con el Ecosistema](#-integración-con-el-ecosistema)
- [Atribución y Licencia](#-atribución-y-licencia)

---

## ✨ Características Principales

- **Intercepción Nativa de Comandos:** Envía comandos mediante el interceptor de chat de AzerothCore / TrinityCore, ejecutándose de manera silenciosa cuando la cuenta posee permisos RBAC / GM activos.
- **Saneamiento Tipográfico 3.3.5a:** Libre de secuencias de escape corruptas o emojis incompatibles con la fuente `FRIZQT__.TTF` del cliente WotLK.
- **Barra de Ejecución Inmediata Siempre Visible:** Permite escribir cualquier comando en la parte inferior de la ventana sin importar la pestaña seleccionada.
- **Persistencia de Configuración y Posición:** Guarda la última pestaña activa, coordenadas de la ventana y botones personalizados por cuenta en `AdminToolsDB`.
- **Ventana Arrastrable y Cierre con ESC:** Registrada en `UISpecialFrames` para cierre estándar con la tecla de escape.

---

## 🗂️ Pestañas y Funcionalidades

| Pestaña | Funcionalidad Principal | Acciones Destacadas |
|---|---|---|
| **Tele** | Teletransporte a capitales y zonas clave | Acceso a capitales de la Alianza, Horda y Neutrales con aviso de seguridad ante ciudades enemigas. Búsqueda (`.lookup tele`), teletransporte libre (`.tele`) y guardado de coordenadas (`.tele add`). |
| **Travel** | Mazmorras, Bandas y Zonas de Leveo | Desplegables multinivel ordenados por expansión (Classic, TBC, WotLK) y nivel recomendado. Teletransporte directo a entradas de estancias. |
| **Self** | Estado y Modos del Administrador | Modos GM (`.gm on/off`), invisibilidad (`.gm visible`), vuelo (`.gm fly`), caminar sobre el agua (`.aura 546`), velocidad modificada (`.modify speed 1-10`), resurrección y exploración de mapas. |
| **Char** | Modificación del Personaje Seleccionado | Subir/bajar nivel, aprender talentos/hechizos/profesiones de clase, reparación completa, oro instantáneo, bolsas de 22 casillas (Bolsa Glacial) y menú desplegable de monturas y habilidades de equitación. |
| **Party** | Gestión de Grupo y Jugadores | Invocación de grupo (`.groupsummon`), teletransporte al jugador (`.appear`), invocar (`.summon`), congelar/descongelar (`.freeze`), expulsar (`.kick`) e inspección (`.pinfo`). |
| **Summon** | Ayudantes y PNJs Temporales | Generación de PNJs temporales (Vendedores de suministros, comida/bebida, subastadores, banqueros e instructores de clase por facción) mediante `.npc add temp`. Botón de despawn (`.npc delete`). |
| **Server** | Telemetría y Control del Servidor | Información de hardware y uptime (`.server info`), coordenadas GPS (`.gps`), guardado forzado (`.saveall`), anuncio global (`.announce`), reinicio o apagado con ventana de confirmación. |
| **Custom** | Botones Personalizados del Administrador | Creación interactiva de botones personalizados vinculados a cualquier comando del emulador. Clic izquierdo ejecuta, clic derecho elimina con confirmación. |

---

## ⌨️ Comandos de Consola (Slash Commands)

El addon responde a los siguientes comandos de consola:

- `/admin` — Abre o cierra el panel principal de administración.
- `/admin <comando>` — Ejecuta un comando directamente sin abrir la ventana (ej: `/admin tele dalaran`).
- `/adt` — Alias corto alternativo.
- `/wpadm` — Alias oficial del ecosistema Project Jaina.
- `/wpgm` — Alias oficial para Game Masters de Project Jaina.
- `/admintools` — Comando extendido.

---

## 📦 Instalación y Requisitos

### Requisitos Previos
1. Cliente **World of Warcraft 3.3.5a (Build 12340)**.
2. Servidor basado en **AzerothCore** o **TrinityCore** con permisos GM asignados a la cuenta (Nivel de seguridad 1 a 3 en `auth.account_access`).

### Instalación
1. Clona o descarga este repositorio dentro del directorio de addons del cliente:
   ```bash
   cd "World of Warcraft/Interface/AddOns"
   git clone https://github.com/DarckRovert/Wanos_AdminTools.git AdminTools
   ```
2. Asegúrate de que la carpeta se llame exactamente `AdminTools`.
3. Inicia el cliente de juego y en la pantalla de personajes activa el addon en el menú de **Accesorios**.

---

## 🛡️ Arquitectura y Seguridad

- **Seguridad en Servidor:** El addon no otorga privilegios por sí mismo; actúa como interfaz de despacho para los comandos del core. Si una cuenta sin privilegios de GM ejecuta una acción, el emulador rechazará el comando y no aplicará ninguna modificación en el mundo.
- **Confirmación para Acciones Destructivas:** Operaciones críticas como `.server restart`, `.server shutdown` o eliminar botones personalizados requieren confirmación mediante diálogos `StaticPopup`.

---

## 🌐 Integración con el Ecosistema

Este addon es el **Módulo Oficial #20** de la infraestructura tecnológica de **Project Jaina - Project Jaina**, coexistiendo armónicamente con:
- `Wanos_GMGenie`: Suite de tickets y soporte a jugadores.
- `Wanos_IntiObjGPS`: Captura de coordenadas de GameObjects.
- `Wanos_Companion`: Bus de comunicación y telemetría comunitaria.
- `Wanos_Graphics`: Renderizado de interfaz cristalina nativa.

---

## 📜 Atribución y Licencia

- **Autor Original:** `valdrea` ([NexusMods Mod 902](https://www.nexusmods.com/worldofwarcraft/mods/902)).
- **Adaptación y Mantenimiento:** Project Jaina Dev Team (DarckRovert / Elnazzareno).
- **Licencia:** Distribuido bajo la [Licencia MIT](LICENSE).
