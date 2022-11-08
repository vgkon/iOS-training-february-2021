//
//  MovieSceneController.swift
//  iOSMovieApp
//
//  Created by Vera Sidiropoulou on 26/2/21.
//

import UIKit

class MovieSceneController : BaseViewController {
    
    @IBOutlet var mediaImage: UIImageView!
    @IBOutlet var mediaTitle: UILabel!
    @IBOutlet var mediaRatings: UILabel!
    @IBOutlet var mediaGenre: UILabel!
    @IBOutlet var mediaDescription: UILabel!
    @IBOutlet var releaseDate: UILabel!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var favouriteButton: UIButton!
    @IBOutlet var mediaHomepage: UILabel!
    
    var items: [String]?
    var tvShowData : TVShowDetails? = nil
    private let movie = MovieDetails()
    var movieData : MovieDetails? = nil
    var mediaId : String = "12"
    var media = MediaType.movie
    var favourite : Bool = false
    
    let dateFormatter : DateFormatter = {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy/MM/dd"
        return dateformatter
    }()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureUI()
        
        favouriteButton.isSelected = favourite
        mediaHomepage.isUserInteractionEnabled = true
        let guestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(labelClicked(_:)))
        mediaHomepage.addGestureRecognizer(guestureRecognizer)
        
        switch media{
        case .movie:
            NetworkManager.shared.download(query: mediaId, dataType: APICallTypes.movieDetails){ [self] result in
                
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
                
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let data):
                    
                    do {
                        self.movieData = try jsonDecoder.decode(MovieDetails.self, from: data)
                        let date = dateFormatter.string(from: self.movieData!.releaseDate!)
                        let genres = movieData!.genres!
                        var genreString = ""
                        for genre in genres{
                            genreString.append("-\(genre.name) ")
                        }
                        DispatchQueue.main.async {
                            self.mediaTitle.text = self.movieData?.movieTitle
                            self.title = self.movieData?.movieTitle
                            items = ["\(mediaTitle.text!)"]
                            self.mediaDescription.text = self.movieData?.movieDescription!
                            self.mediaRatings.text = "Ratings :  \(self.movieData!.voteAverage!) / 10"
                            self.releaseDate.text = "Realease date: \(date)"
                            if self.movieData!.homePage != nil{
                                
                                self.mediaHomepage.text = "\(movieData!.homePage!)"
                            }else{
                                self.mediaHomepage.isHidden = true
                            }
                            self.mediaGenre.text = "Genres: \(genreString)"
                        }
                        self.setupImage(backdropPath: movieData?.backdropPath)
                    } catch {
                        print("Error decoding inside callback. SearchResultsController.textFieldShouldReturn");
                    }
                }
            }
        case .tvShow:
            NetworkManager.shared.download(query: mediaId, dataType: .tVShowDetails){ [self] result in
                
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
                
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let data):
                    
                    do {
                        self.tvShowData = try jsonDecoder.decode(TVShowDetails.self, from: data)
                        let airDate = dateFormatter.string(from: self.tvShowData!.firstAirDate!)
                        let endDate = dateFormatter.string(from: self.tvShowData!.lastAirDate!)
                        let genres = tvShowData!.genres!
                        var genreString = ""
                        for genre in genres{
                            genreString.append("\(genre.name) ")
                        }
                        DispatchQueue.main.async {
                            self.mediaTitle.text = self.tvShowData?.name
                            self.title = self.tvShowData?.name
                            items = ["\(mediaTitle.text!)"]
                            self.mediaDescription.text = self.tvShowData?.overview!
                            self.mediaRatings.text = "Ratings :  \(self.tvShowData!.voteAverage!) / 10"
                            self.releaseDate.text = "Running: \(airDate) - \(endDate)"
                            if self.tvShowData!.homepage != nil{
                                
                                self.mediaHomepage.text = "\(tvShowData!.homepage!)"
                            }else{
                                self.mediaHomepage.isHidden = true
                            }
                            self.mediaGenre.text = "Genres: \(genreString)"
                        }
                        self.setupImage(backdropPath: tvShowData?.backdropPath)
                    } catch {
                        print("Error decoding inside callback. SearchResultsController.textFieldShouldReturn");
                    }
                }
            }
        }
        
    }
    
    var webFromDestination: String? {
        didSet {
            if let webFromDestination = webFromDestination {
                mediaHomepage.text = " \(webFromDestination)"
            }
        }
    }
    
    @objc func labelClicked(_ sender: Any) {
        
        if let destination = self.storyboard?.instantiateViewController(identifier: "WebHomepageController") as? WebHomepageController, let webHomepage = movieData?.homePage{
            destination.homepageUrl = URL(string: webHomepage)

            self.present(destination, animated: true)
        }
        else if let destination = self.storyboard?.instantiateViewController(identifier: "WebHomepageController") as? WebHomepageController, let webHomepage = tvShowData?.homepage{
            destination.homepageUrl = URL(string: webHomepage)

            self.present(destination, animated: true)
        }
    }
    
    func configureUI() {
        
        let image = UIImage(systemName: "suit.heart")
        let imageFilled = UIImage(systemName: "suit.heart.fill")
        favouriteButton.setImage(image, for: .normal)
        favouriteButton.setImage(imageFilled, for: .selected)
        
    }
    
    @IBAction func buttonClicked(_ sender: UIButton) {
        
        favouriteButton.isSelected.toggle()
        
        let encoder = JSONEncoder()
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        encoder.keyEncodingStrategy = .convertToSnakeCase
        var movieFavouriteJSONData : Data?
        guard let favMediaId = Int(mediaId) else{
            return
        }
        let favouriteRequestBody = FavouriteRequestBody(mediaType: media == .movie ? "movie" : "tv", mediaId: favMediaId, favorite: favouriteButton.isSelected)
        
        do{
            movieFavouriteJSONData = try encoder.encode(favouriteRequestBody)
        }catch{
            print("Failed to encode favourite request body")
            return
        }
        guard let jsonData = movieFavouriteJSONData else{ return }
        NetworkManager.shared.post(query: UserDefaults.standard.string(forKey: "accountId")!, dataToPost: jsonData, dataReturned: APICallTypes.markAsFavourite){ result in
            switch result{
            case .failure(let error):
                print(error)
            case .success(let data):
                do{
                    let response = try jsonDecoder.decode(FavouriteResponseBody.self, from: data).success
                    if response {
                        print("success: \(response)")
                    }else{
                        print("failure")
                    }
                }catch{
                    print("Failed to decode favourite response body")
                }
            }
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
    }
    
    @IBAction func shareButtonAction(_ sender: UIButton) {
        
        if let name = items{
            let ac = UIActivityViewController(activityItems: name, applicationActivities: nil)
            present(ac, animated: true)
        }
    }
}


fileprivate extension MovieSceneController {

    func setupImage (backdropPath : String?) {
        guard let imagePath = backdropPath else {
            print("nil image path")
            return
        }
        NetworkManager.shared.download(query: imagePath , dataType: APICallTypes.backdropImage){ result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.mediaImage.image = UIImage(data: data)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
}

