import SwiftUI

struct NewUserView: View {
    @State var username: String = ""
    @State var password: String = ""
    @State var confirmedPassword: String = ""
    
    @State var showWarning = false
    @State var warning = Text("")
    var body: some View {
        VStack {
            Text("New User").font(.title)
            Spacer()
            TextField("Username", text: $username).background(textFieldColor).textFieldStyle(.roundedBorder).border(.black, width: 1)
            SecureField("Password", text: $password).background(textFieldColor).textFieldStyle(.roundedBorder).border(.black, width: 1)
            SecureField("Confirm Password", text: $confirmedPassword).onSubmit(MakeUser).background(textFieldColor).textFieldStyle(.roundedBorder).border(.black, width: 1)
            warning
            Spacer()
        }.padding(50)
    }
    
    func MakeUser() {
        if password == confirmedPassword {
            //Check if password is valid
            //Make the user
        } else {
            warning = Text("Passwords do not match")
        }
    }
}

#Preview {
    NewUserView()
}
