Estoy desarrollando una aplicación móvil inspirada en el juego “Password” en su versión española, adaptada para móviles. El objetivo del juego es que un jugador vea una lista de 5 palabras, y su compañero debe adivinarlas a partir de pistas verbales. Quien da las pistas desliza hacia la derecha si su compañero ha acertado la palabra, o hacia la izquierda si falla. No existe la opción de “pasar palabra”. Al final se muestra un resumen de aciertos.

### Requisitos funcionales:

* El juego muestra siempre 5 palabras.
* Se validan individualmente con gestos (swipe right = acierto, swipe left = fallo).
* Al finalizar, se muestra la cantidad de aciertos.
* Los anuncios intersticiales se muestran cada 3 rondas si el usuario no ha donado.
* Al inicio de la app, el usuario puede donar para desbloquear la versión sin anuncios.

### Requisitos técnicos:

* El proyecto está basado en **React Native**.
* Uso de **Arquitectura Limpia (Clean Architecture)** simplificada, sin interfaces, dividida en:

  * `core/password`: lógica de dominio y servicio del juego.
  * `core/ads`: lógica de monetización y control de anuncios.
  * `core/presentation`: PLoC (estado y lógica de presentación).
  * `ui/screens`: pantallas de la app.
* No se usan interfaces para simplificar.
* No se usan frameworks de gestión de estado externo como Redux ni Bloc.

### Código existente:

Ya tengo la base generada con las siguientes archivos clave:

* `Round.ts`: clase de dominio que representa una ronda de 5 palabras.
* `RoundService.ts`: genera una nueva ronda con palabras.
* `WordRepository.ts`: simula la obtención de palabras.
* `AdsService.ts`: maneja cuándo mostrar anuncios.
* `RoundPloc.ts`: orquesta el estado del juego.
* `GameScreen.tsx`: componente que representa la partida con reconocimiento de gestos.

### ¿Qué necesito?

Ayúdame a mejorar y continuar esta aplicación. Algunas ideas para comenzar:

1. Añadir almacenamiento local persistente de las rondas jugadas y donaciones (por ejemplo, usando `AsyncStorage`).
2. Añadir una pantalla de inicio que permita:

   * Iniciar partida.
   * Donar y eliminar anuncios.
3. Reorganizar o refactorizar cualquier parte que puedas optimizar.
4. Agregar test unitarios básicos al core.
5. Agregar navegación (con React Navigation).
6. Sugerir mejoras visuales (estilo minimalista, colores amigables, etc).
