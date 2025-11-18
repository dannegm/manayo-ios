import Foundation

enum ManayoConfig {
    static var baseURL: String {
        Bundle.main.infoDictionary?["POCKETBASE_URL"] as? String ?? ""
    }

    static var collection: String {
        Bundle.main.infoDictionary?["POCKETBASE_COLLECTION"] as? String ?? ""
    }
    
    static var endpointsURL: String {
        Bundle.main.infoDictionary?["ENDPOINTS_API_URL"] as? String ?? ""
    }
}
