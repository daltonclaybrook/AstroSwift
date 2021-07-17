import ComposableArchitecture
import UIKit

final class SceneDelegate: NSObject, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        let rootView = ContentView(store: Store(
            initialState: AppState(
                isPresentingSolarSystem: false,
                photoOfTheDay: .idle
            ),
            reducer: appReducer,
            environment: AppEnvironment())
        )
        let hostingController = HostingController(rootView: rootView)
        window.rootViewController = hostingController
        self.window = window
        window.makeKeyAndVisible()
    }
}
