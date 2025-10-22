import SwiftUI

struct ForgotPasswordView: View {
    @State var username: String = ""
    var body: some View {
        VStack {
            Text("Forgot Password?").font(.title)
            Spacer()
            VStack {
                TextField("Username", text: $username).background(textFieldColor).textFieldStyle(.roundedBorder).border(.black, width: 1)
                Spacer()
            }.padding(50)
            Spacer()
        }
    }
}

#Preview {
    ForgotPasswordView()
}
