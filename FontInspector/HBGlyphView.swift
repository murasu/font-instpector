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
    //let gridItems[currIndex]: HBGridItem
    let gridItems: [HBGridItem]
    @State var currIndex: Int
    
    var body: some View {
        VStack {
            ZStack {
                Text((gridItems[currIndex].type == HBGridItemItemType.Glyph ? glyphItemLabel() : gridItems[currIndex].text) ?? "")
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
                    if gridItems[currIndex].type != HBGridItemItemType.Glyph && gridItems[currIndex].text != nil {
                        Button(action: { copyTextToClipboard(textToCopy: gridItems[currIndex].text!) }, label: {
                            Image(systemName: "doc.on.doc")
                        })
                        .font(.system(size: 20))
                        .padding(.top, 10)
                        .padding(.bottom, 0)
                        .padding(.horizontal, 10)
                        .buttonStyle(PlainButtonStyle())
                        .help("Copy \(gridItems[currIndex].text!) to clipboard")
                        
                        // Open in String Viewer
                        Button(action: { openTextInStringViewer(text: gridItems[currIndex].text!) }, label: {
                            Image(systemName: "rectangle.and.text.magnifyingglass")
                        })
                        .font(.system(size: 20))
                        .padding(.top, 10)
                        .padding(.bottom, 0)
                        .padding(.horizontal, 10)
                        .buttonStyle(PlainButtonStyle())
                        .help("Open \(gridItems[currIndex].text!) in StringViewer")
                    }
                    else {
                        Text(" ")
                    }
                }
            }
            Divider()
            
            VStack {
                HBGridCellViewRepresentable(wordItem: gridItems[currIndex], scale: scale)
                    .frame(width: max((gridItems[currIndex].width[0] * scale * 1.2), 800), height: 600, alignment: .center)
                
                Divider()
            
                HStack {
                    Button("Prev") {
                        if currIndex > 0 {
                            currIndex -= 1
                        }
                    }
                    Spacer()
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    Spacer()
                    Button("Next") {
                        if currIndex < gridItems.count - 1 {
                            currIndex += 1
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.top, 5)//-25)
            .padding(.bottom, 20)
        }
    }
    
    func glyphItemLabel() -> String {
        if gridItems[currIndex].uniLabel.count > 0 {
            return "\(gridItems[currIndex].label) - \(gridItems[currIndex].uniLabel)"
        }
        
        return gridItems[currIndex].label
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

