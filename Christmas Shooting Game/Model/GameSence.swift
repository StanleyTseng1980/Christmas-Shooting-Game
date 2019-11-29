//
//  GameSence.swift
//  Christmas Shooting Game
//
//  Created by Stanley Tseng on 2019/11/26.
//  Copyright © 2019 StanleyAppWorld. All rights reserved.
//
//  目前碰撞檢測只有拐杖糖（bullet子彈）和雪人及薑餅人（monster）的碰撞有成功
//  monster和player碰撞檢測一直無法成功（尚在找原因）
//  鈴鐺炸彈Bell Bumb目前也無法碰撞monster（若碰撞功能解決後，修改程式內容，應該可以成功）
//  玩家選擇聖誕老人或麋鹿，此功能尚未製作，目前只有聖誕老人可以選。
//  原訂有按鈕可以選擇bullet自動射擊，目前尚未製作。
//  由於SpriteKit功能尚不熟悉，未來繼續努力。

import SpriteKit
import GameplayKit

func +(left: CGPoint, right: CGPoint) -> CGPoint
{
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint
{
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint
{
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint
{
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

extension CGPoint
{
    func length() -> CGFloat
    {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint
    {
        return self / length()
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate
{
    struct PhysicsCategory
    {
        static let none      : UInt32 = 0
        static let player    : UInt32 = 1
        static let monster   : UInt32 = 2
        static let bullet    : UInt32 = 3
        static let ground    : UInt32 = 4
    }
    
    var background = SKSpriteNode(imageNamed: "snowbackground")
    let lifeValue1 = SKSpriteNode(imageNamed: "christmassocks")
    let lifeValue2 = SKSpriteNode(imageNamed: "christmassocks")
    let lifeValue3 = SKSpriteNode(imageNamed: "christmassocks")
    let bellBumb = SKSpriteNode(imageNamed: "bell")
    var scoreLabel: SKLabelNode!
    let player = SKSpriteNode(imageNamed: "santaclaus")
    var bellBumbAction = false
    var monstergogo = false
    {
        didSet
        {
            scoreLabel.text = "Score:\(monstersDestroyed)"
        }
    }
    
    var monstersDestroyed  = 0 {
        didSet {
            scoreLabel.text = "Score:\(monstersDestroyed)"
            if monstersDestroyed == 250
            {
                self.background.texture = SKTexture(imageNamed: "snowbackground1")
            }
            
            if monstersDestroyed % 250 == 0
            {
                monstergogo = true
                run(SKAction.repeatForever(
                    SKAction.sequence([
                        SKAction.run(addMonster),
                        SKAction.wait(forDuration: 1.5),
                        
                    ])
                ))
            }
        }
    }
    override func didMove(to view: SKView)
    {
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        background = SKSpriteNode(imageNamed: "snowbackground")
        background.zPosition = 0
        background.size = frame.size
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(background)
        
        let skView = SKView(frame: view.frame)
        skView.backgroundColor = .clear
        view.addSubview(skView)
        
        let scene = SKScene(size: skView.frame.size)
        scene.anchorPoint = CGPoint(x: 0.5, y: 1)
        scene.backgroundColor = .clear
        
        let emitterNode = SKEmitterNode(fileNamed: "snowmotion")
        scene.addChild(emitterNode!)
        skView.presentScene(scene)
        
        lifeValue1.position = CGPoint(x: size.width * 0.1, y: size.height * 0.90)
        lifeValue1.zPosition = 1
        lifeValue1.size = CGSize(width: 40, height: 60)
        addChild(lifeValue1)
        
        lifeValue2.position = CGPoint(x: size.width * 0.1 + lifeValue1.size.width, y: size.height * 0.90)
        lifeValue2.zPosition = 1
        lifeValue2.size = CGSize(width: 40, height: 60)
        addChild(lifeValue2)
        
        lifeValue3.position = CGPoint(x: size.width * 0.1 + lifeValue1.size.width * 2, y: size.height * 0.90)
        lifeValue3.zPosition = 1
        lifeValue3.size = CGSize(width: 40, height: 60)
        addChild(lifeValue3)
        
        bellBumb.position = CGPoint(x: size.width * 0.9, y: size.height * 0.18)
        bellBumb.zPosition = 1
        bellBumb.size = CGSize(width: 80, height: 60)
        bellBumb.name = "Bumb"
        addChild(bellBumb)
        
        player.position = CGPoint(x: size.width * 0.5, y: size.height * 0.09)
        player.zPosition = 1
        player.size = CGSize(width: 200, height: 160)
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/4)
        player.physicsBody?.isDynamic = false
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        addChild(player)
        
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addMonster),
                SKAction.wait(forDuration: 1.0),
            ])
        ))
        
        let backgroundMusic = SKAudioNode(fileNamed: "background3.mp3")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.fontColor = SKColor.systemOrange
        scoreLabel.text = "Score:0"
        scoreLabel.zPosition = 1
        scoreLabel.position = CGPoint(x: size.width * 0.75, y: size.height * 0.88)
        addChild(scoreLabel)
        
    }
    
    func random() -> CGFloat
    {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        //        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat
    {
        return random() * (max - min) + min
    }
    
    func addMonster()
    {
        // Create sprite
        let monster = monstergogo ? SKSpriteNode(imageNamed: "gingerbreadman") :SKSpriteNode(imageNamed: "snowman2_2")
        
        monster.zPosition = 1
        monster.size = CGSize(width: 80, height: 80)
        monster.physicsBody = SKPhysicsBody(circleOfRadius: monster.size.width/2)
        monster.physicsBody?.isDynamic = false
        monster.physicsBody?.allowsRotation = false
        monster.physicsBody?.affectedByGravity = false
        monster.physicsBody?.categoryBitMask = PhysicsCategory.monster
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.player
        
        // Determine where to spawn the monster along the X axis
        let actualX = random(min: monster.size.width/2, max: size.width - monster.size.width/2)
        
        // Position the monster slightly off-screen along the top edge,
        // and along a random position along the X axis as calculated above
        monster.position = CGPoint(x: actualX, y: size.height + monster.size.height/2)
        
        // Add the monster to the scene
        addChild(monster)
        var actualDuration = CGFloat(10.0)
        // Determine speed of the monster
        if(monstersDestroyed<5)
        {
            actualDuration = random(min: CGFloat(3.0), max: CGFloat(4.0))
        }
        else
        {
            actualDuration = random(min: CGFloat(1.5), max: CGFloat(3.0))
        }
        
        // Create the actions
        let actionMove = SKAction.move(to: CGPoint(x: actualX, y: -monster.size.height/2), duration: TimeInterval(actualDuration))
        
        let actionMoveDone = SKAction.removeFromParent()
        let loseAction = SKAction.run()
        { [weak self] in
            guard let `self` = self else { return }
            
            self.monsterDidCollideWithPlayer(monster: monster, player: self.player)
        }
        
        monster.run(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
    }
    
    // 讓玩家左右移動
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self){
            if location.x > player.position.x {
                let moveToRight = SKAction.moveBy(x: 1, y: 0, duration: 0.1)
                let forever = SKAction.repeat(moveToRight, count: 2)
                player.run(forever)
                
            }else{
                let moveToLeft = SKAction.moveBy(x: -1, y: 0, duration: 0.1)
                let forever = SKAction.repeat(moveToLeft, count: 2)
                player.run(forever)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        // 1 - Choose one of the touches to work with
        guard let touch = touches.first else {
            player.removeAllActions()
            return
        }
        
        let touchLocation = touch.location(in: self)
        
        // 2 - Set up initial location of bullet
        let bullet = SKSpriteNode(imageNamed: "candycane")
        bullet.position = player.position
        bullet.zPosition = 1
        bullet.size = CGSize(width: 50, height: 60)
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width/2)
        bullet.physicsBody?.categoryBitMask = PhysicsCategory.bullet
        bullet.physicsBody?.contactTestBitMask = PhysicsCategory.monster
        bullet.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        // 3 - Determine offset of location to bullet
        let offset = touchLocation - bullet.position
        
        // 4 - Bail out if you are shooting down or backwards
        if offset.y < 0 { return }
        run(SKAction.playSoundFileNamed("gun.mp3", waitForCompletion: false))
        // 5 - OK to add now - you've double checked position
        addChild(bullet)
        
        // 6 - Get the direction of where to shoot
        let direction = offset.normalized()
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + bullet.position
        
        // 9 - Create the actions
        let actionMove = SKAction.move(to: realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        bullet.run(SKAction.sequence([actionMove, actionMoveDone]))
        
        let emitter = SKEmitterNode(fileNamed: "fireexplosion")
        emitter?.position = CGPoint(x: 0, y: -bullet.size.height/2)
        emitter?.zPosition = 1
        bullet.addChild(emitter!)
    }
    
    // 鈴鐺炸彈攻擊
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        for touch in touches
        {
            // 產生鈴鐺影分身效果
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            if touchedNode.name == "Bumb"
            {
                let emitter = SKEmitterNode(fileNamed: "firebomb")
                emitter?.position = CGPoint(x: frame.midX, y: frame.midY)
                emitter?.zPosition = 1
                emitter?.numParticlesToEmit = 40 // 設定出現50個就消失
                scene?.addChild(emitter!)
                
                // 增加大型鈴鐺炸彈
                let emitterBell = SKEmitterNode(fileNamed: "forbell")
                emitterBell?.position = CGPoint(x: frame.midX, y: frame.midY)
                emitterBell?.zPosition = 1
                emitterBell?.numParticlesToEmit = 3 // 設定出現2個就消失
                scene?.addChild(emitterBell!)
            }
        }
    }
    
    func bulletDidCollideWithMonster(bullet: SKSpriteNode, monster: SKSpriteNode)
    {
        print("Hit")
        bullet.removeFromParent()
        monster.removeFromParent()
        
        monstersDestroyed += 10
        if monstersDestroyed == 500
        {
            let reveal = SKTransition.flipHorizontal(withDuration:0.2)
            let gameOverScene = GameOver(size: self.size, win: true)
            view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    // 生命值-聖誕襪
    func monsterDidCollideWithPlayer(monster: SKSpriteNode, player: SKSpriteNode)
    {
        print("Ouch")
        monster.removeFromParent()
        
        if lifeValue3.accessibilityElementsHidden == false {
            lifeValue3.removeFromParent()
            lifeValue3.accessibilityElementsHidden = true
            
        } else if lifeValue2.accessibilityElementsHidden == false {
            lifeValue2.removeFromParent()
            lifeValue2.accessibilityElementsHidden = true
        } else if lifeValue1.accessibilityElementsHidden == false {
            lifeValue1.removeFromParent()
            lifeValue1.accessibilityElementsHidden = true
        } else {
            let reveal = SKTransition.flipHorizontal(withDuration: 0.2)
            let gameOverScene = GameOver(size: self.size, win: false)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    // 拐杖糖和怪物的碰撞測試
    func didBegin(_ contact: SKPhysicsContact) {
        
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch contactMask {
        case PhysicsCategory.bullet | PhysicsCategory.monster:
            
            var firstBody: SKPhysicsBody
            var secondBody: SKPhysicsBody
            
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask
            {
                firstBody = contact.bodyA
                secondBody = contact.bodyB
            }
            else
            {
                firstBody = contact.bodyB
                secondBody = contact.bodyA
            }
            
            if ((firstBody.categoryBitMask & PhysicsCategory.monster != 0) &&
                (secondBody.categoryBitMask & PhysicsCategory.bullet != 0)) {
                if let monster = firstBody.node as? SKSpriteNode,
                    let bullet = secondBody.node as? SKSpriteNode {
                    bulletDidCollideWithMonster(bullet: bullet, monster: monster)
                    // 增加怪物死掉的聲音
                    run(SKAction.playSoundFileNamed("monsterdead.mp3", waitForCompletion: false))
                }
            }
        // 聖誕老人和怪物的碰撞測試（無法感測到...功能無法出來...Orz)
        case PhysicsCategory.monster | PhysicsCategory.player:
            var firstBody: SKPhysicsBody
            var secondBody: SKPhysicsBody
            
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask
            {
                firstBody = contact.bodyA
                secondBody = contact.bodyB
            }
            else
            {
                firstBody = contact.bodyB
                secondBody = contact.bodyA
            }
            
            if ((firstBody.categoryBitMask & PhysicsCategory.player != 0) &&
                (secondBody.categoryBitMask & PhysicsCategory.monster != 0)) {
                if let player = firstBody.node as? SKSpriteNode,
                    let monster = secondBody.node as? SKSpriteNode {
                    monsterDidCollideWithPlayer(monster: monster, player: player)
                }
            }
            
        default:
            print("Some other contact has occurred")
            
        }
    }
}
