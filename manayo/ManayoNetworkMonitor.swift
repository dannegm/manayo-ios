import Foundation
import Network

@MainActor
public final class ManayoNetworkMonitor: ObservableObject {
    public static let shared = ManayoNetworkMonitor()

    @Published public private(set) var isOnline: Bool = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "manayo.network.monitor")

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isOnline = (path.status == .satisfied)
            }
        }
        monitor.start(queue: queue)
    }
}
