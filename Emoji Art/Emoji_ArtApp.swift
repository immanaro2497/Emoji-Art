//
//  Emoji_ArtApp.swift
//  Emoji Art
//
//  Created by Immanuel on 26/06/24.
//

import SwiftUI

@main
struct Emoji_ArtApp: App {
    
//    @StateObject var defaultDocument = EmojiArtDocument()
//    @StateObject var paletteStore = PaletteStore(named: "Main")
//    @StateObject var store2 = PaletteStore(named: "Alternate")
//    @StateObject var store3 = PaletteStore(named: "Special")
    
    var body: some Scene {
        DocumentGroup(newDocument: {
            EmojiArtDocument()
        }, editor: { config in
            EmojiArtDocumentView(document: config.document)
//                .environmentObject(paletteStore)
        })
        
        // MARK: Used before changing this project to document
//        WindowGroup {
//            PaletteManager(stores: [paletteStore, store2, store3])
//            EmojiArtDocumentView(document: defaultDocument)
//                .environmentObject(paletteStore)
//        }
    }
}
