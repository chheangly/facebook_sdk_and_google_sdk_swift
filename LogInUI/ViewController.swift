//
//  ViewController.swift
//  LogInUI
//
//  Created by Pathmazing on 8/1/19.
//  Copyright © 2019 Pathmazing Inc. All rights reserved.
//

import UIKit
import Google
import GoogleSignIn
import FBSDKLoginKit


class ViewController: UIViewController {
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var loginLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func fetchUserProfile() {
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large)"]).start(completionHandler: { (connection, result, error) -> Void in
            if (error == nil){
                let fields = result as? [String:Any]
                let username = fields!["name"] as? String
                if let imageURL = ((fields!["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                    self.profileImageView.imageFromURL(urlString: imageURL)
                }
                self.welcomeLabel.text = "welcome \(username!)"
                self.loginLabel.isHidden = true
            }
        })
    }
    
    @IBAction func onGoogleSiginButtonClick(_ sender: Any) {
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @IBAction func onFacebookSignInButtonClick(_ sender: Any) {
        let facebookReadPermissions = ["public_profile", "email", "user_friends"]
        let manager = FBSDKLoginManager()
        manager.logIn(withReadPermissions: facebookReadPermissions, from: self) { (result, error) in
            if error != nil {
                print("ERROR")
                return
            }
            guard let result = result else { return }
            if result.isCancelled {
                return
            } else {
                if let _ = FBSDKAccessToken.current() {
                    self.fetchUserProfile()
                }
            }
        }
    }

}

extension ViewController: GIDSignInUIDelegate {
    
}

extension ViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            let fullName = user.profile.name
            let imageURL = user.profile.imageURL(withDimension: 100)
            welcomeLabel.text = "Welcome \(fullName!)"
            profileImageView.imageFromURL(urlString: "\(imageURL!)")
            loginLabel.isHidden = true
        }
    }
}
