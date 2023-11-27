//
//  BlogListCellData.swift
//  SearchDaumBlog
//
//  Created by 김우섭 on 11/25/23.
//

import Foundation

// 블로그 리스트 셀에 표시될 데이터를 나타내는 구조체
struct BlogListCellData {
    let thumbnailURL: URL? // 썸네일 이미지 URL
    let name: String? // 블로그 이름
    let title: String? // 문서 제목
    let datetime: Date? // 작성 날짜 및 시간
}
