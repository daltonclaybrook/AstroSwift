import ComposableArchitecture
import SpaceKit

enum PhotoOfTheDayState: Equatable {
    case idle
    case loading
    case loaded(Photo)
    case errorLoading(description: String)
}

enum PhotoOfTheDayAction {
    case fetchPhoto
    case photoLoaded(Photo)
    case failedToLoadPhoto(Error)
}

struct PhotoOfTheDayEnvironment {}

let photoOfTheDayReducer = Reducer<PhotoOfTheDayState, PhotoOfTheDayAction, PhotoOfTheDayEnvironment> { state, action, environment in
    switch action {
    case .fetchPhoto:
        state = .loading
        return .future {
            let astronomy = Astronomy(nasaAPIKey: NASAAPIKey.apiKey)
            do {
                let photo = try await astronomy.fetchPhoto()
                return .photoLoaded(photo)
            } catch let error {
                return .failedToLoadPhoto(error)
            }
        }

    case .photoLoaded(let photo):
        state = .loaded(photo)
        return .none

    case .failedToLoadPhoto(let error):
        state = .errorLoading(description: error.localizedDescription)
        return .none
    }
}
