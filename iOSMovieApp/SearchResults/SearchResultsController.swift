//
//  SearchResultsController.swift
//  iOSMovieApp
//
//  Created by Vassilis Konstantakopoulos on 25/2/21.
//

import UIKit

class SearchResultsController: BaseViewController {
    
    @IBOutlet var resultTypeSelector: UISegmentedControl!
    @IBOutlet var searchTextField: UITextField!
    
    @IBOutlet var searchResultsTableView: UITableView!
    
    var movieResults : [MovieResult] = []
    var tvShowResults : [TVShowResult] = []
    var segmentType : Segment = .movies
    var searchTerm : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchTextField.delegate = self
        self.resultTypeSelector.titleForSegment(at: 0)
        self.searchTextField.text = searchTerm
        
        self.title = "Search Results"
        // Do any additional setup after loading the view.
        searchResultsTableView.dataSource = self
        searchResultsTableView.delegate = self
        searchResultsTableView.rowHeight = UITableView.automaticDimension
        searchResultsTableView.estimatedRowHeight = UITableView.automaticDimension
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleContainerViewTap))
        self.view.addGestureRecognizer(tapRecognizer)
        tapRecognizer.cancelsTouchesInView = false;
        
        search(query: searchTerm!, dataType: APICallTypes.searchMovie)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func handleContainerViewTap() {
        self.view.endEditing(true)
    }
    
    @IBAction func typeChanged(_ sender: UISegmentedControl) {
        segmentType = Segment(rawValue: sender.selectedSegmentIndex)!
        
        if self.segmentType.rawValue == 0{
            search(query: searchTerm!, dataType: APICallTypes.searchMovie)
        }else {
            search(query: searchTerm!, dataType: APICallTypes.searchTVShow)
        }
    }
    
    func getType() -> Decodable.Type{
        switch segmentType{
        case .movies:
            return MovieResult.self
        case .tvShows:
            return TVShowResult.self
        }
    }
    
}

extension SearchResultsController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return segmentType.rawValue == 0 ? movieResults.count : tvShowResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "SearchResultsTableViewCell",
            for: indexPath
        ) as! SearchResultsTableViewCell
        
        if segmentType.rawValue == 0 && movieResults.isEmpty == false{
            var movie: MovieResult
            movie = movieResults[indexPath.row]
            cell.setup(model: movie)
        }else if segmentType.rawValue == 1 && tvShowResults.isEmpty == false{
            var series: TVShowResult
            series = tvShowResults[indexPath.row]
            cell.setup(model: series)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
}

extension SearchResultsController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch segmentType{
        case .movies:
            guard let movieId = movieResults[indexPath.row].movieID else{
                return
            }
            self.cellWasSelected(with: movieId)
            self.searchResultsTableView.deselectRow(at: indexPath, animated: true)
        case .tvShows:
            guard let tvShowId = tvShowResults[indexPath.row].tvShowId else{
                return
            }
            self.cellWasSelected(with: tvShowId)
            self.searchResultsTableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func cellWasSelected(with id: Int) {
        if let movieSceneController = self.storyboard?.instantiateViewController(identifier: "MovieSceneController") as? MovieSceneController{
            movieSceneController.mediaId = String(id)
            movieSceneController.media = (segmentType == .movies) ? .movie : .tvShow
            self.show(movieSceneController, sender: nil)
        }
    }
}

extension SearchResultsController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let searchTerm = textField.text, searchTerm.isEmpty == false else{
            return true
        }
        self.searchTerm = searchTerm
        if self.segmentType.rawValue == 0{
            search(query: self.searchTerm!, dataType: APICallTypes.searchMovie)
        }else {
        }
        textField.resignFirstResponder()
        
        return true
    }
    
    func search(query: String, dataType: APICallTypes){
        NetworkManager.shared.download(query: query, dataType: dataType) { [weak self] result in
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .iso8601
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print(error)
            case .success(let data):
                if dataType == APICallTypes.searchMovie{
                    do {
                        self.movieResults = try jsonDecoder.decode(SearchResults<MovieResult>.self, from: data).results
                    } catch {
                        print("Error decoding inside callback. SearchResultsController.textFieldShouldReturn");
                    }
                    
                    self.movieResults.forEach{ movieResult in
                        print("Movie ID: \(movieResult.movieID!) Movie Name: \(movieResult.movieTitle!)")
                    }
                    self.movieResults = self.movieResults.sorted(){ (lhs: MovieResult, rhs: MovieResult) -> Bool in
                        return lhs.popularity! > rhs.popularity!
                    }
                    DispatchQueue.main.async{
                        self.searchResultsTableView.reloadData()
                    }
                }else {
                    do {
                        self.tvShowResults = try jsonDecoder.decode(SearchResults<TVShowResult>.self, from: data).results
                    } catch {
                        print("Error decoding inside callback. SearchResultsController.textFieldShouldReturn");
                    }
                    
                    self.tvShowResults.forEach{ tvShowResult in
                        print("Movie ID: \(tvShowResult.tvShowId!) Movie Name: \(tvShowResult.name!)")
                    }
                    self.tvShowResults = self.tvShowResults.sorted(){ (lhs: TVShowResult, rhs: TVShowResult) -> Bool in
                        return lhs.popularity! > rhs.popularity!
                    }
                    DispatchQueue.main.async{
                        self.searchResultsTableView.reloadData()
                    }
                }
            }
        }
    }
    
}
