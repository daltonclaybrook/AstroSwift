import SwiftUI

final class HostingController: UIHostingController<MainMenuView> {
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}
