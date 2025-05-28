# Deslizas - El Juego de las Palabras

Una aplicación móvil inspirada en el juego "Password" en su versión española, adaptada para dispositivos móviles. El objetivo del juego es que un jugador vea una lista de 5 palabras, y su compañero debe adivinarlas a partir de pistas verbales.

## 🎮 Características

* **Juego de 5 palabras por ronda**: Cada partida presenta exactamente 5 palabras para adivinar
* **Sistema de categorías**: Elige entre 7 categorías diferentes o juega con palabras mixtas
* **Gestos intuitivos**: Desliza hacia la derecha si aciertan, hacia la izquierda si fallan
* **Sistema de estadísticas**: Seguimiento del progreso, mejor puntuación y promedio
* **Modo por equipos**: Hasta 6 equipos, con rondas y tiempos configurables
* **Monetización opcional**: Anuncios intersticiales cada 3 rondas (eliminables con donación)
* **Almacenamiento persistente**: Las estadísticas y preferencias se guardan localmente
* **Configuraciones personalizables**: Ajusta la experiencia de juego a tu gusto
* **Interfaz moderna**: Diseño minimalista y amigable

## 📂 Categorías Disponibles

1. **🐾 Animales**
2. **🏠 Objetos**
3. **🍎 Comida**
4. **👨‍⚕️ Profesiones**
5. **⚽ Deportes**
6. **🎨 Colores**
7. **😊 Emociones**
8. **🎲 Categoría Mixta**

## 🏗️ Arquitectura

El proyecto utiliza **Arquitectura Limpia (Clean Architecture)** simplificada y un enfoque de gestión de estado basado en **PLoC (Presentation Logic Component)**:

```
src/
├── core/
│   ├── password/          # Lógica de dominio del juego
│   │   ├── Round.dart
│   │   ├── RoundService.dart
│   │   └── WordRepository.dart
│   ├── ads/
│   │   └── AdsService.dart
│   ├── storage/
│   │   └── StorageService.dart
│   └── presentation/
│       ├── RoundPloc.dart
│       ├── TeamPloc.dart
│       └── SettingsPloc.dart
└── ui/
    └── screens/
        ├── HomeScreen.dart
        ├── CategoryScreen.dart
        ├── GameScreen.dart
        ├── StatsScreen.dart
        ├── SettingsScreen.dart
        ├── TeamSetupScreen.dart
        ├── TeamTransitionScreen.dart
        └── TeamResultsScreen.dart
```

### 🧠 Gestión de Estado con PLoC (Presentation Logic Component)

La lógica de presentación y el estado de la aplicación están organizados siguiendo el patrón **PLoC**, una implementación ligera y limpia inspirada en el patrón BLoC, pero sin el uso de streams ni paquetes externos.

* 🔹 **Sin dependencias externas**
* 🔹 **Estados inmutables y encapsulados**
* 🔹 **Separación clara de UI y lógica**
* 🔹 **Testable y escalable**

Componentes clave:

* `RoundPloc`: Orquesta el estado del juego por ronda
* `TeamPloc`: Gestiona rotación de equipos, puntuaciones y transición
* `SettingsPloc`: Controla configuraciones de juego
* `AdsPloc`: Lógica de anuncios y donaciones

## 🧪 Modo por Equipos

1. **Configuración de Equipos**

   * 2 a 6 equipos
   * Nombre personalizable
   * Color único asignado automáticamente
   * Puntuación inicial de 0
   * Configuración de rondas (1-5), tiempo por ronda (15-90 s), categoría

2. **Pantalla de Juego en Modo Equipos**

   * Nombre del equipo
   * Color y ronda actual
   * Temporizador con cuenta regresiva
   * Barra de progreso (X/5 palabras)
   * Puntuaciones en tiempo real
   * Transición automática al siguiente equipo

3. **Pantalla de Transición entre Equipos**

   * Instrucciones para pasar el dispositivo
   * Información del siguiente equipo y ronda
   * Botón para comenzar

4. **Pantalla de Resultados**

   * Podio y clasificación completa
   * Puntuación final de cada equipo
   * Opciones para jugar de nuevo o volver al inicio

5. **Gestión del Juego por Equipos**

   * Control de rotación, rondas, puntuaciones, ganador
   * Estado persistente y robusto

6. **Acceso desde la Pantalla Principal**

   * Juego rápido con 2 equipos
   * Opción de configuración avanzada de equipos

## 📊 Características técnicas

### Persistencia

* **SharedPreferences** o **Hive** (según configuración)
* Almacenamiento local de estadísticas y preferencias

### Monetización

* Anuncios intersticiales cada 3 rondas
* Donaciones que desactivan anuncios
* Control lógico desde `AdsService`

### Navegación

* Sistema de rutas con navegación anidada
* Transiciones animadas entre pantallas

## 📱 Pantallas principales

* **Inicio**: Accesos a modo rápido, configuraciones y estadísticas
* **Categorías**: Vista previa y selección
* **Juego**: Interacción por gestos con feedback visual
* **Equipos**: Transición de rondas, marcador, resultados finales
* **Estadísticas**: Datos por sesión y progreso global
* **Configuración**: Preferencias generales

## 🎯 Cómo jugar

1. Elige una categoría o modo rápido
2. Mira la palabra y da pistas verbales
3. El compañero intenta adivinar
4. Desliza:

   * 👉 Acierto: Derecha
   * 👈 Fallo: Izquierda
5. Pasa al siguiente equipo cuando acabe el tiempo o las palabras

##importante
por ahora no implementar servicios de anuncios, prueba el código siempre antes de terminar la ejecución 
## 🚀 Próximas mejoras

* [x] Categorías de palabras
* [x] Pantalla de configuración
* [x] Juego por equipos
* [ ] Sonidos y vibración
* [ ] Personalización de palabras y temas
* [ ] Modo de dificultad y práctica

## como ejecutar
usar el comando flutter run -d chrome

## 🤝 Contribuir

1. Fork
2. Rama con feature
3. Pull request

## 📄 Licencia

MIT

## 👨‍💻 Autor

Desarrollado con ❤️ para la comunidad hispanohablante
<!--  -->