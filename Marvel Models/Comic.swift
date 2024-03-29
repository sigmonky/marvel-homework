import Foundation

protocol ComicProtocol {
  var title: String? { get }
  var description: String? { get }
  var creators: CreatorList? { get }
}


public struct CreatorSummary: Codable {
   public let name: String?
   public let role: String?
 }

 public struct CreatorList: Codable {
   public let items: [CreatorSummary]
 }

public struct ComicDate: Codable {
  public let type: String?
  public let date: String?
}

public struct Comic: Codable, ComicProtocol {
	public let id: Int
	public let title: String?
	public let issueNumber: Double?
	public let description: String?
	public let pageCount: Int?
	public let thumbnail: Image?
  public let creators: CreatorList?
  public let dates: [ComicDate]?
  
}

public struct ComicStore: Codable, ComicProtocol {
  public let id: Int
  public let title: String?
  public let issueNumber: Double?
  public let description: String?
  public let pageCount: Int?
  public let creators: CreatorList?
  public let dates: [ComicDate]?
}
