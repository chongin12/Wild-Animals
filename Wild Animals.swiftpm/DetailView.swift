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
                    Image(animal.imageString)
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
                }

                SpriteView(scene: gameScene, options: [.allowsTransparency])
            }
            .ignoresSafeArea()
            .animation(.snappy, value: animal.food)
            .gesture(
                TapGesture()
                    .onEnded {
                        animal.foodIncrement()
                        gameScene.popcornEffect()
                    }
            )
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        gameScene.patEffect(at: gesture.location)
                        let velocityWidth = abs(gesture.velocity.width)
                        let velocityHeight = abs(gesture.velocity.height)
                        let moveAmount = sqrt(velocityWidth * velocityWidth + velocityHeight * velocityHeight)
                        gestureAmount += moveAmount
                        print("gestureAmount : \(gestureAmount)")
                        if gestureAmount >= GestureVelocityThreshold {
                            gestureAmount -= GestureVelocityThreshold
                            animal.patIncrement()
                        }
                    }
            )
        }
    }
}

#Preview {
    DetailView(animal: .constant(.mockData))
        .environment(AnimalStorage())
}

final class DetailGameScene: SKScene {
    var width: CGFloat {
        self.size.width
    }

    var height: CGFloat {
        self.size.height
    }

    override func didMove(to view: SKView) {
        self.backgroundColor = .clear
        self.view?.backgroundColor = .clear
        size = view.bounds.size
        self.view?.isUserInteractionEnabled = false
    }

    public func popcornEffect() {
        addPopcorn()
    }

    public func patEffect(at point: CGPoint) {
        let convertedPoint = CGPoint(x: point.x, y: self.size.height - point.y)
        addPat(at: convertedPoint)
    }

    private func addPopcorn() {
        let node = SKSpriteNode(imageNamed: "popcorn.png")
        let nodeWidth: CGFloat = min(width, height) * 0.05
        let nodeHeight: CGFloat = nodeWidth * 1.618
        node.size = CGSize(width: nodeWidth, height: nodeHeight)
        node.position = CGPoint(x: CGFloat.random(in: 0...width), y: height * 0.005)

        // 물리 엔진 설정
        let side = min(width, height) * 0.1
        node.physicsBody = SKPhysicsBody(circleOfRadius: side / 2)
        node.physicsBody?.isDynamic = true // 물리 엔진의 영향을 받게 함
        node.physicsBody?.affectedByGravity = true
        node.physicsBody?.allowsRotation = true // 노드가 회전할 수 있도록 함

        // 발사 속도와 방향 설정
        let randomXVelocity = CGFloat.random(in: -width*0.5...width*0.5) // 좌우 방향 속도
        let randomYVelocity = CGFloat.random(in: height*1.5...height*2.0) // 상승 속도
        node.physicsBody?.velocity = CGVector(dx: randomXVelocity, dy: randomYVelocity)
        node.physicsBody?.linearDamping = 0.1 // 선형 감쇠 조정
        node.physicsBody?.angularDamping = 0.1 // 회전 감쇠 조정

        // 화면 바깥으로 떨어진 후 제거되도록 설정
        let waitAction = SKAction.wait(forDuration: 3) // 3초 후 제거
        let removeAction = SKAction.removeFromParent()
        node.run(SKAction.sequence([waitAction, removeAction]))

        addChild(node)
    }

    private func addPat(at point: CGPoint) {
        let node = SKSpriteNode(imageNamed: "pat.png")
        let side: CGFloat = width * 0.05
        node.size = CGSize(width: side, height: side)
        node.position = point

        let waitAction = SKAction.wait(forDuration: 1) // 3초 후 제거
        let removeAction = SKAction.removeFromParent()
        node.run(SKAction.sequence([waitAction, removeAction]))

        addChild(node)
    }

}
