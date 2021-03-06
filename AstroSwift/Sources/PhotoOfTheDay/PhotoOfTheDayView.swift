import ComposableArchitecture
import SpaceKit
import SwiftUI

struct PhotoOfTheDayWrapperView: View {
    let store: Store<PhotoOfTheDayState, PhotoOfTheDayAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            switch viewStore.state {
            case .idle:
                ProgressView().onAppear {
                    viewStore.send(.fetchPhoto)
                }
            case .loading:
                ProgressView()
            case .loaded(let photo):
                PhotoOfTheDayView(photo: photo)
            case .errorLoading(let description):
                Text("Failed with error: \(description)")
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
