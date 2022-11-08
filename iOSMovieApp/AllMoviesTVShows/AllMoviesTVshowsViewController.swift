//
//  AllMoviesTVshowsViewController.swift
//  iOSMovieApp
//
//  Created by Δημητρα Παπουλια on 3/3/21.
//

import UIKit

class AllMoviesTVshowsViewController: BaseViewController{
    
    
    
    @IBOutlet var allCollectionView: UICollectionView!
    @IBOutlet var searchField: UITextField!
    
    var moviecallcount = 0;
    var tvshowcallcount = 0;
    
    var popularMovies: [MovieResult] = []
    var popularTVShows: [TVShowResult] = []
    var upcomingMovies: [MovieResult] = []
    var favouriteMovies: [MovieResult] = []
    var favouriteTVShows: [TVShowResult] = []
    var favouriteTVShowsIDs: [Int] = []
    var favouriteMoviesIDs: [Int] = []
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchField.delegate = self
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))//kleisimo pliktrologioy
        view.addGestureRecognizer(tapRecognizer)
        tapRecognizer.cancelsTouchesInView = false;
        
        if UserDefaults.standard.string(forKey: "accountId") == nil {
            NetworkManager.shared.download(query: "", dataType: APICallTypes.userDetails){ result in
                
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let data):
                    
                    do{
                        let userDetails = try jsonDecoder.decode(UsersDetails.self, from: data)
                        UserDefaults.standard.setValue(userDetails.username, forKey: "username")
                        UserDefaults.standard.setValue(userDetails.userFullName, forKey: "fullName")
                        UserDefaults.standard.setValue(userDetails.avatar?.tmdb?.avatarPath, forKey: "avatar")
                        UserDefaults.standard.setValue(userDetails.accountId, forKey: "accountId")
                        self.callFavouriteMovies()
                        self.callFavouriteTVShows()
                    } catch {
                        print("Error decoding inside callback.");
                    }
                }
            }
        }
                
        allCollectionView.register(HeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderCollectionReusableView")
        allCollectionView.register(AllCollectionViewCell.nib(), forCellWithReuseIdentifier: "AllCollectionViewCell")
        allCollectionView.delegate = self
        allCollectionView.dataSource = self
        allCollectionView.collectionViewLayout = AllMoviesTVshowsViewController.createLayout()
        callMovies()
        callTVShows()
        callUpcomingMovies()
        callFavouriteMovies()
        callFavouriteTVShows()
        self.navigationController?.setViewControllers([self], animated: false)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    //kleisimo toy pliktrologioy otan o xristis pataei eksw apo auto
    @objc func DismissKeyboard(){
        view.endEditing(true)
    }
    
    static func createLayout() -> UICollectionViewCompositionalLayout{
        
        let insets = NSDirectionalEdgeInsets(top: 15, leading: 30, bottom: 15, trailing: 0)
        let insets2 = NSDirectionalEdgeInsets(top: 15, leading: 25, bottom: 15, trailing: 30)
        let leadingItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        leadingItem.contentInsets = insets
        
        let trailingItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        trailingItem.contentInsets = insets

        
        let topGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.58), heightDimension: .fractionalWidth(1)),
            subitems: [leadingItem])
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(30))
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                        elementKind: UICollectionView.elementKindSectionHeader,
                                                                        alignment: .top)
        sectionHeader.contentInsets = insets2
        let section = NSCollectionLayoutSection(group: topGroup)
        section.boundarySupplementaryItems = [sectionHeader]
        section.orthogonalScrollingBehavior = .continuous
        
        return UICollectionViewCompositionalLayout(section: section)
        
    }
    
    //network calls
    
    func callMovies(){
        
        NetworkManager.shared.download(query: "", dataType: APICallTypes.popularMovie){ result in
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .iso8601
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            switch result {
            case .failure(let error):
                print(error)
            case .success(let data):
                do {
                    self.popularMovies = try jsonDecoder.decode(SearchResults<MovieResult>.self, from: data).results
                } catch {
                    print("Error decoding inside callback. SearchResultsController.textFieldShouldReturn");
                }
                
                self.popularMovies.forEach{ movieResult in
                    print("Movie ID: \(movieResult.movieID!) Movie Name: \(movieResult.movieTitle!)")
                }
                self.popularMovies.sorted(){ (lhs: MovieResult, rhs: MovieResult) -> Bool in
                    return lhs.popularity! > rhs.popularity!
                }
                DispatchQueue.main.async{
                    self.moviecallcount += 1
                    self.allCollectionView.reloadData()
                }
            }
            
        }
    }
    
    func callTVShows(){
        
        NetworkManager.shared.download(query: "", dataType: APICallTypes.popularTVShow){ result in
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .iso8601
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            switch result {
            case .failure(let error):
                print(error)
            case .success(let data):
                do {
                    self.popularTVShows = try jsonDecoder.decode(SearchResults<TVShowResult>.self, from: data).results
                    
                } catch {
                    print("Error decoding inside callback. SearchResultsController.textFieldShouldReturn");
                }
                
                self.popularTVShows.forEach{ TvShowsResult in
                    print("Show ID: \(TvShowsResult.tvShowId!) Show Name: \(TvShowsResult.name!)")
                }
                self.popularTVShows.sorted(){ (lhs: TVShowResult, rhs: TVShowResult) -> Bool in
                    return lhs.popularity! > rhs.popularity!
                }
                DispatchQueue.main.async{
                    self.tvshowcallcount += 1
                    self.allCollectionView.reloadData()
                }
            }
        }
    }
    
    func callUpcomingMovies(){
        
        NetworkManager.shared.download(query: "", dataType: APICallTypes.upcomingMovieResult){ result in
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .iso8601
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            switch result {
            case .failure(let error):
                print(error)
            case .success(let data):
                do {
                    self.upcomingMovies = try jsonDecoder.decode(SearchResults<MovieResult>.self, from: data).results
                    
                } catch {
                    print("Error decoding inside callback. SearchResultsController.textFieldShouldReturn");
                }
                
                self.upcomingMovies.sorted(){ (lhs: MovieResult, rhs: MovieResult) -> Bool in
                    return lhs.popularity! > rhs.popularity!
                }
                DispatchQueue.main.async{
                    self.allCollectionView.reloadData()
                }
            }
        }
    }
    
    func callFavouriteMovies(){
        self.favouriteMoviesIDs.removeAll()
        NetworkManager.shared.download(query: "", dataType: APICallTypes.userFavouriteMovies){ result in
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .iso8601
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            switch result {
            case .failure(let error):
                print(error)
            case .success(let data):
                do {
                    self.favouriteMovies = try jsonDecoder.decode(SearchResults<MovieResult>.self, from: data).results
                    self.favouriteMovies.forEach{ movie in
                        if let _ = movie.movieID {
                            self.favouriteMoviesIDs.append(movie.movieID!)
                        }
                    }
                    
                } catch {
                    print("Error decoding inside callback. SearchResultsController.textFieldShouldReturn");
                }
                
                self.favouriteMovies.sorted(){ (lhs: MovieResult, rhs: MovieResult) -> Bool in
                    return lhs.popularity! > rhs.popularity!
                }
                DispatchQueue.main.async{
                    self.allCollectionView.reloadData()
                }
            }
        }
    }
    
    func callFavouriteTVShows(){
        self.favouriteTVShowsIDs.removeAll()
        NetworkManager.shared.download(query: "", dataType: APICallTypes.userFavouriteTVShows){ result in
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .iso8601
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            switch result {
            case .failure(let error):
                print(error)
            case .success(let data):
                do {
                    self.favouriteTVShows = try jsonDecoder.decode(SearchResults<TVShowResult>.self, from: data).results
                    self.favouriteTVShows.forEach{ tvShow in
                        if let _ = tvShow.tvShowId {
                            self.favouriteTVShowsIDs.append(tvShow.tvShowId!)
                        }
                    }
                } catch {
                    print("Error decoding inside callback. SearchResultsController.textFieldShouldReturn");
                }
                
                self.favouriteTVShows.forEach{ TvShowsResult in
                    print("Show ID: \(TvShowsResult.tvShowId!) Show Name: \(TvShowsResult.name!)")
                }
                self.favouriteTVShows.sorted(){ (lhs: TVShowResult, rhs: TVShowResult) -> Bool in
                    return lhs.popularity! > rhs.popularity!
                }
                DispatchQueue.main.async{
                    self.tvshowcallcount += 1
                    self.allCollectionView.reloadData()
                }
            }
        }
    }
    
}

