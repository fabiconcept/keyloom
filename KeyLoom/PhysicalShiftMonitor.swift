import AppKit

class PhysicalShiftMonitor: ObservableObject {
    static let shared = PhysicalShiftMonitor()
    @Published var isPhysicalShiftDown = false
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    private init() {
        startMonitoring()
    }

    private func startMonitoring() {
        let eventMask: CGEventMask = (1 << CGEventType.flagsChanged.rawValue)
        var selfRef = Unmanaged.passUnretained(self).toOpaque()

        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: { _, _, event, ref -> Unmanaged<CGEvent>? in
                guard let ref = ref else { return Unmanaged.passUnretained(event) }
                let monitor = Unmanaged<PhysicalShiftMonitor>.fromOpaque(ref).takeUnretainedValue()
                let flags = event.flags
                let isShift = flags.contains(.maskShift)
                DispatchQueue.main.async {
                    monitor.isPhysicalShiftDown = isShift
                }
                return Unmanaged.passUnretained(event)
            },
            userInfo: &selfRef
        ) else { return }

        self.eventTap = eventTap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }

    deinit {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            if let source = runLoopSource {
                CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
            }
        }
    }
}
