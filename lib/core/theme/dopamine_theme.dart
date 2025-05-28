import 'package:flutter/material.dart';

// Paleta de colores dopamínica centralizada
class DopamineColors {
  static const Color primaryPurple = Color(0xFF8B5CF6); // Violeta vibrante
  static const Color secondaryPink = Color(0xFFEC4899); // Rosa fucsia
  static const Color electricBlue = Color(0xFF06B6D4); // Azul eléctrico
  static const Color successGreen = Color(0xFF10B981); // Verde vivo
  static const Color warningOrange = Color(0xFFF59E0B); // Naranja energético
  static const Color errorRed = Color(0xFFEF4444); // Rojo potente
  static const Color backgroundDark = Color(0xFF1F2937); // Fondo oscuro con personalidad
  static const Color backgroundLight = Color(0xFFF8FAFC); // Fondo claro vibrante
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF111827);
  static const Color textLight = Color(0xFFF9FAFB);
  static const Color accent1 = Color(0xFFFF6B6B); // Coral vibrante
  static const Color accent2 = Color(0xFF4ECDC4); // Turquesa brillante
  static const Color accent3 = Color(0xFFFFE66D); // Amarillo chispeante
  static const Color accent4 = Color(0xFF9B59B6); // Púrpura profundo
  static const Color accent5 = Color(0xFF3498DB); // Azul brillante
}

// Gradientes predefinidos
class DopamineGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [DopamineColors.primaryPurple, DopamineColors.secondaryPink],
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [DopamineColors.successGreen, DopamineColors.accent2],
  );
  
  static const LinearGradient warningGradient = LinearGradient(
    colors: [DopamineColors.warningOrange, DopamineColors.accent3],
  );
  
  static const LinearGradient errorGradient = LinearGradient(
    colors: [DopamineColors.errorRed, DopamineColors.accent1],
  );
  
  static const LinearGradient electricGradient = LinearGradient(
    colors: [DopamineColors.electricBlue, DopamineColors.accent5],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      DopamineColors.backgroundDark,
      Color(0xFF374151),
      DopamineColors.primaryPurple,
    ],
    stops: [0.0, 0.7, 1.0],
  );
}

// Tema principal de la aplicación
class DopamineTheme {
  static ThemeData get theme {
    return ThemeData(
      primarySwatch: _createMaterialColor(DopamineColors.primaryPurple),
      primaryColor: DopamineColors.primaryPurple,
      scaffoldBackgroundColor: DopamineColors.backgroundLight,
      fontFamily: 'Roboto',
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: DopamineColors.textDark),
        titleTextStyle: TextStyle(
          color: DopamineColors.textDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DopamineColors.primaryPurple,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: DopamineColors.primaryPurple.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // Card Theme
      cardTheme: const CardThemeData(
        color: DopamineColors.cardWhite,
        elevation: 8,
        shadowColor: Color.fromRGBO(139, 92, 246, 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: DopamineColors.textDark,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: DopamineColors.textDark,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(
          color: DopamineColors.textDark,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: DopamineColors.textDark,
          fontSize: 14,
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DopamineColors.cardWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: DopamineColors.electricBlue),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: DopamineColors.electricBlue.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: DopamineColors.primaryPurple, width: 2),
        ),
      ),
      
      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: DopamineColors.primaryPurple,
        primary: DopamineColors.primaryPurple,
        secondary: DopamineColors.secondaryPink,
        error: DopamineColors.errorRed,
        surface: DopamineColors.cardWhite,
        background: DopamineColors.backgroundLight,
      ),
    );
  }
  
  static MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}

// Widgets de utilidad con estilo dopamínico
class DopamineWidgets {
  static Widget gradientContainer({
    required Widget child,
    required LinearGradient gradient,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    EdgeInsets? margin,
    List<BoxShadow>? boxShadow,
  }) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius ?? BorderRadius.circular(15),
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
  
  static Widget dopamineCard({
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? color,
    LinearGradient? gradient,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.all(8),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? DopamineColors.cardWhite) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: DopamineColors.primaryPurple.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
  
  static Widget dopamineButton({
    required String text,
    required VoidCallback onPressed,
    LinearGradient? gradient,
    IconData? icon,
    Color? textColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? DopamineGradients.primaryGradient,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: DopamineColors.primaryPurple.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor ?? Colors.white),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 