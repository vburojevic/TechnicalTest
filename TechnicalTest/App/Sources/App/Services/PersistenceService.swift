import Combine
import Foundation

public protocol PersistenceServiceProtocol {
    func isStorySeen(userId: Int) -> Bool
    func markStoryAsSeen(userId: Int)
    var seenStoryUserIdsPublisher: AnyPublisher<Set<Int>, Never> { get }

    func isStoryItemLiked(itemId: String) -> Bool
    func toggleLike(for itemId: String)
    var likedStoryItemIdsPublisher: AnyPublisher<Set<String>, Never> { get }
}

public class PersistenceService: PersistenceServiceProtocol {
    private let userDefaults: UserDefaults
    private let seenStoriesKey = "seenStoryUserIds"
    private let likedItemsKey = "likedStoryItemIds"

    private let seenStoryUserIdsSubject: CurrentValueSubject<Set<Int>, Never>
    private let likedStoryItemIdsSubject: CurrentValueSubject<Set<String>, Never>

    public var seenStoryUserIdsPublisher: AnyPublisher<Set<Int>, Never> {
        seenStoryUserIdsSubject.eraseToAnyPublisher()
    }

    public var likedStoryItemIdsPublisher: AnyPublisher<Set<String>, Never> {
        likedStoryItemIdsSubject.eraseToAnyPublisher()
    }

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults

        let initialSeenIds = Set(userDefaults.array(forKey: seenStoriesKey) as? [Int] ?? [])
        let initialLikedIds = Set(userDefaults.array(forKey: likedItemsKey) as? [String] ?? [])

        seenStoryUserIdsSubject = CurrentValueSubject(initialSeenIds)
        likedStoryItemIdsSubject = CurrentValueSubject(initialLikedIds)
    }

    public func isStorySeen(userId: Int) -> Bool {
        return seenStoryUserIdsSubject.value.contains(userId)
    }

    public func markStoryAsSeen(userId: Int) {
        var currentSet = seenStoryUserIdsSubject.value
        if currentSet.insert(userId).inserted {
            userDefaults.set(Array(currentSet), forKey: seenStoriesKey)
            seenStoryUserIdsSubject.send(currentSet)
        }
    }

    public func isStoryItemLiked(itemId: String) -> Bool {
        return likedStoryItemIdsSubject.value.contains(itemId)
    }

    public func toggleLike(for itemId: String) {
        var currentSet = likedStoryItemIdsSubject.value
        if currentSet.contains(itemId) {
            currentSet.remove(itemId)
        } else {
            currentSet.insert(itemId)
        }
        userDefaults.set(Array(currentSet), forKey: likedItemsKey)
        likedStoryItemIdsSubject.send(currentSet)
    }
}

class MockPersistenceService: PersistenceServiceProtocol {
    private var seenIds: Set<Int> = [1]
    private var likedIds: Set<String> = ["item_2_1"]

    private let seenStoryUserIdsSubject: CurrentValueSubject<Set<Int>, Never>
    private let likedStoryItemIdsSubject: CurrentValueSubject<Set<String>, Never>

    init() {
        seenStoryUserIdsSubject = CurrentValueSubject(seenIds)
        likedStoryItemIdsSubject = CurrentValueSubject(likedIds)
    }

    var seenStoryUserIdsPublisher: AnyPublisher<Set<Int>, Never> { seenStoryUserIdsSubject.eraseToAnyPublisher() }
    var likedStoryItemIdsPublisher: AnyPublisher<Set<String>, Never> { likedStoryItemIdsSubject.eraseToAnyPublisher() }

    func isStorySeen(userId: Int) -> Bool { seenIds.contains(userId) }
    func markStoryAsSeen(userId: Int) {
        if seenIds.insert(userId).inserted {
            seenStoryUserIdsSubject.send(seenIds)
        }
    }

    func isStoryItemLiked(itemId: String) -> Bool { likedIds.contains(itemId) }
    func toggleLike(for itemId: String) {
        if likedIds.contains(itemId) {
            likedIds.remove(itemId)
        } else {
            likedIds.insert(itemId)
        }
        likedStoryItemIdsSubject.send(likedIds)
    }
}
