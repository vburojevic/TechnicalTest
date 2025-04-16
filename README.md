# Technical Test - SwiftUI Instagram Stories Clone

This project implements a basic Instagram-like Stories feature using SwiftUI, targeting iOS 18.

## Features Implemented

*   **Story List Screen:** Displays a horizontal list of user avatars representing stories.
    *   Supports infinite scrolling (by repeating the user list).
    *   Visually distinguishes between seen and unseen stories using a colored ring around the avatar (Gradient for unseen, Gray for seen).
*   **Story Viewer Screen:** Presented as a sheet when tapping a user avatar.
    *   Displays story items (images fetched from `picsum.photos`) one by one.
    *   Allows navigation between story items using taps on the left/right side of the screen.
    *   Allows navigation between different users' stories by tapping to the next/previous item at the end/beginning of a user's story sequence.
    *   Includes a "Like" button (`heart` icon) for the currently displayed story item.
    *   Includes a close button (`xmark`) to dismiss the viewer.
*   **Persistence:**
    *   **Seen Status:** Remembers which users' stories have been viewed across app sessions using `UserDefaults`.
    *   **Like Status:** Remembers which individual story items have been liked across app sessions using `UserDefaults`.

## Architecture

*   **MVVM (Model-View-ViewModel):** The codebase is structured following the MVVM pattern to promote separation of concerns within the `App` package.
    *   **Models (`TechnicalTest/App/Sources/App/Models`):** Define the data structures (`User`, `Story`, `StoryItem`).
    *   **Views (`TechnicalTest/App/Sources/App/Views`):** Define the UI components (`StoryListView`, `StoryAvatarView`, `StoryViewerView`). Views are designed to be passive and driven by ViewModels.
    *   **ViewModels (`TechnicalTest/App/Sources/App/ViewModels`):** Contain the presentation logic and state management (`StoryListViewModel`, `StoryViewerViewModel`). They interact with Services to fetch and persist data. Uses `@Observable` for SwiftUI integration.
*   **Services (`TechnicalTest/App/Sources/App/Services`):** Abstract away data fetching and persistence logic.
    *   `DataService`: Handles loading user data from the local JSON (`TechnicalTest/App/Sources/App/Data/users.json`) and generating dummy story item data (using `picsum.photos`). Implements pagination logic.
    *   `PersistenceService`: Handles saving/loading seen story and liked item states using `UserDefaults`.
*   **Swift Package (`App`):** All core feature logic (Models, Views, ViewModels, Services, Data) is encapsulated within the local Swift Package named `App` located at `TechnicalTest/App`. The `Package.swift` file defines the target, dependencies (Kingfisher, Alamofire), and includes the `Data` directory as a resource (`resources: [.process("Data")]`) so `users.json` is accessible via `Bundle.module`. Access control is set to `public` only where necessary for interaction with the main application target (`TechnicalTest`), specifically for:
    *   Views used directly by the main target (`StoryListView`).
    *   ViewModels and their initializers used by public Views (`StoryListViewModel`, `StoryViewerViewModel`).
    *   Models used in public API signatures (`User`, `Story`, `StoryItem`).
    *   Service protocols used in public initializers (`DataServiceProtocol`, `PersistenceServiceProtocol`).
    *   Service implementations used as default arguments in public initializers (`DataService`, `PersistenceService`).
    Other components used internally within the package (like `StoryAvatarView`, `UserPage`, `UserPagesResponse`, mock services) remain `internal` (default access level).
*   **Combine:** Used within services and ViewModels for handling asynchronous operations (though currently simple `Just` publishers are used for local data) and for publishing state changes (e.g., seen/liked status updates).
*   **Dependency Injection:** Services are injected into ViewModels via protocols (`DataServiceProtocol`, `PersistenceServiceProtocol`), allowing for easier testing and mocking (Mock services are provided for SwiftUI Previews).

## External Libraries

*   **Kingfisher:** Used for efficiently downloading and caching remote images (`picsum.photos` URLs) displayed in avatars and story items.
*   **Alamofire:** Added as a dependency in `Package.swift` but not actively used yet, as data fetching is currently local. It's available if network requests were needed later.

## Data Source

*   **Users:** Loaded from the local `TechnicalTest/App/Sources/App/Data/users.json` file. This file is included in the `App` package bundle via the `resources` parameter in `Package.swift`, making it loadable using `Bundle.module`.
*   **Story Content:** Dynamically generated using `https://picsum.photos/` URLs. Each user consistently gets the same set of images based on their ID. Images are *not* bundled with the app.

## Assumptions & Limitations

*   **Build Environment:**
    1.  Ensure the `App` Swift Package is correctly added and linked to the `TechnicalTest` application target.
    2.  Resolve Swift Package dependencies (File > Packages > Resolve Package Versions).
    3.  Clean the build folder (Product > Clean Build Folder).
    4.  Verify target memberships for the source files if issues persist.
*   **Story Content:** Story items are simple images from Picsum. No video, text overlays, or complex interactions are implemented.
*   **Error Handling:** Basic error handling is included (displaying messages in ViewModels), but it could be made more robust (e.g., specific error types, retry mechanisms).
*   **UI/UX:** The UI is functional but basic. Animations, transitions, and more sophisticated gestures (like Instagram's) are not implemented.
*   **Testing:** No unit or UI tests have been written, although the architecture with protocols and mock services facilitates testing.
*   **Infinite Scroll:** Implemented by wrapping around the available user list from the JSON. A real backend would provide true pagination.

## How to Run

1.  Open `TechnicalTest.xcodeproj` in Xcode.
2.  Select a simulator or physical device (iOS 18+).
3.  Build and run the `TechnicalTest` scheme.
