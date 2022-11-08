//
//  AllCollectionViewCell.swift
//  iOSMovieApp
//
//  Created by Δημητρα Παπουλια on 3/3/21.
//

import UIKit

class AllCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var movieImage: UIImageView!
    @IBOutlet var movieTitle: UILabel!
    @IBOutlet var movieRatings: UILabel!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var favouriteButton: UIButton!
    
    var task: URLSessionDataTask?
    var media: MediaType?
    var mediaId: Int?
    var tvmodel: TVShowResult?
    var moviemodel: MovieResult?
   
    var shareAction: ((MovieResult?, TVShowResult?) -> Void)?
    var favouriteAction: ((MovieResult?, TVShowResult?) -> Void)?
    
    @IBAction func shareContent(_ sender: UIButton) {
        shareAction?(moviemodel, tvmodel)
    }
    
    @IBAction func favoriteButtonAction(_ sender: UIButton) {
        
        favouriteButton.isSelected.toggle()
        let encoder = JSONEncoder()
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        encoder.keyEncodingStrategy = .convertToSnakeCase
        var movieFavouriteJSONData : Data?
        guard let favMediaId = self.mediaId else{
            return
        }
        //we need to inform the server about the media we want to favour
        let favouriteRequestBody = FavouriteRequestBody(mediaType: media == .movie ? "movie" : "tv", mediaId: favMediaId, favorite: favouriteButton.isSelected)
        
        do{
            movieFavouriteJSONData = try encoder.encode(favouriteRequestBody)
        }catch{
            print("Failed to encode favourite request body")
            return
        }
        guard let jsonData = movieFavouriteJSONData else{ return }
        NetworkManager.shared.post(query: "", dataToPost: jsonData, dataReturned: APICallTypes.markAsFavourite){ result in
            switch result{
            case .failure(let error):
                print(error)
            case .success(let data):
                do{
                    //decode the server response
                    let response = try jsonDecoder.decode(FavouriteResponseBody.self, from: data).success
                    if response {
                        print("success: \(response)")
                        self.favouriteAction?(self.moviemodel, self.tvmodel)
                    }else{
                        print("failure")
                    }
                }catch{
                    print("Failed to decode favourite response body")
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setImage()
        movieImage.layer.cornerRadius = 15 // gia na ginoyn stroggylemenes oi gwnies
        self.layer.cornerRadius = 15
        // Initialization code
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "AllCollectionViewCell", bundle: nil)
    }
    
    func setImage() {
        self.movieImage.backgroundColor = .darkGray
    }
    
    func configureUI() {
        let image = UIImage(systemName: "suit.heart")
        let imageFilled = UIImage(systemName: "suit.heart.fill")
        favouriteButton.setImage(image, for: .normal)
        favouriteButton.setImage(imageFilled, for: .selected)
    }
    
    func setUpMovies(model: MovieResult, favourite: Bool){
        reset()
        configureUI()
        media = .movie
        moviemodel = model
        mediaId = model.movieID
        favouriteButton.isSelected = favourite
        movieTitle.text = "\(model.movieTitle!)"
        movieRatings.text = "Rating: \(model.voteAverage!)"
        
        guard let posterPath = model.posterPath else{
            print("Nil Image path")
            return
        }
        getImage(posterPath: posterPath)
        
    }
 
    
    func setUpTvShows(model: TVShowResult, favourite: Bool){
        reset()
        configureUI()
        media = .tvShow
        tvmodel = model
        mediaId = model.tvShowId
        favouriteButton.isSelected = favourite
        movieTitle.text = "\(model.name!)"
        movieRatings.text = "Rating: \(model.voteAverage!)"
        
        guard let posterPath = model.posterPath else{
            print("Nil Image path")
            return
        }
        getImage(posterPath: posterPath)
        
    }
    
    private func getImage(posterPath: String){
        task = NetworkManager.shared.download(query: posterPath, dataType: .itemImage) { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async{
                    self?.movieImage.image = UIImage(data: data)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func reset(){
        task?.cancel()
        favouriteButton.isSelected = false
        movieImage.image = UIImage(systemName: "placeholder")
        movieTitle.text = ""
        movieRatings.text = ""
        moviemodel = nil
        tvmodel = nil
    }
}
