# Deslizas - El Juego de las Palabras

Una aplicación móvil inspirada en el juego "Password" en su versión española, adaptada para dispositivos móviles. El objetivo del juego es que un jugador vea una lista de 5 palabras, y su compañero debe adivinarlas a partir de pistas verbales.

## 🎮 Características

- **Juego de 5 palabras por ronda**: Cada partida presenta exactamente 5 palabras para adivinar
- **Sistema de categorías**: Elige entre 7 categorías diferentes o juega con palabras mixtas
- **Gestos intuitivos**: Desliza hacia la derecha si aciertan, hacia la izquierda si fallan
- **Sistema de estadísticas**: Seguimiento del progreso, mejor puntuación y promedio
- **Monetización opcional**: Anuncios intersticiales cada 3 rondas (eliminables con donación)
- **Almacenamiento persistente**: Las estadísticas y preferencias se guardan localmente
- **Configuraciones personalizables**: Ajusta la experiencia de juego a tu gusto
- **Interfaz moderna**: Diseño minimalista y amigable

## 📂 Categorías Disponibles

1. **🐾 Animales**: Perros, gatos, elefantes, y más fauna
2. **🏠 Objetos**: Muebles, vehículos, y objetos cotidianos
3. **🍎 Comida**: Frutas, platos, bebidas, y alimentos
4. **👨‍⚕️ Profesiones**: Médicos, profesores, artistas, y oficios
5. **⚽ Deportes**: Fútbol, tenis, natación, y actividades físicas
6. **🎨 Colores**: Rojo, azul, verde, y toda la paleta cromática
7. **😊 Emociones**: Alegría, tristeza, amor, y sentimientos
8. **🎲 Categoría Mixta**: Palabras de todas las categorías mezcladas

## 🏗️ Arquitectura

El proyecto utiliza **Arquitectura Limpia (Clean Architecture)** simplificada:

```
src/
├── core/
│   ├── password/          # Lógica de dominio del juego
│   │   ├── Round.ts       # Entidad de ronda
│   │   ├── RoundService.ts # Servicio de rondas
│   │   └── WordRepository.ts # Repositorio de palabras con categorías
│   ├── ads/               # Lógica de monetización
│   │   └── AdsService.ts  # Servicio de anuncios
│   ├── storage/           # Persistencia de datos
│   │   └── StorageService.ts # Servicio de almacenamiento
│   └── presentation/      # PLoC (Presentation Logic)
│       └── RoundPloc.ts   # Orquestador de estado
└── ui/
    └── screens/           # Pantallas de la aplicación
        ├── HomeScreen.tsx      # Pantalla principal
        ├── CategoryScreen.tsx  # Selección de categorías
        ├── GameScreen.tsx      # Pantalla de juego
        ├── StatsScreen.tsx     # Estadísticas detalladas
        └── SettingsScreen.tsx  # Configuraciones
```

## 🚀 Instalación

### Prerrequisitos

- Node.js (versión 16 o superior)
- React Native CLI
- Android Studio (para Android) o Xcode (para iOS)
- Un dispositivo físico o emulador

### Pasos de instalación

1. **Clonar el repositorio**
   ```bash
   git clone <url-del-repositorio>
   cd deslizas
   ```

2. **Instalar dependencias**
   ```bash
   npm install
   ```

3. **Configurar el entorno de React Native**
   
   Para Android:
   ```bash
   npx react-native run-android
   ```
   
   Para iOS:
   ```bash
   cd ios && pod install && cd ..
   npx react-native run-ios
   ```

## 🎯 Cómo jugar

1. **Inicio**: Desde la pantalla principal, elige entre:
   - **Elegir categoría**: Selecciona una categoría específica
   - **Juego rápido**: Juega con palabras mixtas de todas las categorías

2. **Selección de categoría**: 
   - Explora las 7 categorías disponibles
   - Ve una vista previa de las palabras de cada categoría
   - Elige "Categoría Mixta" para mayor variedad

3. **Gameplay**: 
   - Se muestra una palabra en el centro de la pantalla
   - Un jugador da pistas verbales sobre la palabra
   - El otro jugador intenta adivinar
   - **Desliza hacia la derecha** si acierta la palabra
   - **Desliza hacia la izquierda** si falla

4. **Progreso**: 
   - Completa las 5 palabras de la ronda
   - Ve tu progreso en tiempo real
   - Observa la lista de palabras con resultados

