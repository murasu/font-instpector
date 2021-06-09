//
//  WordsCellViewRepresentable.swift
//
//  Created by Muthu Nedumaran on 3/3/21.
//

import Combine
import SwiftUI

struct HBGridCellViewRepresentable: NSViewRepresentable {
    
    typealias NSViewType = HBGridCellView

    @EnvironmentObject var fiModel: FIModel

    var wordItem:HBGridItem
    var scale:CGFloat

    func makeNSView(context: Context) -> HBGridCellView {
        let cellView = HBGridCellView()
        // Set defaults
        cellView.hbFont1 = fiModel.hbFont1
        cellView.hbFont2 = fiModel.hbFont1
        cellView.gridItem = wordItem
        cellView.scale = scale
        return cellView
    }
    
    func updateNSView(_ nsView: HBGridCellView, context: Context) {
        //print("Update called: in TraceRowViewRepresentable")
        nsView.hbFont1 = fiModel.hbFont1
        nsView.hbFont2 = fiModel.hbFont1
        nsView.gridItem = wordItem
        nsView.scale = scale
    }
}
