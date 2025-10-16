import SwiftUI

struct NewUserView: View {
    @State var username: String = ""
    @State var password: String = ""
    @State var confirmedPassword: String = ""
    
    @State var showWarning = false
    @State var warning = Text("")
    var body: some View {
        VStack {
            Spacer()
            TextField("Username", text: $username)
            SecureField("Password", text: $password)
            SecureField("Confirm Password", text: $confirmedPassword).onSubmit(MakeUser)
            warning
            Spacer()
        }
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
