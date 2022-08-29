//
//  APIClient.swift
//  Task
//
// Created by apple on 29/08/22.
//

import Foundation
import UIKit

public typealias JSON = [String: Any]
public typealias HTTPHeaders = [String: String]

public enum RequestMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
public enum ApiResult<Value> {
    case success(Value)
    case failure(Error)
}

struct RegenarateTokenModel: Codable {
    let valid: Bool
    let message: String
    let token: String
}


public class APIClient {
    var dataTask : URLSessionDataTask?
    public func sendRequest(_ url: String,
                            method: RequestMethod,
                            headers: HTTPHeaders? = nil,
                            body: JSON? = nil, beforeLogin: Bool = false,
                            completion: @escaping (Result<(Data?), Error>) -> Void) {
        
        guard let apiUrl = URL(string: url)else {
            completion(.failure(NSError(domain: url, code: -1, userInfo: [NSLocalizedDescriptionKey: "In Correct URL"])))
            return
        }
        
        var urlRequest = URLRequest(url: apiUrl)
        urlRequest.timeoutInterval = 30.0
        urlRequest.httpMethod = method.rawValue
        
   
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if headers != nil {
            urlRequest.allHTTPHeaderFields = headers
        }

        if let body = body {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body)
            } catch {
                print(error)
            }
        }
        
        if dataTask != nil {
            dataTask!.cancel()
        }
        
        dataTask = URLSession.shared.dataTask(with: urlRequest) { (result)  in

            switch result {

            case .success((let response, let data)):

                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200..<299 ~= statusCode else {
                    completion(.failure(NSError(domain: url, code: -1, userInfo: [NSLocalizedDescriptionKey: "InvalidResponse"])))
                    return
                }

                do {
                    if let convertedDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                        let serializedData = try? JSONSerialization.data(withJSONObject: convertedDict , options: .prettyPrinted)
                        completion(.success(serializedData))
                        return
                    }

                } catch let jsonError {
                    DispatchQueue.main.async {
                        completion(.failure(jsonError))
                    }
                }
                
            case .failure(let error):
                if let nsError = error as NSError?, nsError.code == NSURLErrorTimedOut {
                    DispatchQueue.main.async {
                        let timeOutError = NSError(domain: url, code: NSURLErrorTimedOut, userInfo: [NSLocalizedDescriptionKey: "Request timed out"])
                        completion(.failure(timeOutError as Error))
                    }
                    return
                }
                if let nsError = error as NSError?, nsError.code == 53 {
                    DispatchQueue.main.async {
                        let timeOutError = NSError(domain: url, code: 53, userInfo: [NSLocalizedDescriptionKey: "Request timed out"])
                        completion(.failure(timeOutError as Error))
                    }
                    return
                }
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        dataTask?.resume()
    }

    public func sendRequest<T: Decodable>(for: T.Type = T.self,
                                          url: String,
                                          method: RequestMethod,
                                          headers: HTTPHeaders? = nil,
                                          body: JSON? = nil,
                                          completion: @escaping (ApiResult<T>) -> Void) {
        
        return sendRequest(url, method: method,headers: headers,body: body , completion: { (result) in
            switch result {
            case .success(let dict):
                do {
                    let decoder = JSONDecoder()
                    
                    if let data = dict {
                        try completion(.success(decoder.decode(T.self, from: data)))
                    }
                    
                } catch let decodingError {
                    print("error %@",decodingError)
                    completion(.failure(decodingError))
                }
                break
            case .failure(let error):
                completion(.failure(error))
                break
                
            }
        })
    }
    
}

extension URLSession {
    func dataTask(with url: URLRequest, result: @escaping (Result<(URLResponse, Data), Error>) -> Void) -> URLSessionDataTask {
        return dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                result(.failure(error))
                return
            }
            guard let response = response, let data = data else {
                let error = NSError(domain: "error", code: 0, userInfo: nil)
                result(.failure(error))
                return
            }
            result(.success((response, data)))
        }
    }
}
