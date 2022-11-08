//
//  BaseViewController.swift
//  iOSMovieApp
//
//  Created by Δημητρα Παπουλια on 3/8/21.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        updateButtonImage()

    }
    
    @objc func addTapped(sender: UIBarButtonItem) {
        
        if let userSceneController = self.storyboard?.instantiateViewController(identifier: "UserSceneController") as? UserSceneController{
            userSceneController.sourceViewController = self
            self.present(userSceneController, animated: true)
        }
    }
    
    func returnToLogin(){
        if let loginViewController = self.storyboard?.instantiateViewController(identifier: "LoginViewController") as? LoginViewController{
            self.navigationController?.show(loginViewController, sender: nil)
        }
    }
    

    func updateButtonImage(){
        
        
        let button : UIButton
        button = UIButton(type: UIButton.ButtonType.custom)
        button.setImage(UIImage(systemName: "person.fill"), for: .normal)
        button.addTarget(self, action:#selector(addTapped), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItems = [barButton]
    }
}

