import Cocoa
import AppKit
import PlaygroundSupport


class ComicVC {
    var comicVM: ComicViewModel
    
    init() {
        comicVM = ComicViewModel()
        comicVM.getComic(comicId: 61537) { (comicMetaData,thumbNail, error) in
            print(comicMetaData)
            print(thumbNail)
            print(error)
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
    // Yet another request with a mandatory parameter
    

let comicVC = ComicVC()




// Put your own keys!
// You can freely get a key here: https://developer.marvel.com/docs
//let apiClient = MarvelAPIClient(publicKey: "24dfba65b5783b7eca68f72e2aedc9f2",
                                //privateKey: "01dfce1538b10cb534e958bf9b475812d0adc3f5")

// A simple request with no parameters
//apiClient.send(GetCharacters()) { response in
//	print("\nGetCharacters finished:")
//
//	response.map { dataContainer in
//		for character in dataContainer.results {
//			print("  Title: \(character.name ?? "Unnamed character")")
//			print("  Thumbnail: \(character.thumbnail?.url.absoluteString ?? "None")")
//		}
//	}
//}

//// Another request filling interesting optional parameters, a string and an enum
//apiClient.send(GetComics(titleStartsWith: "Avengers", format: .digital)) { response in
//	print("\nGetComics finished:")
//
//	do {
//		let dataContainer = try response.get()
//        print(dataContainer.results)
//
//		for comic in dataContainer.results {
//			print("  Title: \(comic.title ?? "Unnamed comic")")
//			print("  Thumbnail: \(comic.thumbnail?.url.absoluteString ?? "None")")
//		}
//	} catch {
//		print(error)
//	}
//}

//var thumbNail: String?
//// Yet another request with a mandatory parameter
//apiClient.send(GetComic(comicId: 61537)) { response in
//	print("\nGetComic finished:")
//
//	switch response {
//	case .success(let dataContainer):
//		let comic = dataContainer.results.first
//
//		print("  Title: \(comic?.title ?? "Unnamed comic")")
//		print("  Thumbnail: \(comic?.thumbnail?.url.absoluteString ?? "None")")
//        print(" Description: \(comic?.description ?? "No description available")")
//
//        if let creators = comic?.creators {
//            for creator in creators.items {
//                let creatorDescription = """
//                \(creator.name ?? "unnamed")
//                \(creator.role ?? "mystery")\n
//                """
//                print(creatorDescription)
//            }
//        }
//
//        apiClient.fetchImageResult(from:comic?.thumbnail?.url.absoluteString ?? "None") { result in
//
//            switch result {
//            case .success(let imageData):
//                if imageData != nil,
//                    let thumbNailImg = NSImage(data: imageData!) {
//                        print(thumbNailImg)
//                } else {
//                   print("bupkes")
//                }
//            case .failure(let error):
//                print("ERROR! \(error.localizedDescription)")
//            }
//
//        }
//
//	case .failure(let error):
//		print(error)
//	}
//}



PlaygroundPage.current.needsIndefiniteExecution = true
