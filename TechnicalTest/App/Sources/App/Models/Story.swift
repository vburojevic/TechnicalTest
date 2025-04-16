import Foundation

public struct Story: Codable, Identifiable, Hashable {
    public var id: Int { userId }
    public let userId: Int
    public let items: [StoryItem]

    public init(userId: Int, items: [StoryItem]) {
        self.userId = userId
        self.items = items
    }
}
