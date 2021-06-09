//
//  FontInspectorApp.swift
//  FontInspectorApp
//
//  Created by Muthu Nedumaran on 23/4/21.
//

import SwiftUI

@main
struct FontInspectorApp: App {

    @StateObject var fiModel = FIModel()

    var body: some Scene {
        DocumentGroup(newDocument: FontInspectorAppDocument()) { file in
            ContentView(document: file.$document).environmentObject(fiModel)
        }
        
        WindowGroup("StringView") {
            HBStringView()
                .environmentObject(fiModel)
                .handlesExternalEvents(preferring: Set(arrayLiteral: "stringview"), allowing: Set(arrayLiteral: "*"))
        }
        .handlesExternalEvents(matching: Set(arrayLiteral: "stringview"))
    }
}
