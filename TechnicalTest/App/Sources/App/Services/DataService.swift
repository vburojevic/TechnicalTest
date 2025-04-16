import Combine
import Foundation

public protocol DataServiceProtocol {
    func fetchUserPage(page: Int) -> AnyPublisher<[User], Error>
    func fetchStory(for userId: Int) -> AnyPublisher<Story, Error>
    func fetchInitialUsers() -> AnyPublisher<[User], Error>
}

public class DataService: DataServiceProtocol {
    private var allUsers: [User] = []
    private let usersPerPage = 10

    public init() {
        loadUsers()
    }

    private func loadUsers() {
        let bundle = Bundle.module
        let resourceName = "users"
        let resourceExtension = "json"
        let subdirectory = "Data"

        var urlToLoad: URL? = nil

        if let urlRoot = bundle.url(forResource: resourceName, withExtension: resourceExtension) {
            urlToLoad = urlRoot
        } else if let urlSub = bundle.url(forResource: resourceName, withExtension: resourceExtension, subdirectory: subdirectory) {
            urlToLoad = urlSub
        } else if let mainBundleUrl = Bundle.main.url(forResource: resourceName, withExtension: resourceExtension) {
            urlToLoad = mainBundleUrl
        } else {
            allUsers = []
            return
        }

        guard let finalUrl = urlToLoad else {
            allUsers = []
            return
        }

        do {
            let data = try Data(contentsOf: finalUrl)
            let decoder = JSONDecoder()
            let decodedResponse = try decoder.decode(UserPagesResponse.self, from: data)
            allUsers = decodedResponse.pages.flatMap { $0.users }
        } catch {
            allUsers = []
        }
    }

    public func fetchInitialUsers() -> AnyPublisher<[User], Error> {
        guard !allUsers.isEmpty else {
            let errorMsg = "Failed to load user data during initialization."
            return Fail(error: NSError(domain: "DataService", code: 1001, userInfo: [NSLocalizedDescriptionKey: errorMsg]))
                .eraseToAnyPublisher()
        }

        let initialUserCount = min(allUsers.count, 20)
        let initialUsers = Array(allUsers.prefix(initialUserCount))
        return Just(initialUsers)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    public func fetchUserPage(page: Int) -> AnyPublisher<[User], Error> {
        let totalUsers = allUsers.count
        guard totalUsers > 0 else {
            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        let startIndex = (page - 1) * usersPerPage
        let pageUsers = (0 ..< usersPerPage).map { index -> User in
            let userIndex = (startIndex + index) % totalUsers
            return allUsers[userIndex]
        }

        return Just(pageUsers)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    public func fetchStory(for userId: Int) -> AnyPublisher<Story, Error> {
        let numberOfItems = 3
        let items = (1 ... numberOfItems).map { itemIndex -> StoryItem in
            let imageId = (userId * 10) + itemIndex
            let imageUrl = "https://picsum.photos/id/\(imageId)/400/600"
            let stableItemId = "\(userId)-\(itemIndex)"
            return StoryItem(id: stableItemId, imageUrl: imageUrl)
        }
        let story = Story(userId: userId, items: items)

        return Just(story)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

class MockDataService: DataServiceProtocol {
    init() {}

    func fetchInitialUsers() -> AnyPublisher<[User], Error> {
        let mockUsers = [
            User(id: 1, name: "Neo", profilePictureUrl: "https://i.pravatar.cc/150?u=1"),
            User(id: 2, name: "Trinity", profilePictureUrl: "https://i.pravatar.cc/150?u=2"),
            User(id: 3, name: "Morpheus", profilePictureUrl: "https://i.pravatar.cc/150?u=3"),
        ]
        return Just(mockUsers)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func fetchUserPage(page: Int) -> AnyPublisher<[User], Error> {
        let mockUsers = (1 ... 10).map { i -> User in
            let id = (page - 1) * 10 + i
            return User(id: id, name: "User \(id)", profilePictureUrl: "https://i.pravatar.cc/150?u=\(id)")
        }
        return Just(mockUsers)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func fetchStory(for userId: Int) -> AnyPublisher<Story, Error> {
        let items = (1 ... 3).map { itemIndex -> StoryItem in
            let imageId = (userId * 10) + itemIndex
            let imageUrl = "https://picsum.photos/id/\(imageId)/400/600"
            let stableItemId = "\(userId)-\(itemIndex)"
            return StoryItem(id: stableItemId, imageUrl: imageUrl)
        }
        let story = Story(userId: userId, items: items)
        return Just(story)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
