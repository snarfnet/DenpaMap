import Foundation
import Network
import CoreTelephony

class NetworkMeasurer {
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")

    var currentNetworkType: String = "Unknown"
    var isConnected: Bool = false

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied

            if path.usesInterfaceType(.wifi) {
                self?.currentNetworkType = "WiFi"
            } else if path.usesInterfaceType(.cellular) {
                self?.currentNetworkType = self?.getCellularType() ?? "Cellular"
            } else if path.usesInterfaceType(.wiredEthernet) {
                self?.currentNetworkType = "Ethernet"
            } else {
                self?.currentNetworkType = "Unknown"
            }
        }
        monitor.start(queue: monitorQueue)
    }

    private func getCellularType() -> String {
        let info = CTTelephonyNetworkInfo()
        guard let radioType = info.serviceCurrentRadioAccessTechnology?.values.first else {
            return "Cellular"
        }
        switch radioType {
        case CTRadioAccessTechnologyNR, CTRadioAccessTechnologyNRNSA:
            return "5G"
        case CTRadioAccessTechnologyLTE:
            return "LTE"
        case CTRadioAccessTechnologyWCDMA, CTRadioAccessTechnologyHSDPA, CTRadioAccessTechnologyHSUPA:
            return "3G"
        case CTRadioAccessTechnologyEdge, CTRadioAccessTechnologyGPRS:
            return "2G"
        default:
            return "Cellular"
        }
    }

    func getSSID() -> String? {
        // NEHotspotNetwork requires entitlement; return nil for now
        return nil
    }

    /// Measure latency and download speed
    func measure() async -> (latencyMs: Double, speedMbps: Double) {
        let latency = await measureLatency()
        let speed = await measureDownloadSpeed()
        return (latency, speed)
    }

    private func measureLatency() async -> Double {
        let url = URL(string: "https://www.apple.com/library/test/success.html")!
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 10

        let start = CFAbsoluteTimeGetCurrent()
        do {
            let _ = try await URLSession.shared.data(for: request)
            let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
            return elapsed
        } catch {
            return 9999
        }
    }

    private func measureDownloadSpeed() async -> Double {
        // Download ~100KB file to measure speed
        let url = URL(string: "https://www.apple.com/v/home/takeover/d/built-in-background/large_2x.jpg")!
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 15

        let start = CFAbsoluteTimeGetCurrent()
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let elapsed = CFAbsoluteTimeGetCurrent() - start
            if elapsed > 0 {
                let bytesPerSec = Double(data.count) / elapsed
                return bytesPerSec * 8 / 1_000_000 // Convert to Mbps
            }
            return 0
        } catch {
            return 0
        }
    }

    deinit {
        monitor.cancel()
    }
}
