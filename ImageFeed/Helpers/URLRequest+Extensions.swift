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
    ) -> URLRequest? {
        guard var urlComponents = URLComponents(string: urlString) else {
            fatalError()
        }
        var queryItems: [URLQueryItem] = []
        for (key, value) in parameters {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        urlComponents.queryItems = queryItems
        guard
            let url = urlComponents.url
        else {
            assertionFailure("Failed to create URL")
            return nil
        }
        var request = URLRequest(url: urlComponents.url!)
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
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request) { data, response, error in
            if let error = error {
                fulfillCompletionOnMainThread(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let errorDescription = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                fulfillCompletionOnMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                return
            }
            
            guard let data = data else {
                fulfillCompletionOnMainThread(.failure(NetworkError.urlSessionError))
                return
            }
            
            fulfillCompletionOnMainThread(.success(data))
        }
        
        return task
    }
}


extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        let task = data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    print("Ошибка декодирования: \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }
}



