import Foundation


public struct MarvelResponse<Response: Decodable>: Decodable {
	public let status: String?
	public let message: String?
	public let data: DataContainer<Response>?
}
