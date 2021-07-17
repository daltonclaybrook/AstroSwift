import ComposableArchitecture
import SpaceKit
import SwiftUI

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

struct PhotoOfTheDayWrapperView: View {
    let store: Store<PhotoOfTheDayState, PhotoOfTheDayAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            switch viewStore.state {
            case .idle:
                AnyView(ProgressView().onAppear {
                    viewStore.send(.fetchPhoto)
                })
            case .loading:
                AnyView(ProgressView())
            case .loaded(let photo):
                AnyView(PhotoOfTheDayView(photo: photo))
            case .errorLoading(let description):
                AnyView(Text("Failed with error: \(description)"))
            }
        }.navigationBarTitle(Text("Photo of the Day"), displayMode: .inline)
    }
}

struct PhotoOfTheDayView: View {
    let photo: Photo

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                AsyncImage(url: photo.hdURL) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }.padding()
                }

                Text(photo.title)
                    .font(.headline)
                    .padding()

                Text(photo.explanation)
                    .font(.body)
                    .padding()
            }
        }
    }
}

struct PhotoOfTheDayView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoOfTheDayView(photo: Photo(
            title: "Testing",
            explanation: "This is a test",
            url: URL(string: "https://testing.com")!,
            hdURL: URL(string: "https://testing.com")!
        ))
    }
}
