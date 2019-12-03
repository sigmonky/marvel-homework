import Foundation
import UIKit


struct CustomError {
    var errorDescription: String
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
      populateFromLocalStore(localStore: localStore, localComicData: localComicData, comicId: comicId)
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
  
  private func populateFromLocalStore( localStore: LocalStore,localComicData: ComicStore, comicId: Int) {
    var comicMetaData: ComicMetaData?
    comicMetaData = self.composeComicMetaData(comic: localComicData)
    var mainCell = MainDisplayCell()
    mainCell.title = comicMetaData?.title ?? "Unnamed comic"
    mainCell.description = comicMetaData?.description ?? "No description available"
    
    if let thumbNail = localStore.retrieveImage(forKey: String(comicId), inStorageType: .fileSystem)  {
      mainCell.thumbNail = thumbNail
    } else {
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
}
