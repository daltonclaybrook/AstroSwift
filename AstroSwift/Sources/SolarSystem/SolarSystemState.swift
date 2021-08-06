import ComposableArchitecture

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
