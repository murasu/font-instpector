//
//  HBGlyphView.swift
//
//  Created by Muthu Nedumaran on 8/3/21.
//

import Cocoa
import Combine
import SwiftUI

struct HBGlyphView: View {
    @Environment(\.openURL) var openURL
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var fiModel: FIModel

    let scale: CGFloat
    let gridItem: HBGridItem
    //let gridItems: [HBGridItem]
    //var currIndex: Int
    
    var body: some View {
        VStack {
            ZStack {
                Text((gridItem.type == HBGridItemItemType.Glyph ? glyphItemLabel() : gridItem.text) ?? "")
                    .font(.title)
                    .padding(.horizontal, 15)
                    .padding(.top, 15)
                    .padding(.bottom, 10)
                
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }, label: {
                        Image(systemName: "multiply.circle")
                    })
                    .font(.system(size: 20))
                    .padding(.top, 10)
                    .padding(.bottom, 0)
                    .padding(.horizontal, 10)
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    // Copy button - only for clusters and words.
                    // TODO: Glyphs only if there's a unicode value
                    if gridItem.type != HBGridItemItemType.Glyph && gridItem.text != nil {
                        Button(action: { copyTextToClipboard(textToCopy: gridItem.text!) }, label: {
                            Image(systemName: "doc.on.doc")
                        })
                        .font(.system(size: 20))
                        .padding(.top, 10)
                        .padding(.bottom, 0)
                        .padding(.horizontal, 10)
                        .buttonStyle(PlainButtonStyle())
                        .help("Copy \(gridItem.text!) to clipboard")
                        
                        // Open in String Viewer
                        Button(action: { openTextInStringViewer(text: gridItem.text!) }, label: {
                            Image(systemName: "rectangle.and.text.magnifyingglass")
                        })
                        .font(.system(size: 20))
                        .padding(.top, 10)
                        .padding(.bottom, 0)
                        .padding(.horizontal, 10)
                        .buttonStyle(PlainButtonStyle())
                        .help("Open \(gridItem.text!) in StringViewer")
                    }
                    else {
                        Text(" ")
                    }
                }
            }
            Divider()
            
            VStack {
                HBGridCellViewRepresentable(wordItem: gridItem, scale: scale)
                    .frame(width: max((gridItem.width[0] * scale * 1.2), 800), height: 600, alignment: .center)
                
                Divider()
            
                HStack {
                    Button("Prev") {
                        print("I should show the previous item")
                    }
                    Spacer()
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    Spacer()
                    Button("Next") {
                        print("I should show the next item")
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.top, 5)//-25)
            .padding(.bottom, 20)
        }
    }
    
    func glyphItemLabel() -> String {
        if gridItem.uniLabel.count > 0 {
            return "\(gridItem.label) - \(gridItem.uniLabel)"
        }
        
        return gridItem.label
    }
    
    func openTextInStringViewer(text: String) {
        if let url = URL(string: "FontInspector://stringview") {
            // Open the StringViewer
            fiModel.hbStringViewText = text
            openURL(url)
            // Close the view
            presentationMode.wrappedValue.dismiss()
        }
    }
}

