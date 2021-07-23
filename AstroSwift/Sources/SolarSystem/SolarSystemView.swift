import Combine
import ComposableArchitecture
import SpaceKit
import SwiftUI

struct SolarSystemState: Equatable {
    var isAnimating: Bool
    var currentDate: Date
}

enum SolarSystemAction: Equatable {
    case startAnimating
    case stopAnimating
    case incrementCurrentDate
}

struct SolarSystemEnvironment {
    let dateIncrement: TimeInterval
    let displayLinkClient: DisplayLinkClient
}

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

let solarSystemReducer = Reducer<SolarSystemState, SolarSystemAction, SolarSystemEnvironment> { state, action, environment in
    struct AnimationCancellable: Hashable {}
    struct DisplayLinkTimerId: Hashable {}

    switch action {
    case .startAnimating:
        state.isAnimating = true
        state.currentDate = Date(timeIntervalSince1970: 0)

        return environment
            .displayLinkClient
            .startDisplayLink(DisplayLinkTimerId())
            .map { .incrementCurrentDate }
            .cancellable(
                id: AnimationCancellable(),
                cancelInFlight: true
            )

    case .stopAnimating:
        state.isAnimating = false
        return Effect.cancel(id: AnimationCancellable())

    case .incrementCurrentDate:
        state.currentDate.addTimeInterval(environment.dateIncrement)
        return .none
    }
}

struct SolarSystemView: View {
    @ObservedObject
    var viewStore: ViewStore<SolarSystemState, SolarSystemAction>

    private let planetUtility = PlanetPositionUtility()

    init(store: Store<SolarSystemState, SolarSystemAction>) {
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                ForEach(Planet.allCases, id: \.self) { planet in
                    let size = getEllipseSize(with: geometry, for: planet)
                    let angle = planetUtility.angle(of: planet, date: viewStore.currentDate)
                    EllipseView(ellipseSize: size)
                        .zIndex(-100_000)
                    PlanetView(
                        ellipseSize: size,
                        planet: planet,
                        angle: angle
                    )
                }
                Image("sun")
            }
            .position(x: geometry.size.width / 2.0, y: geometry.size.height / 2.0)
        }
        .background {
            Image("background")
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
        .ignoresSafeArea()
        .onAppear { viewStore.send(.startAnimating) }
        .onDisappear { viewStore.send(.stopAnimating) }
    }

    // MARK: - Helpers

    private func getEllipseSize(with proxy: GeometryProxy, for planet: Planet) -> CGSize {
        let (widthPadding, heightPadding) = proxy.size.width > proxy.size.height ? (80.0, 40.0) : (40.0, 80.0)
        let maxWidth = proxy.size.width - widthPadding
        let maxHeight = proxy.size.height - heightPadding
        let multiplier = planetUtility.ellipseSizeMultiplier(for: planet)
        return CGSize(
            width: maxWidth * multiplier,
            height: maxHeight * multiplier
        )
    }
}

struct SolarSystemView_Previews: PreviewProvider {
    static var previews: some View {
        SolarSystemView(store: .default)
    }
}

extension Store where State == SolarSystemState, Action == SolarSystemAction {
    static var `default`: Store<State, Action> {
        Store(
            initialState: SolarSystemState(
                isAnimating: false,
                currentDate: Date(timeIntervalSince1970: 0)
            ),
            reducer: solarSystemReducer,
            environment: SolarSystemEnvironment(
                dateIncrement: 60 * 60 * 12, // Advance by 12 hours every frame
                displayLinkClient: .live
            )
        )
    }
}
