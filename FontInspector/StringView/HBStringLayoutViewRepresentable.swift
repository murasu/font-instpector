//
//  HBStringLayoutViewRepresentable.swift
//
//  Created by Muthu Nedumaran on 25/3/21.
//

import Combine
import SwiftUI

struct HBStringLayoutViewRepresentable: NSViewRepresentable {

    typealias NSViewType = HBStringLayoutView

    @EnvironmentObject var fiModel: FIModel

    var fontSize: Double
    @ObservedObject var slData1: StringLayoutData
    @ObservedObject var slData2: StringLayoutData
    @ObservedObject var stringViewSettings: HBStringViewSettings

    func makeNSView(context: Context) -> HBStringLayoutView {
        let slView = HBStringLayoutView()
        slView.hbFont1      = fiModel.hbFont1
        slView.hbFont2      = fiModel.hbFont1
        slView.slData1      = slData1
        slView.slData2      = slData2
        slView.text         = fiModel.hbStringViewText
        slView.fontSize     = fontSize
        slView.viewSettings = stringViewSettings

        return slView
    }
    
    func updateNSView(_ nsView: HBStringLayoutView, context: Context) {
        //print("Update called: in TraceRowViewRepresentable")
        nsView.hbFont1      = fiModel.hbFont1
        nsView.hbFont2      = fiModel.hbFont1
        nsView.slData1      = slData1
        nsView.slData2      = slData2
        nsView.text         = fiModel.hbStringViewText
        nsView.fontSize     = fontSize
        nsView.viewSettings = stringViewSettings
    }
}
