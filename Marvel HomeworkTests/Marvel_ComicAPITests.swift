//Marvel Homework by Randy Weinstein

import XCTest

public class BadAPIClient: NetworkServices {
  func fetchImage(from urlString: String, completionHandler: @escaping (Result<Data?, Error>) -> ()) {
    completionHandler(.failure(MarvelError.decoding))
  }
  
  func send<T>(_ request: T, completion: @escaping (Result<DataContainer<T.Response>, Error>) -> ()) where T : APIRequest {
    completion(.failure(MarvelError.decoding))
  }
  
  
}

class Marvel_ComicAPITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testComicViewModelAPIErrors() {
      let returnDataClosure: (ComicMetaData?, CustomError?) -> () = { (comicMetaData, error) in
        print(error?.errorDescription ?? "no description")
        XCTAssertNotNil(error?.errorDescription, "error message not returned")
      }
      
      let returnImageClosure:(UIImage?, CustomError?) -> () = {(image,error) in
         print(error?.errorDescription ?? "no description")
         XCTAssertNotNil(error?.errorDescription, "error message not returned")
        }
      
      let vm = ComicViewModel(networkServices: BadAPIClient())
      vm.getComic(comicId: 0, onReturnData: returnDataClosure, onReturnImage: returnImageClosure)
      vm.apiClient.fetchImage(from: "xx", completionHandler: { result in
        returnImageClosure(nil,CustomError(errorDescription: "Unit Test Validation"))
      })
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
