//
//  UIImageViewExtension.swift
//  Task
//
//  Created by apple on 29/08/22.
//

import UIKit

extension UIImageView {
    
    func getImageFromLocalDirectory(havingUrl url: String) {
        let fileManager = FileManager.default
        let filePath = FilePathHandler.getFileLocalPath(fileName: (url as NSString).lastPathComponent)
        if fileManager.fileExists(atPath: filePath), let image = UIImage(contentsOfFile: filePath) {
            self.image = image
            return
        }
        self.image = UIImage(named: "image")
    }
    
    func decodeImage(_ encodeString: String) {
        
        if  let dataDecoded : Data = Data(base64Encoded: encodeString, options: .ignoreUnknownCharacters) {
            DispatchQueue.main.async() {
                if let image = UIImage(data: dataDecoded) {
                    self.image = image
                }
            }
        }
    }
    
    func downloadImage(url: String, downloadComplete: (() -> ())?) {
        let fileManager = FileManager.default
        let filePath = FilePathHandler.getFileLocalPath(fileName: url)
        if fileManager.fileExists(atPath: filePath), let image = UIImage(contentsOfFile: filePath) {
            DispatchQueue.main.async {
                self.image = image
                if let completion = downloadComplete {
                    completion()
                }
            }
            return
        }
        if let Url = URL.init(string: url) {
            getDataFromUrl(url: Url) { data, response, error in
                guard let data = data, error == nil
                    else {
                        if let completion = downloadComplete {
                            completion()
                        }
                        return
                }
                DispatchQueue.main.async() {
                    if let image = UIImage(data: data) {
                        if !(fileManager.fileExists(atPath: filePath)) {
                            if let imageData = image.pngData() {
                                _ = fileManager.createFile(atPath: filePath, contents: imageData, attributes: nil)
                            } else if let imageData = image.jpegData(compressionQuality: 0.5) {
                                _ = fileManager.createFile(atPath: filePath, contents: imageData, attributes: nil)
                            }
                        }
                        if self.image != image{
                            DispatchQueue.main.async {
                                self.image = image
                                if let completion = downloadComplete {
                                    completion()
                                }
                            }
                        }
                      return
                    }
                    
                    self.image = UIImage(named: "defaultGrey")
                    if let completion = downloadComplete {
                        completion()
                    }
                }
            }
            return
        }
        self.image = UIImage(named: "defaultGrey")
        if let completion = downloadComplete {
            completion()
        }
    }
    private func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
}
