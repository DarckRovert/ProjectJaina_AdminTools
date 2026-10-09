# 🛡️ Política de Seguridad y Mitigación de Vulnerabilidades — AdminTools

**Proyecto:** Ecosistema Project Jaina  
**Repositorio Oficial:** [https://github.com/DarckRovert/ProjectJaina_AdminTools](https://github.com/DarckRovert/ProjectJaina_AdminTools)

---

## 🔒 Modelo de Seguridad y Control de Acceso (RBAC)

### 1. Despacho Basado en Intercepción del Servidor
`AdminTools` actúa exclusivamente como una interfaz gráfica (GUI) de despacho de cadenas de texto. No ejecuta código privilegiado en el cliente ni elude la seguridad del emulador.
- Todos los comandos son evaluados por la tabla `rbac_account_permissions` y el nivel de seguridad del emulador (AzerothCore/TrinityCore).
- Si un usuario sin rango de GM hace clic en un botón, el emulador rechaza la ejecución del comando.

### 2. Confirmación Obligatoria para Operaciones Críticas
Comandos que comprometen la disponibilidad del reino (`.server restart`, `.server shutdown`, `.server shutdown cancel`) cuentan con cerrojos visuales mediante `StaticPopup_Show`, exigiendo confirmación explícita del operador antes del despacho.

### 3. Mitigación de Desbordamiento de Buffer
Toda cadena enviada a través de `RunCmd` es truncada a un máximo estricto de **255 bytes** (`cmd:sub(1, 255)`), previniendo saturación de paquetes de chat hacia el socket del servidor.

---

## 🚨 Reporte de Vulnerabilidades

Si detectas un comportamiento anómalo o brecha de seguridad:
- Reporte directo al Staff de Project Jaina vía Discord Privado.
- [GitHub Issues](https://github.com/DarckRovert/ProjectJaina_AdminTools/issues).
