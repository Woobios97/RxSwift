//
//  SearchBlogNetwork.swift
//  SearchDaumBlog
//
//  Created by 김우섭 on 11/26/23.
//

import RxSwift
import UIKit

enum SearchNetworkError: Error {
    case invaildURL
    case invaildJSON
    case networkError
}

class SearchBlogNetwork {
    private let session: URLSession
    let api = SearchBlogAPI()
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func searchBlog(query: String) -> Single<Result<DKBlog, SearchNetworkError>> {
        guard let url = api.searchBlog(query: query).url else {
            return .just(.failure(.invaildURL))
        }
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("KakaoAK dd699145fc6fff3850a1892701741830", forHTTPHeaderField: "Authorization")
        
        return session.rx.data(request: request as URLRequest)
            .map { data in
                do {
                    let blogData = try JSONDecoder().decode(DKBlog.self, from: data)
                    return .success(blogData)
                } catch {
                    return .failure(.invaildJSON)
                }
            }
            .catch { _ in
                    .just(.failure(.networkError))
            }
            .asSingle()
    }
}
