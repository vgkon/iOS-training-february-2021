//
//  MovieSceneController.swift
//  iOSMovieApp
//
//  Created by Vera Sidiropoulou on 26/2/21.
//

import Foundation
import UIKit

class MovieSceneController : UIViewController {
    
    @IBOutlet var movieImage: UIImageView!
    @IBOutlet var movieTitle: UILabel!
    @IBOutlet var movieRatings: UILabel!
    @IBOutlet var movieGenre: UILabel!
    @IBOutlet var movieDescription: UILabel!
    @IBOutlet var releaseDate: UILabel!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var favouriteButton: UIButton!
    
//    private let movie = MovieDetails ()
    let movieUrl = "https://api.themoviedb.org/3/movie/18?api_key=4e1a0205795e49daf04ab861550103ad&language=en-US"
    var movieData : MovieDetails? = nil
    let movieID = String(11)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        //        setupLabels()
        //        setupImage()
        //        setupButton()
    }
    
    // 2 states for the favourite button
    func configureUI() {
        let image = UIImage(systemName: "suit.heart")
        let imageFilled = UIImage(systemName: "suit.heart.fill")
        favouriteButton.setImage(image, for: .normal)
        favouriteButton.setImage(imageFilled, for: .selected)
    }
    // tap the button
    @IBAction func buttonClicked(_ sender: UIButton) {
        favouriteButton.isSelected.toggle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NetworkManager.shared.download(query: movieID, dataType: MovieDetails.self){ [self] result in
            
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            let formatter = DateFormatter ()
            formatter.dateFormat = "DD-MM-YYYY"
            jsonDecoder.dateDecodingStrategy = .formatted(formatter)
            print(movieData?.releaseDate)
            
            
            switch result {
            case .failure(let error):
                print(error)
            case .success(let data):
                
                do {
                    
                    self.movieData = try jsonDecoder.decode(MovieDetails.self, from: data)
//                    self.movieData?.genres.forEach { genre in
//                        do{
//                            genre = try?genre.jsonDecode(Genre, from: genre)
//                        }
//                        catch{
//                            print("error decoding genre")
//                        }
//                    }
                        DispatchQueue.main.async {
                            self.movieTitle.text = self.movieData?.movieTitle
                            self.movieDescription.text = self.movieData?.movieDescription!
                            self.movieRatings.text = "Ratings :  \(self.movieData!.voteAverage!) / 10"
                            self.releaseDate.text = "Realease Date : \(self.movieData?.releaseDate)"
                            self.movieGenre.text = "\(self.movieData?.genres)"
                            
                        }
                        self.setupImage()
                    } catch {
                        print("Error decoding inside callback. SearchResultsController.textFieldShouldReturn");
                    }
                }
            }
        }
    }
    
    fileprivate extension MovieSceneController {
        
        //    func setupLabels () {
        //
        //    }
        
        func setupImage () {
            guard let imagePath = self.movieData?.posterPath else {
                print("nil image path")
                return
            }
            //        print(imagePath)
            NetworkManager.shared.download(query: imagePath , dataType: UIImage.self){ result in
                switch result {
                case .success(let data):
                    DispatchQueue.main.async {
                        self.movieImage.image = UIImage(data: data)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        //        func setupButton () {
        //        shareButton
        //        favouriteButton
        //    }
        
    }

