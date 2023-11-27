//
//  DKBlog.swift
//  SearchDaumBlog
//
//  Created by 김우섭 on 11/26/23.
//

import Foundation

// 블로그 검색 결과를 나타내는 구조체
struct DKBlog: Codable {
    let documents: [DKDocument] // 검색된 블로그 문서들의 배열
}

// 개별 블로그 문서를 나타내는 구조체
struct DKDocument: Codable {
    let title: String? // 문서 제목
    let name: String? // 블로그 이름
    let thumbnail: String? // 썸네일 이미지 URL
    let datetime: Date? // 작성 날짜 및 시간
    
    // JSON 키 매핑
    enum CodingKeys: String, CodingKey {
        case title, thumbnail, datetime
        case name = "blogname" // JSON의 "blogname" 키를 "name" 프로퍼티로 매핑
    }
    
    // 커스텀 디코딩 초기화 메서드
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // HTML 태그와 HTML 엔터티를 제거하는 과정
        self.title = try? values.decode(String?.self, forKey: .title)?
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            .replacingOccurrences(of: "&[^;]+;", with: "", options: .regularExpression, range: nil)
        self.name = try? values.decode(String?.self, forKey: .name)
        self.thumbnail = try? values.decode(String?.self, forKey: .thumbnail)
        self.datetime = Date.parse(values, key: .datetime) // 날짜 파싱
    }
}

// Date 타입을 위한 확장
extension Date {
    // JSON 디코딩 중 날짜 문자열 파싱을 위한 메서드
    static func parse<K: CodingKey>(_ values: KeyedDecodingContainer<K>, key: K) -> Date? {
        guard let dateString = try? values.decode(String.self, forKey: key),
              let date = from(dateString: dateString) else {
            return nil
        }
        
        return date
    }
    
    // 날짜 문자열을 Date 객체로 변환
    static func from(dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        dateFormatter.locale = Locale(identifier: "ko_kr")
        return dateFormatter.date(from: dateString)
    }
}
