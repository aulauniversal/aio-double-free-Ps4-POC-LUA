# AIO Double Free Exploit (PS5/PS4) - Lua Versions

Este repositorio contiene tres variantes de un exploit basado en una condición de carrera (*double free*) en el sistema de AIO (Asynchronous I/O) de PlayStation 5 y PlayStation 4.

El exploit ha sido adaptado completamente a Lua para ser utilizado en entornos compatibles como **ArtemisLuaLoader** y **remote_lua_loader**.

---

## 📄 Archivos incluidos

### 1. `aio_double_free_5000int.lua`
- Realiza **5000 intentos secuenciales** para provocar la condición de *double free*.
- Comprueba los errores en cada intento.
- Pensado para pruebas automáticas estándar, asegurando un balance entre rapidez y estabilidad.

### 2. `aio_double_free_int_infi_debug.lua`
- Corre en **bucle infinito**, mostrando el **número de intento** en pantalla.
- Se detiene automáticamente al detectar el *double free*.
- Ideal para debugging en vivo, observando la progresión de los intentos.

### 3. `aio_double_free_direc_3874_int_mem.lua`
- Versión **ultra optimizada**:
  - **Salta directamente** hasta el intento **3874**, basado en observaciones donde suele producirse la condición de carrera de manera determinista.
  - No realiza lectura ni verificación de errores en los 3873 intentos previos.
  - Acelera enormemente el proceso de explotación.
- Perfecto para ataques rápidos y optimizados.

---

## ⚡ Cambios realizados respecto al exploit original

- **Optimización del uso de memoria**: se realiza la reserva de buffers fuera de los bucles principales para evitar agotar el *bump allocator*.
- **Mejora de la eficiencia**: opción de salto directo a la ventana de race condition observada (intento 3874 con juego AIKAGI 2 en FW 12.50).
- **Implementación de tres variantes**:
  - Estándar (5000 intentos),
  - Debugging infinito (feedback visual en cada intento),
  - Ejecución acelerada (salto inmediato a condición óptima).

---

## 👥 Créditos

Este trabajo se basa en el esfuerzo colectivo y la infraestructura proporcionada por los siguientes proyectos:

- [Gezine/ArtemisLuaLoader](https://github.com/Gezine/ArtemisLuaLoader)
- [shahrilnet/remote_lua_loader](https://github.com/shahrilnet/remote_lua_loader)
- [Master-s/remote_lua_loader](https://github.com/Master-s/remote_lua_loader)
- https://github.com/EchoStretch

Agradecimientos especiales a los desarrolladores de estas plataformas

---

## 📢 Nota final

Este repositorio tiene fines educativos e investigativos.  
No nos responsabilizamos del uso indebido de los scripts aquí presentados.

