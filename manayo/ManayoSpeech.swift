import Foundation
import AVFoundation

@MainActor
public final class ManayoSpeech {
    public static let shared = ManayoSpeech()

    private let synthesizer = AVSpeechSynthesizer()

    private init() {}

    public func speak(card: ManayoCard) {
        let text = card.kana.isEmpty ? card.jp : card.kana

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.rate = 0.45
        utterance.pitchMultiplier = 1.0

        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }
    
    public func speakUsage(card: ManayoCard) {
        guard let text = card.usage?.jp, !text.isEmpty else {
            return
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.rate = 0.45
        utterance.pitchMultiplier = 1.0

        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }

    public func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
