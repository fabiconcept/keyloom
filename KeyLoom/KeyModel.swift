import SwiftUI

struct Key: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let shiftLabel: String?
    let type: KeyType
    let relativeWidth: CGFloat

    init(_ label: String, shift: String? = nil, type: KeyType = .character, relativeWidth: CGFloat = 1) {
        self.label = label
        self.shiftLabel = shift
        self.type = type
        self.relativeWidth = relativeWidth
    }
}

enum KeyType { case character, space, enter, backspace, shift, caps, tab }

let keyRows: [[Key]] = [
    [
        Key("`",shift: "~"), Key("1",shift: "!"), Key("2",shift: "@"), Key("3",shift: "#"), Key("4",shift: "$"),
        Key("5",shift: "%"), Key("6",shift: "^"), Key("7",shift: "&"), Key("8",shift: "*"), Key("9",shift: "("),
        Key("0",shift: ")"), Key("-",shift: "_"), Key("=",shift: "+"),
        Key("\u{232B}", type: .backspace, relativeWidth: 1.5)
    ],
    [
        Key("\u{21E5}", type: .tab, relativeWidth: 1.5),
        Key("q",shift: "Q"), Key("w",shift: "W"), Key("e",shift: "E"), Key("r",shift: "R"), Key("t",shift: "T"),
        Key("y",shift: "Y"), Key("u",shift: "U"), Key("i",shift: "I"), Key("o",shift: "O"), Key("p",shift: "P"),
        Key("[",shift: "{"), Key("]",shift: "}"), Key("\\",shift: "|")
    ],
    [
        Key("\u{21EA}", type: .caps, relativeWidth: 1.8),
        Key("a",shift: "A"), Key("s",shift: "S"), Key("d",shift: "D"), Key("f",shift: "F"), Key("g",shift: "G"),
        Key("h",shift: "H"), Key("j",shift: "J"), Key("k",shift: "K"), Key("l",shift: "L"),
        Key(";",shift: ":"), Key("'",shift: "\""),
        Key("\u{21A9}", type: .enter, relativeWidth: 1.8)
    ],
    [
        Key("\u{21E7}", type: .shift, relativeWidth: 2.3),
        Key("z",shift: "Z"), Key("x",shift: "X"), Key("c",shift: "C"), Key("v",shift: "V"), Key("b",shift: "B"),
        Key("n",shift: "N"), Key("m",shift: "M"), Key(",",shift: "<"), Key(".",shift: ">"), Key("/",shift: "?"),
        Key("\u{21E7}", type: .shift, relativeWidth: 2.3)
    ],
    [
        Key("space", type: .space)
    ]
]
