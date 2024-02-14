//
//  ContentViewModel.swift
//  StorifyQR
//
//  Created by Maks Winters on 15.01.2024.
//

import Foundation
import SwiftUI

struct Tags: Codable {
    var tags: [Tag]
}

@Observable
final class ContentViewModel {
    static let imageConverter = ImageCoverter()
    let dataSource: StoredItemDataSource
    let tagDataSource = TagDataSource.shared
    
    var storedItems = [StoredItem]()
    
    var path: NavigationPath
    
    var importingData = false
    
    var importingAlert = false
    var errorAlert = false
    var errorMessage = ""
    
    var importItem: StoredItem?
    var importItemTags: [Tag]?
    
    func saveItem() {
        dataSource.appendItem(item: importItem!)
        dataSource.appendTagToItem(item: importItem!, tags: importItemTags!)
        fetchItems()
    }
    
    func saveImport(_ success: URL) {
        do {
            
            let decoded: StoredItem = try Bundle.main.decode(success)
            let rawTags: Tags = try Bundle.main.decode(success)
            
            let taglessObject = StoredItem(photo: decoded.photo, name: decoded.name, itemDescription: decoded.itemDescription, location: decoded.location)
            
            importItem = taglessObject
            importItemTags = rawTags.tags
            
            importingAlert = true
        } catch {
            errorMessage = error.localizedDescription
            errorAlert = true
        }
    }
    
    func getImage(item: StoredItem) -> Image? {
        return item.photo.flatMap { Image(data: $0) }
    }
    
    func fetchItems() {
        storedItems = dataSource.fetchItems()
    }
    
    func processImport(result: Result<URL, any Error>) {
        switch result {
        case .success(let success):
            saveImport(success)
        case .failure(let failure):
            print(failure.localizedDescription)
        }
    }
    
    init(dataSource: StoredItemDataSource = StoredItemDataSource.shared, path: NavigationPath = NavigationPath()) {
        self.dataSource = dataSource
        self.path = path
    }
}
