//
//  EditItemViewModel.swift
//  StorifyQR
//
//  Created by Maks Winters on 31.01.2024.
//

import Foundation
import SwiftUI
import PhotosUI

@Observable
final class EditItemViewModel: BaseItemEditing {
    
    static let saveButtonStyle = Color.blue.gradient
    
    let mapView: MapView
    
    let item: StoredItem
    
    init(item: StoredItem,
         isShowingNameWarning: Bool = false,
         isShowingAlert: Bool = false) {
        self.item = item
        self.mapView = MapView(userCustomLocation: item.location)
        super.init(item: item)
    }
    
    @MainActor
    func saveChanges() {
        let itemDescChecked = itemDescription.isEmpty ? "No description." : itemDescription
        let itemsLocation = mapView.viewModel.getCurrentLocation()
        dataSource.editItem(item: item, photo: photoData, name: name, itemDescription: itemDescChecked, tags: tags, location: itemsLocation)
    }
    
    func checkLocation() {
        if item.location != nil {
            mapView.viewModel.isIncludingLocation = true
        }
    }
}
