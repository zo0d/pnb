//
//  GameScene.swift
//  pnb
//
//  Created by BJ on 2019-05-16.
//  Copyright © 2019 BJ. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scoreLabel: SKLabelNode!
    var triesLabel: SKLabelNode!
    var editLabel: SKLabelNode!
    
    var tries = 5 {
        didSet {
            triesLabel.text = "Tries: \(tries)"
        }
    }
    
    var ballColors = ["ballBlue", "ballRed", "ballYellow", "ballGrey", "ballCyan", "ballGreen"]
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        
        triesLabel = SKLabelNode(fontNamed: "Chalkduster")
        triesLabel.text = "Tries: 5"
        triesLabel.horizontalAlignmentMode = .right
        triesLabel.position = CGPoint(x: 780, y: 700)
        addChild(triesLabel)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            
            let objects = nodes(at: location)
            
            if objects.contains(editLabel) {
                editingMode.toggle()
            } else {
                if editingMode {
                    if self.childNode(withName: "ball") == nil {
                        let ball = SKSpriteNode(imageNamed: ballColors.randomElement()!)
                        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                        ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
                        ball.physicsBody?.restitution = 0.4
                        ball.position.x = location.x
                        ball.position.y = 750
                        ball.name = "ball"
                        
                        addChild(ball)
                    }
                } else {
                    let size = CGSize(width: Int.random(in: 16...128), height: 16)
                    let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                    box.zRotation = CGFloat.random(in: 0...3)
                    box.position = location
                    box.name = "box"
                    box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                    box.physicsBody?.isDynamic = false
                    
                    addChild(box)
                }
            }
        }
    }
    
    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        
        if nodeA.name == "ball" {
            collisionBetween(ball: nodeA, object: nodeB)
        } else if nodeB.name == "ball"{
            collisionBetween(ball: nodeB, object: nodeA)
        }
    }
    
    func collisionBetween(ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(node: ball)
            score += 1
            tries += 1
        } else if object.name == "bad" {
            destroy(node: ball)
            score -= 1
            tries -= 1
            if tries == 0 {
                let ac = UIAlertController(title: "Game Over", message: "Play again?", preferredStyle: .alert)
                
                ac.addAction(UIAlertAction(title: "Ok", style: .default) {
                    [weak self] _ in
                    self?.enumerateChildNodes(withName: "box") {
                        (node, stop) in
                        node.removeFromParent()
                    }
                    self?.score = 0
                    self?.tries = 5
                })
                
                // Calling alert from GameScene object
                self.view?.window?.rootViewController?.present(ac, animated: true, completion: nil)
            }
        } else if object.name == "box" {
            destroy(node: object)
        }
    }
    
    func destroy(node: SKNode) {
        if node.name == "ball" {
            if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
                fireParticles.position = node.position
                addChild(fireParticles)
            }
            node.removeFromParent()
        } else {
            node.removeFromParent()
        }
    }
}
