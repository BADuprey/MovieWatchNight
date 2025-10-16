import SwiftUI

struct NewUserView: View {
    @State var username: String = ""
    @State var password: String = ""
    @State var confirmedPassword: String = ""
    @State var emailAddress: String = ""
    
    @State var showWarning = false
    @State var warning = Text("")
    var body: some View {
        VStack {
            Text("New User").font(.title)
            Spacer()
            TextField("Username", text: $username).textFieldStyle(.roundedBorder).border(.black, width: 1).padding(5)
            TextField("Email Address", text: $emailAddress).textFieldStyle(.roundedBorder).border(.black, width: 1).padding(5)
            SecureField("Password", text: $password).textFieldStyle(.roundedBorder).border(.black, width: 1).padding(5)
            SecureField("Confirm Password", text: $confirmedPassword).onSubmit(MakeUser).textFieldStyle(.roundedBorder).border(.black, width: 1).padding(5)
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
