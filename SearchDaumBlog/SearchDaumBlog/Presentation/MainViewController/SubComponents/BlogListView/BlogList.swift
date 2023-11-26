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
    let disposBag = DisposeBag()
    
    let headerView = FilterView(
        frame: CGRect(
            origin: .zero,
            size: CGSize(width: UIScreen.main.bounds.width, height: 50)
        )
    )
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        bind()
        attribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MainViewController -> BlogListView
    let cellData = PublishSubject<[BlogListCellData]>()
    
    /*
     UITableView의 cellForRowAt의 Rx
     */
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
    
    private func attribute() {
        self.backgroundColor = .systemBackground
        self.register(BlogListCell.self, forCellReuseIdentifier: "BlogListCell")
        self.separatorStyle = .singleLine
        self.rowHeight = 100
        self.tableHeaderView = headerView
    }
}
