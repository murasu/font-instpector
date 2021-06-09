//
//  TwoWindowDocumentAppApp.swift
//  TwoWindowDocumentApp
//
//  Created by Muthu Nedumaran on 23/4/21.
//

import SwiftUI

@main
struct TwoWindowDocumentAppApp: App {

    @StateObject var myObject = MyObject()

    var body: some Scene {
        DocumentGroup(newDocument: TwoWindowDocumentAppDocument()) { file in
            ContentView(document: file.$document).environmentObject(myObject)
        }
        
        WindowGroup("SecondWindow") {
            SecondView().environmentObject(myObject)
        }
        .handlesExternalEvents(matching: Set(arrayLiteral: "secondview"))
    }
}
