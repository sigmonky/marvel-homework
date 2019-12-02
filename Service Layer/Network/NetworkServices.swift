import Foundation


protocol NetworkServices {
  func send<T: APIRequest>(_ request: T, completion: @escaping ResultCallback<DataContainer<T.Response>>)
  func fetchImage(from urlString: String, completionHandler: @escaping (Result<Data?, Error>) -> ())
}
