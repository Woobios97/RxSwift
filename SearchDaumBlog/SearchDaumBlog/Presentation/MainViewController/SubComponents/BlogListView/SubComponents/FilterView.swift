//
//  FilterView.swift
//  SearchDaumBlog
//
//  Created by 김우섭 on 11/25/23.
//

import UIKit
import RxSwift
import RxCocoa

class FilterView: UITableViewHeaderFooterView {
    let disposBag = DisposeBag() // 메모리 관리를 위한 DisposeBag
    
    let sortButton = UIButton() // 정렬 버튼
    let bottomBoder = UIView() // 하단 경계선 뷰
    
    // 외부에서 관찰 가능한 정렬 버튼 탭 이벤트
    let sortButtonTapped = PublishRelay<Void>()
    
    // 초기화 메서드
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        bind() // 이벤트 바인딩
        attribute() // 속성 설정
        layout() // 레이아웃 설정
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 이벤트 바인딩 설정
    private func bind() {
        sortButton.rx.tap
            .bind(to: sortButtonTapped)
            .disposed(by: disposBag)
    }
    
    // 속성 설정
    private func attribute() {
        sortButton.setImage(UIImage(systemName: "list.bullet"), for: .normal) // 정렬 버튼 이미지 설정
        bottomBoder.backgroundColor = .lightGray // 하단 경계선 색상 설정
    }
    
    // 레이아웃 설정
    private func layout() {
        [sortButton, bottomBoder]
            .forEach {
                addSubview($0)
            }
        
        // 정렬 버튼 및 하단 경계선의 레이아웃 설정
        sortButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().inset(12)
            $0.width.height.equalTo(28)
        }
        
        bottomBoder.snp.makeConstraints {
            $0.top.equalTo(sortButton.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(0.5)
        }
    }
}
