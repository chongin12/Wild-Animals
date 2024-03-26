//
//  DetailView.swift
//  Wild Animals
//
//  Created by 정종인 on 3/21/24.
//

import SwiftUI
import SpriteKit

struct DetailView: View {
    @State private var gestureAmount: CGFloat = 0.0
    @Binding var animal: Animal
    @State private var gameScene = DetailGameScene()
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                VStack {
                    Image(animal.imageData)
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .scaleEffect(animal.growth.scale + CGFloat(animal.food) * 0.001)

                    Text("\(animal.growth.description) ")
                        .fontWeight(.semibold)
                    + Text(animal.name)

                    HStack {
                        Spacer()
                        Text("밥 : \(animal.food)")
                        Spacer()
                        Text("쓰담 : \(animal.pat)")
                        Spacer()
                    }
                    .padding()
                }

                SpriteView(scene: gameScene, options: [.allowsTransparency])
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        animal.reset()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }

                }
            }
        }
        .onTapGesture {
            animal.foodIncrement()
            gameScene.foodEffect()
        }
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    gameScene.patEffect(at: gesture.location)
                    let velocityWidth = abs(gesture.velocity.width)
                    let velocityHeight = abs(gesture.velocity.height)
                    let moveAmount = sqrt(velocityWidth * velocityWidth + velocityHeight * velocityHeight)
                    gestureAmount += moveAmount
                    if gestureAmount >= GESTURE_VELOCITY_THRESHOLD {
                        gestureAmount -= GESTURE_VELOCITY_THRESHOLD
                        animal.patIncrement()
                        gameScene.heartEffect(at: gesture.location)
                    }
                }
        )
        .ignoresSafeArea()
    }
}

//#Preview {
//    DetailView(animal: .constant(.mockData))
//}
