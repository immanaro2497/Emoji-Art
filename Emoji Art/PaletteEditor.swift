//
//  PaletteEditor.swift
//  Emoji Art
//
//  Created by Immanuel on 27/06/24.
//

import SwiftUI

struct PaletteEditor: View {
    
    @Binding var palette: Palette
    
    private let emojiFont = Font.system(size: 40)
    
    @State private var emojisToAdd: String = ""
    
    @FocusState private var focused: Focused?
    
    enum Focused {
        case name
        case addEmojis
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $palette.name)
                    .focused($focused, equals: .name)
            } header: {
                Text("Name")
            }
            Section {
                TextField("Add Emojis Here", text: $emojisToAdd)
                    .focused($focused, equals: .addEmojis)
                    .font(emojiFont)
                    .onChange(of: emojisToAdd) { _, emojisToAdd in
                        palette.emojis = (emojisToAdd + palette.emojis)
//                            .filter { $0.isEmoji }
                            .uniqued
                    }
                removeEmojis
            } header: {
                Text("Emojis")
            }
        }
        .frame(minWidth: 300, minHeight: 350)
        .onAppear {
            if palette.name.isEmpty {
                focused = .name
            } else {
                focused = .addEmojis
            }
        }
    }
    
    var removeEmojis: some View {
        VStack(alignment: . trailing) {
            Text("Tap to Remove Emojis").font(.caption).foregroundColor(.gray)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(palette.emojis.uniqued.map(String.init), id: \.self) { emoji in
                    Text(emoji)
                        .onTapGesture {
                            withAnimation {
                                palette.emojis.removeAll { char in
                                    char == emoji.first
                                }
                                emojisToAdd.removeAll { char in
                                    char == emoji.first
                                }
                            }
                        }
                }
            }
        }
        .font(emojiFont)
    }
    
}

#Preview {
    
    struct PaletteEditorPreview: View {
        @State private var palette = PaletteStore(named: "Preview").palettes.first!
        var body: some View {
            PaletteEditor(palette: $palette)
        }
    }
    
    return PaletteEditorPreview()
}
