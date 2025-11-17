# manayo

manayo es una app iOS minimalista para aprender japonés usando “cartas de hechizo” al estilo TCG.
Cada carta contiene una frase o expresión japonesa, su lectura, significado, ejemplo de uso y audio TTS.
Piensa en un deck de academia mágica… pero versión japonés práctico, casual y bonito.

## ✨ Características

- Cartas estilo Magic/Tarot con diseño limpio.
- Swipe tipo Tinder para navegar el deck (descartar, favorito, abrir lista).
- Text-to-speech nativo (ja-JP) para escuchar pronunciación real.
- Ejemplos de uso con romaji, japonés y español.
- Vista de Deck con pestañas: **Todos / Favoritos / Nuevos**.
- Modo offline completo.
- Sincronización con PocketBase cuando hay red.
- Contador de “visto X veces” + insignia “NUEVO”.
- Soporte para crear cartas manuales o generarlas con IA nativa de Apple (Foundation Models).

## 🏗 Tecnologías

- **SwiftUI** (iOS 17+ / 26+ vibes).
- **PocketBase** para almacenamiento remoto.
- **UserDefaults** para meta local (favoritos, vistos, etc.).
- **Apple Intelligence** / `FoundationModels` para sugerencias generativas.
- **AVSpeechSynthesizer** para texto a voz japonés.

## 📦 Requerimientos

- Xcode 16+
- iOS 17+ (algunas features requieren dispositivo con Apple Intelligence)
- Instancia de PocketBase con la colección `manayo_cards`.

## 🔧 Configuración

La app lee configuración desde `Info.plist`:

```xml
<key>POCKETBASE_URL</key>
<string>https://base.hckr.mx</string>

<key>POCKETBASE_COLLECTION</key>
<string>manayo_cards</string>
