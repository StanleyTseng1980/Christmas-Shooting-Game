//
//  GameOver.swift
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

import Foundation
import SpriteKit

var size2:CGSize?

class GameOver: SKScene {
    
    init(size: CGSize, win:Bool) {
        super.init(size: size)
        
        let button = win ? SKSpriteNode(imageNamed: "santaclaus1") : SKSpriteNode(imageNamed: "gingerbreadman")
        
        size2 = size
        backgroundColor = SKColor.white
        
        button.position = CGPoint(x: 200, y: 250)
        button.name = "GameOver"
        addChild(button)
        
        let message = win ? "You Win! >///<" : "You Lose T___T"
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.black
        
        label.position = CGPoint(x: size.width/2, y: size.height/2 + 100)
        addChild(label)
        if !win
        {
            let Music = SKAudioNode(fileNamed: "sad.mp3")
            Music.autoplayLooped = true
            addChild(Music)
        }
        else
        {
            let Music = SKAudioNode(fileNamed: "happy.mp3")
            Music.autoplayLooped = true
            addChild(Music)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        for touch in touches
        {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)
            if touchedNode.name == "GameOver"
            {
                run()
            }
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func run()
    {
        run(SKAction.sequence([
            SKAction.run() { [weak self] in
                
                guard let `self` = self else { return }
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                let scene = GameScene(size: size2!)
                self.view?.presentScene(scene, transition:reveal)
            }
        ]))
    }
}
