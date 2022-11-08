//
//  UserSceneController.swift
//  iOSMovieApp
//
//  Created by Vera Sidiropoulou on 3/3/21.
//

import Foundation
import UIKit

class UserSceneController : UIViewController {
    
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var userName: UILabel!
    @IBOutlet var userMail: UILabel!
    @IBOutlet var usersfavoutiteMovies: UILabel!
    @IBOutlet var usersShares: UILabel!
    @IBOutlet var userMoviesRated: UILabel!
    
    private let userDetails = UsersDetails()
    private let usersMoviesRated = MoviesdRated()
    private let usersFavouriteMovies = UserFavouriteMovies()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    
    
    
    
    
    
}
