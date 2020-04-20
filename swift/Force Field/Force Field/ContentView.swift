//
//  ContentView.swift
//  Force Field
//
//  Created by Daniel Sylwestrowicz on 4/19/20.
//  Copyright © 2020 Daniel Sylwestrowicz. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var model = ContentModel()
    var body: some View {
        VStack {
            Text( "Force Field: Social Distancing" )
                .font(.title)
            Toggle( isOn: $model.enabled ) {
                Text("Enable Force Field")
                    .font(.body)
            }
            .padding(.horizontal, 15.0)
        }
            
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
