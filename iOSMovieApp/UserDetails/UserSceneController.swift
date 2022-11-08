//
//  UserSceneController.swift
//  iOSMovieApp
//
//  Created by Vera Sidiropoulou on 3/3/21.
//

import UIKit

class UserSceneController : UIViewController {
    
    @IBOutlet var userName: UILabel!
    @IBOutlet var favoutiteMovies: UILabel!
    @IBOutlet var moviesRated: UILabel!
    @IBOutlet var favouriteTVShows: UILabel!
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet var logoutButton: UIButton!
    
    var sourceViewController : BaseViewController?

    private var userDetails : UsersDetails?
    private var avatarPathStruct : Tmdb?
    private var usersMoviesRated = MoviesdRated()
    private var usersFavouriteMovies = UserFavouriteMovies()
    private var usersFavouriteTVShows = UserFavouriteTVShows()
    
    var sessionId = UserDefaults.standard.string(forKey: "sessionId")!

    override func viewDidLoad() {
        super.viewDidLoad()
        userImage.layer.masksToBounds = true
        userImage.layer.cornerRadius = userImage.bounds.height / 2
        loadUserData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
    }
    
    @IBAction func logoutButtonAction(_ sender: UIButton) {
        UserDefaults.standard.setValue(nil, forKey: "sessionId")
        UserDefaults.standard.setValue(nil, forKey: "username")
        UserDefaults.standard.setValue(nil, forKey: "fullName")
        UserDefaults.standard.setValue(nil, forKey: "avatar")
        UserDefaults.standard.setValue(nil, forKey: "accountId")
        self.dismiss(animated: true){
            self.sourceViewController?.returnToLogin()
        }
    }
    
    func loadUserData(){
        guard let username = UserDefaults.standard.string(forKey: "username") else{
            return
        }
        self.userName.text = username
        setupUserImage()
        
        NetworkManager.shared.download(query: self.sessionId, dataType: APICallTypes.userFavouriteMovies){ [self] result in

            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            
            switch result {
            case .failure(let error):
                print(error)
            case .success(let data):
                
                do {
                    self.usersFavouriteMovies = try jsonDecoder.decode(UserFavouriteMovies.self, from: data)
                    DispatchQueue.main.async {
                        if let userFavouriteMovies = usersFavouriteMovies.totalResults {
                            self.favoutiteMovies.text = "\(username) 's favourite movies are  \(userFavouriteMovies)"
                        }
                    }
                } catch {
                    print("Error decoding inside callback.");
                }
            }
        }
        
        NetworkManager.shared.download(query: self.sessionId, dataType: APICallTypes.userFavouriteTVShows){ [self] result in

            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            
            switch result {
            case .failure(let error):
                print(error)
            case .success(let data):
                
                do {
                    self.usersFavouriteTVShows = try jsonDecoder.decode(UserFavouriteTVShows.self, from: data)
                    DispatchQueue.main.async {
                        if let userFavouriteTVShows = usersFavouriteTVShows.totalResults {
                            self.favouriteTVShows.text = "\(username) 's favourite TV shows are  \(userFavouriteTVShows)"
                        }
                    }
                } catch {
                    print("Error decoding inside callback.");
                }
            }
        }
        
        NetworkManager.shared.download(query: self.sessionId, dataType: APICallTypes.userRatedMovies){ [self] result in

            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            
            switch result {
            case .failure(let error):
                print(error)
            case .success(let data):
                
                do {
                    self.usersMoviesRated = try jsonDecoder.decode(MoviesdRated.self, from: data)
                    DispatchQueue.main.async {
                        if let userRatedMovies = usersMoviesRated.totalResults {
                            self.moviesRated.text =  "\(username) has rated \(userRatedMovies) movies"
                        }
                    }
                    
                } catch {
                    print("Error decoding inside callback.");
                }
            }
        }
    }
}

fileprivate extension UserSceneController{
    func setupUserImage () {
        guard let userImage = UserDefaults.standard.string(forKey: "avatar") else {
            print("nil image path")
            return
        }
        NetworkManager.shared.download(query: userImage , dataType: APICallTypes.avatar){ result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.userImage.image = UIImage(data: data)
                }
            case .failure(let error):
                print(error)
            }
        }
        
    }
}
