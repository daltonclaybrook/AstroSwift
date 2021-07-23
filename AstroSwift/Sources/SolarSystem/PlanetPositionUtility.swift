import SpaceKit
import SwiftUI

struct PlanetPositionUtility {
    private let sizeMultiplierForPlanet: [Planet: CGFloat]

    init() {
        var currentMultiplier = 1.0
        let minMultiplier = 0.1
        let allPlanets = Planet.allCases.reversed()
        let decrementAmount = (currentMultiplier - minMultiplier) / Double(allPlanets.count)

        sizeMultiplierForPlanet = allPlanets.reduce(into: [:]) { result, planet in
            defer { currentMultiplier -= decrementAmount }
            result[planet] = currentMultiplier
        }
    }

    func ellipseSizeMultiplier(for planet: Planet) -> CGFloat {
        sizeMultiplierForPlanet[planet] ?? 1.0
    }

    func angle(of planet: Planet, date: Date) -> Angle {
        let position = PlanetPosition(planet: planet, date: date)
        return .radians(position.longitude)
    }
}
