import Foundation

enum ManayoConfig {
    static var baseURL: String {
        Bundle.main.infoDictionary?["POCKETBASE_URL"] as? String ?? ""
    }

    static var collection: String {
        Bundle.main.infoDictionary?["POCKETBASE_COLLECTION"] as? String ?? ""
    }
}
