//
//  MovieDetailsViewModel.swift
//  Task
//
//  Created by Barath K on 29/08/22.
//

import UIKit

class MovieDetailsViewModel: NSObject {

    var movieDetails: MovieDetails?

    func getMovieDetails(id:Int, completion: @escaping(_ isSuccess: Bool) -> ()) {
        
        let totalUrl = "https://api.themoviedb.org/3/movie/\(id)?api_key=48b33ec538eb1f545bc72f6dc9894561"
        
        APIClient().sendRequest(totalUrl, method: .get) { [weak self](result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    guard let data = data else {return}
                    do {
                        let decodedData = try JSONDecoder().decode(MovieDetails.self, from: data)
                        self?.movieDetails = decodedData
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
    
    // MARK:- Bussiness Methods
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int) {
        return (seconds / 60, (seconds % 60))
    }
    
    func formattedDateFromString(dateString: String, withFormat format: String) -> String? {

        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-mm-dd"

        if let date = inputFormatter.date(from: dateString) {

            let outputFormatter = DateFormatter()
          outputFormatter.dateFormat = format

            return outputFormatter.string(from: date)
        }

        return nil
    }
}
