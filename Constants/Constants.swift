//Marvel Homework by Randy Weinstein

import Foundation

struct APIConstants {
  static let publicKey =  "put yours here"
  static let privateKey = "put yours here"
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
