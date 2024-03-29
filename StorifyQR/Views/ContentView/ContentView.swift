//
//  ContentView.swift
//  StorifyQR
//
//  Created by Maks Winters on 01.01.2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Bindable var viewModel = ContentViewModel()
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            Background {
                ScrollView(.vertical) {
                    VStack {
//                        if viewModel.isSearching {
//                            SearchBar(searchText: $viewModel.searchText)
//                                .padding()
//                        }
                        tags
                            .padding()
                        items
                            .animation(reduceMotion ? .none : .bouncy(duration: 0.3), value: viewModel.storedItems)
                    }
                }
                .onAppear {
                    viewModel.fetchItems()
                }
                .navigationDestination(for: StoredItem.self, destination: { item in
                    ItemDetailView(item: item)
                })
                .navigationTitle("StorifyQR")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink {
                            NewItemView()
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Import", systemImage: "square.and.arrow.down") {
                            viewModel.importingData.toggle()
                        }
                    }
                }
                .fileImporter(isPresented: $viewModel.importingData, allowedContentTypes: [.sqrExportType]) { result in
                    viewModel.processImport(result: result)
                }
                .alert("Import \(viewModel.importItem?.name ?? "")?", isPresented: $viewModel.importingAlert) {
                    Button("Cancel") { }
                    Button("Save") {
                        viewModel.saveItem()
                    }
                }
                .alert("There was an error", isPresented: $viewModel.errorAlert) {
                    Button("OK") { }
                } message: {
                    Text(viewModel.errorMessage)
                }
            }
        }
    }
    
    var tags: some View {
        ScrollView(.horizontal) {
            HStack {
                Capsule()
                    .tint(.primary)
                    .overlay (
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.reversed)
                                .onTapGesture {
                                    withOptionalAnimation {
                                        viewModel.isSearching.toggle()
                                    }
                                }
                            if viewModel.isSearching {
                                TextField("", text: $viewModel.searchText)
                                    .foregroundStyle(.reversed)
                                    .placeholder(when: viewModel.searchText.isEmpty) {
                                        Text("Search...").foregroundColor(.reversed)
                                    }
                            }
                        }
                            .padding(.horizontal)
                    )
                    .frame(width: viewModel.isSearching ? 200 : 45, height: 45)
                ForEach(viewModel.tags) { tag in
                    let isSelected = tag == viewModel.selectedTag
                    TagView(tag: tag)
                        .onTapGesture {
                            viewModel.filterTag(tag: tag)
                        }
                        .overlay (
                            Capsule()
                                .stroke(lineWidth: isSelected ? 3 : 0)
                        )
                        .padding(.horizontal, 1)
                        .padding(.vertical, 2)
                }
            }
        }
        .scrollIndicators(.hidden)
    }
    
    var items: some View {
        ForEach(viewModel.filteredItems) { item in
            NavigationLink(value: item) {
                LazyVStack {
                    HStack {
                        let image = viewModel.getImage(item: item)
                        if image != nil {
                            image!
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(topLeading: 25, bottomLeading: 25, bottomTrailing: 0, topTrailing: 0)))
                        } else {
                            HStack(spacing: 0) {
                                Image(systemName: "shippingbox")
                                    .font(.system(size: 50))
                                    .frame(width: 100, height: 100)
                                Rectangle()
                                    .frame(width: 1, height: 100)
                            }
                        }
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .bold()
                            let append = item.itemDescription?.count ?? 0 > 20
                            Text(item.itemDescription?.prefix(20).appending(
                                append ? "..." : ""
                            ) ?? "Do description")
                        }
                        .padding(.horizontal)
                        Spacer()
                    }
                    .modifier(ContentPad(enablePadding: false))
                    .padding(.horizontal)
                }
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    // https://forums.developer.apple.com/forums/thread/661669
    StoredItemDataSource.shared.appendItem(item: StoredItem(name: "Testing item", itemDescription: "This item is used for testing", location: nil))
    return ContentView()
}
