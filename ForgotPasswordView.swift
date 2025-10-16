import SwiftUI

struct ForgotPasswordView: View {
    @State var username: String = ""
    var body: some View {
        // How are we actually resetting a password without an email address?
        VStack {
            Text("Forgot Password?").font(.title)
            Spacer()
            TextField("Username", text: $username)
            Spacer()
        }
    }
}
