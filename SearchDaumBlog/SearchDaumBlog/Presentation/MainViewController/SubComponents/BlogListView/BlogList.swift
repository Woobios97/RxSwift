//
//  BlogList.swift
//  SearchDaumBlog
//
//  Created by 김우섭 on 11/25/23.
//

import UIKit
import RxSwift
import RxCocoa

class BlogListView: UITableView {
    let disposBag = DisposeBag() // 메모리 관리를 위한 DisposeBag
    
    // 헤더 뷰로 사용되는 필터 뷰
    let headerView = FilterView(
        frame: CGRect(
            origin: .zero,
            size: CGSize(width: UIScreen.main.bounds.width, height: 50)
        )
    )
    
    // 초기화 메서드
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        bind() // 데이터 바인딩
        attribute() // 속성 설정
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // BlogListView로 전달될 데이터
    let cellData = PublishSubject<[BlogListCellData]>() // 블로그 리스트 데이터
    
    // 데이터 바인딩 설정
    private func bind() {
        cellData
            .asDriver(onErrorJustReturn: [])
            .drive(self.rx.items) { tv, row, data in
                let index = IndexPath(row: row, section: 0)
                let cell = tv.dequeueReusableCell(withIdentifier: "BlogListCell", for: index) as!
                BlogListCell
                cell.setData(data)
                return cell
            }
            .disposed(by: disposBag)
    }
    
    // 뷰 속성 설정
    private func attribute() {
        self.backgroundColor = .systemBackground
        self.register(BlogListCell.self, forCellReuseIdentifier: "BlogListCell")
        self.separatorStyle = .singleLine
        self.rowHeight = 100
        self.tableHeaderView = headerView // 헤더 뷰 설정
    }
}
