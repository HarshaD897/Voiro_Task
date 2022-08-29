//
//  MovieListViewController.swift
//  Task
//
//  Created by apple on 29/08/22.
//

import UIKit

class MovieListViewController: UIViewController {

    @IBOutlet weak var listTableView: UITableView!
    
    private lazy var viewModel: MovieListViewModel = {
        return MovieListViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Movies"

        self.setUpTableView()
        self.callingServiceMethod()

        // Do any additional setup after loading the view.
    }
    
    //MARK: - Common Methods
    
    func setUpTableView() {
        listTableView.tableFooterView = UIView()
        self.listTableView.register(UINib.init(nibName: "ListTableViewCell", bundle: nil), forCellReuseIdentifier: "SongList")
        self.listTableView.rowHeight = UITableView.automaticDimension
        self.listTableView.estimatedRowHeight = 120.0
    }
    
    //MARK: - Calling Service  Method
    
    func callingServiceMethod() {
        
        if !Reachability.isConnectedToNetwork() {
            return
        }
        self.listTableView.isHidden = true
        self.showIndicatorMethod()
        self.viewModel.getMovieList { isSuccess in
            self.hiddenIndicatorMethod()
            if isSuccess {
                self.listTableView.isHidden = false
                DispatchQueue.main.async {
                    self.listTableView.reloadData()
                }
                return
            }
        }
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

extension MovieListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.movieListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SongList", for: indexPath) as? ListTableViewCell {
            cell.selectionStyle = .none
            cell.dataUpdate(data: self.viewModel.movieListArray[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let detailsView = Utilitys.navigatedView(bundle: "Main", identifier: "MovieDetailsViewController") as? MovieDetailsViewController {
            detailsView.selectedList = self.viewModel.movieListArray[indexPath.row]
            self.navigationController?.pushViewController(detailsView, animated: true)
        }
    }
}
