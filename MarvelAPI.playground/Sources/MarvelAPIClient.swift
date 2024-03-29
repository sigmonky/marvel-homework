import Foundation

public typealias ResultCallback<Value> = (Result<Value, Error>) -> ()

struct MarvelAPI {
    static let publicKey = "your key here"
    static let privateKey = "your key here"
    static let endPointURL = URL(string: "https://gateway.marvel.com:443/v1/public/")!
}

public class MarvelAPIClient {
    private let baseEndpointUrl: URL?
	private let session = URLSession(configuration: .default)

	private let publicKey: String
	private let privateKey: String

	public init() {
        self.publicKey = MarvelAPI.publicKey
        self.privateKey = MarvelAPI.privateKey
        self.baseEndpointUrl = MarvelAPI.endPointURL
	}

  public func send<T: APIRequest>(_ request: T,  passingURLString: Bool = false, completion: @escaping ResultCallback<DataContainer<T.Response>>) {

        var endpoint: URL
    
        endpoint = self.endpoint(for: request)

		
		let task = session.dataTask(with: URLRequest(url: endpoint)) { data, response, error in
			if let data = data {
				do {
					let marvelResponse = try JSONDecoder().decode(MarvelResponse<T.Response>.self, from: data)
					if let dataContainer = marvelResponse.data {
						completion(.success(dataContainer))
					} else if let message = marvelResponse.message {
						completion(.failure(MarvelError.server(message: message)))
					} else {
						completion(.failure(MarvelError.decoding))
					}
				} catch {
					completion(.failure(error))
				}
			} else if let error = error {
				completion(.failure(error))
			}
		}
		task.resume()
	}

    private func endpoint<T: APIRequest>(for request: T) -> URL {
        guard let baseEndpointUrl = baseEndpointUrl else {
            fatalError("URL malformed")
        }
        
        guard let baseUrl = URL(string: request.resourceName, relativeTo: baseEndpointUrl) else {
            fatalError("Bad resourceName: \(request.resourceName)")
        }
        

		var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)!

		// Common query items needed for all Marvel requests
		let timestamp = "\(Date().timeIntervalSince1970)"
		let hash = "\(timestamp)\(privateKey)\(publicKey)".md5
		let commonQueryItems = [
			URLQueryItem(name: "ts", value: timestamp),
			URLQueryItem(name: "hash", value: hash),
			URLQueryItem(name: "apikey", value: publicKey)
		]

		// Custom query items needed for this specific request
		let customQueryItems: [URLQueryItem]

		do {
			customQueryItems = try URLQueryItemEncoder.encode(request)
		} catch {
			fatalError("Wrong parameters: \(error)")
		}

		components.queryItems = commonQueryItems + customQueryItems

		// Construct the final URL with all the previous data
		return components.url!
	}
    
    
    public func fetchImageResult(from urlString: String, completionHandler: @escaping (Result<Data?, Error>) -> ()) {

        let url = URL(string: urlString)
            
        let dataTask = session.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                completionHandler(.failure(error!))
            } else {
                completionHandler(.success(data))
            }
        }
        dataTask.resume()
    }
}




