//
//  ViewController.swift
//  iOSMovieApp
//
//  Created by Vassilis Konstantakopoulos on 20/2/21.
//

import UIKit
import SafariServices

class LoginViewController: UIViewController {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var appNameLabel: UILabel!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var logoImage: UIImageView!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var incorrectCredentialsMessage: UILabel!
    @IBOutlet var loginButtonCircular: UIButton!
    @IBOutlet var signUp: UIButton!
    
    let notificationCenter = NotificationCenter.default
    var requestToken : RequestToken?
    var userCredentials = UserCredentials()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        loginButtonCircular.layer.cornerRadius = 15
        incorrectCredentialsMessage.isHidden = true
        notificationCenter.addObserver(self, selector: #selector(handleKeyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleKeyboard(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleContainerViewTap))
        self.view.addGestureRecognizer(tapRecognizer)
        tapRecognizer.cancelsTouchesInView = false;
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
    }
    
    @IBAction func signUpAction(_ sender: UIButton) {
        
        let vc = SFSafariViewController(url: URL(string: "https://www.themoviedb.org/signup")!)
        present(vc, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    
    @objc func handleKeyboard(notification: Notification) {
        
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: self.view)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentOffset = .zero
        } else {
            scrollView.contentOffset = CGPoint(x: 0,
                                               y: keyboardViewEndFrame.height)
        }
        
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0,
                                                        left: 0,
                                                        bottom: scrollView.contentOffset.y,
                                                        right: 0)
        
    }
    
    
    @objc func handleContainerViewTap() {
        
        self.view.endEditing(true)
    }
    
    func acceptableCredentials() -> Bool{
        if usernameTextField.text == "" || passwordTextField.text == ""{
            return false
        }
        
        userCredentials.username = usernameTextField.text!
        userCredentials.password = passwordTextField.text!
        
        return true
    }
    
    @IBAction func login(_ sender: UIButton) {
        
        if acceptableCredentials() == false{
            return
        }
        
        print(userCredentials)
        
        let group = DispatchGroup()
        let group2 = DispatchGroup()
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        var loginJSONData = Data()
        
        group.enter()
        NetworkManager.shared.download(query: "", dataType: APICallTypes.requestToken){ [self] result in
            switch result{
            case .failure(let error):
                print(error)
            case .success(let data):
                do{
                    self.userCredentials.requestToken = try jsonDecoder.decode(RequestToken.self, from: data).requestToken
                }catch{
                    print("Could not decode request token")
                }
            }
            
            do{
                loginJSONData = try encoder.encode(userCredentials)
            }catch{
                print("Failed to encode userCredentials")
            }
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.global()) {
            group2.enter()
            NetworkManager.shared.post(query: "", dataToPost: loginJSONData, dataReturned: APICallTypes.validateCredentials){ [self] result in
                switch result{
                case .failure(let error):
                    print(error)
                    DispatchQueue.main.async{
                        self.incorrectCredentialsMessage.isHidden = false
                    }
                case .success(let data):
                    do{
                        self.requestToken = try? jsonDecoder.decode(RequestToken.self, from: data)
                        loginJSONData = try encoder.encode(requestToken)
                    }catch{
                        print("Failed to login")
                    }
                }
                group2.leave()
            }
            
            group2.notify(queue: DispatchQueue.global()){
                NetworkManager.shared.post(query: "", dataToPost: loginJSONData, dataReturned: APICallTypes.requestSessionID){ [self] result in
                    switch result{
                    case .failure(let error):
                        print(error)
                    case .success(let data):
                        let sessionId = try? jsonDecoder.decode(SessionId.self, from: data).sessionId
                        UserDefaults.standard.setValue(sessionId, forKey: "sessionId")
                        loadApplication()
                    }
                    
                }
            }
        }
        
    }
    
    func loadApplication(){
        DispatchQueue.main.async{
            if let allMoviesTVShowsViewController = self.storyboard?.instantiateViewController(identifier: "AllMoviesTVshowsViewController"){
                self.navigationController?.show(allMoviesTVShowsViewController, sender: nil)
            }
        }
    }
    
}
