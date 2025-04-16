import Combine
import Foundation
import SwiftUI

@Observable
public class StoryViewerViewModel {
    let allUsers: [User]
    let initialUserId: Int

    private let dataService: DataServiceProtocol
    private let persistenceService: PersistenceServiceProtocol

    var currentUserIndex: Int
    var currentUser: User { allUsers[currentUserIndex] }
    var currentStory: Story?
    var currentStoryItemIndex: Int = 0
    var isLoadingStory: Bool = false
    var errorMessage: String?
    var likedItemIds: Set<String> = []

    var progress: Double = 0.0
    var isPaused: Bool = false
    let storyDuration: TimeInterval = 3.0
    private var timerSubscription: AnyCancellable?

    private var cancellables = Set<AnyCancellable>()

    public init(allUsers: [User],
                initialUserId: Int,
                dataService: DataServiceProtocol = DataService(),
                persistenceService: PersistenceServiceProtocol = PersistenceService())
    {
        self.allUsers = allUsers
        self.initialUserId = initialUserId
        self.dataService = dataService
        self.persistenceService = persistenceService

        if let startIndex = allUsers.firstIndex(where: { $0.id == initialUserId }) {
            currentUserIndex = startIndex
        } else {
            currentUserIndex = 0
        }

        subscribeToLikedStatus()

        loadStory(for: currentUser.id)
    }

    private func loadStory(for userId: Int) {
        guard !isLoadingStory else { return }
        stopTimer()
        isLoadingStory = true
        errorMessage = nil
        currentStory = nil
        currentStoryItemIndex = 0
        progress = 0.0

        dataService.fetchStory(for: userId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoadingStory = false
                if case let .failure(error) = completion {
                    self?.errorMessage = "Failed to load story: \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] story in
                guard let self = self else { return }
                self.currentStory = story
                self.markStoryAsSeen()
                self.startTimer()
            })
            .store(in: &cancellables)
    }

    func nextStoryItem() {
        guard let story = currentStory else { return }
        if currentStoryItemIndex < story.items.count - 1 {
            currentStoryItemIndex += 1
            startTimer()
        } else {
            nextUser()
        }
    }

    func previousStoryItem() {
        guard currentStory != nil else { return }
        if currentStoryItemIndex > 0 {
            currentStoryItemIndex -= 1
            startTimer()
        } else {
            previousUser()
        }
    }

    func nextUser() {
        guard currentUserIndex < allUsers.count - 1 else {
            stopTimer()
            return
        }
        currentUserIndex += 1
        loadStory(for: currentUser.id)
    }

    func previousUser() {
        guard currentUserIndex > 0 else {
            stopTimer()
            return
        }
        currentUserIndex -= 1
        loadStory(for: currentUser.id)
    }

    private func startTimer() {
        stopTimer()
        progress = 0.0
        isPaused = false

        timerSubscription = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, !self.isPaused else { return }

                self.progress += 0.05 / self.storyDuration
                if self.progress >= 1.0 {
                    self.nextStoryItem()
                }
            }
    }

    private func stopTimer() {
        timerSubscription?.cancel()
        timerSubscription = nil
    }

    func pausePlayback() {
        isPaused = true
    }

    func resumePlayback() {
        isPaused = false
    }

    deinit {
        stopTimer()
    }

    private func markStoryAsSeen() {
        persistenceService.markStoryAsSeen(userId: currentUser.id)
    }

    private func subscribeToLikedStatus() {
        persistenceService.likedStoryItemIdsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedLikedIds in
                self?.likedItemIds = updatedLikedIds
            }
            .store(in: &cancellables)
    }

    func isCurrentItemLiked() -> Bool {
        guard let story = currentStory, currentStoryItemIndex < story.items.count else { return false }
        let currentItemId = story.items[currentStoryItemIndex].id
        return likedItemIds.contains(currentItemId)
    }

    func toggleLikeForCurrentItem() {
        guard let story = currentStory, currentStoryItemIndex < story.items.count else { return }
        let currentItemId = story.items[currentStoryItemIndex].id
        persistenceService.toggleLike(for: currentItemId)
    }
}
