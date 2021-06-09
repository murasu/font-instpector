//
//  SecondView.swift
//  TwoWindowDocumentApp
//
//  Created by Muthu Nedumaran on 23/4/21.
//

import SwiftUI

struct SecondView: View {
    @EnvironmentObject var myObject: FIModel
    
    var body: some View {
        VStack {
            /*
            Text("Second Window")
                .font(.title)
                .padding()
            Text(myObject.title)
                .padding()
            Text(myObject.filename)
                .padding()
 */
        }
        .padding()
    }
}

struct SecondView_Previews: PreviewProvider {
    static var previews: some View {
        SecondView()
    }
}
