//
//  FontInspectorApp.swift
//  FontInspectorApp
//
//  Created by Muthu Nedumaran on 23/4/21.
//

import SwiftUI

@main
struct FontInspectorApp: App {

    @StateObject var myObject = MyObject()

    var body: some Scene {
        DocumentGroup(newDocument: FontInspectorAppDocument()) { file in
            ContentView(document: file.$document).environmentObject(myObject)
        }
        
        WindowGroup("SecondWindow") {
            SecondView().environmentObject(myObject)
        }
        .handlesExternalEvents(matching: Set(arrayLiteral: "secondview"))
    }
}
