import Combine
import ComposableArchitecture
import SpaceKit
import SwiftUI

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
