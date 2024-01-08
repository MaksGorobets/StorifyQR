//
//  NewItemView.swift
//  StorifyQR
//
//  Created by Maks Winters on 04.01.2024.
//
// https://stackoverflow.com/questions/69965379/swiftui-how-to-prevent-keyboard-in-a-sheet-to-push-up-my-main-ui
//
// https://stackoverflow.com/questions/56491386/how-to-hide-keyboard-when-using-swiftui
//
// https://www.youtube.com/watch?v=83RhhYeybgQ
//

import SwiftUI
import PhotosUI

struct NewItemView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var viewModel = NewItemViewModel()
    
    var body: some View {
        Background {
            ScrollView {
                VStack(spacing: 20) {
// Picture view, picture selector
                    VStack {
                        if viewModel.image != nil {
                            viewModel.image!
                                .resizable()
                                .scaledToFit()
                        } else {
                            Rectangle()
                                .frame(height: 250)
                                .foregroundStyle(.link)
                                .overlay (
                                    Image(systemName: "shippingbox.fill")
                                        .font(.system(size: 100))
                                )
                        }
                        PhotosPicker("Select a photo", selection: $viewModel.pickerItem)
                            .buttonStyle(.bordered)
                            .clipShape(.capsule)
                            .padding(.top)
                            .onChange(of: viewModel.pickerItem) { oldValue, newValue in
                                viewModel.loadImage()
                            }
                        Spacer()
                    }
// Tags
                    VStack {
                        Text("Tags:")
                            .font(.system(.headline))
                            .padding(.horizontal)
                        ScrollView(.horizontal) {
                            HStack {
                                Text("No photo")
                                    .padding(10)
                                    .foregroundStyle(.white)
                                    .background(.blue.gradient)
                                    .clipShape(RoundedRectangle(cornerRadius: 25.0))
                                ForEach(viewModel.tags) { tag in
                                    Text(tag.title)
                                        .padding(10)
                                        .foregroundStyle(.white)
                                        .background(.blue.gradient)
                                        .clipShape(RoundedRectangle(cornerRadius: 25.0))
                                }
                                .onChange(of: viewModel.tags) { oldValue, newValue in
                                    print("Received value \(newValue)")
                                }
                                Button {
                                    viewModel.isShowingSheet.toggle()
                                } label: {
                                    Image(systemName: "plus")
                                        .frame(width: 25, height: 25)
                                }
                                .buttonStyle(.bordered)
                                .buttonBorderShape(.circle)
                            }
                        }
                    }
                    .modifier(ContentPad())
                    .padding(.horizontal)
                    .sheet(isPresented: $viewModel.isShowingSheet) {
                        AddTagView { tag in
                            viewModel.tags.append(tag)
                        }
                        .presentationDetents([.medium])
                    }
// Name TextField
                    VStack {
                        Text("Name:")
                            .font(.system(.headline))
                            .padding(.horizontal)
                        TextField("Enter your item's name", text: $viewModel.name)
                            .frame(height: 50)
                        if viewModel.isShowingNameWarning {
                            Text("Name is required to proceed!")
                                .foregroundStyle(.red)
                                .padding(.horizontal)
                        }
                    }
                    .modifier(ContentPad())
                    .padding(.horizontal)
// Description TextField
                    VStack {
                        Text("Description:")
                            .font(.system(.headline))
                            .padding(.horizontal)
                        TextField("Enter your item's name", text: $viewModel.itemDescription, axis: .vertical)
                            .frame(height: 100)
                            .lineLimit(2...5)
                    }
                    .modifier(ContentPad())
                    .padding(.horizontal)
                    viewModel.mapView
                }
            }
// Bottom save floating button
            .safeAreaInset(edge: .bottom, alignment: .center) {
                Button {
                    viewModel.askToSave()
                } label: {
                    StyledButtonComponent(title: "Save", foregroundStyle: NewItemViewModel.saveButtonStyle)
                        .containerRelativeFrame(.horizontal) { width, axis in
                            width * 0.7
                        }
                }
                .padding(.vertical)
            }
            .navigationTitle("Add new item")
            .navigationBarTitleDisplayMode(.inline)
        }.onTapGesture {
            viewModel.endEditing()
        }
        .alert("Save \(viewModel.name)?", isPresented: $viewModel.isShowingAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                viewModel.saveToContext()
                dismiss()
            }
        }
    }
}

#Preview {
    NewItemView()
}