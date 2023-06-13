//
//  ButtonStyle+Additions.swift
//  AngleAndFaceRecognition
//
//  Created by Aviv Frenkel on 11/06/2023.
//

import SwiftUI

struct ScalingButton: ButtonStyle {
    @Binding var enabled: Bool
    
    init(enabled: Binding<Bool> = .constant(true)) {
        self._enabled = enabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(enabled ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            .disabled(!enabled)
    }
}
