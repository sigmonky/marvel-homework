import Foundation
import UIKit

protocol ComicDisplayCell {
  var cellType: DisplayCellType { get set }
}

enum DisplayCellType {
  case mainCell
  case contributorCell
  case publishDateCell
}

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
    
  var apiClient: NetworkServices
  var displayCells = [ComicDisplayCell]()
  
  init(networkServices: NetworkServices) {
    apiClient = networkServices
  }
  
  func getComic(comicId: Int, onReturnData: @escaping ( _ onReturnData: ComicMetaData?, _ error: CustomError?)->(),onReturnImage: @escaping ( _ thumbNail: UIImage?, _ error: CustomError?) ->() ) {
      
      let clientReturnClosure = onReturnData
      let imageReturnClosure = onReturnImage
    
    let localStore = LocalStore()
    if let localComicData = localStore.retrieveComicMetaData(comicId: comicId) {
      var comicMetaData: ComicMetaData?
      comicMetaData = self.composeComicMetaData(comic: localComicData)
      var mainCell = MainDisplayCell()
      mainCell.title = comicMetaData?.title ?? "Unnamed comic"
      mainCell.description = comicMetaData?.description ?? "No description available"
      if let thumbNail = localStore.retrieveImage(forKey: String(comicId), inStorageType: .fileSystem)  {
        mainCell.thumbNail = thumbNail
      } else {
        print("could not retrieve local image")
        localStore.removeComicMetaData(comicID: comicId)
      }
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
    } else {
      apiClient.send(GetComic(comicId: comicId)) {[unowned self] response in
          var comicMetaData: ComicMetaData?
          
          switch response {
              case .success(let dataContainer):
                  
                  guard let comic = dataContainer.results.first else {
                      let errorMessage = CustomError(errorDescription: "Comic book info not available")
                      clientReturnClosure(nil, errorMessage)
                      return
                  }
                  
                  let localStore = LocalStore()
                  localStore.storeComicMetaData(comic: comic)
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

                   self.apiClient.fetchImage(from:thumbnailURL) { [unowned self] result in

                       switch result {
                       case .success(let imageData):
                           if imageData != nil,
                               let img = UIImage(data: imageData!) {
                            let localStore = LocalStore()
                            localStore.store(image: img, forKey: String(comic.id), withStorageType: .fileSystem)
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
  
  private func composeComicMetaData(comic: ComicProtocol) -> ComicMetaData {
    
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
  
//  private func composeComicMetaData(comic: Comic) -> ComicMetaData {
//
//        let title = comic.title ?? "Unnamed comic"
//        let description = comic.description ?? "No description available"
//
//        var creatorList = [ComicBookCreator]()
//        if let creators = comic.creators {
//            for creator in creators.items {
//                let name = creator.name ?? "unnamed"
//                let role = creator.role ?? "not identified"
//                var roleText: String = ""
//                var domain: DesignDomain = .interior
//                if role.contains("(cover)") {
//                    roleText = role.replacingOccurrences(of: "(cover)", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
//                    domain = .cover
//                } else {
//                    roleText = role
//                    domain = .interior
//                }
//
//                let creator = ComicBookCreator(name: name, role: roleText, domain: domain)
//                creatorList.append(creator)
//
//            }
//        }
//
//        return ComicMetaData(title: title, description: description, creators: creatorList)
//
//    }
    
  
        
}
