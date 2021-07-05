//
//  SolarSystemView.swift
//  AstroSwift
//
//  Created by Dalton Claybrook on 7/5/21.
//

import SpaceKit
import SwiftUI

struct SolarSystemView: View {
    @ObservedObject
    private var viewModel = SolarSystemViewModel()
    private let timeIncrement: TimeInterval = 60 * 60 * 12

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                ForEach(Planet.allCases, id: \.self) { planet in
                    let size = getEllipseSize(with: geometry, for: planet)
                    let angle = viewModel.angle(of: planet)
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
        }
        .ignoresSafeArea()
        .background(Image("background"))
        .onAppear {
            viewModel.startAdvancingTime(
                startDate: Date(timeIntervalSince1970: 0),
                increment: timeIncrement
            )
        }
    }

    // MARK: - Helpers

    private func getEllipseSize(with proxy: GeometryProxy, for planet: Planet) -> CGSize {
        let maxWidth = proxy.size.width - 80.0
        let maxHeight = proxy.size.height - 40.0
        let multiplier = viewModel.ellipseSizeMultiplier(for: planet)
        return CGSize(
            width: maxWidth * multiplier,
            height: maxHeight * multiplier
        )
    }
}

struct SolarSystemView_Previews: PreviewProvider {
    static var previews: some View {
        SolarSystemView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}