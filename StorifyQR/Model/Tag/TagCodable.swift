//
//  TagCodable.swift
//  StorifyQR
//
//  Created by Maks Winters on 19.01.2024.
//

import Foundation

extension Tag: Codable {
    enum CodingKeys: CodingKey {
        case title
        case size
        case isMLSuggested
        case tagColor
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(size, forKey: .size)
        try container.encode(isMLSuggested, forKey: .isMLSuggested)
        try container.encode(color, forKey: .tagColor)
        // Not encoding items since Many to Many relationships cause circular refernces and loops whipe exporting leading to a crash
    }
    
    static func <(lhs: Tag, rhs: Tag) -> Bool {
        !lhs.isMLSuggested && rhs.isMLSuggested
    }
    
    static func == (lhs: Tag, rhs: Tag) -> Bool {
        lhs.title == rhs.title && lhs.isMLSuggested == rhs.isMLSuggested
    }
}
