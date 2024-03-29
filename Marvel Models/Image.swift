import Foundation

/// Common object for images coming from the Marvel API
/// Shows how to fully conform to Decodable
public struct Image: Codable {
	enum ImageKeys: String, CodingKey {
		case path = "path"
		case fileExtension = "extension"
	}

	/// The remote URL for this image
	public let url: URL

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: ImageKeys.self)

//		let path = try container.decode(String.self, forKey: .path)
//		let fileExtension = try container.decode(String.self, forKey: .fileExtension)
    
    let path = try container.decode(String.self, forKey: .path)
    let fileExtension = try container.decode(String.self, forKey: .fileExtension)

    guard let url = URL(string: "\(String(describing: path)).\(String(describing: fileExtension))") else { throw MarvelError.decoding }

		self.url = url
	}
}
