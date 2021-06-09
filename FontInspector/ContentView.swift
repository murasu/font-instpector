//
//  ContentView.swift
//  TwoWindowDocumentApp
//
//  Created by Muthu Nedumaran on 23/4/21.
//

import SwiftUI

class FIModel: ObservableObject {
    @Published var projectName      = ""
    @Published var hbFont1          = HBFont(filePath: "", fontSize: 40)
    @Published var hbStringViewText = ""
    // Holds the last updated timestamp. Used to force change the value for UI updates
    @Published var lastUpdated      = ""
    func refresh() {
        self.lastUpdated = NSDate().timeIntervalSince1970.debugDescription
    }
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
        NavigationView() {
            // Sidebar
            HStack (alignment: .top) {
                VStack(alignment: .leading) {
                    HBSidebarFont()
                    Spacer()
                }
            }
            .padding(.vertical, 20)
            .frame(minWidth: 200, idealWidth: 220, maxWidth: 240)
            // Main Content
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
            .onDrop(of: ["public.truetype-ttf-font", "public.file-url"], delegate: self)
            .onAppear {
                if document.fiProject.fontFile1Bookmark != nil {
                    fiModel.hbFont1.loadFontWith(fontBookmark: document.fiProject.fontFile1Bookmark!, fontSize: 40)
                }
                refreshGlyphsInFonts()
                fiModel.refresh()
            }
            .toolbar {
                // Toggle sidebar
                ToolbarItem(placement: .navigation) {
                    Button(action: toggleLeftSidebar, label: {
                        Image(systemName: "sidebar.left")
                    })
                }
                // Button to fire second view
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
            
            /*
            HStack (alignment: .top) {
                VStack(alignment: .leading) {
                    HBSidebarFont()
                    Spacer()
                }
            }
            .padding(.vertical, 20)
            .frame(minWidth: 200, idealWidth: 220, maxWidth: 240)
             */
        }
    }
    
    func refreshGlyphsInFonts() {
        print("Refreshing items in Font tab")
        hbGridItems.removeAll()
        if fiModel.hbFont1.fileUrl != nil {
            // Easier to get glyphname in a CGFont
            let cgFont = CTFontCopyGraphicsFont(fiModel.hbFont1.ctFont!, nil)
            let fontData1   = fiModel.hbFont1.getHBFontData()
            // Get the glyph information and set the width of the widest glyph as the maxCellWidth
            glyphCellWidth  = 100
            let scale       = (Hibizcus.FontScale / (2048/fiModel.hbFont1.metrics.upem)) * (192/40)
            // Let's run this in the background as it can take very long for large fonts
            DispatchQueue.global(qos: .background).async {
                for i in 0 ..< fiModel.hbFont1.glyphCount {
                    let gId         = CGGlyph(i)
                    let gName       = cgFont.name(for: gId)! as String
                    let fd1         = fontData1!.getGlyfData(forGlyphName: gName)
                    let adv         = fd1?.width ?? 0
                    let width       = CGFloat(Float(adv)/scale)
                    var wordItem    = HBGridItem(type:HBGridItemItemType.Glyph, text: "")
                    wordItem.glyphIds[0]    = gId
                    wordItem.width[0]       = width
                    wordItem.label          = gName
                    wordItem.uniLabel       = fiModel.hbFont1.unicodeLabelForGlyphId(glyph: gId)
                    //var hasDiff     = false // no difference
                    let widthDiff   = false
                    let glyfDiff    = false
                    
                    //wordItem.hasDiff  = hasDiff
                    wordItem.diffGlyf   = glyfDiff
                    wordItem.diffWidth  = widthDiff
                    glyphCellWidth = max(width, glyphCellWidth)
                    DispatchQueue.main.async {
                        hbGridItems.append(wordItem)
                        maxCellWidth = glyphCellWidth
                    }
                }
            }
        }
        
        return
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
                    fiModel.refresh()
                    // Save the bookmark in document for future use
                    document.fiProject.fontFile1Bookmark = securityScopedBookmark(ofUrl: url)
                    refreshGlyphsInFonts()
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

// Toggle Left Sidebar
func toggleLeftSidebar() {
    NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
}
