import Foundation

public struct User: Codable, Identifiable, Hashable {
    public let id: Int
    public let name: String
    public let profilePictureUrl: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case profilePictureUrl = "profile_picture_url"
    }

    public init(id: Int, name: String, profilePictureUrl: String) {
        self.id = id
        self.name = name
        self.profilePictureUrl = profilePictureUrl
    }
}

struct UserPage: Codable {
    let users: [User]
}

struct UserPagesResponse: Codable {
    let pages: [UserPage]
}
