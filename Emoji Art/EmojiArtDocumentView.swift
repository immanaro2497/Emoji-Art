//
//  EmojiArtDocumentView.swift
//  Emoji Art
//
//  Created by Immanuel on 26/06/24.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    
    @StateObject var paletteStore = PaletteStore(named: "Shared")
    @ObservedObject var document: EmojiArtDocument
//    @EnvironmentObject var store: PaletteStore
    @Environment(\.undoManager) var undoManager
    
    //    private let emojis = "☠️🍭👻🕸️🧙😱😤🫥👺⁉️🙀💀😈🎃😀🐢👋⛔️🥲🏁"
    // MARK: @ScaledMetric scales the value. so when font size is changed in settings the dependent font also scales
    @ScaledMetric private var paletteEmojiSize: CGFloat = 40
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            PaletteChooser()
                .font(.system(size: paletteEmojiSize))
                .padding(.horizontal)
                .scrollIndicators(.hidden)
        }
        .toolbar {
            UndoButton()
        }
        .environmentObject(paletteStore)
    }
    
    private var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                if document.background.isFetching {
                    ProgressView()
                        .scaleEffect(2)
                        .tint(.blue)
                        .position (EmojiArt.Emoji.Position.zero.in(geometry))
                }
                documentContents(in: geometry)
                    .scaleEffect(zoom * gestureZoom)
                    .offset(pan + gesturePan)
            }
            .onTapGesture (count: 2) {
                zoomToFit(document.bbox, in: geometry)
            }
            .gesture(panGesture.simultaneously(with: zoomGesture))
            .dropDestination(for: Sturldata.self) { sturldatas, location in
                return drop(sturldatas, at: location, in: geometry)
            }
            .onChange(of: document.background.failureReason) { _, reason in
                showBackgroundFailureAlert = reason != nil
            }
            .onChange (of: document.background.uiImage) { _, uiImage in
                zoomToFit(uiImage?.size, in: geometry)
            }
            .alert(
                "Set Background",
                isPresented: $showBackgroundFailureAlert,
                presenting: document.background.failureReason,
                actions: { reason in
                    Button("OK", role: .cancel) {}
                },
                message: { reason in
                    Text(reason)
                }
            )
        }
    }
    
    private func zoomToFit(_ size: CGSize?, in geometry: GeometryProxy) {
        if let size {
            zoomToFit(CGRect(center: .zero, size: size), in: geometry)
        }
    }
    
    private func zoomToFit(_ rect: CGRect, in geometry: GeometryProxy) {
        withAnimation {
            if rect.size.width > 0, rect.size.height > 0,
               geometry.size.width > 0, geometry.size.height > 0 {
                let hZoom = geometry.size.width / rect.size.width
                let vZoom = geometry.size.height / rect.size.height
                zoom = min(hZoom, vZoom)
                pan = CGOffset(
                    width: -rect.midX * zoom,
                    height: -rect.midY * zoom
                )
            }
        }
    }
    
    @State private var showBackgroundFailureAlert = false
    
    @State private var zoom: CGFloat = 1
    @GestureState private var gestureZoom: CGFloat = 1
    
    @State private var pan: CGOffset = .zero
    @GestureState private var gesturePan: CGOffset = .zero
    
    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .updating($gestureZoom, body: { inMotionPinchScale, gestureZoom, _ in
                gestureZoom = inMotionPinchScale
            })
            .onEnded { endingPinchScale in
                zoom *= endingPinchScale
            }
    }
    
    private var panGesture: some Gesture {
        DragGesture()
            .updating($gesturePan, body: { value, gesturePan, _ in
                gesturePan = value.translation
            })
            .onEnded { value in
                pan += value.translation
            }
    }
    
    @ViewBuilder
    private func documentContents(in geometry: GeometryProxy) -> some View {
//        AsyncImage(url: document.background) { phase in
//            if let image = phase.image {
//                image
//            } else if let url = document.background {
//                if phase.error != nil {
//                    Text("\(url)" )
//                } else {
//                    ProgressView()
//                }
//            }
//        }
        if let uiImage = document.background.uiImage {
            Image(uiImage: uiImage)
                .position(EmojiArt.Emoji.Position.zero.in(geometry))
        }
        ForEach(document.emojis) { emoji in
            Text(emoji.string)
                .font(emoji.font)
                .position(emoji.position.in(geometry))
        }
    }
    
    private func drop(_ sturldatas: [Sturldata], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        for sturldata in sturldatas {
            switch sturldata {
            case .url(let url):
                document.setBackground(url, undoWith: undoManager)
                return true
            case .string(let emoji):
                document.addEmoji(
                    emoji,
                    at: emojiPosition(at: location, in: geometry),
                    size: Int(paletteEmojiSize / zoom),
                    undoWith: undoManager
                )
                return true
            default:
                break
            }
        }
        return false
    }
    
    private func emojiPosition(at location: CGPoint, in geometry: GeometryProxy) -> EmojiArt.Emoji.Position {
        let center = geometry.frame(in: .local).center
        return EmojiArt.Emoji.Position(
            x: Int((location.x - center.x - pan.width) / zoom),
            y: Int(-(location.y - center.y - pan.height) / zoom)
        )
    }
    
}

#Preview {
    EmojiArtDocumentView(document: EmojiArtDocument())
        .environmentObject(PaletteStore(named: "Preview"))
}
