//
import SwiftUI

struct ViewManagerView: View {
    enum Views{
        case logInView
        case newUserView
        case forgotPasswordView
    }
    @State var currentView = Views.logInView
    
    var body: some View {
        VStack {
            switch currentView {
                case .logInView:
                    LogInView()
                case .newUserView:
                    NewUserView()
                case .forgotPasswordView:
                    ForgotPasswordView()
            }
            Spacer()
            VStack {
                if currentView == .logInView{
                    Button("Forgot Password?", action: {currentView = .forgotPasswordView}).padding(10)
                    Button("New User? Sign Up!", action: {currentView = .newUserView}).padding(10)
                } else {
                    Button("Back <-", action: {currentView = .logInView})
                }
            }
        }
        
    }
}

#Preview {
    ViewManagerView()
}
