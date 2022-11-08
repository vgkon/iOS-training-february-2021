//
//  SearchResultsTableViewCell.swift
//  iOSMovieApp
//
//  Created by Vassilis Konstantakopoulos on 28/2/21.
//

import UIKit

class SearchResultsTableViewCell : UITableViewCell{
    
    @IBOutlet var itemImage: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var genreLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var voteCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //initialSetup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.itemImage.layer.cornerRadius = self.itemImage.bounds.height / 4
    }
    
    func setup(model: MovieResult) {
        
        // We need to reset the cell first
        reset()
        
        titleLabel.text = "\(model.movieTitle!)"
        genreLabel.isHidden = true
        genreLabel.text = "Genre: Default"
        ratingLabel.text = "Rating: \(model.voteAverage!)"
        voteCountLabel.text = "\(model.voteCount!) votes"
        
        guard let _ = model.posterPath else{
            print("Nil Image Path")
            return
        }
        getImage(path: model.posterPath!)
        
    }
    
    func setup(model: TVShowResult) {
        
        // We need to reset the cell first
        reset()
        
        titleLabel.text = "\(model.name!)"
        genreLabel.text = "Genre: Default"
        ratingLabel.text = "Rating: \(model.voteAverage!)"
        voteCountLabel.text = "\(model.voteCount!) votes"
        
        guard let _ = model.posterPath else{
            print("Nil Image Path")
            return
        }
        getImage(path: model.posterPath!)
        
    }
    
    private func reset() {
        
        itemImage?.image = UIImage(systemName: "photo.tv")
        itemImage?.image?.withTintColor(.white)
        titleLabel.text = ""
        genreLabel.text = ""
        ratingLabel.text = ""
        voteCountLabel.text = ""
        
    }
    
    private func getImage(path: String) {
        
        NetworkManager.shared.download(query: path, dataType: APICallTypes.itemImage) { [weak self] result in
            switch result {
            case .failure: break
            case .success(let data):
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    self?.itemImage.image = image
                }
            }
        }
        
    }
    
}
