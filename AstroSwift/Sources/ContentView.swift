import ComposableArchitecture
import SwiftUI

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

let contentViewReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
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
}.binding(action: /AppAction.binding)

let pulledBackPhotoReducer = photoOfTheDayReducer.pullback(
    state: \AppState.photoOfTheDay,
    action: /AppAction.photoOfTheDay,
    environment: { (_: AppEnvironment) in PhotoOfTheDayEnvironment() }
)

let appReducer = Reducer.combine(contentViewReducer, pulledBackPhotoReducer)

struct ContentView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        NavigationView {
            WithViewStore(store) { viewStore in
                List {
                    NavigationLink.init("Solar System", isActive: viewStore.binding(keyPath: \.isPresentingSolarSystem, send: AppAction.binding)) {
                        SolarSystemWrapperView(store: store)
                    }

                    NavigationLink("Photo of the Day") {
                        PhotoOfTheDayWrapperView(store: store.scope(
                            state: \.photoOfTheDay,
                            action: AppAction.photoOfTheDay
                        ))
                    }
                }
                .navigationTitle("Astro Swift!")
                .navigationBarHidden(false)
            }
        }
    }
}

struct SolarSystemWrapperView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack(alignment: .topLeading) {
                SolarSystemView()
                Button(action: { viewStore.send(.dismissSolarSystem) }) {
                    Image(systemName: "xmark").foregroundColor(.white).padding(40)
                }
            }.navigationBarHidden(true)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: Store(
            initialState: AppState(
                isPresentingSolarSystem: false,
                photoOfTheDay: .idle
            ),
            reducer: appReducer,
            environment: AppEnvironment())
        )
    }
}
