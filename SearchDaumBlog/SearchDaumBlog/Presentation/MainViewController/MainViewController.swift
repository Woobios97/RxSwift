//
//  MainViewController.swift
//  SearchDaumBlog
//
//  Created by 김우섭 on 11/25/23.
//

import UIKit
import RxSwift
import RxCocoa

class MainViewController: UIViewController {
    
    let disposeBag = DisposeBag() // 메모리 관리를 위한 DisposeBag
    
    // UI 컴포넌트 정의
    let searchBar = SearchBar() // 검색 바
    let listView = BlogListView() // 블로그 목록을 표시하는 테이블 뷰
    
    // 사용자가 얼럿 액션을 선택했을 때의 이벤트를 처리하기 위한 Relay
    let alertActionTapped = PublishRelay<AlertAction>()
    
    // 초기화
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        // 데이터 바인딩, 속성 설정, 레이아웃 설정
        bind()
        attribute()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 데이터 바인딩을 위한 메서드
    private func bind() {
        // 블로그 검색 결과
        let blogResult = searchBar.shouldLoadResult
            .flatMapLatest { query in
                SearchBlogNetwork().searchBlog(query: query)
            }
            .share()
        
        // 성공한 검색 결과 처리
        let blogValue = blogResult
            .compactMap { data -> DKBlog? in
                guard case .success(let value) = data else {
                    return nil
                }
                return value
            }
        
        // 실패한 검색 결과 (오류) 처리
        let blogError = blogResult
            .compactMap { data -> String? in
                guard case .failure(let error) = data else {
                    return nil
                }
                return error.localizedDescription
            }
        
        // 네트워크를 통해 가져온 블로그 데이터를 리스트 뷰에 표시하기 위한 형태로 변환
        let cellData = blogValue
            .map { blog -> [BlogListCellData] in
                return blog.documents
                    .map { doc in
                        let thumnailURL = URL(string: doc.thumbnail ?? "")
                        return BlogListCellData(
                            thumbnailURL: thumnailURL,
                            name: doc.name,
                            title: doc.title,
                            datetime: doc.datetime
                        )
                    }
            }
        
        // 정렬 옵션 선택 처리
        let sortedType = alertActionTapped
            .filter {
                switch $0 {
                case .title, .datetime:
                    return true
                default:
                    return false
                }
            }
            .startWith(.title)
        
        // 정렬된 데이터를 리스트 뷰에 바인딩
        Observable
            .combineLatest(
                sortedType,
                cellData
            ) { type, data -> [BlogListCellData] in
                switch type {
                case .title:
                    return data.sorted { $0.title ?? "" < $1.title ?? "" }
                case .datetime:
                    return data.sorted { $0.datetime ?? Date() > $1.datetime ?? Date() }
                default:
                    return data
                }
            }
            .bind(to: listView.cellData)
            .disposed(by: disposeBag)
        
        // 정렬 옵션 선택을 위한 얼럿 시트 생성
        let alertSheetForSorting = listView.headerView.sortButtonTapped
            .map { _ -> Alert in
                return (title: nil, message: nil, actions: [.title, .datetime, .cancle], style: .actionSheet)
            }
        
        // 오류 메시지 표시를 위한 얼럿 생성
        let alertForErrorMessage = blogError
            .map { message -> Alert in
                return (
                    title: "OMG",
                    message: "오류가 발생했어요 ‼️. 잠시후 다시 시도해주세요 \(message)",
                    actions: [.confirm],
                    style: .alert
                )
            }
        
        // 얼럿 표시 및 사용자 선택 처리
        Observable
            .merge(
                alertSheetForSorting,
                alertForErrorMessage
            )
            .asSignal(onErrorSignalWith: .empty())
            .flatMapLatest { alert -> Signal<AlertAction> in
                let alertController = UIAlertController(title: alert.title, message: alert.message, preferredStyle: alert.style)
                return self.presentAlertController(alertController, actions: alert.actions)
            }
            .emit(to: alertActionTapped)
            .disposed(by: disposeBag)
    }
    
    // UI 속성 설정
    private func attribute() {
        title = "다음 블로그 검색" // 타이틀 설정
        view.backgroundColor = .systemBackground
    }
    
    // UI 레이아웃 설정
    private func layout() {
        [searchBar, listView].forEach { view.addSubview($0) }
        
        // 검색 바와 리스트 뷰의 오토레이아웃 설정
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
        }
        
        listView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}

// 여기에는 알림창 관련 타입 및 메서드 확장이 포함
extension MainViewController {
    // 알림창에 대한 타입 정의
    typealias Alert = (title: String?, message: String?, actions: [AlertAction], style: UIAlertController.Style)
    
    // 알림창의 액션을 나타내는 열거형
    enum AlertAction: AlertActionConvertible {
        case title, datetime, cancle
        case confirm
        
        // 액션의 타이틀과 스타일 정의
        var title: String {
            switch self {
            case .title:
                return "Title"
            case .datetime:
                return "Datetime"
            case .cancle:
                return "취소"
            case .confirm:
                return "확인"
            }
        }
        
        var style: UIAlertAction.Style {
            switch self {
            case .title, .datetime:
                return .default
            case .cancle, .confirm:
                return .cancel
            }
        }
    }
    
    // 알림창을 표시하고 사용자의 선택을 처리하는 메서드
    func presentAlertController<Action: AlertActionConvertible>(_ alertController: UIAlertController,
                                                                actions: [Action]) -> Signal<Action> {
        if actions.isEmpty { return .empty() }
        return Observable
            .create { [weak self] observer in
                guard let self = self else { return Disposables.create() }
                for action in actions {
                    alertController.addAction(
                        UIAlertAction(
                            title: action.title,
                            style: action.style,
                            handler: { _ in
                                observer.onNext(action)
                                observer.onCompleted()
                            })
                    )
                }
                self.present(alertController, animated: true)
                
                return Disposables.create {
                    alertController.dismiss(animated: true)
                }
            }
            .asSignal(onErrorSignalWith: .empty())
    }
}
