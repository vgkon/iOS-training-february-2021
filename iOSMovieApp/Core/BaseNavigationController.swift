//
//  BaseNavigationController.swift
//  iOSMovieApp
//
//  Created by Vassilis Konstantakopoulos on 9/3/21.
//

import UIKit

final class BaseNavigationController: UINavigationController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.string(forKey: "sessionId") != nil {
            if let allMoviesTVShowsViewController = self.storyboard?.instantiateViewController(identifier: "AllMoviesTVshowsViewController"){
                self.setViewControllers([allMoviesTVShowsViewController], animated: true)
            }
        }else{
            if let loginViewController = self.storyboard?.instantiateViewController(identifier: "LoginViewController"){
                self.setViewControllers([loginViewController], animated: true)
            }
        }
    }
    
}