extension AllMoviesTVshowsViewController : UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0{
            guard let movieId = popularMovies[indexPath.row].movieID else{
                return
            }
            self.cellWasSelected(mediaId: movieId, media: .movie)
            self.allCollectionView.deselectItem(at: indexPath, animated: true)
        }else if indexPath.section == 2{
            guard let movieId = upcomingMovies[indexPath.row].movieID else{
                return
            }
            self.cellWasSelected(mediaId: movieId, media: .movie)
            self.allCollectionView.deselectItem(at: indexPath, animated: true)
        }else if indexPath.section == 1 {
            guard let tvShowId = popularTVShows[indexPath.row].tvShowId else{
                return
            }
            self.cellWasSelected(mediaId: tvShowId, media: .tvShow)
            self.allCollectionView.deselectItem(at: indexPath, animated: true)
        }else if indexPath.section == 3 {
            guard let movieId = favouriteMovies[indexPath.row].movieID else{
                return
            }
            self.cellWasSelected(mediaId: movieId, media: .movie)
            self.allCollectionView.deselectItem(at: indexPath, animated: true)
            
        }else if indexPath.section == 4 {
            guard let tvShowId = favouriteTVShows[indexPath.row].tvShowId else{
                return
            }
            self.cellWasSelected(mediaId: tvShowId, media: .tvShow)
            self.allCollectionView.deselectItem(at: indexPath, animated: true)
            
        }
    }
    
    func cellWasSelected(mediaId id: Int, media: MediaType) {
        if let movieSceneController = self.storyboard?.instantiateViewController(identifier: "MovieSceneController") as? MovieSceneController{
            movieSceneController.mediaId = String(id)
            movieSceneController.media = media
            movieSceneController.favourite = favouriteMoviesIDs.contains(id) || favouriteTVShowsIDs.contains(id) ? true : false
            self.show(movieSceneController, sender: nil)
        }
    }
}

