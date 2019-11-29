import UIKit

struct Auteurs : Codable {
  let auteurs : [Auteur]
}

struct Auteur: Codable {
  let name: String
  let bio: String
  let source: String
  let image: String
  
  // Decode JSON
  static func auteursFromBundle() -> [Auteur] {
    var auteurs: [Auteur] = []
    let url = Bundle.main.url(forResource: "auteurs", withExtension: "json")!
    do {
      let data = try Data(contentsOf: url)
      let json = try JSONDecoder().decode(Auteurs.self, from: data)
      auteurs = json.auteurs
    }
    catch {
      print("Error occured during Parsing", error)
    }
    return auteurs
  }
}

