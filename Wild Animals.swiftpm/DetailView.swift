//
//  DetailView.swift
//  Wild Animals
//
//  Created by 정종인 on 3/21/24.
//

import SwiftUI

struct DetailView: View {
    @Binding var animal: Animal
    var body: some View {
        Image(animal.imageString)
            .resizable()
            .scaledToFit()
            .padding()
            .scaleEffect(animal.growth.scale)
    }
}

#Preview {
    DetailView(animal: .constant(.mockData))
}
