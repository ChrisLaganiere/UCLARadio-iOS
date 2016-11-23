//
//  ShowViewController.swift
//  UCLA Radio
//
//  Created by Christopher Laganiere on 6/8/16.
//  Copyright © 2016 ChrisLaganiere. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import UserNotifications

class ShowViewController: BaseViewController {
    
    static let storyboardID = "showViewController"
    
    var show: Show?
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var djsLabel: UILabel!
    @IBOutlet weak var blurbLabel: UILabel!
    
    @IBOutlet weak var notificationsSwitch: UISwitch!
    
    
    @IBAction func notificationsToggled(_ sender: UISwitch) {
        if let show = show {
            if #available(iOS 10.0, *) {
                let current = UNUserNotificationCenter.current()
                if sender.isOn {
                    let requestIdentifier = show.title
                    
                    let content = UNMutableNotificationContent()
                    content.title = "UCLA Radio"
                    content.subtitle = show.title + " is on in 15 minutes!"
                    content.body = "Woah! These new notifications look amazing! Don’t you agree?"
                    
                    var notificationTime = show.time
                    notificationTime.minute = -15
                    
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: notificationTime,
                                                                repeats: true)
                    
                    let request = UNNotificationRequest(identifier: requestIdentifier,
                                                        content: content,
                                                        trigger: trigger)
                    
                    current.add(request)
                } else {
                    current.removePendingNotificationRequests(withIdentifiers: [show.title])
                }
                

            } else {
                
                let notification = UILocalNotification()
                
                notification.alertBody = show.title + " is on in 15 minutes!!"
                
                let calendar = NSCalendar(calendarIdentifier: .gregorian)!

                let notificationDate = calendar.date(byAdding: DateComponents(minute: -15), to: show.getNextDateOfShow())!
                
                
                print("Notification Date: \(notificationDate)")
                
                notification.fireDate = notificationDate
                notification.repeatInterval = .weekOfYear
                notification.repeatCalendar = Calendar.current
                notification.soundName = UILocalNotificationDefaultSoundName;
                
                if sender.isOn {
                    UIApplication.shared.scheduleLocalNotification(notification)
                } else {
                    UIApplication.shared.cancelLocalNotification(notification)
                }
            }
        }
        UserDefaults.standard.set(notificationsSwitch.isOn, forKey: (show?.title)! + "-switchState")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeLabel.textColor = UIColor.lightGray
        
        genreLabel.textColor = UIColor.darkGray
        blurbLabel.textColor = UIColor.darkGray
        djsLabel.textColor = UIColor.darkGray
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        if let show = show {
            notificationsSwitch.isOn =  UserDefaults.standard.bool(forKey: show.title + "-switchState")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let show = show {
            styleForShow(show)
            
            // track view analytics
            let tracker = GAI.sharedInstance().defaultTracker
            tracker?.set(kGAIScreenName, value: "Show: \(show.title)")
            let builder = GAIDictionaryBuilder.createScreenView()
            if let builder = builder {
                tracker?.send(builder.build() as [NSObject : AnyObject])
            }
        }
    }
    
    //func getLocalizedTimeString(showTime: DateComponents)
    
    fileprivate func styleForShow(_ show: Show) {
        
        let formatter = DateFormatter()
        formatter.amSymbol = formatter.amSymbol.lowercased()
        formatter.pmSymbol = formatter.pmSymbol.lowercased()
        
        // Format: Shorterned day of week (EEE), Shortened 12 hour (h), AM/PM (a)
        formatter.dateFormat = "EEE ha"
        
        let showDate = show.getClosestDateOfShow()
        
        timeLabel.text = formatter.string(from: showDate)
        titleLabel.text = show.title
        djsLabel.text = show.djString
        
        let placeholder = UIImage(named: "radio")
        if let picture = show.picture {
            imageView.sd_setImage(with: RadioAPI.absoluteURL(picture), placeholderImage: placeholder)
        } else {
            imageView.image = placeholder
        }
        
        genreLabel.text = ""
        if let genre = show.genre {
            genreLabel.text = genre
        }
        
        blurbLabel.text = ""
        if let blurb = show.blurb {
            blurbLabel.text = blurb
        }
    }
}
