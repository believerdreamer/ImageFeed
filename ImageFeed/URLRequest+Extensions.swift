//
//  URLRequest+Extensions.swift
//  ImageFeed
//
//  Created by Архип Семёнов on 10.02.2024.
//

import Foundation

// MARK: - HTTP Request

extension URLRequest {
    static func makeHTTPRequest(
        urlString: String,
        parameters: [String: String],
        httpMethod: String
    ) -> URLRequest {
        var urlComponents = URLComponents(string: urlString)
        var queryItems: [URLQueryItem] = []
        for (key, value) in parameters {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        urlComponents?.queryItems = queryItems
        
        var request = URLRequest(url: urlComponents!.url!)
        request.httpMethod = httpMethod
        return request
    }
}

// MARK: - Network Connection

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result <Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletion: (Result <Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        let task = dataTask(with: request) { data, response, error in
            if let data = data,
               let response = response,
               let statusCode = (response as? HTTPURLResponse)?.statusCode
            {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletion(.success(data))
                } else {
                    fulfillCompletion(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fulfillCompletion(.failure(NetworkError.urlRequestError(error)))
            } else {
                fulfillCompletion(.failure(NetworkError.urlSessionError))
            }
        }
        task.resume()
        return task
    }
}

