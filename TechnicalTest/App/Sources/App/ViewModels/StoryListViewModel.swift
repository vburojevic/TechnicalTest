import Combine
import Foundation
import SwiftUI

public class StoryListViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var seenStoryUserIds: Set<Int> = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let dataService: DataServiceProtocol
    private let persistenceService: PersistenceServiceProtocol

    private var currentPage = 1
    private var canLoadMorePages = true

    private var cancellables = Set<AnyCancellable>()

    public init(dataService: DataServiceProtocol = DataService(),
                persistenceService: PersistenceServiceProtocol = PersistenceService())
    {
        self.dataService = dataService
        self.persistenceService = persistenceService

        subscribeToSeenStatus()
        loadInitialUsers()
    }

    func loadInitialUsers() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        currentPage = 1

        dataService.fetchInitialUsers()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = "Failed to load stories: \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] initialUsers in
                self?.users = initialUsers
                self?.currentPage = 1
                self?.canLoadMorePages = true
            })
            .store(in: &cancellables)
    }

    func loadMoreUsersIfNeeded(currentUser: User?) {
        guard let currentUser = currentUser, canLoadMorePages, !isLoading else {
            return
        }

        let thresholdIndex = users.index(users.endIndex, offsetBy: -5)
        if let userIndex = users.firstIndex(where: { $0.id == currentUser.id }), userIndex >= thresholdIndex {
            loadMoreUsers()
        }
    }

    func loadMoreUsers() {
        guard canLoadMorePages, !isLoading else { return }

        isLoading = true
        currentPage += 1

        dataService.fetchUserPage(page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = "Failed to load more stories: \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] newUsers in
                guard let self = self else { return }
                if newUsers.isEmpty {
                } else {
                    self.users.append(contentsOf: newUsers)
                }
            })
            .store(in: &cancellables)
    }

    private func subscribeToSeenStatus() {
        persistenceService.seenStoryUserIdsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedSeenIds in
                self?.seenStoryUserIds = updatedSeenIds
            }
            .store(in: &cancellables)
    }

    func isStorySeen(userId: Int) -> Bool {
        return seenStoryUserIds.contains(userId)
    }

    func markStoryAsSeen(userId: Int) {
        persistenceService.markStoryAsSeen(userId: userId)
    }
}
