//
//  GameViewController.swift
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
import AVFoundation

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 建立skView，並使用GameScene場景
        let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView
        scene.scaleMode = .aspectFill
        skView.ignoresSiblingOrder = true
        skView.presentScene(scene)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

