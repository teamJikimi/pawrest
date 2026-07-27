//
//  SelfAssessmentRadioButton.swift
//  pawrest
//
//  Created by Moon AYoung on 6/15/26.
//

import SwiftUI

struct SelfAssessmentRadioButton: View {
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(isSelected ? .radioButtonSelected : .radioButtonDefault)
                .resizable()
                .frame(width: 24, height: 24)
        }
    }
}
