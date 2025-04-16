import Kingfisher
import SwiftUI

struct StoryAvatarView: View {
    let user: User
    let isSeen: Bool

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: isSeen ? [.gray] : [.yellow, .orange, .red]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2.5
                    )
                    .frame(width: 68, height: 68)

                KFImage(URL(string: user.profilePictureUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray.opacity(0.1), lineWidth: 1))
            }

            Text(user.name)
                .font(.caption)
                .lineLimit(1)
                .frame(width: 70)
        }
        .padding(.horizontal, 4)
    }
}

#Preview {
    HStack {
        StoryAvatarView(
            user: User(id: 1, name: "Neo", profilePictureUrl: "https://i.pravatar.cc/150?u=1"),
            isSeen: false
        )
        StoryAvatarView(
            user: User(id: 2, name: "Trinity", profilePictureUrl: "https://i.pravatar.cc/150?u=2"),
            isSeen: true
        )
    }
    .padding()
}
