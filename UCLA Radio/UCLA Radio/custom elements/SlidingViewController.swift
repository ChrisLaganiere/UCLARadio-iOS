//
//  SlidingViewController.swift
//  UCLA Radio
//
//  Created by Christopher Laganiere on 5/15/16.
//  Copyright © 2016 ChrisLaganiere. All rights reserved.
//

import Foundation
import UIKit
import DynamicColor

@objc enum SlidingViewControllerPosition: Int {
    case open
    case closed
}

@objc protocol SlidingVCDelegate {
    weak var slider: SlidingViewController? { get set }
}

class SliderTabView: UIView {
    func willAppear() { }
    func willDisappear() { }
}

class SlidingViewController: UIViewController {
    
    var contentViewController: UIViewController?
    var tabView: SliderTabView?
    
    var position: SlidingViewControllerPosition = .open
    weak var sliderDelegate: SlidingVCDelegate?
    
    fileprivate let AnimationDuration = 0.3
    
    fileprivate var panGesture: UIPanGestureRecognizer?
    fileprivate var tabPanGesture: UIPanGestureRecognizer?
    fileprivate var tabTapGesture: UITapGestureRecognizer?
    fileprivate var yPositionConstraint: NSLayoutConstraint?
    fileprivate var heightConstraint: NSLayoutConstraint?
    fileprivate var contentYPositionContraint: NSLayoutConstraint?
    fileprivate var contentHeightPositionContraint: NSLayoutConstraint?
    fileprivate var initialRelativeYPosition: CGFloat?
    fileprivate var initialContentBackgroundColor: UIColor?
    
    init () {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addContent(_ content: UIViewController) {
        contentViewController = content
        addChildViewController(content)
        view.addSubview(content.view)
        content.view.translatesAutoresizingMaskIntoConstraints = false
        
        contentHeightPositionContraint = NSLayoutConstraint(item: content.view, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.0, constant: 0.0)
        view.addConstraint(contentHeightPositionContraint!)
        contentYPositionContraint = NSLayoutConstraint(item: content.view, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0)
        view.addConstraint(contentYPositionContraint!)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[content]|", options: [], metrics: nil, views: ["content": content.view]))
        content.didMove(toParentViewController: self)
        if let delegate = content as? SlidingVCDelegate {
            sliderDelegate = delegate
            sliderDelegate?.slider = self
        }
        
        initialContentBackgroundColor = content.view.backgroundColor
    }
    
    func addTabView(_ tabView: SliderTabView) {
        self.tabView = tabView
        view.addSubview(tabView)
        let tabHeight = tabView.frame.size.height
        tabView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tab]|", options: [], metrics: nil, views: ["tab": tabView]))
        view.addConstraint(NSLayoutConstraint(item: tabView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: tabView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: tabHeight))
        view.superview?.setNeedsLayout()
        
        heightConstraint?.constant = tabHeight
        contentYPositionContraint?.constant = tabHeight
        contentHeightPositionContraint?.constant = -tabHeight
        
        tabView.isUserInteractionEnabled = true
        tabPanGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        tabView.addGestureRecognizer(tabPanGesture!)
        
        tabTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        tabView.addGestureRecognizer(tabTapGesture!)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        view.addGestureRecognizer(panGesture!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updatePosition(.open, animated: false)
        tabView?.willAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabView?.willDisappear()
    }
    
    func preferredConstraints() -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        constraints.append(NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: view.superview, attribute: .width, multiplier: 1.0, constant: 0))
        heightConstraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: view.superview, attribute: .height, multiplier: 1.0, constant: 0)
        constraints.append(heightConstraint!)
        constraints.append(NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: view.superview, attribute: .centerX, multiplier: 1.0, constant: 0))
        yPositionConstraint = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: view.superview, attribute: .bottom, multiplier: 1.0, constant: 0)
        constraints.append(yPositionConstraint!)
        return constraints
    }
    
    func updatePosition(_ position: SlidingViewControllerPosition, animated: Bool) {
        view.superview?.layoutIfNeeded()
        switch position {
        case .open:
            let constant = -view.frame.size.height
            yPositionConstraint?.constant = constant
        case .closed:
            var constant: CGFloat = 0
            if let tab = tabView {
                constant -= tab.frame.size.height
            }
            yPositionConstraint?.constant = constant
        }
        view.superview?.setNeedsLayout()
        self.position = position
//        sliderDelegate?.positionUpdated(position)
        
        let alpha: CGFloat = (position == .closed) ? 1.0 : 0.0
        let newColor = (position == .closed) ? UIColor.black : initialContentBackgroundColor
        if (animated) {
            UIView.animate(withDuration: AnimationDuration, animations: {
                self.view.superview?.layoutIfNeeded()
                self.tabView?.alpha = alpha
//                self.tabView?.backgroundColor = newColor
                self.contentViewController?.view.backgroundColor = newColor
            })
        }
    }
    
    func didPan(_ gesture: UIPanGestureRecognizer) {
        let touchLocation = gesture.location(in: view.superview)
        if initialRelativeYPosition == nil {
            initialRelativeYPosition = gesture.location(in: view).y
        }
        
        switch(gesture.state) {
        case .began:
            break;
        case .changed:
            if let relativeYPosition = initialRelativeYPosition {
                let MinimumYPosition = -tabView!.frame.size.height
                let MaximumYPosition = 15 + -tabView!.frame.size.height + contentViewController!.view.frame.size.height
                let touchYPosition = touchLocation.y - relativeYPosition
                let newYPosition: CGFloat = max(MinimumYPosition, min(MaximumYPosition, touchYPosition))
                view.frame.origin = CGPoint(x: 0, y: newYPosition)
                
                let openPercentage = 1.0 - (newYPosition-MinimumYPosition)/(MaximumYPosition-MinimumYPosition)
//                sliderDelegate?.openPercentageChanged(openPercentage)
                tabView?.alpha = 0.3 + 0.7*(1.0 - openPercentage)
                let newColor = UIColor.black.mixed(withColor: initialContentBackgroundColor ?? Constants.Colors.darkBlue, weight: openPercentage)
//                self.tabView?.backgroundColor = newColor
                self.contentViewController?.view.backgroundColor = newColor
            }
        default:
            let shouldOpen = touchLocation.y < view.frame.size.height/2 || gesture.velocity(in: view?.superview).y < -300
            updatePosition((shouldOpen ? .open : .closed), animated: true)
            initialRelativeYPosition = nil
        }
    }
    
    func didTap(_ gesture: UITapGestureRecognizer) {
        initialRelativeYPosition = nil
        updatePosition((position == .closed) ? .open : .closed, animated: true)
    }
}
