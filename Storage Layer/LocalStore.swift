//Marvel Homework by Randy Weinstein

import UIKit

enum StorageType {
    case userDefaults
    case fileSystem
}

class LocalStore {

  func store(image: UIImage, forKey key: String, withStorageType storageType: StorageType) {
      if let pngRepresentation = image.pngData() {
          switch storageType {
          case .fileSystem:
              if let filePath = filePath(forKey: key) {
                  do  {
                      try pngRepresentation.write(to: filePath,
                                                  options: .atomic)
                  } catch let err {
                      print("Saving file resulted in error: ", err)
                  }
              }
          case .userDefaults:
              UserDefaults.standard.set(pngRepresentation,
                                          forKey: key)
          }
      }
  }
  
  func retrieveImage(forKey key: String,
                              inStorageType storageType: StorageType) -> UIImage? {
      switch storageType {
      case .fileSystem:
          if let filePath = self.filePath(forKey: key),
              let fileData = FileManager.default.contents(atPath: filePath.path),
              let image = UIImage(data: fileData) {
              return image
          }
      case .userDefaults:
          if let imageData = UserDefaults.standard.object(forKey: key) as? Data,
              let image = UIImage(data: imageData) {
              return image
          }
      }
      
      return nil
  }
  
  func storeComicMetaData(comic: Comic) {
    let defaults = UserDefaults.standard
    
    // Use PropertyListEncoder to convert Player into Data / NSData
    defaults.set(try? PropertyListEncoder().encode(comic), forKey: "comic")
  }
  
  func retrieveComicMetaData(comicId: Int) -> Comic? {
    return nil
  }

  private func filePath(forKey key: String) -> URL? {
      let fileManager = FileManager.default
      guard let documentURL = fileManager.urls(for: .documentDirectory,
                                              in: FileManager.SearchPathDomainMask.userDomainMask).first else { return nil }
      
      return documentURL.appendingPathComponent(key + ".png")
  }
}
