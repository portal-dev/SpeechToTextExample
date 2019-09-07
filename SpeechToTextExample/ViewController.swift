//
//  ViewController.swift
//  SpeechToTextExample
//
//  Created by Jonathan Kopp on 9/6/19.
//  Copyright © 2019 Jonathan Kopp. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    let speechService = SpeechService()
    
    var speechLabel: UILabel = {
        let label = UILabel()
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        label.font = UIFont.italicSystemFont(ofSize: 25)
        label.adjustsFontSizeToFitWidth = true
        label.text = "Press speach button to begin!"
        label.textAlignment = .center
        return label
    }()
    var speechButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "icons8-microphone-100"), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 50
        button.addTarget(self, action: #selector(speechPressed), for: .touchUpInside)
        return button
    }()
    var gifView : UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        //Layout
        speechLabel.frame = CGRect(x: 5, y: 100, width: view.bounds.width - 10, height: 50)
        view.addSubview(speechLabel)
        speechButton.frame = CGRect(x: view.bounds.width / 2 - 50, y: 200, width: 100, height: 100)
        view.addSubview(speechButton)
        gifView.frame = CGRect(x: 5, y: 350, width: view.bounds.width - 10, height: 200)
        view.addSubview(gifView)
        
        //Subscribing to get text once microphone is done recording!
        NotificationCenter.default.addObserver(self, selector: #selector(micOutputCompleted), name: NSNotification.Name(rawValue: "micOutput"), object: nil)
    }

    @objc func micOutputCompleted(_ notification: Notification)
    {
        let text = notification.userInfo?["output"] as? String
        speechLabel.text = text
        if(text?.lowercased() == "open sesame")//key word action
        {
            openDoor()
        }
    }
    @objc func speechPressed()
    {
        speechButton.shake()
        if(speechButton.backgroundColor == .white)
        {
            speechButton.backgroundColor = #colorLiteral(red: 0.09029659377, green: 0.456161131, blue: 1, alpha: 1)
            speechService.requestMicAccess()
            voiceAnimation()
        }else{
            speechService.stopRecording()
            speechButton.backgroundColor = .white
            speechLabel.text = "Press speach button to begin!"
            stopAnimation()
        }
        
    }
    
    //Fun gifs to play!
    func openDoor()
    {
        print("Opening the door")
        self.gifView.loadGif(name: "2534jg")
    }
    func voiceAnimation()
    {
        self.gifView.loadGif(name: "audio-spectrum-demo")
    }
    func stopAnimation()
    {
        self.gifView.image = nil
    }
}

//to spice things up a little :)
extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.35
        animation.values = [-10.0, 10.0, -10.0, 10.0, -5.0, 5.0, -2.0, 2.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}
