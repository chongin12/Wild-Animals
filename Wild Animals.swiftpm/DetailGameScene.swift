//
//  DetailGameScene.swift
//  Wild Animals
//
//  Created by 정종인 on 3/25/24.
//

import Foundation
import SpriteKit

final class DetailGameScene: SKScene {
    let patNode = SKSpriteNode(imageNamed: "pat.png")

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

        makePat()
    }

    public func foodEffect() {
        addFood()
    }

    public func patEffect(at point: CGPoint) {
        let convertedPoint = CGPoint(x: point.x, y: self.size.height - point.y)
//        addPat(at: convertedPoint)
        movePat(at: convertedPoint)
    }

    public func heartEffect(at point: CGPoint) {
        let convertedPoint = CGPoint(x: point.x, y: self.size.height - point.y)
        addHeart(at: convertedPoint)
    }

    private func addFood() {
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
        let side: CGFloat = width * 0.10
        node.size = CGSize(width: side, height: side)
        node.position = point

        let waitAction = SKAction.wait(forDuration: 1) // 1초 후 제거
        let removeAction = SKAction.removeFromParent()
        node.run(SKAction.sequence([waitAction, removeAction]))

        addChild(node)
    }

    private func makePat() {
        let side: CGFloat = width * 0.10
        patNode.size = CGSize(width: side, height: side)
        patNode.position = CGPoint(x: width * 0.9, y: height * 0.1)

        addChild(patNode)
    }

    private func movePat(at point: CGPoint) {
        patNode.position = point
    }

    private func addHeart(at point: CGPoint) {
        let node = SKSpriteNode(imageNamed: "heart.png")
        let side: CGFloat = width * 0.05
        node.size = CGSize(width: side, height: side)
        node.position = point
        addChild(node)

        let moveUpAction = SKAction.moveBy(x: 0, y: 500, duration: 2)
        let fadeOutAction = SKAction.fadeOut(withDuration: 2)
        let removeAction = SKAction.removeFromParent()
        let sequenceAction = SKAction.sequence([SKAction.group([moveUpAction, fadeOutAction]), removeAction])

        node.run(sequenceAction)
    }
}
