import Foundation

public typealias ResultCallback<Value> = (Result<Value, Error>) -> ()

public class MarvelAPIClient: NetworkServices {
    private let baseEndpointUrl: URL?
	private let session = URLSession(configuration: .default)

	private let publicKey: String
	private let privateKey: String
  
	public init() {
    self.publicKey = APIConstants.publicKey
    self.privateKey = APIConstants.privateKey
    self.baseEndpointUrl = APIConstants.baseEndPoinUrl
	}

  public func send<T: APIRequest>(_ request: T, completion: @escaping ResultCallback<DataContainer<T.Response>>) {

    guard let endpoint = self.endpoint(for: request) else {
      completion(.failure(MarvelError.server(message: APIConstants.basePointErrorMsg)))
      return
    }

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

    private func endpoint<T: APIRequest>(for request: T) -> URL? {
      
    guard let baseEndpointUrl = baseEndpointUrl else {
        return nil
    }
    
    guard let baseUrl = URL(string: request.resourceName, relativeTo: baseEndpointUrl) else {
        return nil
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
			return nil
		}

		components.queryItems = commonQueryItems + customQueryItems

		return components.url
	}
    
    
    public func fetchImage(from urlString: String, completionHandler: @escaping (Result<Data?, Error>) -> ()) {

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




