# Manayō

Manayō es una app iOS minimalista para aprender japonés usando “cartas de hechizo” al estilo TCG.
Cada carta contiene una frase o expresión japonesa, su lectura, significado, ejemplo de uso y audio TTS.
Piensa en un deck de academia mágica… pero versión japonés práctico, casual y bonito.

🌸 ¿Por qué se llama Manayō?

El nombre Manayō nació en una de esas conversaciones donde el japonés y la creatividad se mezclan sin pedir permiso.
Al principio solo buscábamos algo que sonara a juego de palabras entre mana (la energía mágica en los TCG) y yomi (leer, entender). Algo tipo “cartas de hechizo, pero para aprender japonés”.

Mientras jugueteábamos con ideas —y de paso inventábamos cartas falsas que sonaban a conjuros— apareció la palabra 真名 (mana): que significa “nombre verdadero”.
Ese concepto nos encantó: el “nombre verdadero” como símbolo de poder, de significado profundo… justo lo que queríamos transmitir con cada carta: pequeñas palabras japonesas con alma propia.

Luego vino la última chispa: estirar la ‘o’ final con macron (ō) para darle ese sabor lingüístico-nipón que tanto nos gusta.
Y así, entre vibecoding y un par de risas de por medio, quedó bautizado:

Manayō — las palabras como magia.

*Y sí, esto fue generado por **Luna**, la IA de este prodigioso dev.*

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
