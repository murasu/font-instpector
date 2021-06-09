//
//  HBSidebarFont.swift
//
//  Created by Muthu Nedumaran on 15/4/21.
//

import Combine
import SwiftUI
import AppKit

struct HBSidebarFont: View {
    @EnvironmentObject var fiModel: FIModel
    @State private var showingLanguageSelection = false
    var showCompareFont = false

    var body: some View {
        HStack (alignment: .top) {
            
            // ----------------------------------------
            // First Font File
            // ----------------------------------------

            if fiModel.hbFont1.fileUrl != nil {
                Button(action: removeFont1, label: {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                })
                .padding(.leading, 10)
                .accentColor(.red)
                .help("Remove font")
            }
            /*
            else {
                Button(action: addFont1, label: {
                    Image(systemName: "plus.circle")
                })
                .padding(.leading, 10)
                .help("Set main font")
            } */
            Text("Main font:")
                .multilineTextAlignment(.leading)
                .padding(.trailing, 15)
                .padding(.bottom, 2)
                // remove this when (+) buton is enabled
                .padding(.leading, 10)
            Spacer()
            /*
            if fiModel.hbFont1.fileWatcher.fontFileChanged {
                Button(action: reloadFont1, label: {
                    Image(systemName: "arrow.clockwise")
                })
                .padding(.trailing, 15)
                .help("Reload font")
            } */
        }
        if fiModel.hbFont1.fileUrl != nil {
            Text(fiModel.hbFont1.fileUrl!.lastPathComponent)
                .multilineTextAlignment(.leading)
                .padding(.leading, 20)
                .padding(.bottom, 2)
                .foregroundColor(Hibizcus.FontColor.MainFontUIColor)
            Text(fiModel.hbFont1.version)
                .multilineTextAlignment(.leading)
                .padding(.leading, 20)
                .padding(.bottom, 10)
                .foregroundColor(Hibizcus.FontColor.MainFontUIColor)
            
            // TODO: Should I have a seperate flag to show shaper?
            if showCompareFont {
                Text("Shaper:")
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 20)
                    .padding(.bottom, 5)
                
                Picker("", selection: $fiModel.hbFont1.selectedShaper) {
                    ForEach(fiModel.hbFont1.shapers, id: \.self) { scriptName in
                        Text(scriptName)
                    }
                }
                .padding(.leading, 10)
                .padding(.trailing,15)
                .padding(.bottom, 30)
            }
        }
        else {
            Text("None selected")
                .multilineTextAlignment(.leading)
                .padding(.leading, 20)
                .padding(.bottom, 20)
                .foregroundColor(.gray)
        }
        
        // ----------------------------------------
        // Second Font File
        // ----------------------------------------
        /*
        if showCompareFont {
            Divider()
            
            HStack (alignment: .top) {
                if hbProject.hbFont2.fileUrl != nil {
                    Button(action: removeFont2, label: {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.red)
                    })
                    .padding(.leading, 10)
                    .accentColor(.red)
                    .help("Remove font")
                }
                /*else {
                    Button(action: addFont2, label: {
                        Image(systemName: "plus.circle")
                    })
                    .padding(.leading, 10)
                    .help("Set compare font")
                } */
                Text("Comparison font:")
                    .multilineTextAlignment(.leading)
                    .padding(.trailing, 15)
                    .padding(.bottom, 2)
                    // remove this when (+) buton is enabled
                    .padding(.leading, 10)
                Spacer()
                if hbProject.hbFont2.fileWatcher.fontFileChanged {
                    Button(action: reloadFont2, label: {
                        Image(systemName: "arrow.clockwise")
                    })
                    .padding(.trailing, 15)
                    .help("Reload font")
                }
            }
            .padding(.top, 15)
            
            if fiModel.hbFont2.fileUrl != nil {
                Text(hbProject.hbFont2.fileUrl!.lastPathComponent)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 20)
                    .padding(.bottom, 2)
                    .foregroundColor(Hibizcus.FontColor.CompareFontUIColor)
                Text(hbProject.hbFont2.version)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 20)
                    .padding(.bottom, 10)
                    .foregroundColor(Hibizcus.FontColor.CompareFontUIColor)
                Text("Shaper:")
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 20)
                    .padding(.bottom, 5)
                
                Picker("", selection: $hbProject.hbFont2.selectedShaper) {
                    ForEach(hbProject.hbFont2.shapers, id: \.self) { scriptName in
                        Text(scriptName)
                    }
                }
                .padding(.leading, 10)
                .padding(.trailing,15)
                .padding(.bottom, 30)
            }
            else {
                Text("None selected")
                    .multilineTextAlignment(.leading)
                    .padding(.leading, 20)
                    .padding(.bottom, 20)
                    .foregroundColor(.gray)
            }
        } */
    }
    
    func addFont1() {
        openFont(fontNum:1)
    }
    
    func addFont2() {
        openFont(fontNum:2)
    }
    
    func openFont(fontNum:Int) {
        let openPanel = NSOpenPanel()
        openPanel.prompt = "Select file"
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["ttf","ttc","otf"]
        openPanel.begin { (result) -> Void in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                let selectedPath = openPanel.url!.path
                DispatchQueue.main.async {
                    print("Selected \(selectedPath) for font \(fontNum)")
                    switch (fontNum) {
                    case 1:
                        fiModel.hbFont1.setFontFile(filePath: selectedPath)
                    //case 2:
                    //    fiModel.hbFont2.setFontFile(filePath: selectedPath)
                    default:
                        print("This should never be printed!")
                    }
                    
                }
            }
        }
    }
    
    func removeFont1() {
        fiModel.hbFont1.setFontFile(filePath: "")
        fiModel.refresh()
    }
    
    /*
    func removeFont2() {
        fiModel.hbFont2.setFontFile(filePath: "")
        fiModel.refresh()
    } */
    
    func reloadFont1() {
        //fiModel.hbFont1.fileWatcher.fontFileChanged = false
        fiModel.hbFont1.reloadFont()
        fiModel.refresh()
    }
    
    /*
    func reloadFont2() {
        fiModel.hbFont2.fileWatcher.fontFileChanged = false
        fiModel.hbFont2.reloadFont()
        fiModel.refresh()
    } */
}
