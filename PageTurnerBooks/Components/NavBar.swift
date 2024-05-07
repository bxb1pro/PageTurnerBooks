//
//  NavBar.swift
//  PageTurnerBooks
//
//  Created by Staff on 04/05/2024.
//

import SwiftUI

struct NavBar: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    private var selectedTab = 1
    
    var body: some View {
        TabView {
            Group{
                NavigationStack{
                    //HomePageView()
                }
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(1)
                
                NavigationStack{
                    BookSearchView().environmentObject(BookManager.shared)
                }
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(2)
                
                NavigationStack {
                                    if !authViewModel.currentUserId.isEmpty {
                                        ListsView(viewModel: BooksListViewModel(userId: authViewModel.currentUserId))
                                    } else {
                                        Text("No user logged in")
                                    }
                                }
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Lists")
                }
                .tag(3)
                
                NavigationStack{
                    AccountView()
                }
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Account")
                }
                .tag(4)
            }
        }
        .onAppear {
                    print("NavBar is using user ID: \(authViewModel.currentUserId)")
                }
        .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
//        .toolbarBackground(Color(.black), for: .tabBar)
//        .toolbarBackground(.visible, for: .tabBar)
//        .toolbarColorScheme(.dark, for: .tabBar)

    }
}
