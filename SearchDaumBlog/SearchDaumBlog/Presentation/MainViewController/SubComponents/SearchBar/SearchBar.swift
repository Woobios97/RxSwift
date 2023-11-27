//
//  SearchBar.swift
//  SearchDaumBlog
//
//  Created by 김우섭 on 11/25/23.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class SearchBar: UISearchBar {
    let disposeBag = DisposeBag() // 메모리 관리를 위한 DisposeBag
    
    let searchButton = UIButton() // 검색 버튼
    
    // SearchBar 버튼 탭 이벤트
    let searchButtonTapped = PublishRelay<Void>() // 검색 버튼 탭 이벤트를 감지하기 위한 Relay
    
    // SearchBar 외부로 내보낼 이벤트
    var shouldLoadResult = Observable<String>.of("") // 검색 결과를 로드해야 할 때 발생하는 이벤트
    
    // 초기화 메서드
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        bind() // 바인딩 설정
        attribute() // 속성 설정
        layout() // 레이아웃 설정
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 이벤트 바인딩
    private func bind() {
        // 검색 버튼 클릭과 검색 필드의 검색 버튼 클릭을 병합
        Observable.merge(
            self.rx.searchButtonClicked.asObservable(),
            searchButton.rx.tap.asObservable()
        )
        .bind(to: searchButtonTapped)
        .disposed(by: disposeBag)
        
        // 검색 버튼 탭 시 키보드 숨김
        searchButtonTapped
            .asSignal()
            .emit(to: self.rx.endEditing)
            .disposed(by: disposeBag)
        
        // 검색 결과 로드 이벤트 정의
        self.shouldLoadResult = searchButtonTapped
            .withLatestFrom(self.rx.text) { $1 ?? "" }
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
    }
    
    // UI 속성 설정
    private func attribute() {
        searchButton.setTitle("검색", for: .normal)
        searchButton.setTitleColor(.systemBlue, for: .normal)
    }
    
    // 레이아웃 설정
    private func layout() {
        addSubview(searchButton)
        
        // 검색 필드와 검색 버튼의 레이아웃 설정
        searchTextField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.trailing.equalTo(searchButton.snp.leading).offset(-12)
            $0.centerY.equalToSuperview()
        }
        
        searchButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(12)
        }
    }
}

// RxSwift를 활용한 SearchBar의 확장
extension Reactive where Base: SearchBar {
    var endEditing: Binder<Void> {
        return Binder(base) { base, _ in
            base.endEditing(true)
        }
    }
}
