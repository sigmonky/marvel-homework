import Cocoa
import AppKit
import PlaygroundSupport

class ComicVC {
    var comicVM: ComicViewModel
    
    init() {
        comicVM = ComicViewModel()
        comicVM.getComic(comicId: 61537) { (comicMetaData,thumbNail, error) in
            print(comicMetaData as Any)
            print(thumbNail as Any)
            print(error as Any)
        }
    }
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


class ComicViewModel {
    
    let apiClient = MarvelAPIClient()
    
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
    
    func getComic(comicId: Int, onReturnData: @escaping (_ metaData: ComicMetaData?, _ thumbNail: NSImage?, _ error: CustomError?)->()) {
        
        let clientReturnClosure = onReturnData
        
        apiClient.send(GetComic(comicId: comicId)) { response in
            var comicMetaData: ComicMetaData?
            var thumbNailImg: NSImage?
            
            switch response {
                case .success(let dataContainer):
                    
                    guard let comic = dataContainer.results.first else {
                        let errorMessage = CustomError(errorDescription: "Comic book info not available")
                        clientReturnClosure(nil, nil, errorMessage)
                        return
                    }
                    
                    comicMetaData = self.composeComicMetaData(comic: comic)
                    
                    guard let thumbnailURL = comic.thumbnail?.url.absoluteString  else {
                        let errorMessage = CustomError(errorDescription: "No thumbnail image URL provided")
                        clientReturnClosure(comicMetaData, nil, errorMessage)
                        return
                    }
                    
                    self.apiClient.fetchImageResult(from:thumbnailURL) { result in
                        
                        switch result {
                        case .success(let imageData):
                            if imageData != nil,
                                let img = NSImage(data: imageData!) {
                                thumbNailImg = img
                            }
                            clientReturnClosure(comicMetaData,thumbNailImg,nil)
                        case .failure(let error):
                            let customError = CustomError(errorDescription: error.localizedDescription)
                            clientReturnClosure(comicMetaData,nil,customError)
                        }
                    }
                   
                case .failure(let error):
                    let errorMessage = CustomError(errorDescription: error.localizedDescription)
                    clientReturnClosure(nil,nil,errorMessage)
            }
            
        }
    }
        
}

print("instantiate proxy comic view controller")
let comicVC = ComicVC()

PlaygroundPage.current.needsIndefiniteExecution = true
