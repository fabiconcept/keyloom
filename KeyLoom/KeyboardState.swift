import AppKit

class KeyboardState: ObservableObject {
    static let shared = KeyboardState()
    @Published var isShifted: Bool = false
    @Published var isCaps: Bool = false

    private init() {
        let flags = NSEvent.modifierFlags
        isShifted = flags.contains(.shift)
        isCaps = flags.contains(.capsLock)

        NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            DispatchQueue.main.async {
                self?.isShifted = event.modifierFlags.contains(.shift)
                self?.isCaps = event.modifierFlags.contains(.capsLock)
            }
        }
        NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            DispatchQueue.main.async {
                self?.isShifted = event.modifierFlags.contains(.shift)
                self?.isCaps = event.modifierFlags.contains(.capsLock)
            }
            return event
        }
    }
}
