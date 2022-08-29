//
//  CommonFile.swift
//  Task
//
//  Created by apple on 29/08/22.
//

import UIKit

let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height

let baseUrlForImage = "https://image.tmdb.org/t/p"

class Utilitys: NSObject {
    static func navigatedView(bundle:String,identifier:String) -> UIViewController? {
        let storyBoard = UIStoryboard.init(name: bundle, bundle: nil)
        let commonViewController = storyBoard.instantiateViewController(withIdentifier: identifier)
        return commonViewController
    }
}
