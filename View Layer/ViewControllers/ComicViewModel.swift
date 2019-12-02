import Foundation
import UIKit

enum DesignDomain {
    case cover
    case interior
}

struct ComicBookCreator {
    var name: String
    var role: String
    var domain: DesignDomain
}



struct ComicMetaData {
    var title: String
    var description: String
    var creators: [ComicBookCreator]
}

struct CustomError {
    var errorDescription: String
}

enum DisplayCellType {
  case mainCell
  case contributorCell
  case publishDateCell
}

protocol ComicDisplayCell {
  var cellType: DisplayCellType { get set }
}



struct MainDisplayCell: ComicDisplayCell {
  var cellType: DisplayCellType = .mainCell
  var title: String?
  var description: String?
  var thumbNail: UIImage?
  
  init( initTitle: String? = nil, initDescription: String? = nil, initThumbNail: UIImage? = nil) {
    self.title = initTitle
    self.description = initDescription
    self.thumbNail = initThumbNail
  }
}

struct ContributeDisplayCell: ComicDisplayCell {
  var cellType: DisplayCellType = .contributorCell
  var title: String?
  var contributors: String?
  
  init( initTitle: String? = nil, initContributors: String? = nil) {
    self.title = initTitle
    self.contributors = initContributors
  }
}


class ComicViewModel {
    
  let apiClient = MarvelAPIClient()
  var displayCells = [ComicDisplayCell]()
    
  private func composeComicMetaData(comic: Comic) -> ComicMetaData {
    
        let title = comic.title ?? "Unnamed comic"
        let description = comic.description ?? "No description available"
  
        var creatorList = [ComicBookCreator]()
        if let creators = comic.creators {
            for creator in creators.items {
                let name = creator.name ?? "unnamed"
                let role = creator.role ?? "not identified"
                var roleText: String = ""
                var domain: DesignDomain = .interior
                if role.contains("(cover)") {
                    roleText = role.replacingOccurrences(of: "(cover)", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                    domain = .cover
                } else {
                    roleText = role
                    domain = .interior
                }
                
                let creator = ComicBookCreator(name: name, role: roleText, domain: domain)
                creatorList.append(creator)
                
            }
        }
            
        return ComicMetaData(title: title, description: description, creators: creatorList)
        
    }
    
  func getComic(comicId: Int, onReturnData: @escaping ( _ onReturnData: ComicMetaData?, _ error: CustomError?)->(),onReturnImage: @escaping ( _ thumbNail: UIImage?, _ error: CustomError?) ->() ) {
        
        let clientReturnClosure = onReturnData
        let imageReturnClosure = onReturnImage
        
        apiClient.send(GetComic(comicId: comicId)) {[unowned self] response in
            var comicMetaData: ComicMetaData?
            
            switch response {
                case .success(let dataContainer):
                    
                    guard let comic = dataContainer.results.first else {
                        let errorMessage = CustomError(errorDescription: "Comic book info not available")
                        clientReturnClosure(nil, errorMessage)
                        return
                    }
                    
                    comicMetaData = self.composeComicMetaData(comic: comic)
                    var mainCell = MainDisplayCell()
                    mainCell.title = comicMetaData?.title ?? "Unnamed comic"
                    mainCell.description = comicMetaData?.description ?? "No description available"
                    self.displayCells.append(mainCell)
                   
                    
                    var coverContributors = ContributeDisplayCell()
                    coverContributors.title = "Cover"
                    if let coverList = comicMetaData?.creators.filter({ $0.domain == .cover}) {
                      let coverList = coverList.map {
                        return $0.name + ": " + $0.role
                      }
                      coverContributors.contributors = coverList.joined(separator:"\n")
                    }
                    self.displayCells.append(coverContributors)
                    
                    var interiorContributors = ContributeDisplayCell()
                    interiorContributors.title = "Interior"
                    
                    if let interiorList = comicMetaData?.creators.filter({ $0.domain == .interior}) {
                      let interiorList = interiorList.map {
                        return $0.name + ": " + $0.role
                      }
                      interiorContributors.contributors = interiorList.joined(separator:"\n")
                    }
                    
                    self.displayCells.append(interiorContributors)
                    clientReturnClosure(nil, nil)
                    
                    guard let thumbnailURL = comic.thumbnail?.url.absoluteString  else {
                         let errorMessage = CustomError(errorDescription: "No thumbnail image URL provided")
                         imageReturnClosure(nil, errorMessage)
                         return
                     }

                     self.apiClient.fetchImageResult(from:thumbnailURL) { [unowned self] result in

                         switch result {
                         case .success(let imageData):
                             if imageData != nil,
                                 let img = UIImage(data: imageData!) {
                              
                              print(self.displayCells)
                              var updatedMainInfo = self.displayCells[0] as! MainDisplayCell
                              updatedMainInfo.thumbNail = img
                              self.displayCells[0] = updatedMainInfo
                               imageReturnClosure(nil,nil)
                             }
              
                             
                         case .failure(let error):
                             let customError = CustomError(errorDescription: error.localizedDescription)
                             imageReturnClosure(nil,customError)
                         }
                     }
                    
                   
                case .failure(let error):
                    let errorMessage = CustomError(errorDescription: error.localizedDescription)
                    clientReturnClosure(nil,errorMessage)
            }
            
        }
    }
        
}
