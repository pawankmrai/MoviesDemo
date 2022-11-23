//
//  NetworkManager.swift
//  MoviesDemo
//
//  Created by Pawan on 20/11/22.
//

import Foundation

protocol NetworkSession {
	func loadData(with urlRequest: URLRequest,
				  completionHandler: @escaping (Data?, Error?) -> Void)
}

extension URLSession: NetworkSession {
  func loadData(with urlRequest: URLRequest,
				completionHandler: @escaping (Data?, Error?) -> Void) {
	let task = dataTask(with: urlRequest) { (data, _, error) in
		completionHandler(data, error)
	}

	task.resume()
  }
}

class NetworkManager {
	private let session: NetworkSession

	init(session: NetworkSession = URLSession.shared) {
		self.session = session
	}

	func makeRequest<T: Decodable>(
		with url: URL,
		decode decodable: T.Type,
		completionHandler: @escaping (Result<T, Error>) -> Void
	) {
		session.loadData(with: URLRequest(url: url)) { data, error in
			guard let data = data else {
				completionHandler(.failure(error!))
				return
			}

			do {
				let jsonDecoder = JSONDecoder()
				let parsed = try jsonDecoder.decode(decodable, from: data)
				completionHandler(.success(parsed))
			} catch {
				completionHandler(.failure(error))
			}
		}
	}
}

class MoviesLoader {
	//
	static func fetchMovies(url: URL,
							manager: NetworkManager,
							completion: @escaping (Result<[Movie], Error>) -> Void) {
		//
		manager.makeRequest(with: url,
							decode: Movies.self) { response in
			//
			switch response {
			case .success(let movies):
				completion(.success(movies))
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}
}
