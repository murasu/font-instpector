//
//  HBStringGlyphListView.swift
//
//  Created by Muthu Nedumaran on 13/4/21.
//

import Cocoa
import Combine
import SwiftUI

struct StringViewGlyph: Identifiable, Equatable {
    var id = UUID() // to conform to identifiable protocol
    var name: String
    var glyphId: Int
    var unicode: String
    var character: String
    var color: Color
    static func == (lhs: StringViewGlyph, rhs: StringViewGlyph) -> Bool {
        return lhs.id == rhs.id
    }
} 

struct StringViewGlyphRowHeader: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            HStack {
                Text("GID")
                    .font(.system(size: 14, design: .monospaced))
                    .frame(width: 35, height: 20, alignment: .trailing)
                    .foregroundColor(Color.primary)
                Divider()
                Text("GLYPH NAME")
                    .font(.system(size: 14, design: .monospaced))
                    .frame(width: 200, height: 20, alignment: .leading)
                    .foregroundColor(Color.primary)
                Spacer()
                Divider()
                Text("UNI")
                    .font(.system(size: 14, design: .monospaced))
                    .frame(width: 50, height: 20, alignment: .leading)
                    .foregroundColor(Color.primary)
                Divider()
                Text("CHR")
                    .font(.system(size: 14, design: .monospaced))
                    .frame(width: 40, height: 20, alignment: .leading)
                    .foregroundColor(Color.primary)
            }
            Divider()
        }
    }
}

struct StringViewGlyphRow: View {
    @Environment(\.colorScheme) var colorScheme
    
    var glyph: HBGlyph
    var inColor: Bool
    var defaultColor: Color
    
    var body: some View {
        VStack {
            HStack {
                Text(verbatim: String(glyph.glyphId))
                    .font(.system(size: 14, design: .monospaced))
                    .frame(width: 35, height: 20, alignment: .trailing)
                    .foregroundColor(inColor ? (colorScheme == .dark ? glyph.color : glyph.color.opacity(255)) : defaultColor)
                Divider()
                Text(verbatim: glyph.name)
                    .font(.system(size: 14, design: .monospaced))
                    .frame(width: 200, height: 20, alignment: .leading)
                    .foregroundColor(inColor ? (colorScheme == .dark ? glyph.color : glyph.color.opacity(255)) : defaultColor)
                Spacer()
                Divider()
                Text(verbatim: glyph.unicode.hasPrefix("0000") ? " " : glyph.unicode)
                    .font(.system(size: 14, design: .monospaced))
                    .frame(width: 50, height: 20, alignment: .leading)
                    .foregroundColor(inColor ? (colorScheme == .dark ? glyph.color : glyph.color.opacity(255)) : defaultColor)
                Divider()
                Text(verbatim: glyph.unicode.hasPrefix("0000") ? " " : glyph.character)
                    .font(.system(size: 14, design: .monospaced))
                    .frame(width: 40, height: 20, alignment: .leading)
                    .foregroundColor(inColor ? (colorScheme == .dark ? glyph.color : glyph.color.opacity(255)) : defaultColor)
            }
            Divider()
        }
    }
}

struct StringGlyphListView: View {
    @EnvironmentObject var fiModel: FIModel
    @ObservedObject var stringViewSettings: HBStringViewSettings
    var defaultColor: Color
    var mainFont: Bool
        
    var body: some View {
        List {
            Section(header: StringViewGlyphRowHeader()) {
                // TODO: Need a better way to manage StringLayoutData. Figure out a way to reuse the data obtained
                // for the StringLayoutView instead of calling getStringLayoutData() again for StringGlyphListView
                if showList() {
                    ForEach(fiModel.hbFont1.getStringLayoutData(forText: fiModel.hbStringViewText).hbGlyphs,
                            id: \.self) { hbGlyph in
                        StringViewGlyphRow(glyph: hbGlyph,
                                           inColor: true
                                            && stringViewSettings.coloredItems,
                                           defaultColor: defaultColor)
                    }
                }
            }
        }
    }
    
    func showList() -> Bool {
        if mainFont && stringViewSettings.showFont1 {
            return true
        }
        if !mainFont && stringViewSettings.showFont2 {
            return true
        }
        
        return false
    }
}

