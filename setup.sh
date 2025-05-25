#!/bin/bash

echo "🎮 Configurando Deslizas - El Juego de las Palabras"
echo "=================================================="

# Verificar si Node.js está instalado
if ! command -v node &> /dev/null; then
    echo "❌ Node.js no está instalado. Por favor, instala Node.js primero."
    exit 1
fi

# Verificar si npm está instalado
if ! command -v npm &> /dev/null; then
    echo "❌ npm no está instalado. Por favor, instala npm primero."
    exit 1
fi

echo "✅ Node.js y npm detectados"

# Instalar dependencias
echo "📦 Instalando dependencias..."
npm install

if [ $? -eq 0 ]; then
    echo "✅ Dependencias instaladas correctamente"
else
    echo "❌ Error al instalar dependencias"
    exit 1
fi

# Verificar si React Native CLI está instalado globalmente
if ! command -v react-native &> /dev/null; then
    echo "📱 Instalando React Native CLI..."
    npm install -g react-native-cli
fi

echo ""
echo "🎉 ¡Configuración completada!"
echo ""
echo "Para ejecutar la aplicación:"
echo "  Android: npm run android"
echo "  iOS:     npm run ios"
echo ""
echo "Para ejecutar tests:"
echo "  npm test"
echo ""
echo "¡Disfruta jugando Deslizas! 🎮" 