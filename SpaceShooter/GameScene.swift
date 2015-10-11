//
//  GameScene.swift
//  SpaceShooter
//
//  Created by Berganza on 7/10/15.
//  Copyright (c) 2015 Berganza. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var background:SKNode!
    var width = UIScreen.mainScreen().bounds.size.width
    var heigth = UIScreen.mainScreen().bounds.size.height
    
    
    var backgroundSpeed = 100.0
    var delta:NSTimeInterval = NSTimeInterval(0.0)
    var timeInterval:NSTimeInterval = NSTimeInterval(0.0)
    
    
    
    var player:SKSpriteNode!
    var repeatAction:SKAction!
    
    
    
    
    let playerCategory: UInt32 = 1 << 0
    let asteroideCategory: UInt32 = 1 << 1
    let bulletCategory: UInt32 = 1 << 2
    
    
    
    var explosion: SKEmitterNode!
    var explosionAsteroide: SKEmitterNode!
    
    
    
    var gameOver:Bool = false
    
    
    var update:Int = 0
    
    
    
    override func didMoveToView(view: SKView) {
        
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        
        
        initBackground()
        initPlayer()
        initAsteroide()

        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       
        if let touch = touches.first {
            
            let location = touch.locationInNode(self)
            if location.x > width - width/3 {
                
                if gameOver == false {
                    createBullet()
                }
                
                
            }
        }
        
    }
    
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.locationInNode(self)
            
            
            
            if location.x < width - width/3 {
                
                let newLocation:CGPoint = CGPoint(x: location.x + 80, y: location.y)
                let move = SKAction.moveTo(newLocation, duration: 0.2)
                player.runAction(move)
                
            }
            
            
            
        }
    }
    
   
    override func update(currentTime: CFTimeInterval) {
        update++
        if timeInterval == 0.0 {
            delta = 0.0
        } else {
            delta = currentTime - timeInterval
        }
        timeInterval = currentTime
        
        moveBackground()
        
    }
    
    func initBackground() {
        
        background = SKNode()
        addChild(background)
        
        for i in 0...2 {
            let tile = SKSpriteNode(imageNamed: "background")
            tile.size = CGSize(width: width, height: heigth)
            tile.anchorPoint = CGPointZero
            tile.position = CGPointMake(CGFloat(i) * width, 0)
            tile.name = "bg"
            tile.zPosition = 1
            background.addChild(tile)
        }
    }
    
    
    
    func moveBackground() {
        
        let posX = -backgroundSpeed * delta
        background.enumerateChildNodesWithName("bg", usingBlock: {( tmpSprite, stop) -> Void in
            tmpSprite.position = CGPoint(x:tmpSprite.position.x + CGFloat(posX),y:0)
            
            if tmpSprite.position.x <= -tmpSprite.frame.size.width {
                tmpSprite.position = CGPoint(x: tmpSprite.frame.size.width, y: 0)
            }
        })
    }
    
    
    func initPlayer() {
        player = SKSpriteNode(imageNamed: "Spaceship")
        player.position = CGPoint(x: 50, y: CGRectGetMidY(frame))
        
        let aspect = player.size.width/player.size.height
        
        player.size = CGSize(width: 80, height: 80/aspect)
        player.anchorPoint = CGPointMake(0.5, 0.5)
        
        player.zRotation = CGFloat( -M_PI_2 )
        player.zPosition = 2
        
        addChild(player)
        
        
        
        
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        
        player.physicsBody?.dynamic = false
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.contactTestBitMask = asteroideCategory
        player.physicsBody?.collisionBitMask = asteroideCategory
        
        
        
        
        
        
        
    }
    
    
    func createAsteriode() -> SKSpriteNode {
        let asteroide = SKSpriteNode(imageNamed: "asteroide")
        asteroide.setScale(0.3)
        asteroide.zPosition = 3
        
        let randomY = CGFloat(arc4random_uniform(UInt32(frame.size.height - asteroide.size.height * 2)))
        
        asteroide.position.y = randomY + asteroide.size.height
        asteroide.position.x = frame.size.width + asteroide.size.width
        
        
        
        asteroide.physicsBody = SKPhysicsBody(texture: asteroide.texture!, size: asteroide.size)
        asteroide.physicsBody?.categoryBitMask = asteroideCategory
        asteroide.physicsBody?.contactTestBitMask = bulletCategory
        asteroide.physicsBody?.collisionBitMask = bulletCategory
        
        
        
        
        
        return asteroide
    }
    
    func initAsteroide() {
        let wait = SKAction.waitForDuration(2)
        
        let create = SKAction.runBlock { () -> Void in
            let asteroide = self.createAsteriode()
            self.addChild(asteroide)
            
            asteroide.runAction(SKAction.moveToX(-50, duration: 2), completion: {
                asteroide.removeFromParent()
            })
        }
        
        let sequence = SKAction.sequence([wait, create])
        repeatAction = SKAction.repeatActionForever(sequence)
        
        runAction(repeatAction, withKey: "asteroide")
    }
    
    
    
    func createBullet() {
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.position.y = player.position.y
        bullet.position.x = player.position.x + 60
        bullet.setScale(0.15)
        bullet.zPosition = 4
        
        bullet.runAction(SKAction.moveToX(width + 50, duration: 0.5), completion: {
            bullet.removeFromParent()
        })
        addChild(bullet)
        
        
        
        bullet.physicsBody = SKPhysicsBody(texture: bullet.texture!, size: bullet.size)
        bullet.physicsBody?.categoryBitMask = bulletCategory
        bullet.physicsBody?.contactTestBitMask = asteroideCategory
        bullet.physicsBody?.collisionBitMask = asteroideCategory
        
        
        
    }
    
    
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        if update == 0 { return }
        update = 0
        
        
        if contact.bodyA.categoryBitMask == asteroideCategory && contact.bodyB.categoryBitMask == bulletCategory
        || contact.bodyA.categoryBitMask == bulletCategory && contact.bodyB.categoryBitMask == asteroideCategory
        
        {
            var tmpBullet:SKPhysicsBody
            var tmpAsteroide:SKPhysicsBody
            
            if contact.bodyA.categoryBitMask == asteroideCategory {
                tmpAsteroide = contact.bodyA
                tmpBullet = contact.bodyB
            } else {
                tmpAsteroide = contact.bodyB
                tmpBullet = contact.bodyA
            }
            
            tmpBullet.node?.removeFromParent()
            tmpAsteroide.node?.removeFromParent()
            
            explosionAsteroide(contact.contactPoint)
        }
        
        if contact.bodyA.categoryBitMask == playerCategory || contact.bodyB.categoryBitMask == playerCategory {
            
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
            
            explosionPlayer(self.player.position)
            
            gameOver = true
            
            self.removeActionForKey("asteroide")
            
            self.runAction(SKAction.waitForDuration(3), completion: { () -> Void in
                self.initPlayer()
                self.runAction(self.repeatAction, withKey: "asteroide")
                self.gameOver = false
            })
        }
    }
    
    
    func initExplosionPlayer() {
        explosion = SKEmitterNode(fileNamed: "Explosion1.sks")!
        explosionAsteroide = SKEmitterNode(fileNamed: "Explosion2.sks")!
    }
    
    func explosionPlayer(pos: CGPoint) {
        explosion = SKEmitterNode(fileNamed: "Explosion1.sks")!
        explosion.particlePosition = pos
        explosion.zPosition = 4
        self.addChild(explosion)
        
        self.runAction(SKAction.waitForDuration(2), completion: {
            self.explosion.removeFromParent()
        })
    }
    
    func explosionAsteroide(pos: CGPoint) {
        explosionAsteroide = SKEmitterNode(fileNamed: "Explosion2.sks")!
        explosionAsteroide.particlePosition = pos
        explosionAsteroide.zPosition = 4
        self.addChild(explosionAsteroide)
        
        self.runAction(SKAction.waitForDuration(2), completion: {
            self.explosionAsteroide.removeFromParent()
        })
    }

    
    
    
}








