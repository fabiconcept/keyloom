import SwiftUI

class KeyboardState: ObservableObject {
    static let shared = KeyboardState()
    @Published var isShifted: Bool = false
    @Published var isCaps: Bool = false

    private init() {
        NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            DispatchQueue.main.async {
                self?.isShifted = event.modifierFlags.contains(.shift)
            }
        }
        NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            DispatchQueue.main.async {
                self?.isShifted = event.modifierFlags.contains(.shift)
            }
            return event
        }
    }
}
