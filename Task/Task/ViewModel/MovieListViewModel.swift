//
//  MovieListViewModel.swift
//  Task
//
// Created by apple on 29/08/22.
//

import UIKit

class MovieListViewModel: NSObject {

    var movieListArray: [MovieList] = []

    func getMovieList(completion: @escaping(_ isSuccess: Bool) -> ()) {
        let totalUrl = "https://api.themoviedb.org/3/movie/popular?api_key=48b33ec538eb1f545bc72f6dc9894561"
        APIClient().sendRequest(totalUrl, method: .get) { [weak self](result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    guard let data = data else {return}
                    do {
                        let decodedData = try JSONDecoder().decode(MovieResponse.self, from: data)
                        self?.movieListArray = decodedData.results ?? []
                        completion(true)
                        return
                    }
                    catch {
                        print(error)
                        completion(false)
                    }
                case .failure(_):
                    completion(false)
                }
            }
        }
    }
}
