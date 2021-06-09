//
//  ContentView.swift
//  TwoWindowDocumentApp
//
//  Created by Muthu Nedumaran on 23/4/21.
//

import SwiftUI

class FIModel: ObservableObject {
    @Published var hbFont1 = HBFont(filePath: "", fontSize: 40)
}

enum HBGridItemItemType {
    case Glyph, Cluster, Word, Number
}

struct HBGridItem : Hashable {
    var type: HBGridItemItemType?
    var text: String?
    var id          = UUID()                    // Unique ID for this item
    var glyphIds    = [kCGFontIndexInvalid,     // For Font1 and Font2
                       kCGFontIndexInvalid]
    var width       = [CGFloat(0),
                       CGFloat(0)]
    var height      = CGFloat(0)                // The rest of the data is for Font1 only
    var lsb         = CGFloat(0)
    var rsb         = CGFloat(0)
    var label       = ""                        // Stores the glyph name in the case of font comparison
    var uniLabel    = ""                        // Label that holds the unicode value
    var diffWidth   = false
    var diffGlyf    = false
    var diffLayout  = false
    var colorGlyphs = false
    func hasDiff() -> Bool {
        return diffWidth || diffGlyf || diffLayout
    }
}

struct ContentView: View, DropDelegate {
    @Environment(\.openURL) var openURL
    @EnvironmentObject var fiModel: FIModel
    @Binding var document: FontInspectorAppDocument

    
    @State var hbGridItems              = [HBGridItem]()
    @State var minCellWidth: CGFloat    = 100
    @State var maxCellWidth: CGFloat    = 100
    @State var glyphCellWidth:CGFloat   = 100
    @State var showGlyphView            = false
    @State var tappedItem               = HBGridItem()
    
    var body: some View {
        VStack {

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: maxCellWidth))], spacing: 10) {
                    ForEach(hbGridItems, id: \.self) { hbGridItem in
                        HBGridCellViewRepresentable(wordItem: hbGridItem, scale: 1.0)
                            .frame(width: maxCellWidth, height: 92, alignment: .center)
                            .border(Color.primary.opacity(0.7), width: tappedItem==hbGridItem ? 1 : 0)
                            .gesture(TapGesture(count: 2).onEnded {
                                // UI Update should be done on main thread
                                DispatchQueue.main.async {
                                    tappedItem = hbGridItem
                                }
                                print("double clicked on item \(hbGridItem)")
                                doubleClicked(clickedItem: hbGridItem)
                            })
                            .simultaneousGesture(TapGesture().onEnded {
                                DispatchQueue.main.async {
                                    tappedItem = hbGridItem
                                }
                                print("single clicked on item \(hbGridItem)")
                            })
                            .sheet(isPresented: $showGlyphView, onDismiss: glyphViewDismissed) {
                                HBGlyphView(scale: tappedItem.type == .Word ? 4.0 : 6.0,
                                            gridItem: tappedItem)
                            }
                        
                    }
                }
                .padding(.horizontal)
                .background(Color(NSColor.textBackgroundColor))
            }
            
            
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
                    fiModel.hbFont1.fontSize = 40
                    fiModel.hbFont1.setFontFile(filePath: url.path)
                    // Save the bookmark in document for future use
                    document.fiProject.fontFile1Bookmark = securityScopedBookmark(ofUrl: url)
                }
            }
        }
        
        return true
    }
    
    
    func securityScopedBookmark(ofUrl: URL) -> Data {
        // Create a security scoped bookmark so we can open this again in the future
        let bookmarkData = try! ofUrl.bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
        return bookmarkData
    }
    
    
    /*
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
    
    func doubleClicked(clickedItem: HBGridItem) {
        showGlyphView = tappedItem == clickedItem
    }
    
    func glyphViewDismissed() {
        showGlyphView = false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(FontInspectorAppDocument()))
    }
}
