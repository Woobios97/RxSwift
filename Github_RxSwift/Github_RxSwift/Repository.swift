//
//  Repository.swift
//  Github_RxSwift
//
//  Created by 김우섭 on 11/24/23.
//

import Foundation

struct Repository: Codable {
    let id: Int
    let name: String
    let description: String
    let stargazersCount: Int
    let language: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, language
        case stargazersCount = "stargazers_count"
    }
}

