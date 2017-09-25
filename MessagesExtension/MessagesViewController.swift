//
//  MessagesViewController.swift
//  MessagesExtension
//
//  Created by Andrew Ogren on 9/19/17.
//  Copyright © 2017 Andrew Ogren. All rights reserved.
//

import UIKit
import Messages

class CompactViewController: MSMessagesAppViewController {
    // ...
    @IBOutlet var mainView: UIView!
    @IBOutlet var makeDrawingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeDrawingButton.layer.cornerRadius = 10
    }
    
    @IBAction func makeDrawing(_ sender: UIButton) {
        requestPresentationStyle(.expanded)
    }
}

class ExpandedViewController: MSMessagesAppViewController {
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var topImageView: UIImageView!
    
    private var mouseSwiped = false
    private var lastPoint: CGPoint?
    
    var conversation: MSConversation?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        mouseSwiped = false
        let touch = touches.first!
        lastPoint = touch.location(in: view)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        mouseSwiped = true
        let touch = touches.first!
        let currentPoint = touch.location(in: view)
        
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        topImageView.image?.draw(in: CGRect(x: 0, y: 0, width: mainImageView.frame.size.width, height: mainImageView.frame.size.height))
        UIGraphicsGetCurrentContext()?.move(to: lastPoint!)
        UIGraphicsGetCurrentContext()?.addLine(to: currentPoint)
        UIGraphicsGetCurrentContext()?.setLineCap(.round)
        UIGraphicsGetCurrentContext()?.setLineWidth(10)
        UIGraphicsGetCurrentContext()?.setStrokeColor(red: 0, green: 0, blue: 0, alpha: 1)
        UIGraphicsGetCurrentContext()?.setBlendMode(.normal)
        UIGraphicsGetCurrentContext()?.strokePath()
        topImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        topImageView.alpha = 1
        UIGraphicsEndImageContext()

        lastPoint = currentPoint
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (!mouseSwiped) {
            UIGraphicsBeginImageContext(mainImageView.frame.size)
            topImageView.image?.draw(in: CGRect(x: 0, y: 0, width: mainImageView.frame.size.width, height: mainImageView.frame.size.height))
            UIGraphicsGetCurrentContext()?.setLineCap(.round)
            UIGraphicsGetCurrentContext()?.setLineWidth(10)
            UIGraphicsGetCurrentContext()?.setStrokeColor(red: 0, green: 0, blue: 0, alpha: 1)
            UIGraphicsGetCurrentContext()?.move(to: lastPoint!)
            UIGraphicsGetCurrentContext()?.addLine(to: lastPoint!)
            UIGraphicsGetCurrentContext()?.strokePath()
            topImageView.image = UIGraphicsGetImageFromCurrentImageContext()
            topImageView.alpha = 1
            UIGraphicsEndImageContext()
        }
        
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.draw(in: CGRect(x: 0, y: 0, width: mainImageView.frame.size.width, height: mainImageView.frame.size.height), blendMode: .normal, alpha: 1.0)
        topImageView.image?.draw(in: CGRect(x: 0, y: 0, width: mainImageView.frame.size.width, height: mainImageView.frame.size.height), blendMode: .normal, alpha: 1.0)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        topImageView.image = nil
    }
    
    @IBAction func sendDrawing(_ sender: UIButton) {
        let message: MSMessage = composeMessage()
        
        conversation!.insert(message) { error in
            if let error = error {
                print(error)
            }
        }
        
        requestPresentationStyle(.compact)
    }
    
    
    private func composeMessage() -> MSMessage {
        let layout = MSMessageTemplateLayout()
        layout.image = mainImageView.image
        print(layout.image!.size)
        layout.imageTitle = "iMessage Extension"
        layout.caption = "Hello world!"
        
        let message = MSMessage()
        message.shouldExpire = true
        message.layout = layout
        
        return message
    }
    
    
}

class MessagesViewController: MSMessagesAppViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Conversation Handling
    
    override func willBecomeActive(with conversation: MSConversation) {
        super.willBecomeActive(with: conversation)
        presentVC(for: conversation, with: presentationStyle)
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Remove child view controllers
        removeAllChildViewControllers()
        
        guard let conversation = activeConversation else {
            fatalError("Expected the active conversation")
        }
        
        presentVC(for: conversation, with: presentationStyle)
    }
    
    private func presentVC(for conversation: MSConversation, with presentationStyle: MSMessagesAppPresentationStyle) {
        let controller: UIViewController
        
        removeAllChildViewControllers()
        
        if presentationStyle == .compact {
            guard let vc = instantiateCompactVC() as? CompactViewController  else { fatalError("wrong type") }
            controller = vc
            addChildViewController(controller)
            view.addSubview(controller.view)
            
            NSLayoutConstraint(item: vc.mainView, attribute: NSLayoutAttribute.height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.0, constant: -40.0).isActive = true
            NSLayoutConstraint(item: vc.mainView, attribute: NSLayoutAttribute.height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.0, constant: -40.0).isActive = true
        } else {
            guard let vc = instantiateExpandedVC() as? ExpandedViewController  else { fatalError("wrong type") }
            vc.conversation = conversation
            controller = vc
            addChildViewController(controller)
            view.addSubview(controller.view)
            
            NSLayoutConstraint(item: vc.mainImageView, attribute: NSLayoutAttribute.height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.0, constant: -40.0).isActive = true
            NSLayoutConstraint(item: vc.topImageView, attribute: NSLayoutAttribute.height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1.0, constant: -40.0).isActive = true
        }
        
        NSLayoutConstraint.activate([
            controller.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            controller.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            controller.view.topAnchor.constraint(equalTo: view.topAnchor),
        ])
        
        controller.didMove(toParentViewController: self)
    }
    
    private func instantiateCompactVC() -> UIViewController {
        guard let compactVC = storyboard?.instantiateViewController(withIdentifier: "CompactVC") as? CompactViewController else {
            fatalError("Can't instantiate CompactViewController")
        }
        
        return compactVC
    }
    
    private func instantiateExpandedVC() -> UIViewController {
        guard let expandedVC = storyboard?.instantiateViewController(withIdentifier: "ExpandedVC") as? ExpandedViewController else {
            fatalError("Can't instantiate ExpandedViewController")
        }
        
        return expandedVC
    }
    
    private func removeAllChildViewControllers() {
        for child in childViewControllers {
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }
}
