//Marvel Homework by Randy Weinstein

import Foundation


public class StubAPIClient: NetworkServices {
  func fetchImage(from urlString: String, completionHandler: @escaping (Result<Data?, Error>) -> ()) {
    let errorTemp = NSError(domain:"", code:0, userInfo:nil)
    completionHandler(.failure(errorTemp))
  }
  
  func send<T>(_ request: T, completion: @escaping (Result<DataContainer<T.Response>, Error>) -> ()) where T : APIRequest {
    completion(.failure(MarvelError.decoding))
  }
  
  
}
