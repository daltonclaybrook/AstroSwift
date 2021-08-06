import ComposableArchitecture

struct AppState: Equatable {
    var isPresentingSolarSystem: Bool
    var photoOfTheDay: PhotoOfTheDayState
}

enum AppAction {
    case dismissSolarSystem
    case binding(BindingAction<AppState>)
    case photoOfTheDay(PhotoOfTheDayAction)
}

struct AppEnvironment {}

let mainMenuViewReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
    switch action {
    case .dismissSolarSystem:
        state.isPresentingSolarSystem = false
        return .none

    case .binding:
        return .none

    case .photoOfTheDay:
        // This action is handled by another reducer
        return .none
    }
}
.binding(action: /AppAction.binding)

let pulledBackPhotoReducer = photoOfTheDayReducer.pullback(
    state: \AppState.photoOfTheDay,
    action: /AppAction.photoOfTheDay,
    environment: { (_: AppEnvironment) in PhotoOfTheDayEnvironment() }
)

let appReducer = Reducer.combine(
    mainMenuViewReducer,
    pulledBackPhotoReducer
)
