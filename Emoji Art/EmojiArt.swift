//
//  EmojiArt.swift
//  Emoji Art
//
//  Created by Immanuel on 26/06/24.
//

import Foundation

struct EmojiArt: Codable {
    
    var background: URL?
    private(set) var emojis = [Emoji]()
    
    func json() throws -> Data {
        let encoded = try JSONEncoder().encode(self)
        print("EmojiArt = \(String(data: encoded, encoding: .utf8) ?? "nil")")
        return encoded
    }
    
    init(json: Data) throws {
        self = try JSONDecoder().decode(EmojiArt.self, from: json)
    }
    
    init() {
        
    }
    
    private var uniqueEmojiId = 0
    
    mutating func addEmoji(_ emoji: String, at position: Emoji.Position, size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(
            string: emoji,
            position: position,
            size: size,
            id: uniqueEmojiId
        ))
    }
    
    struct Emoji: Identifiable, Codable {
        
        let string: String
        var position: Position
        var size: Int
        var id: Int
        
        struct Position: Codable {
            
            var x: Int
            var y: Int
            
            static let zero = Self(x: 0, y: 0)
            
        }
        
    }
    
}
