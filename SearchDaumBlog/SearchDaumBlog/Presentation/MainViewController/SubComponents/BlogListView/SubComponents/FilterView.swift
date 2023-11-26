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
    let disposBag = DisposeBag()
    
    let sortButton = UIButton()
    let bottomBoder = UIView()
    
    // FilterView 외부에서 관찰
    let sortButtonTapped = PublishRelay<Void>()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        bind()
        attribute()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        sortButton.rx.tap
            .bind(to: sortButtonTapped)
            .disposed(by: disposBag)
    }
    
    private func attribute() {
        sortButton.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        bottomBoder.backgroundColor = .lightGray
    }
    
    private func layout() {
        [sortButton, bottomBoder]
            .forEach {
                addSubview($0)
            }
        
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
