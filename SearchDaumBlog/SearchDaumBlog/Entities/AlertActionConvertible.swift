//
//  AlertActionConvertible.swift
//  SearchDaumBlog
//
//  Created by 김우섭 on 11/26/23.
//

import UIKit

protocol AlertActionConvertible {
    var title: String { get }
    var style: UIAlertAction.Style { get }
}
