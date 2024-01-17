//
//  NewItemViewModel.swift
//  StorifyQR
//
//  Created by Maks Winters on 05.01.2024.
//
// https://dev.to/jameson/swiftui-with-swiftdata-through-repository-36d1
//
// https://www.youtube.com/watch?v=4-Q14fCm-VE
//

import Foundation
import SwiftUI
import PhotosUI

@Observable
final class NewItemViewModel {
    
    static let saveButtonStyle = LinearGradient(colors: [.blue, .yellow], startPoint: .bottomLeading, endPoint: .topTrailing)
    
    @ObservationIgnored
    private let dataSource: StoredItemDataSource
    
    let mapView = MapView()
    
    var name = ""
    var isShowingNameWarning = false
    var itemDescription = ""
    
    var pickerItem: PhotosPickerItem?
    var photoData: Data?
    var image: Image?
    
    var mlModelTag = Tag(title: "ExampleML", colorComponent: ColorComponents.fromColor(.blue))
    var tags = [Tag]()
    
    var isShowingSheet = false
    var isShowingAlert = false
    
    init(dataSource: StoredItemDataSource = StoredItemDataSource.shared, name: String = "", isShowingNameWarning: Bool = false, itemDescription: String = "", pickerItem: PhotosPickerItem? = nil, image: Image? = nil, isShowingAlert: Bool = false) {
        self.dataSource = dataSource
        self.name = name
        self.isShowingNameWarning = isShowingNameWarning
        self.itemDescription = itemDescription
        self.pickerItem = pickerItem
        self.image = image
        self.isShowingAlert = isShowingAlert
    }
    
    func endEditing() {
        UIApplication.shared.endEditing()
    }
    
    func loadImage() {
        Task {
            guard let rawImage = try await pickerItem?.loadTransferable(type: Data.self) else { return }
            photoData = rawImage
            let uiImage = UIImage(data: rawImage)
            image = Image(uiImage: uiImage!)
        }
    }
    
    func checkIsNameFilled() -> Bool {
        isShowingNameWarning = false
        guard !name.isEmpty else {
            isShowingNameWarning = true
            return false
        }
        return true
    }
    
    func saveToContext() {
        guard checkIsNameFilled() else { return }
        let newItem = StoredItem(photo: photoData, name: name, itemDescription: itemDescription.isEmpty ? nil : itemDescription, location: appendLocation())
        dataSource.appendItem(item: newItem)
//        tags.insert(mlModelTag, at: 0) // MLModel computed tag insertion
//        Above commented code causes duplicate values and crashes the app
//        TODO: Find a better way to insert MLModel result tag
        dataSource.appendTagToItem(item: newItem, tags: tags)
    }
    
    func appendLocation() -> Coordinate2D? {
        if mapView.viewModel.isIncludingLocation {
            let location = mapView.viewModel.rawLocation
            return Coordinate2D(latitude: location.latitude, longitude: location.longitude)
        } else {
            return nil
        }
    }
    
    func askToSave() {
        guard checkIsNameFilled() else { return }
        isShowingAlert = true
    }
    
}
