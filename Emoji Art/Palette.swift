//
//  Palette.swift
//  Emoji Art
//
//  Created by Immanuel on 27/06/24.
//

import Foundation

struct Palette: Identifiable, Codable, Hashable {
    var name: String
    var emojis: String
    var id = UUID()
    
    static var builtins: [Palette] { [
        Palette(name: "Vehicles", emojis: "🚗🚕🚙🚌🚎🏎️🚓"),
        Palette(name: "Sports", emojis: "⚽️🏀🏈⚾️🥎🎾🏐"),
        Palette(name: "Music", emojis: "🪇🎹🥁🪘🎷🎺🪗"),
        Palette(name: "Animals", emojis: "🐘🦛🦏🐪🦒🐅🦈🦓"),
        Palette(name: "Animal faces", emojis: "🐶🐱🐭🐹🐰🦊🐻"),
        Palette(name: "Flora", emojis: "🌵🎄🌲🌳🌴🪵🌱"),
        Palette(name: "Weather", emojis: "☀️🌤️⛅️🌥️☁️🌦️🌧️⛈️🌩️🌨️"),
        Palette(name: "People", emojis: "🚶‍♀️🚶🚶‍♂️🏃‍♀️🏃"),
    ] }
    
}
