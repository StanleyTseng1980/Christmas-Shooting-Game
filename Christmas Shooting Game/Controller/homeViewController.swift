//
//  homeViewController.swift
//  Christmas Shooting Game
//
//  Created by Stanley Tseng on 2019/11/27.
//  Copyright © 2019 StanleyAppWorld. All rights reserved.
//
//  目前碰撞檢測只有拐杖糖（bullet子彈）和雪人及薑餅人（monster）的碰撞有成功
//  monster和player碰撞檢測一直無法成功（尚在找原因）
//  鈴鐺炸彈Bell Bumb目前也無法碰撞monster（若碰撞功能解決後，修改程式內容，應該可以成功）
//  玩家選擇聖誕老人或麋鹿，此功能尚未製作，目前只有聖誕老人可以選。
//  原訂有按鈕可以選擇bullet自動射擊，目前尚未製作。
//  由於SpriteKit功能尚不熟悉，未來繼續努力。

import UIKit
import SpriteKit
import AVFoundation

class homeViewController: UIViewController {
    
    var player = AVQueuePlayer()
    var looper: AVPlayerLooper?
    
    // 設定連續播放的背景音樂
    func nowPlaySong() {
        
        let sound = Bundle.main.path(forResource: "background1", ofType: "mp3")
        let item = AVPlayerItem(url: URL(fileURLWithPath: sound!))
        looper = AVPlayerLooper(player: player, templateItem: item)
        player.volume = 0.3
        player.play()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nowPlaySong()
        
        // 在view產生雪花飄的Particle
        let skView = SKView(frame: view.frame)
        skView.backgroundColor = .clear
        view.addSubview(skView)
        
        let scene = SKScene(size: skView.frame.size)
        scene.anchorPoint = CGPoint(x: 0.5, y: 1)
        scene.backgroundColor = .clear
        
        let emitterNode = SKEmitterNode(fileNamed: "snowmotion")
        scene.addChild(emitterNode!)
        skView.presentScene(scene)
        
        // 使用emitter會無法點選button，所以自己創建一個
        let image = UIImage(named: "playbutton")
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.frame = CGRect(x: 85, y: 650, width: 244, height: 213)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(buttonTouchInside), for:.touchUpInside)
        self.view.addSubview(button)
        
    }
    
    // 使用自己創建的button連結自下一個view controller（GameViewController)
    @objc func buttonTouchInside(sender: UIButton!)
    {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "roleViewController") as! RoleViewController
        self.present(nextViewController, animated: true, completion: nil)
        // 移除在view開啟的skView
        for view in self.view.subviews {
            view.removeFromSuperview()
        }
        player.pause()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
