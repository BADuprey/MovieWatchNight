import SwiftUI
import CryptoKit

let textFieldColor = Color(red: 200/255, green: 200/255, blue: 255/255, opacity: 0.5)
struct LogInView: View {
    @State var username: String = ""
    @State var password: String = ""
    @State var loginFailed = true
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            Text("Log In").font(.title)
            Spacer()
            VStack {
                TextField("Username", text: $username).background(textFieldColor).border(.black, width: 1)
                SecureField("Password", text: $password).background(textFieldColor).border(.black, width: 1)
            }.padding(50)
            
            Spacer()
            if loginFailed {
                Text("Login Failed")
            }
            Spacer()
            Button("Log In", action: HandleLogin)
            Spacer()
        }
    }
    
    func HandleLogin(){
        loginFailed = false
        let passwordData = Data(password.utf8)
        let passwordHash = SHA256.hash(data: passwordData).description
        //Send username and password to check
        var checks = true
        
        if checks {
            //Goto MainMenu!
            
        } else {
            //Display failure of user
            loginFailed = true
        }
    }
}

#Preview {
    LogInView()
}
