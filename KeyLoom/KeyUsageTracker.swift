import Foundation

class KeyUsageTracker: ObservableObject {
    static let shared = KeyUsageTracker()
    @Published var usageCounts: [String: Int] = [:]

    private init() {
        if let saved = UserDefaults.standard.dictionary(forKey: "keyUsageCounts") as? [String: Int] {
            usageCounts = saved
        }
    }

    func recordUse(_ key: String) {
        usageCounts[key, default: 0] += 1
        UserDefaults.standard.set(usageCounts, forKey: "keyUsageCounts")
    }

    func topKeys(_ count: Int) -> [String] {
        let allKeys = KeyboardSettings.allCharacterKeys
        let sorted = allKeys.sorted { (usageCounts[$0] ?? 0) > (usageCounts[$1] ?? 0) }
        return Array(sorted.prefix(count))
    }
}
