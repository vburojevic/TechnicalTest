import Kingfisher
import SwiftUI

public struct StoryViewerView: View {
    @State var viewModel: StoryViewerViewModel
    @Environment(\.dismiss) var dismiss

    public init(viewModel: StoryViewerViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        GeometryReader { _ in
            ZStack(alignment: .top) {
                Color.black.ignoresSafeArea(.all)

                if viewModel.isLoadingStory {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let story = viewModel.currentStory, !story.items.isEmpty {
                    let currentItemIndex = min(max(0, viewModel.currentStoryItemIndex), story.items.count - 1)
                    let currentItem = story.items[currentItemIndex]

                    GeometryReader { imageProxy in
                        KFImage(URL(string: currentItem.imageUrl))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipped()
                            .highPriorityGesture(
                                SpatialTapGesture()
                                    .onEnded { value in
                                        if value.location.x < imageProxy.size.width / 2 {
                                            viewModel.previousStoryItem()
                                        } else {
                                            viewModel.nextStoryItem()
                                        }
                                    }
                            )
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { _ in
                                        if !viewModel.isPaused {
                                            viewModel.pausePlayback()
                                        }
                                    }
                                    .onEnded { _ in
                                        viewModel.resumePlayback()
                                    }
                            )
                    }

                } else if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Text("No story items available.")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                VStack(spacing: 0) {
                    if let story = viewModel.currentStory {
                        storyProgressView(itemCount: story.items.count,
                                          currentIndex: viewModel.currentStoryItemIndex,
                                          progress: viewModel.progress)
                            .padding(.top, 60)
                            .padding(.bottom, 8)
                    }

                    storyHeader

                    Spacer()

                    storyFooter
                }
            }
            .gesture(
                DragGesture(minimumDistance: 50)
                    .onEnded { value in
                        if value.translation.height > 50 {
                            dismiss()
                        }
                    }
            )
        }
        .statusBarHidden(true)
        .edgesIgnoringSafeArea(.all)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var storyHeader: some View {
        HStack {
            KFImage(URL(string: viewModel.currentUser.profilePictureUrl))
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)
                .clipShape(Circle())
            Text(viewModel.currentUser.name)
                .foregroundColor(.white)
                .font(.footnote)
                .fontWeight(.semibold)
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 12)
    }

    private var storyFooter: some View {
        HStack(spacing: 12) {
            Spacer()

            Button {
                viewModel.toggleLikeForCurrentItem()
            } label: {
                Image(systemName: viewModel.isCurrentItemLiked() ? "heart.fill" : "heart")
                    .font(.title2)
                    .foregroundColor(viewModel.isCurrentItemLiked() ? .red : .white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 30)
    }

    private func storyProgressView(itemCount: Int, currentIndex: Int, progress: Double) -> some View {
        HStack(spacing: 4) {
            ForEach(0 ..< itemCount, id: \.self) { index in
                SegmentedProgressView(progress: progressValue(for: index, currentIndex: currentIndex, currentProgress: progress))
            }
        }
        .padding(.horizontal, 8)
    }

    private func progressValue(for index: Int, currentIndex: Int, currentProgress: Double) -> Double {
        if index < currentIndex { return 1.0 }
        if index == currentIndex { return currentProgress }
        return 0.0
    }

    private struct SegmentedProgressView: View {
        var progress: Double
        var body: some View {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color.white.opacity(0.3))
                    Rectangle().fill(Color.white).frame(width: geometry.size.width * CGFloat(progress))
                }
                .clipShape(Capsule())
            }
            .frame(height: 2.5)
        }
    }
}

#Preview {
    let mockUsers = [
        User(id: 1, name: "Neo", profilePictureUrl: "https://i.pravatar.cc/150?u=1"),
        User(id: 2, name: "Trinity", profilePictureUrl: "https://i.pravatar.cc/150?u=2"),
    ]
    let mockViewModel = StoryViewerViewModel(
        allUsers: mockUsers,
        initialUserId: 1,
        dataService: MockDataService(),
        persistenceService: MockPersistenceService()
    )
    return StoryViewerView(viewModel: mockViewModel)
}