5. **Resultados**: Al final se muestra tu puntuación y puedes iniciar una nueva ronda

## 📊 Características técnicas

### Gestión de estado
- **PLoC Pattern**: Presentation Logic Component para manejar el estado de la UI
- **Observer Pattern**: Suscripción a cambios de estado
- **Sin frameworks externos**: No usa Redux ni MobX

### Persistencia
- **AsyncStorage**: Almacenamiento local de estadísticas y preferencias
- **Datos persistentes**: Rondas jugadas, mejor puntuación, estado de donación

### Monetización
- **Anuncios intersticiales**: Se muestran cada 3 rondas
- **Sistema de donaciones**: Elimina anuncios permanentemente
- **Lógica condicional**: Los donadores no ven anuncios

### Navegación
- **React Navigation**: Stack navigator para las pantallas
- **Transiciones suaves**: Animaciones personalizadas entre pantallas

### Sistema de categorías
- **7 categorías temáticas**: Organizadas por tipo de palabra
- **Categoría mixta**: Combina todas las categorías
- **Selección flexible**: Elige la experiencia que prefieras

## 🧪 Testing

Ejecutar los tests unitarios:

```bash
npm test
```

Los tests cubren:
- Lógica de dominio (Round, AdsService, WordRepository)
- Sistema de categorías
- Casos edge y validaciones
- Comportamiento de los servicios

## 📱 Pantallas

### Pantalla de Inicio
- Resumen de estadísticas personales
- Botón para elegir categoría
- Opción de juego rápido (mixto)
- Acceso a estadísticas y configuración
- Opción de donación

### Pantalla de Categorías
- Lista de 7 categorías temáticas
- Vista previa de palabras por categoría
- Opción de categoría mixta destacada
- Contador de palabras por categoría

### Pantalla de Juego
- Palabra actual en el centro
- Indicador de categoría seleccionada
- Barra de progreso (X/5)
- Lista de palabras de la ronda con resultados
- Reconocimiento de gestos de deslizamiento
- Feedback visual (colores verde/rojo)

### Pantalla de Estadísticas
- Resumen general de partidas
- Métricas de rendimiento con niveles
- Progreso visual con barras
- Estado de donación
- Opciones para reiniciar datos

### Pantalla de Configuración
- Configuraciones de audio y vibración (próximamente)
- Opciones de experiencia de juego
- Información de la aplicación
- Opción para reiniciar todos los datos

## 🎨 Diseño

### Paleta de colores
- **Primario**: #4A90E2 (Azul)
- **Éxito**: #27AE60 (Verde)
- **Error**: #E74C3C (Rojo)
- **Advertencia**: #F39C12 (Naranja)
- **Texto**: #2C3E50 (Gris oscuro)
- **Fondo**: #F8F9FA (Gris claro)

### Principios de UX
- **Minimalismo**: Interfaz limpia y sin distracciones
- **Feedback inmediato**: Respuesta visual a todas las acciones
- **Accesibilidad**: Textos legibles y contrastes adecuados
- **Gestos intuitivos**: Deslizamiento natural para las acciones principales
- **Organización clara**: Categorías bien definidas y fáciles de navegar

## 🔧 Configuración de desarrollo

### Scripts disponibles

```bash
npm start          # Iniciar Metro bundler
npm run android    # Ejecutar en Android
npm run ios        # Ejecutar en iOS
npm test           # Ejecutar tests
npm run lint       # Verificar código con ESLint
```

### Estructura de archivos de configuración

- `package.json`: Dependencias y scripts
- `tsconfig.json`: Configuración de TypeScript
- `babel.config.js`: Configuración de Babel
- `metro.config.js`: Configuración de Metro bundler

## 🚀 Próximas mejoras

- [x] ✅ Categorías de palabras (animales, objetos, etc.)
- [x] ✅ Pantalla de configuraciones
- [x] ✅ Sistema de navegación mejorado
- [ ] Modo multijugador online
- [ ] Sonidos y efectos de audio
- [ ] Vibración en gestos
- [ ] Temas visuales personalizables
- [ ] Integración con redes sociales
- [ ] Sistema de logros y badges
- [ ] Palabras personalizadas por el usuario
- [ ] Modo de dificultad variable
- [ ] Temporizador opcional
- [ ] Modo de práctica individual

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 👨‍💻 Autor

Desarrollado con ❤️ para la comunidad de jugadores de palabras.

---

¿Tienes preguntas o sugerencias? ¡Abre un issue en el repositorio! 