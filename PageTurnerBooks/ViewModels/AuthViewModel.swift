import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var isSignedIn = false
    
    var currentUserId: String {
        userSession?.uid ?? ""
    }
    
    init() {
        self.userSession = Auth.auth().currentUser
        if let userSession = userSession {
            print("Session Init - User ID: \(userSession.uid)")
            self.isSignedIn = true
        } else {
            print("Session Init - No active user session")
        }
        
        Task {
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            DispatchQueue.main.async {
                self.userSession = result.user
                self.isSignedIn = true
                print("Sign-in successful - User ID: \(result.user.uid)")
            }
            await fetchUser()
        } catch {
            print("Sign-in failed: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.isSignedIn = false
            }
            throw error
        }
    }
    
    func createUser(withEmail email: String, password: String, fullName: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            DispatchQueue.main.async {
                self.userSession = result.user
                print("User creation successful - User ID: \(result.user.uid)")
            }
            let user = User(id: result.user.uid, fullName: fullName, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            let db = Firestore.firestore()
            try await db.collection("Users").document(user.id).setData(encodedUser)
            print("Firestore user data set for User ID: \(user.id)")
            await fetchUser()
        } catch {
            print("Failed to create user: \(error.localizedDescription)")
        }
    }
    
    func logOut() {
        guard let user = Auth.auth().currentUser, !user.uid.isEmpty else {
            print("Logout failed - No user session found")
            return
        }
        
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.userSession = nil
                self.currentUser = nil
                self.isSignedIn = false
                print("Logged out successfully")
            }
        } catch {
            print("Logout failed: \(error.localizedDescription)")
        }
    }
    
    
    func deleteUser() {
        
        guard let user = Auth.auth().currentUser, !user.uid.isEmpty else {
            print("Delete user failed - No user logged in or invalid user ID")
            return
        }
        
        print("Attempting to delete user with ID: \(user.uid)")
        
        let db = Firestore.firestore()
        
        // Function to delete a subcollection
        func deleteSubcollection(_ collectionPath: String, completion: @escaping () -> Void) {
            db.collection(collectionPath).getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("No documents found in subcollection: \(collectionPath)")
                    completion()
                    return
                }
                
                for document in documents {
                    document.reference.delete()
                }
                
                completion()
            }
        }
        
        // Delete each subcollection
        let subcollections = ["CurrentlyReading", "FinishedReading", "WantToRead"]
        let group = DispatchGroup()
        
        for subcollection in subcollections {
            let path = "Users/\(user.uid)/\(subcollection)"
            group.enter()
            deleteSubcollection(path) {
                group.leave()
            }
        }
        
        // After all subcollections are deleted, delete the user document and account
        group.notify(queue: .main) {
            db.collection("Users").document(user.uid).delete { error in
                if let error = error {
                    print("Failed to delete user data from Firestore: \(error.localizedDescription)")
                    return
                }
                
                print("User data deleted from Firestore for User ID: \(user.uid)")
                
                user.delete { error in
                    if let error = error {
                        print("Failed to delete user account: \(error.localizedDescription)")
                    } else {
                        DispatchQueue.main.async {
                            self.userSession = nil
                            self.currentUser = nil
                            self.isSignedIn = false
                            print("User account deleted successfully.")
                        }
                    }
                }
            }
        }
    }
    
    
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid, !uid.isEmpty else {
            print("Fetch user failed - User ID is nil or empty")
            return
        }
        do {
            let snapshot = try await Firestore.firestore().collection("Users").document(uid).getDocument()
            self.currentUser = try snapshot.data(as: User.self)
            print("Current user fetched: \(String(describing: self.currentUser))")
        } catch {
            print("Failed to fetch user: \(error.localizedDescription)")
        }
    }
    
    
    func updatePassword(currentPassword: String, newPassword: String) async throws {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            throw NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No authenticated user found."])
        }

        // Reauthenticate the user to ensure they are the one requesting the password change
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        do {
            try await user.reauthenticate(with: credential)

            // Update the password
            try await user.updatePassword(to: newPassword)
            print("Password updated successfully.")

            // Optional: Update Firestore if needed
            // let db = Firestore.firestore()
            // try await db.collection("Users").document(user.uid).updateData(["lastPasswordChange": FieldValue.serverTimestamp()])
            
            // Feedback for UI
            DispatchQueue.main.async {
                print("Your password has been updated successfully.")
            }
        } catch let error as NSError {
            print("Error updating password: \(error.localizedDescription)")
            throw error
        }
    }
    
    
    
}

extension AuthViewModel {
    static var mock: AuthViewModel {
        let mock = AuthViewModel()
        mock.currentUser = User(id: "testUser", fullName: "Brad Turner", email: "bradturner@gmail.com")
        mock.isSignedIn = true
        return mock
    }
}

