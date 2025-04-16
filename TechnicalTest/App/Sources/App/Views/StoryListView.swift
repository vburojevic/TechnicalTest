import SwiftUI

public struct StoryListView: View {
    @StateObject private var viewModel: StoryListViewModel
    @State private var selectedUserId: Int? = nil

    public init(viewModel: StoryListViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Text("Stories")
                .font(.headline)
                .padding(.leading)

            if viewModel.isLoading && viewModel.users.isEmpty {
                ProgressView()
                    .frame(height: 100)
            } else if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
                    .frame(height: 100)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 0) {
                        ForEach(viewModel.users.indices, id: \.self) { index in
                            let user = viewModel.users[index]
                            StoryAvatarView(
                                user: user,
                                isSeen: viewModel.isStorySeen(userId: user.id)
                            )
                            .onTapGesture {
                                selectedUserId = user.id
                            }
                        }
                        if viewModel.isLoading && !viewModel.users.isEmpty {
                            ProgressView()
                                .padding(.horizontal)
                        }

                        if !viewModel.isLoading {
                            Color.clear
                                .frame(width: 1, height: 1)
                                .onAppear {
                                    viewModel.loadMoreUsers()
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 100)
            }
        }
        .onAppear {}
        .onDisappear {}
        .fullScreenCover(item: $selectedUserId) { userId in
            if !viewModel.users.isEmpty {
                let viewerViewModel = StoryViewerViewModel(
                    allUsers: viewModel.users,
                    initialUserId: userId
                )
                StoryViewerView(viewModel: viewerViewModel)
            } else {
                Text("Error: Cannot display story.")
            }
        }
    }
}

extension Int: @retroactive Identifiable {
    public var id: Int { self }
}

#Preview {
    StoryListView(
        viewModel: StoryListViewModel(dataService: MockDataService(), persistenceService: MockPersistenceService())
    )
    .padding(.vertical)
}
