import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Profile")
                    .font(.largeTitle)
                Text("Profile content will be added later")
                    .foregroundColor(.gray)
            }
            .navigationTitle("Profile")
        }
    }
} 