import Combine
import ComposableArchitecture
import QuartzCore

struct DisplayLinkClient {
    /// Start the display link, providing an identifier for storing the display link target
    let startDisplayLink: (_ id: AnyHashable) -> Effect<Void, Never>
}

extension DisplayLinkClient {
    static let live = Self { id in
        .run { subscriber in
            let target = DisplayLinkTarget {
                subscriber.send(())
            }
            let displayLink = CADisplayLink(target: target, selector: #selector(DisplayLinkTarget.displayLinkFired(_:)))
            displayLink.add(to: .main, forMode: .default)
            dependencies[id] = target

            return AnyCancellable {
                displayLink.invalidate()
                dependencies[id] = nil
            }
        }
    }
}

final class DisplayLinkTarget {
    private let didFire: () -> Void

    init(didFire: @escaping () -> Void) {
        self.didFire = didFire
    }

    @objc
    fileprivate func displayLinkFired(_ displayLink: CADisplayLink) {
        didFire()
    }
}

private var dependencies: [AnyHashable: DisplayLinkTarget] = [:]
