import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    @EnvironmentObject var bookManager: BookManager
    var coordinator: Coordinator

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Search", text: $searchText)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    Button(action: {
                        coordinator.searchBooks(searchText, source: .searchBar)
                        searchText = ""  // Clear text after search
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.title)
                            .foregroundColor(.primary)
                    }
                }
                .padding()

                if !bookManager.books.isEmpty {
                    List(bookManager.books, id: \.id) { book in
                        BookRow(book: book)
                    }
                }
            }
        }
    }
}

