import ComposableArchitecture
import SwiftUI

struct MainMenuView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        NavigationView {
            WithViewStore(store) { viewStore in
                List {
                    NavigationLink("Solar System", isActive: viewStore.binding(keyPath: \.isPresentingSolarSystem, send: AppAction.binding)) {
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
                SolarSystemView(store: .default)
                Button(action: { viewStore.send(.dismissSolarSystem) }) {
                    Image(systemName: "xmark").foregroundColor(.white).padding(40)
                }
            }.navigationBarHidden(true)
        }
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView(store: Store(
            initialState: AppState(
                isPresentingSolarSystem: false,
                photoOfTheDay: .idle
            ),
            reducer: appReducer,
            environment: AppEnvironment())
        )
    }
}
