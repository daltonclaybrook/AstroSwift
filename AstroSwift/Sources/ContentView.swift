import ComposableArchitecture
import SwiftUI

struct AppState: Equatable {
    var isPresentingSolarSystem: Bool
}

enum AppAction {
    case dismissSolarSystem
    case binding(BindingAction<AppState>)
}

struct AppEnvironment {}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
    switch action {
    case .dismissSolarSystem:
        state.isPresentingSolarSystem = false
        return .none

    case .binding:
        return .none
    }
}.binding(action: /AppAction.binding)

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
                        Text("Fix me!")
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
            initialState: AppState(isPresentingSolarSystem: false),
            reducer: appReducer,
            environment: AppEnvironment())
        )
    }
}
