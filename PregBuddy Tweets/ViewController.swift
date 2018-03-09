//
//  ViewController.swift
//  PregBuddy Tweets
//
//  Created by CBH iOS on 06/03/18.
//  Copyright © 2018 MM iOS. All rights reserved.
//

import UIKit
import TwitterKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func twitterSignInBtnAction(_ sender: Any) {
        TWTRTwitter.sharedInstance().logIn { (session, error) in
            if (session != nil) {
                print("userID in as \(String(describing: session?.userID))");
                print("signed in as \(String(describing: session?.userName))");
            } else {
                print("error: \(String(describing: error?.localizedDescription))");
            }
        }
    }

}

