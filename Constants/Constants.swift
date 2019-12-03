//Marvel Homework by Randy Weinstein

import Foundation

struct APIConstants {
  static let publicKey =  "24dfba65b5783b7eca68f72e2aedc9f2"
  static let privateKey = "01dfce1538b10cb534e958bf9b475812d0adc3f5"
  static let baseEndPoinUrl = URL(string: "https://gateway.marvel.com:443/v1/public/")!
  static let basePointErrorMsg = "Could not resolve API endpoint"
}

struct ComicDetails {
  static let errorAlertTitle = "Comic Currently Unvailable"
  static let errorAlertMsg = "We are unable to download the comic information you requested. Please try again later."
  static let errorAlertBtnLbl = "Close"
  static let mainCellId = "MainCell"
  static let contributorCellId = "Contributors"
}
