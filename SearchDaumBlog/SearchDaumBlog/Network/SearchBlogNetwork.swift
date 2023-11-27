//
//  SearchBlogNetwork.swift
//  SearchDaumBlog
//
//  Created by 김우섭 on 11/26/23.
//

import RxSwift
import UIKit

// 네트워크 요청 중 발생할 수 있는 오류 유형을 정의하는 열거형
enum SearchNetworkError: Error {
    case invaildURL // 유효하지 않은 URL
    case invaildJSON // JSON 디코딩 실패
    case networkError // 네트워크 관련 오류
}

// 블로그 검색을 위한 네트워크 요청을 관리하는 클래스
class SearchBlogNetwork {
    private let session: URLSession // HTTP 요청을 처리할 URLSession 인스턴스

    let api = SearchBlogAPI() // API 엔드포인트 구성을 위한 인스턴스
    
    // 초기화 메서드, 기본값으로 공유 URLSession 인스턴스 사용
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // 주어진 쿼리로 블로그 검색을 수행하고 결과를 반환하는 메서드
    func searchBlog(query: String) -> Single<Result<DKBlog, SearchNetworkError>> {
        guard let url = api.searchBlog(query: query).url else {
            return .just(.failure(.invaildURL)) // URL 생성 실패시 오류 반환
        }
        
        // HTTP GET 요청 설정
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("KakaoAK dd699145fc6fff3850a1892701741830", forHTTPHeaderField: "Authorization") // API 키 설정
        
        // 네트워크 요청 및 응답 처리
        return session.rx.data(request: request as URLRequest)
            .map { data in
                do {
                    let blogData = try JSONDecoder().decode(DKBlog.self, from: data)
                    return .success(blogData) // 성공적으로 데이터 디코딩
                } catch {
                    return .failure(.invaildJSON) // JSON 디코딩 실패
                }
            }
            .catch { _ in
                    .just(.failure(.networkError)) // 기타 네트워크 오류 처리
            }
            .asSingle() // Single 타입으로 반환
    }
}
