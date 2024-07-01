//
//  Sturldata.swift
//  Emoji Art
//
//  Created by Immanuel on 26/06/24.
//

import CoreTransferable

// a type which represents either a String, a URL or a Data
// it implements Transferable by proxy

enum Sturldata: Transferable {
    
    case string(String)
    case url(URL)
    case data(Data)
    
    init(url: URL) {
        // some URLs have the data for an image directly embedded in the URL itself
        // (i.e. they are NOT a REFERENCE to the data somewhere else like most are)
        // these sorts of URLs are called "data scheme" URLs
        // (they will have "image/jpeg" or some such as the mime type)
//        if let imageData = url.dataSchemeImageData {
//            self = .data(imageData)
//        } else {
            self = .url(url)
//        }
    }
    
    init(string: String) {
        // if the string looks like a URL, we're treat it like one
        if string.hasPrefix("http"), let url = URL(string: string) {
            self = .url(url)
        } else {
            self = .string(string)
        }
    }
    
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation { Sturldata(string: $0) }
        ProxyRepresentation { Sturldata(url: $0) }
        ProxyRepresentation { Sturldata.data($0) }
    }
    
}
