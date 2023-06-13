//
//  StartTestView.swift
//  AngleAndFaceRecognition
//
//  Created by Aviv Frenkel on 12/06/2023.
//

import SwiftUI

struct StartTestView: View {
    @ObservedObject private var viewModel: StartTestViewModel
    @State private var buttonEnabled = false
    
    init(viewModel: StartTestViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {

        Text("Test Started")
    }
}

struct StartTestView_Previews: PreviewProvider {
    static var previews: some View {
        StartTestView(viewModel: StartTestViewModel())
    }
}
