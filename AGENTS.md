# 🤖 Directrices de Ingeniería y Restricciones para Agentes IA — AdminTools

**Addon:** `AdminTools` (`WoWPeru_AdminTools`)  
**Repositorio Oficial:** [https://github.com/DarckRovert/WoWPeru_AdminTools](https://github.com/DarckRovert/WoWPeru_AdminTools)  
**Motor Gráfico y Runtime:** WoW 3.3.5a WotLK (Build 12340) / Lua 5.1 (Blizzard VM)

---

## ⚠️ Reglas Inquebrantables del Motor 3.3.5a

Al inspeccionar, mantener o refactorizar este addon, cualquier ingeniero o agente de IA debe cumplir obligatoriamente las siguientes restricciones:

### 1. APIs Prohibidas de Retail (Inexistentes en 3.3.5a)
- ❌ **`SetColorTexture(r, g, b, a)`:** NO existe en 3.3.5a. Usar `texture:SetTexture("Interface\\Buttons\\WHITE8X8")` y `SetVertexColor`.
- ❌ **`C_Timer.After(sec, func)`:** NO existe. Utilizar Frame invisible con acumulador `OnUpdate`.
- ❌ **`IsInRaid()` / `IsInGroup()`:** NO existen en 3.3.5a. Usar `GetNumRaidMembers() > 0` o `GetNumPartyMembers() > 0`.
- ❌ **`GROUP_ROSTER_UPDATE`:** NO existe en WotLK. Usar `RAID_ROSTER_UPDATE` y `PARTY_MEMBERS_CHANGED`.

### 2. Normas Tipográficas y de Glifos (Cero Errores `?`)
- ❌ **Prohibido el uso de emojis Unicode o caracteres > U+024F:** La fuente `FRIZQT__.TTF` de Blizzard 3.3.5a carece de glifos modernos (como `▼`, `—`, `✨`).
- ✅ **Solución:** Utilizar caracteres alfanuméricos ASCII o símbolos estándar en rango Latin-1 (`v`, `-`, `·`).

### 3. Normas de Despacho y Red
- **Longitud Máxima de Comandos:** Todo comando enviado vía `SendChatMessage` no debe exceder los **255 bytes**.
- **Sin Dependencias de Retail:** Mantener compatibilidad exclusiva con el binario `Wow.exe` Build 12340.
