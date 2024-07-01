//
//  EmojiArtDocument.swift
//  Emoji Art
//
//  Created by Immanuel on 26/06/24.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static let emojiart = UTType(exportedAs: "com.example.emojiart")
}

class EmojiArtDocument: ReferenceFileDocument {
    
    func snapshot(contentType: UTType) throws -> Data {
        try emojiArt.json()
    }
    
    func fileWrapper(snapshot: Data, configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: snapshot)
    }
    
    static var readableContentTypes: [UTType] {
        [.emojiart]
    }
    
    required init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            emojiArt = try EmojiArt(json: data)
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    
    
    typealias Emoji = EmojiArt.Emoji
    
    @Published var emojiArt: EmojiArt = EmojiArt() {
        didSet {
            
            // MARK: Used before changing this project to document
            //            autosave()
            //            if emojiArt.background != oldValue.background {
            //                Task {
            //                    await fetchBackgroundImage()
            //                }
            //            }
        }
    }
    
    // MARK: Used before changing this project to document
    //    private let autosaveURL: URL = URL.documentsDirectory.appendingPathComponent("Autosaved.emojiart")
    //
    //    private func autosave() {
    //        save(to: autosaveURL)
    //        print("autosaved to \(autosaveURL)")
    //    }
    //
    //    private func save(to url: URL) {
    //        do {
    //            let data = try emojiArt.json()
    //            try data.write(to: url)
    //        } catch {
    //            print("EmojiArtDocument: error while saving \(error.localizedDescription)")
    //        }
    //    }
    
    init() {
        
        // MARK: Used before changing this project to document
        //        if let data = try? Data(contentsOf: autosaveURL),
        //           let autosavedEmojiArt = try? EmojiArt(json: data) {
        //            emojiArt = autosavedEmojiArt
        //        }
    }
    
    var emojis: [Emoji] {
        emojiArt.emojis
    }
    
    var bbox: CGRect {
        var bbox = CGRect.zero
        for emoji in emojiArt.emojis {
            bbox = bbox.union(emoji.bbox)
        }
        if let backgroundSize = background.uiImage?.size {
            bbox = bbox.union(CGRect(center: .zero, size: backgroundSize))
        }
        return bbox
    }
    
    //    var background: URL? {
    //        emojiArt.background
    //    }
    
    @Published var background: Background = .none
    
    // MARK: Background Image
    
    @MainActor
    private func fetchBackgroundImage() async {
        if let url = emojiArt.background {
            background = .fetching(url)
            do {
                let image = try await fetchUIImage(from: url)
                if url == emojiArt.background {
                    background = .found(image)
                }
            } catch {
                background = .failed("Could not set background: \(error.localizedDescription)")
            }
        } else {
            background = .none
        }
    }
    
    private func fetchUIImage(from url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)
        if let uiImage = UIImage(data: data) {
            return uiImage
        } else {
            throw FetchError.badImageData
        }
    }
    
    enum FetchError: Error {
        case badImageData
    }
    
    enum Background {
        case none
        case fetching(URL)
        case found(UIImage)
        case failed(String)
        
        var uiImage: UIImage? {
            switch self {
            case .found(let uiImage): return uiImage
            default: return nil
            }
        }
        
        var urlBeingFetched: URL? {
            switch self {
            case .fetching(let url): return url
            default: return nil
            }
        }
        
        var isFetching: Bool { urlBeingFetched != nil }
        
        var failureReason: String? {
            switch self {
            case .failed(let reason): return reason
            default: return nil
            }
        }
        
    }
    
    // MARK: Intent(s)
    
    private func undoablyPerform(_ action: String, with undoManager: UndoManager? = nil, doit: () -> Void) {
        let oldEmojiArt = emojiArt
        doit()
        undoManager?.registerUndo(withTarget: self) { myself in
            myself.undoablyPerform(action, with: undoManager) {
                myself.emojiArt = oldEmojiArt
            }
        }
        undoManager?.setActionName(action)
    }
    
    func setBackground(_ url: URL?, undoWith undoManager: UndoManager? = nil) {
        undoablyPerform("Set Background", with: undoManager) {
            emojiArt.background = url
        }
    }
    
    func addEmoji(_ emoji: String, at position: Emoji.Position, size: Int, undoWith undoManager: UndoManager? = nil) {
        undoablyPerform("Add \(emoji)", with: undoManager) {
            emojiArt.addEmoji(emoji, at: position, size: Int(size))
        }
    }
    
}

extension EmojiArt.Emoji {
    var font: Font {
        Font.system(size: CGFloat(size))
    }
    
    var bbox: CGRect {
        CGRect(
            center: position.in(nil),
            size: CGSize(width: CGFloat(size), height: CGFloat(size))
        )
    }
}

extension EmojiArt.Emoji.Position {
    func `in`(_ geometry: GeometryProxy?) -> CGPoint {
        let center = geometry?.frame(in: .local).center ?? .zero
        return CGPoint(x: center.x + CGFloat(x), y: center.y - CGFloat(y))
    }
}
