//
//  Livro.swift
//  TempoComDeusApp
//
//  Created by Lidiane Gomes Barbosa on 03/09/20.
//  Copyright © 2020 Lidiane Gomes Barbosa. All rights reserved.
//

import Foundation
class Livro: Codable {
    let abbrev: String
    let chapters: [[String]]
    let name: String
    
    init(abbrev: String, chapters: [[String]], name: String) {
        self.abbrev = abbrev
        self.chapters = chapters
        self.name = name
    }
    enum CodingKeys: String, CodingKey {
        case abbrev, chapters, name
    }
    
}