extension AllMoviesTVshowsViewController : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 1 {
            return popularTVShows.count
        } else if section == 2{
            return upcomingMovies.count
        } else if section == 0 {
            return popularMovies.count
        } else if section == 3{
            return favouriteMovies.count
        }else{
            return favouriteTVShows.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = allCollectionView.dequeueReusableCell(withReuseIdentifier: "AllCollectionViewCell", for: indexPath) as! AllCollectionViewCell
        if indexPath.section == 1 {
            let show = popularTVShows[indexPath.row]
            cell.setUpTvShows(model: show, favourite: favouriteTVShowsIDs.contains(show.tvShowId!) ? true : false)
        }else if indexPath.section == 0{
            let movie = popularMovies[indexPath.row]
            // var movie = array[indexPath.section][indexPath.row]
            cell.setUpMovies(model: movie, favourite: favouriteMoviesIDs.contains(movie.movieID!) ? true : false)
        }else if indexPath.section == 2{
            let movie = upcomingMovies[indexPath.row]
            cell.setUpMovies(model: movie, favourite: favouriteMoviesIDs.contains(movie.movieID!) ? true : false)
        }else if indexPath.section == 3{
            let movie = favouriteMovies[indexPath.row]
            cell.setUpMovies(model: movie, favourite: true)
        }else if indexPath.section == 4 {
            let show = favouriteTVShows[indexPath.row]
            cell.setUpTvShows(model: show, favourite: true)
        }
        cell.shareAction = {movie, tvshow in
            if let movie = movie {
                self.present(UIActivityViewController(activityItems: [movie.movieTitle!], applicationActivities: nil), animated: true)
            }else if let tvshow = tvshow {
                self.present(UIActivityViewController(activityItems: [tvshow.name!], applicationActivities: nil), animated: true)
            }
        }
        cell.favouriteAction = { movie, tvshow in
            if let _ = movie {
                self.callFavouriteMovies()
            }else if let _ = tvshow {
                self.callFavouriteTVShows()
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = allCollectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderCollectionReusableView", for:  indexPath) as! HeaderCollectionReusableView
        if indexPath.section == 0 {
            header.configure()
            header.label.text = "Popular Movies"
            return header
        }else if indexPath.section == 1 {
            header.configure()
            header.label.text = "Popular TV Shows"
            return header
        }else if indexPath.section == 2 {
            header.configure()
            header.label.text = "Upcoming Movies"
            return header
        }else if indexPath.section == 3 {
            header.configure()
            header.label.text = "Favourite Movies"
            return header
        }else if indexPath.section == 4 {
            header.configure()
            header.label.text = "Favourite TV Shows"
            return header
        }else{
            return UICollectionReusableView()
        }
        
    }
}

extension AllMoviesTVshowsViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let searchTerm = textField.text, searchTerm.isEmpty == false else{
            return true
        }
        if let searchResultsController = self.storyboard?.instantiateViewController(identifier: "SearchResultsController") as? SearchResultsController {
            searchResultsController.searchTerm = searchTerm
            self.navigationController?.show(searchResultsController, sender: nil)
        }

        textField.resignFirstResponder()
        return true
    }
    
}

