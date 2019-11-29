import Foundation

public struct Comic: Decodable {
	public let id: Int
	public let title: String?
	public let issueNumber: Double?
	public let description: String?
	public let pageCount: Int?
	public let thumbnail: Image?
  public let creators: CreatorList?
  public let dates: [ComicDate]?
  public struct ComicDate: Decodable {
    public let type: String?
    public let date: String?
  }
  public struct CreatorSummary: Decodable {
    public let name: String?
    public let role: String?
  }

  public struct CreatorList: Decodable {
    public let items: [CreatorSummary]
  }
  
}





/*
 CreatorList {
 available (int, optional): The number of total available creators in this list. Will always be greater than or equal to the "returned" value.,
 returned (int, optional): The number of creators returned in this collection (up to 20).,
 collectionURI (string, optional): The path to the full list of creators in this collection.,
 items (Array[CreatorSummary], optional): The list of returned creators in this collection.
 }
 
 CreatorSummary {
 resourceURI (string, optional): The path to the individual creator resource.,
 name (string, optional): The full name of the creator.,
 role (string, optional): The role of the creator in the parent entity.
 }
 */
