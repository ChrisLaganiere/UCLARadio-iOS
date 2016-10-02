//
//  AboutViewController.swift
//  UCLA Radio
//
//  Created by Christopher Laganiere on 6/3/16.
//  Copyright © 2016 ChrisLaganiere. All rights reserved.
//

import Foundation
import UIKit

class AboutViewController: BaseViewController {
    
    static let storyboardID = "aboutViewController"
    
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var instagramButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var tumblrButton: UIButton!
    
    // MARK: - Actions
    
    @IBAction func facebookButtonHit(_ sender: AnyObject) {
        UIApplication.shared.openURL(URL(string: "https://www.facebook.com/UCLARadio")!)
    }
    
    @IBAction func instagramButtonHit(_ sender: AnyObject) {
        let deepURL = URL(string: "instagram:://user?username=uclaradio")!
        if UIApplication.shared.canOpenURL(deepURL) {
            UIApplication.shared.openURL(deepURL)
        }
        else {
            UIApplication.shared.openURL(URL(string: "https://www.instagram.com/uclaradio")!)
        }
    }
    
    @IBAction func twitterButtonHit(_ sender: AnyObject) {
        let deepURL = URL(string: "twitter://user?screen_name=uclaradio")!
        if UIApplication.shared.canOpenURL(deepURL) {
            UIApplication.shared.openURL(deepURL)
        } else {
            UIApplication.shared.openURL(URL(string: "https://twitter.com/uclaradio")!)
        }
    }
    
    @IBAction func tumblrButtonHit(_ sender: AnyObject) {
        let deepURL = URL(string: "tumblr://x-callback-url/blog?blogName=uclaradio")!
        if UIApplication.shared.canOpenURL(deepURL) {
            UIApplication.shared.openURL(deepURL)
        }
        else {
            UIApplication.shared.openURL(URL(string: "https://uclaradio.tumblr.com")!)
        }
    }
}
