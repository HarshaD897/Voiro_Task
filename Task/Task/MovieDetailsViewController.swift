//
//  MovieDetailsViewController.swift
//  Task
//
//  Created by Barath K on 29/08/22.
//

import UIKit

class MovieDetailsViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var releaseLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var castLabel: UILabel!

    private lazy var viewModel: MovieDetailsViewModel = {
        return MovieDetailsViewModel()
    }()
    var selectedList: MovieList!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Movie Details"
        
        self.callingServiceMethod()
        self.scrollView.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    func setupData() {
        guard let details = viewModel.movieDetails else {
            return
        }
        
        let finalUrl = baseUrlForImage + details.posterPath
        profileImage.downloadImage(url: finalUrl) {
            print("Image Downloaded Successfully: \(finalUrl)")
        }
        
        self.titleLabel.text = details.title
        let duration = viewModel.secondsToHoursMinutesSeconds(details.runtime)
        self.durationLabel.text = "\(duration.0) hour \(duration.1) mins"
        self.releaseLabel.text = viewModel.formattedDateFromString(dateString: details.releaseDate, withFormat: "dd MMMM yyyy")
        let languages = details.spokenLanguages.compactMap { $0.englishName }.joined(separator: ", ")
        self.languageLabel.text = languages
        let genres = details.genres.compactMap { $0.name }.joined(separator: ", ")
        self.genreLabel.text = genres
        self.ratingLabel.text = "\(details.voteAverage) & \(details.voteCount) votes"
        
        self.aboutLabel.text = details.overview
        
        self.castLabel.text = details.productionCompanies.compactMap { $0.name }.joined(separator: "\n\n")
    }
    
    //MARK: - Calling Service  Method
    
    func callingServiceMethod() {
        
        if !Reachability.isConnectedToNetwork() {
            return
        }
        self.showIndicatorMethod()
        self.viewModel.getMovieDetails(id: selectedList.id, completion: { isSuccess in
            self.hiddenIndicatorMethod()
            if isSuccess {
                self.scrollView.isHidden = false
                self.setupData()
                return
            }
        })
    }
  

    // MARK:- Show & Hidden Indicator Methods
    
    func showIndicatorMethod() {
        if let image = UIImage(named: "load") {
            let  customIndicator = MyIndicator(frame: CGRect(x: (screenWidth - 100) / 2, y: (screenHeight - 100) / 2, width: 100, height: 100), image: image)
            self.view.addSubview(customIndicator)
            customIndicator.startAnimating()
        }
    }
    
    func hiddenIndicatorMethod() {
        for subList in self.view.subviews {
            if subList is MyIndicator {
                subList.removeFromSuperview()
            }
        }
    }

}
