# 📦 Guía de Instalación y Despliegue — AdminTools

[![WoW Version](https://img.shields.io/badge/WoW-3.3.5a%20(12340)-blue.svg)](https://darckrovert.github.io/ProjectJaina_Web/)
[![Repositorio](https://img.shields.io/badge/GitHub-DarckRovert%2FProjectJaina__AdminTools-black?logo=github)](https://github.com/DarckRovert/ProjectJaina_AdminTools)

## 📋 Requisitos Previos
- **Cliente:** World of Warcraft 3.3.5a (Build 12340), en español (`esES`) o inglés (`enUS`).
- **Servidor:** AzerothCore o TrinityCore (**Project Jaina — Project Jaina**).
- **Cuenta con Rango GM:** Nivel de seguridad `1` (Moderador), `2` (Game Master) o `3` (Administrador).

---

## 🚀 Instalación en el Cliente

1. **Localizar la Carpeta de Addons:**  
   Dirígete a tu directorio de instalación del juego:  
   `World of Warcraft\Interface\AddOns\`

2. **Copiar o Clonar el Addon:**  
   ```bash
   git clone https://github.com/DarckRovert/ProjectJaina_AdminTools.git AdminTools
   ```

3. **Verificación de Estructura:**  
   Asegúrate de que la ruta exacta sea:  
   `World of Warcraft\Interface\AddOns\AdminTools\AdminTools.toc`

4. **Activación:**  
   Inicia el juego, accede a la lista de personajes y en el botón **Accesorios** verifica que **Admin Tools** esté activado.

---

## 🗄️ Configuración de Permisos en la Base de Datos (Servidor)

Para que el servidor intercepte los comandos ejecutados por los botones en lugar de mostrarlos en `/say`:

1. Conéctate a la base de datos de autenticación (`auth`).
2. Asigna permisos de GM a la cuenta deseada:
   ```sql
   -- Otorgar rango de Administrador (Nivel 3) a la cuenta
   INSERT INTO account_access (id, gmlevel, RealmID) 
   VALUES ((SELECT id FROM account WHERE username = 'MI_CUENTA_GM'), 3, -1)
   ON DUPLICATE KEY UPDATE gmlevel = 3;
   ```
3. Reinicia la sesión en el cliente.
