import Foundation

public struct StoryItem: Codable, Identifiable, Hashable {
    public let id: String
    public let imageUrl: String

    public init(id: String, imageUrl: String) {
        self.id = id
        self.imageUrl = imageUrl
    }
}
