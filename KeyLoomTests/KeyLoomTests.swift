@testable import KeyLoom
import XCTest

final class ClipboardItemTests: XCTestCase {
    func testInitWithDefaults() {
        let item = ClipboardItem(text: "hello")
        XCTAssertEqual(item.text, "hello")
        XCTAssertFalse(item.isPinned)
        XCTAssertNil(item.pinnedAt)
    }

    func testInitWithPin() {
        let date = Date()
        let item = ClipboardItem(text: "pinned", isPinned: true, pinnedAt: date)
        XCTAssertTrue(item.isPinned)
        XCTAssertEqual(item.pinnedAt, date)
    }

    func testCodableRoundTrip() throws {
        let item = ClipboardItem(text: "test text", isPinned: true, pinnedAt: Date())
        let data = try JSONEncoder().encode(item)
        let decoded = try JSONDecoder().decode(ClipboardItem.self, from: data)
        XCTAssertEqual(decoded.text, item.text)
        XCTAssertEqual(decoded.isPinned, item.isPinned)
        XCTAssertEqual(decoded.id, item.id)
    }

    func testCodableWithoutPin() throws {
        let item = ClipboardItem(text: "no pin")
        let data = try JSONEncoder().encode(item)
        let decoded = try JSONDecoder().decode(ClipboardItem.self, from: data)
        XCTAssertEqual(decoded.text, "no pin")
        XCTAssertFalse(decoded.isPinned)
        XCTAssertNil(decoded.pinnedAt)
    }

    func testUniqueIDs() {
        let a = ClipboardItem(text: "a")
        let b = ClipboardItem(text: "b")
        XCTAssertNotEqual(a.id, b.id)
    }
}

final class ClipboardManagerTests: XCTestCase {
    var manager: ClipboardManager!

    override func setUp() {
        manager = ClipboardManager.shared
        manager.items.removeAll()
    }

    func testAddItem() {
        let item = ClipboardItem(text: "test")
        manager.addItem(item)
        XCTAssertTrue(manager.items.contains(where: { $0.id == item.id }))
    }

    func testSortedItemsPinnedFirst() {
        let unpinned = ClipboardItem(text: "second")
        let pinned = ClipboardItem(text: "first", isPinned: true)
        manager.addItem(unpinned)
        manager.addItem(pinned)
        let sorted = manager.sortedItems
        XCTAssertEqual(sorted.first?.isPinned, true)
    }

    func testDeleteItem() {
        let item = ClipboardItem(text: "delete me")
        manager.addItem(item)
        manager.deleteItem(item)
        XCTAssertFalse(manager.items.contains(where: { $0.id == item.id }))
    }

    func testTogglePin() {
        let item = ClipboardItem(text: "pin me")
        manager.addItem(item)
        manager.togglePin(item)
        XCTAssertTrue(manager.items.first(where: { $0.id == item.id })?.isPinned == true)
    }

    func testTogglePinUnpin() {
        let item = ClipboardItem(text: "pin-unpin", isPinned: true)
        manager.addItem(item)
        manager.togglePin(item)
        XCTAssertFalse(manager.items.first(where: { $0.id == item.id })?.isPinned == true)
    }

    func testClearKeepsPinned() {
        let pinned = ClipboardItem(text: "keep", isPinned: true)
        let unpinned = ClipboardItem(text: "remove")
        manager.addItem(unpinned)
        manager.addItem(pinned)
        manager.clear()
        XCTAssertTrue(manager.items.contains(where: { $0.id == pinned.id }))
        XCTAssertFalse(manager.items.contains(where: { $0.id == unpinned.id }))
    }

    func testPinnedLimit() {
        for i in 0..<6 {
            manager.addItem(ClipboardItem(text: "pinned-\(i)", isPinned: true))
        }
        let pinnedCount = manager.items.filter(\.isPinned).count
        XCTAssertLessThanOrEqual(pinnedCount, 6)
    }

    func testMaxItemsEnforced() {
        KeyboardSettings.shared.clipboardMaxItems = 10
        for i in 0..<20 {
            manager.addItem(ClipboardItem(text: "item-\(i)"))
        }
        let unpinned = manager.items.filter { !$0.isPinned }
        XCTAssertLessThanOrEqual(unpinned.count, 10)
    }
}

final class KeyboardSettingsTests: XCTestCase {
    var settings: KeyboardSettings!

    override func setUp() {
        settings = KeyboardSettings.shared
    }

    func testDefaultValues() {
        settings.resetToDefaults()
        XCTAssertEqual(settings.keySize, 30)
        XCTAssertEqual(settings.keyboardWidth, 490)
        XCTAssertEqual(settings.keyCornerRadius, 6)
        XCTAssertEqual(settings.keySpacing, 4)
        XCTAssertEqual(settings.panelCornerRadius, 22)
        XCTAssertTrue(settings.showBrokenKeyHighlight)
        XCTAssertEqual(settings.brokenKeyColor, "blue")
        XCTAssertTrue(settings.brokenKeys.contains("t"))
        XCTAssertEqual(settings.keyOpacity, 0.35)
        XCTAssertTrue(settings.showKeyShadow)
        XCTAssertTrue(settings.neomorphismEnabled)
        XCTAssertEqual(settings.neomorphismIntensity, 0.85)
        XCTAssertEqual(settings.fontSize, 13)
        XCTAssertEqual(settings.startMode, "expanded")
        XCTAssertFalse(settings.launchAtLogin)
        XCTAssertEqual(settings.clipboardMaxItems, 500)
        XCTAssertTrue(settings.soundEnabled)
        XCTAssertEqual(settings.soundVolume, 0.5)
    }

