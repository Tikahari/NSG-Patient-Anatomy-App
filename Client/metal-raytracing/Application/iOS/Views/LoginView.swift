		//
//  ContentView.swift
//  NSG_Metal_Render3D
//
//  Created by Daniel Williamson on 10/23/20.
//

import SwiftUI

let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)
struct LoginView: View {
    
    @ObservedObject var networkController = NetworkController()
    
    @Binding var authenticationDidSucceed: Bool

    @State var username: String = ""
    @State var password: String = ""
    
    @State var authenticationDidFail: Bool = false
    @State var didAuthenticate: Bool = false
    
    
    var body: some View {
        if networkController.isAuthenticated {
            ScanSelectionView(headscans: $networkController.scans)
        } else {
            VStack{
                Spacer()
                NSGLogo()
                Spacer()
                UsernameTextField(username: $username)
                PasswordSecureField(password: $password)
                if networkController.authenticationDidFail {
                    authenticationFailureContent()
                        
                }
                Spacer()
                Button(action: {
                    networkController.POSTUserAuthentication(password: password, username: username)
                    
                }) {
                    LoginButtonContent()
                }
                Spacer()
                
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    @State var authenticationDidSucceed: Bool = false
    static var previews: some View {
        MainView()
    }
}
        
        struct NSGLogo: View {
            var body: some View {
                Image("NSG-Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.all)
                    .alignmentGuide(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=Guide@*/.top/*@END_MENU_TOKEN@*/) { dimension in
                        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/dimension[.top]/*@END_MENU_TOKEN@*/
                    }
                    .frame(width: 250, height: 250  )
            }
        }
        
        
        struct LoginButtonContent: View {
            var body: some View {
                Text("Login")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 225, height: 50)
                    .background(Color.blue)
                    .cornerRadius(15.0)
            }
        }
        
        
        struct UsernameTextField: View {
            @Binding var username: String
            
            var body: some View {
                return TextField("Username", text: $username)
                    .frame(width: 250, height: 18, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .padding()
                    .background(lightGreyColor)
                    .cornerRadius(10.0)
                    .padding(.bottom, 20)
            }
        }
        
        
        struct PasswordSecureField: View {
            @Binding var password: String
            
            var body: some View {
                return SecureField("Password", text: $password)
                    .frame(width: 250, height: 18, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .padding()
                    .background(lightGreyColor)
                    .cornerRadius(10.0)
                    .padding(.bottom, 20)
            }
        }
        
        
        struct authenticationFailureContent: View {
            var body: some View {
                Text("Login Invalid. Please check your credentials.")
                    .frame(width: 275)
                    .foregroundColor(.red)
            }
        }
        
        
//        struct authenticationSuccesfulContent: View {
//            @Binding var username: String
//            var body: some View {
////                Text(username)
////                ScanSelectionView()
////                Text("Login succeeded!")
////                    .font(.headline)
////                    .frame(width: 250, height: 80)
////                    .background(Color.green)
////                    .cornerRadius(20.0)
////                    .foregroundColor(.white)
////                    .animation(Animation.default)
//            }
//
//        }
//
