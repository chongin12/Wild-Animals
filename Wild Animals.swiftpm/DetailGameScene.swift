//
//  DetailGameScene.swift
//  Wild Animals
//
//  Created by 정종인 on 3/25/24.
//

import Foundation
import SpriteKit

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
        self.view?.isUserInteractionEnabled = false
        size = view.bounds.size
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
