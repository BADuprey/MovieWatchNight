import SwiftUI

struct ForgotPasswordView: View {
    @State var username: String = ""
    var body: some View {
        // How are we actually resetting a password without an email address?
        VStack {
            Spacer()
            Text("Forgot Password?").font(.title)
            Spacer()
            VStack {
                TextField("Username", text: $username).textFieldStyle(.roundedBorder).border(.black, width: 1).padding(5)
                Spacer()
            }.padding(50)
            Spacer()
        }
    }
}

#Preview {
    ForgotPasswordView()
}
