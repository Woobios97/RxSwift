//
//  SearchBlogAPI.swift
//  SearchDaumBlog
//
//  Created by 김우섭 on 11/26/23.
//

import Foundation

struct SearchBlogAPI {
    static let scheme = "https" // URL 스키마
    static let host = "dapi.kakao.com" // API 호스트
    static let path = "/v2/search/" // API 경로
    
    // 블로그 검색 URL 구성
    func searchBlog(query: String) -> URLComponents {
        var components = URLComponents()
        components.scheme = SearchBlogAPI.scheme // 스키마 설정
        components.host = SearchBlogAPI.host // 호스트 설정
        components.path = SearchBlogAPI.path + "blog" // 경로 설정
        
        // 쿼리 아이템 설정
        components.queryItems = [
            URLQueryItem(name: "query", value: query)
        ]
        
        return components
    }
}
