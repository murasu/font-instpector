//
//  ContentView.swift
//  TwoWindowDocumentApp
//
//  Created by Muthu Nedumaran on 23/4/21.
//

import SwiftUI

class MyObject: ObservableObject {
    @Published var title: String = "Change this!"
    @Published var filename: String = "Default.txt"
}

struct ContentView: View {
    @Environment(\.openURL) var openURL
    @EnvironmentObject var myObject: MyObject
    @Binding var document: TwoWindowDocumentAppDocument

    var body: some View {
        VStack {
            TextField("", text: $myObject.title)
                .font(.title)
                .padding()
            TextField("", text: $myObject.filename)
                .font(.title)
                .padding()
            Divider()
            Text(myObject.title)
                .padding()
            Text(myObject.filename)
                .padding()
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: ToolbarItemPlacement.automatic) {
                Button(action: {
                    if let url = URL(string: "FontInspector://secondview") {
                        openURL(url)
                    }
                }, label: {
                    Image(systemName: "rectangle.3.offgrid")
                })
            }
        }
    }
    /*
    func performDrop(info: DropInfo) -> Bool {
        guard info.hasItemsConforming(to: ["public.file-url"]) else {
            return false
        }
        
        guard let itemProvider = info.itemProviders(for: [(kUTTypeFileURL as String)]).first else { return false }
        
        itemProvider.loadItem(forTypeIdentifier: (kUTTypeFileURL as String), options: nil) {item, error in
            guard let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
            // There should be a better way to determine filetype
            let urlstring = url.absoluteString.lowercased()
            if urlstring.hasSuffix(".ttf") || urlstring.hasSuffix(".otf") || urlstring.hasSuffix(".ttc") {
                DispatchQueue.main.async {
                    if hbProject.hbFont1.fileUrl == nil {
                        setHBFont(fromUrl: url, asMainFont: true)
                    }
                    else {
                        setHBFont(fromUrl: url, asMainFont: false)
                    }
                }
            }
        }
        
        return true
    }
    
    func refreshGlyphsInFonts() {
        print("Refreshing items in Font tab")
        hbGridItems.removeAll()
        if hbProject.hbFont1.fileUrl != nil {
            // If we already have the data backed up, use it instead of recreating
            if glyphItems.count > 0 && glyphItems.count == hbProject.hbFont1.glyphCount {
                hbGridItems = glyphItems
                maxCellWidth = glyphCellWidth
                return
            }
            
            glyphItems.removeAll()
            
            // Easier to get glyphname in a CGFont
            let cgFont = CTFontCopyGraphicsFont(hbProject.hbFont1.ctFont!, nil)
            
            let fontData1   = hbProject.hbFont1.getHBFontData()
            let fontData2   = hbProject.hbFont2.getHBFontData()
            let cgFont2     = hbProject.hbFont2.fileUrl != nil ? CTFontCopyGraphicsFont(hbProject.hbFont2.ctFont!, nil) : nil
            
            // Get the glyph information and set the width of the widest glyph as the maxCellWidth
            glyphCellWidth  = 100
            let scale       = (Hibizcus.FontScale / (2048/hbProject.hbFont1.metrics.upem)) * (192/40)
            // Let's run this in the background as it can take very long for large fonts
            DispatchQueue.global(qos: .background).async {
                for i in 0 ..< hbProject.hbFont1.glyphCount {
                    let gId         = CGGlyph(i)
                    let gName       = cgFont.name(for: gId)! as String
                    let fd1         = fontData1!.getGlyfData(forGlyphName: gName)
                    let adv         = fd1?.width ?? 0
                    let width       = CGFloat(Float(adv)/scale)
                    var wordItem    = HBGridItem(type:HBGridItemItemType.Glyph, text: "")
                    wordItem.glyphIds[0]    = gId
                    wordItem.width[0]       = width
                    wordItem.label          = gName
                    wordItem.uniLabel       = hbProject.hbFont1.unicodeLabelForGlyphId(glyph: gId)
                    //var hasDiff     = false // no difference
                    var widthDiff   = false
                    var glyfDiff    = false
                    if (fontData2 != nil) {
                        let fd2     = fontData2!.getGlyfData(forGlyphName: gName)
                        glyfDiff    = fd1?.glyf != fd2?.glyf
                        let gId2    = cgFont2?.getGlyphWithGlyphName(name: gName as CFString)
                        wordItem.glyphIds[1] = gId2 != nil ? CGGlyph(gId2!) : kCGFontIndexInvalid
                        let adv2    = fd2?.width ?? 0
                        wordItem.width[1] = CGFloat(Float(adv2)/scale)
                        widthDiff   = abs(width - wordItem.width[1]) > 0.01
                    }
                    //wordItem.hasDiff  = hasDiff
                    wordItem.diffGlyf   = glyfDiff
                    wordItem.diffWidth  = widthDiff
                    glyphCellWidth = max(width, glyphCellWidth)
                    DispatchQueue.main.async {
                        hbGridItems.append(wordItem)
                        glyphItems.append(wordItem)
                        maxCellWidth = glyphCellWidth
                        //print("Grid now has \(hbGridItems.count) glyphs")
                    }
                }
            }
        }
        
        return
    } */
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(TwoWindowDocumentAppDocument()))
    }
}