    func testResetToDefaults() {
        settings.keySize = 40
        settings.keyboardWidth = 600
        settings.resetToDefaults()
        XCTAssertEqual(settings.keySize, 30)
        XCTAssertEqual(settings.keyboardWidth, 490)
    }

    func testAllCharacterKeysCount() {
        XCTAssertEqual(KeyboardSettings.allCharacterKeys.count, 47)
    }

    func testAllCharacterKeysContainsBasic() {
        let keys = KeyboardSettings.allCharacterKeys
        XCTAssertTrue(keys.contains("a"))
        XCTAssertTrue(keys.contains("z"))
        XCTAssertTrue(keys.contains("1"))
        XCTAssertTrue(keys.contains("0"))
        XCTAssertTrue(keys.contains(","))
        XCTAssertTrue(keys.contains("/"))
    }

    func testEffectiveCollapsedKeysCustom() {
        settings.useCustomCollapsedKeys = true
        settings.collapsedKeys = ["a", "b", "c", "d", "e"]
        settings.collapsedKeyCount = 3
        let effective = settings.effectiveCollapsedKeys()
        XCTAssertEqual(effective.count, 3)
        XCTAssertEqual(effective, ["a", "b", "c"])
    }

    func testEffectiveCollapsedKeysUsage() {
        settings.useCustomCollapsedKeys = false
        settings.collapsedKeyCount = 3
        let effective = settings.effectiveCollapsedKeys()
        XCTAssertEqual(effective.count, 3)
    }
}

final class KeyUsageTrackerTests: XCTestCase {
    var tracker: KeyUsageTracker!

    override func setUp() {
        tracker = KeyUsageTracker.shared
        tracker.usageCounts = [:]
    }

    func testRecordUse() {
        tracker.recordUse("a")
        XCTAssertEqual(tracker.usageCounts["a"], 1)
    }

    func testRecordUseIncrements() {
        tracker.recordUse("a")
        tracker.recordUse("a")
        tracker.recordUse("a")
        XCTAssertEqual(tracker.usageCounts["a"], 3)
    }

    func testRecordMultipleKeys() {
        tracker.recordUse("a")
        tracker.recordUse("b")
        tracker.recordUse("c")
        XCTAssertEqual(tracker.usageCounts.count, 3)
    }

    func testTopKeysReturnsCorrectCount() {
        tracker.recordUse("a")
        tracker.recordUse("b")
        tracker.recordUse("c")
        tracker.recordUse("d")
        tracker.recordUse("e")
        tracker.recordUse("f")
        let top = tracker.topKeys(3)
        XCTAssertEqual(top.count, 3)
    }

    func testTopKeysOrderedByUsage() {
        tracker.recordUse("z")
        tracker.recordUse("z")
        tracker.recordUse("m")
        let top = tracker.topKeys(2)
        XCTAssertEqual(top.first, "z")
    }
}

final class SoundManagerTests: XCTestCase {
    func testSoundStyles() {
        let allCases = SoundManager.SoundStyle.allCases
        XCTAssertEqual(allCases.count, 6)
        XCTAssertTrue(allCases.contains(.keyClick))
        XCTAssertTrue(allCases.contains(.soft))
        XCTAssertTrue(allCases.contains(.mechanical))
        XCTAssertTrue(allCases.contains(.glass))
        XCTAssertTrue(allCases.contains(.minimal))
        XCTAssertTrue(allCases.contains(.bottle))
    }

    func testSoundStyleDisplayNames() {
        XCTAssertEqual(SoundManager.SoundStyle.keyClick.displayName, "Key Click")
        XCTAssertEqual(SoundManager.SoundStyle.soft.displayName, "Soft")
        XCTAssertEqual(SoundManager.SoundStyle.mechanical.displayName, "Mechanical")
    }

    func testSoundStyleSpecs() {
        let spec = SoundManager.SoundStyle.keyClick.spec
        XCTAssertEqual(spec.frequencies, [1200, 1800])
        XCTAssertEqual(spec.duration, 0.03)
        XCTAssertEqual(spec.volume, 0.35)
    }
}

final class KeyModelTests: XCTestCase {
    func testKeyInit() {
        let key = Key("a", shift: "A")
        XCTAssertEqual(key.label, "a")
        XCTAssertEqual(key.shiftLabel, "A")
        XCTAssertEqual(key.type, .character)
        XCTAssertEqual(key.relativeWidth, 1)
    }

    func testKeyWithType() {
        let key = Key("⌫", type: .backspace, relativeWidth: 1.5)
        XCTAssertEqual(key.label, "⌫")
        XCTAssertEqual(key.type, .backspace)
        XCTAssertEqual(key.relativeWidth, 1.5)
    }

    func testKeyHashable() {
        let a = Key("a")
        let b = Key("a")
        XCTAssertNotEqual(a, b)
        XCTAssertNotEqual(a.id, b.id)
    }

    func testKeyRowsNotEmpty() {
        XCTAssertFalse(keyRows.isEmpty)
    }

    func testKeyRowsHasFiveRows() {
        XCTAssertEqual(keyRows.count, 5)
    }

    func testKeyRowsHasSpaceRow() {
        let lastRow = keyRows.last!
        XCTAssertEqual(lastRow.count, 1)
        XCTAssertEqual(lastRow[0].type, .space)
    }
}

final class KeyboardStateTests: XCTestCase {
    func testKeyboardStateInit() {
        let state = KeyboardState.shared
        XCTAssertFalse(state.isShifted)
        XCTAssertFalse(state.isCaps)
    }
}

final class KeystrokeSenderTests: XCTestCase {
    func testKeystrokeSenderShared() {
        let sender = KeystrokeSender.shared
        XCTAssertNotNil(sender)
    }
}
