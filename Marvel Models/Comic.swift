import Foundation

public struct Comic: Codable {
	public let id: Int
	public let title: String?
	public let issueNumber: Double?
	public let description: String?
	public let pageCount: Int?
	public let thumbnail: Image?
  public let creators: CreatorList?
  public let dates: [ComicDate]?
  public struct ComicDate: Codable {
    public let type: String?
    public let date: String?
  }
  public struct CreatorSummary: Codable {
    public let name: String?
    public let role: String?
  }

  public struct CreatorList: Codable {
    public let items: [CreatorSummary]
  }
  
}
