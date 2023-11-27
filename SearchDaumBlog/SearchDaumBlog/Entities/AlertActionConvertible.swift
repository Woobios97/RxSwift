//
//  AlertActionConvertible.swift
//  SearchDaumBlog
//
//  Created by 김우섭 on 11/26/23.
//

import UIKit

// 경고창에서 사용할 액션을 정의하는 프로토콜
protocol AlertActionConvertible {
    var title: String { get } // 액션의 제목
    var style: UIAlertAction.Style { get } // 액션의 스타일
}
