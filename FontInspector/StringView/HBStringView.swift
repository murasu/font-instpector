//
//  HBStringView.swift
//
//  Created by Muthu Nedumaran on 25/3/21.
//

import Combine
import SwiftUI
import AppKit

class HBStringViewSettings: ObservableObject {
    @Published var showFont1        = true
    @Published var showFont2        = true
    @Published var drawMetrics      = false
    @Published var drawUnderLine    = false
    @Published var drawBoundingBox  = false
    @Published var drawAnchors      = false
    @Published var coloredItems     = true
    // This is used to force update view when fonts change
    @Published var toggleRefresh    = false
    @Published var fontSize: Double = 100
}

struct HBStringView: View, DropDelegate {
    @Environment(\.openURL) var openURL
    @EnvironmentObject var fiModel: FIModel
    @StateObject var stringViewSettings = HBStringViewSettings()
    
    var body: some View {
        NavigationView() {
            // Sidebar
            HBStringSidebarView(stringViewSettings: stringViewSettings)
            
            // Main Content
            VSplitView {
                VStack {
                    // The text field where we input text
                    TextField(Hibizcus.UIString.TestStringPlaceHolder, text: $fiModel.hbStringViewText)
                        .font(.title)
                        /*
                        .onChange(of: fiModel.hbFont1.selectedScript) { newScript in
                            // Update layout data for both fonts when script is changed
                            fiModel.hbFont2.selectedScript = newScript
                            fiModel.refresh()
                        }
                        .onChange(of: fiModel.hbFont1.selectedLanguage) { newLanguage in
                            // Update layout data for both fonts when language is changed
                            fiModel.hbFont2.selectedLanguage = newLanguage
                            fiModel.refresh()
                        } */
                    // The text to display the unicodes of the string
                    HStack {
                        Text(fiModel.hbStringViewText.hexString())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.body)
                            .foregroundColor(.blue)
                            .padding(.vertical, 3)
                        Spacer()
                        Button(action: copyHexString, label: {
                            Image(systemName: "doc.on.doc")
                        })
                        .padding(.vertical, 3)
                        .padding(.trailing, 5)
                        .foregroundColor(.primary)
                        .help("Copy hex string to clipboard")
                    }
                    .padding(.leading, 5)
                    .padding(.trailing, 5)
                    if fiModel.hbFont1.fileUrl != nil  {
                        // Our custom view to display the shaped text
                        HBStringLayoutViewRepresentable(fontSize: stringViewSettings.fontSize,
                                                        slData1: fiModel.hbFont1.getStringLayoutData(forText: fiModel.hbStringViewText),
                                                        slData2: fiModel.hbFont1.getStringLayoutData(forText: fiModel.hbStringViewText),
                                                        stringViewSettings: stringViewSettings)
                            .onDrop(of: ["public.text", "public.truetype-ttf-font", "public.file-url"], delegate: self)
                            .onDrag({
                                let dragData = jsonFrom(font1: fiModel.hbFont1.fileUrl!.absoluteString, font2: fiModel.hbFont1.fileUrl!.absoluteString, text: fiModel.hbStringViewText)
                                UserDefaults.standard.setValue(dragData, forKey: "droppedjson")
                                print("Dragging out \(dragData)")
                                return NSItemProvider(item: dragData as NSString, typeIdentifier: kUTTypeText as String)
                            })
                    }
                    else {
                        VStack {
                            Spacer()
                            Text(Hibizcus.UIString.DragAndDropGridItemOrTwoFontFiles)
                                .font(.title)
                                .padding(.vertical, 50)
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                    }
                }
                Divider()
                VStack {
                    HStack {
                        // Glyphs in the shaped text, shaped using font1, the main font
                        VStack {
                            StringGlyphListView(stringViewSettings:stringViewSettings,
                                                defaultColor: Color.primary,
                                                mainFont: true)
                        }
                        .padding(.leading, 10)
                        /*
                        if fiModel.hbFont2.fileUrl != nil {
                            Divider()
                            // Glyphs in the shaped text, shaped font2, the compare font
                            VStack {
                                StringGlyphListView(stringViewSettings:stringViewSettings,
                                                    defaultColor: (fiModel.hbFont2.fileUrl == nil) ? Color.primary : Hibizcus.FontColor.CompareFontUIColor.opacity(0.8),
                                                    mainFont: false)
                            }
                            .padding(.trailing, 10)
                        } */
                    }
                }
            }
        }
        .toolbar {
            // Toggle sidebar
            ToolbarItem(placement: .navigation) {
                Button(action: toggleLeftSidebar, label: {
                    Image(systemName: "sidebar.left")
                })
            }
        }
        .onDrop(of: ["public.text", "public.truetype-ttf-font", "public.file-url"], delegate: self)
        .navigationTitle(Text("StringViewer: \(fiModel.projectName)"))
    }
    
    func performDrop(info: DropInfo) -> Bool {
        guard info.hasItemsConforming(to: ["public.file-url"]) || info.hasItemsConforming(to: ["public.text"]) else {
            return false
        }
        
        if info.hasItemsConforming(to: ["public.text"]) {
            // This is JSON data
            guard let itemProvider = info.itemProviders(for: [(kUTTypeText as String)]).first else { return false }
            
            itemProvider.loadItem(forTypeIdentifier: (kUTTypeText as String), options: nil) {item, error in
                if item != nil {
                    // Cheating
                    let droppedData = UserDefaults.standard.string(forKey: "droppedjson")
                    let jsonData = droppedData!.data(using: .utf8)!
                    do {
                        let dictionary = try JSONDecoder().decode([String:String].self, from: jsonData)
                        
                        //let f1 = dictionary["font1"]
                        //let f2 = dictionary["font2"]
                        let tx = dictionary["text"]
                        if tx != nil {
                            DispatchQueue.main.async {
                                fiModel.hbStringViewText = tx!
                            }
                        }
                    }
                    catch{
                        print("Error: \(error.localizedDescription)")
                    }
                }
            }
        }
        else {
            guard let itemProvider = info.itemProviders(for: [(kUTTypeFileURL as String)]).first else { return false }
            
            itemProvider.loadItem(forTypeIdentifier: (kUTTypeFileURL as String), options: nil) {item, error in
                guard let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
                // There should be a better way to determine filetype
                let urlstring = url.absoluteString.lowercased()
                if urlstring.hasSuffix(".ttf") || urlstring.hasSuffix(".otf") || urlstring.hasSuffix(".ttc") {
                    DispatchQueue.main.async {
                        fiModel.hbFont1.setFontFile(filePath: url.path)
                        fiModel.refresh()
                    }
                }
            }
        }
        
        return true
    }
    
    func copyHexString() {
        NSPasteboard.general.clearContents()
        if !NSPasteboard.general.setString(fiModel.hbStringViewText.hexString(), forType: NSPasteboard.PasteboardType.string) {
            print("Error setting string in pasteboard")
        }
        else {
            postNotification(title: "StringViewer", message: "\(fiModel.hbStringViewText.hexString()) copied to clipboard")
        }
    }
    
    func jsonFrom(font1:String, font2:String, text:String) -> String {
        let data = [
            "font1": font1,
            "font2": font2,
            "text": text
        ]
        
        let dataInJson = try! JSONEncoder().encode(data)
        return String(data: dataInJson, encoding: .utf8)!
    }
}

