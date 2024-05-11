//
//  AccountView.swift

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showEmailFields = false
    @State private var showPasswordFields = false
    @State private var newEmail: String = ""
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var showingDeleteConfirmation = false
    @State private var showAccountAlert = false
    @State private var showLogoutAlert = false
    @State private var showingConfirmation = false
    @State private var isCurrentPasswordValid = false
    @State private var showSuccessAlert = false
    @FocusState private var fieldIsFocused: Bool
    
    var body: some View {
        //TODO: Commented out Vstack currently disables Sign Out button
//        VStack{
            NavigationStack {
                VStack (spacing: 0) {
                    Text("Account Information")
                        .frame(maxWidth: .infinity)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.pTPrimary)
                        .ignoresSafeArea(edges: .horizontal)
                        .ignoresSafeArea(edges: .bottom)
                    
                    Form{
                        Section(){
                            DisclosureGroup("Email", isExpanded: $showEmailFields){
                                VStack(alignment: .leading) {
                                    if let email = authViewModel.currentUser?.email {
                                        Text(email)
                                            .bold()
                                            .padding(.bottom, 10)
                                    }
                                }
                                .padding()
                                
                            }
                            .accentColor(Color.pTPrimary)
                            
                            DisclosureGroup("Password", isExpanded: $showPasswordFields) {
                                VStack(spacing: 15) {
                                    
                                    HStack {
                                        SecureField("Current Password", text: $currentPassword)
                                            .padding(8)
                                            .overlay(
                                                Rectangle()
                                                    .frame(height: 0.4)
                                                    .foregroundColor(.gray),
                                                alignment: .bottom
                                            )
                                            .focused($fieldIsFocused)
                                        
                                        Button(action: {
                                            authViewModel.validateCurrentPassword(currentPassword: currentPassword) { isValid, error in
                                                DispatchQueue.main.async {
                                                    if let error = error {
                                                        print("Validation error: \(error.localizedDescription)")
                                                    } else {
                                                        print("Re-authentication success, isValid set to \(isValid)")
                                                    }
                                                    isCurrentPasswordValid = isValid
                                                }
                                            }
                                        }) {
                                            Image(systemName: "checkmark.circle")
                                                .foregroundColor(isCurrentPasswordValid ? .green : .gray)
                                        }
                                        .padding(.trailing, 10)
                                    }
                                    
                                    if !isCurrentPasswordValid && !currentPassword.isEmpty {
                                        Text("Wrong password. Please try again.")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                            .padding(.leading, 8)
                                            .padding(.top, 2)
                                    }
                                    
                                    SecureField("New Password", text: $newPassword)
                                        .padding(8)
                                        .overlay(
                                            Rectangle()
                                                .frame(height: 0.4)
                                                .foregroundColor(.gray),
                                            alignment: .bottom
                                        )
                                        .focused($fieldIsFocused)
                                    if newPassword.count > 0 && newPassword.count < 6 {
                                        Text("Password must be at least 6 characters long.")
                                            .font(.caption)
                                            .foregroundColor(.red)
                                            .padding(.bottom, 5)
                                    }
                                    
                                    SecureField("Confirm New Password", text: $confirmPassword)
                                        .padding(8)
                                        .overlay(
                                            Rectangle()
                                                .frame(height: 0.4)
                                                .foregroundColor(.gray),
                                            alignment: .bottom
                                        )
                                        .padding(.bottom, 10)
                                        .focused($fieldIsFocused)
                                    
                                    Button("Update Password") {
                                        if newPassword == confirmPassword {
                                            showingConfirmation = true
                                        } else {
                                            print("The new passwords do not match.")
                                        }
                                    }
                                    .disabled(!isCurrentPasswordValid || newPassword.isEmpty || confirmPassword.isEmpty || newPassword != confirmPassword || newPassword.count < 6)
                                    .accentColor(.blue)
                                    .confirmationDialog("Are you sure you want to update your password?", isPresented: $showingConfirmation, titleVisibility: .visible) {
                                        Button("Update", role: .destructive) {
                                            Task {
                                                do {
                                                    try await authViewModel.updatePassword(currentPassword: currentPassword, newPassword: newPassword)
                                                    DispatchQueue.main.async {
                                                        currentPassword = ""
                                                        newPassword = ""
                                                        confirmPassword = ""
                                                        showSuccessAlert = true
                                                    }
                                                } catch {
                                                    print("Failed to update password: \(error.localizedDescription)")
                                                }
                                            }
                                        }
                                        Button("Cancel", role: .cancel) { }
                                    }
                                }
                            }
                            .accentColor(Color.pTPrimary)
                            .alert("Password Changed", isPresented: $showSuccessAlert) {
                                Button("OK", role: .cancel) { }
                            } message: {
                                Text("Your password has been successfully updated.")
                            }
                        }
                        
                        
                        VStack {
                            SecondaryButton(title: "Sign Out", action: {
                                self.showLogoutAlert = true // Set to true to show the alert when tapped
                            })
                            .padding()
                            .frame(alignment: .center)
                            .alert(isPresented: $showLogoutAlert) { // Configure the alert
                                Alert(
                                    title: Text("Confirm Sign Out"),
                                    message: Text("Are you sure you want to sign out?"),
                                    primaryButton: .destructive(Text("Sign Out")) {
                                        print("Logging out...")
                                        authViewModel.logOut()
                                    },
                                    secondaryButton: .cancel()
                                )
                            }
                        }
                    }
                    Spacer()
                    //TODO: This jumps to just above the keyboard when the keyboard is open
                    Text("Delete Account")
                        .fontWeight(.bold)
                        .foregroundColor(.pTWarning)
                        .onTapGesture {
                            self.showAccountAlert = true // Set to true to show the alert when tapped
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .alert(isPresented: $showAccountAlert) {
                            Alert(
                                title: Text("Confirm Deletion"),
                                message: Text("Are you sure you want to delete your account? This action cannot be undone."),
                                primaryButton: .destructive(Text("Delete")) {
                                    print("Delete button pressed. Attempting to delete user...")
                                    authViewModel.deleteUser()
                                },
                                secondaryButton: .cancel()
                            )
                        }
                }
            }
            
//        }
//        .onTapGesture {
//            fieldIsFocused = false
//        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
            .environmentObject(AuthViewModel())
    }
}
