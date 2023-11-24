//
//  RepositoryListViewController.swift
//  Github_RxSwift
//
//  Created by 김우섭 on 11/24/23.
//

import UIKit
import RxSwift
import RxCocoa


class RepositoryListViewController: UITableViewController {
    
    private let organization = "Apple"
    /// BehaviorSubject 타입의 repositories. 초기값으로 빈 배열을 가짐.
    private let repositories = BehaviorSubject<[Repository]>(value: [])
    /// DisposeBag 인스턴스를 사용하여 구독(subscriptions) 관리.
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 뷰 컨트롤러의 타이틀을 설정. 'Apple Repositories'라는 문자열로 설정됨.
        title = organization + " Repositories"
        
        // 테이블 뷰의 새로고침 컨트롤을 초기화하고 구성.
        self.refreshControl = UIRefreshControl()
        let refreshControl = self.refreshControl!
        refreshControl.backgroundColor = .white
        refreshControl.tintColor = .darkGray
        refreshControl.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
        // 새로고침 이벤트 발생시 호출될 메소드를 지정.
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        
        tableView.register(RepositoryListCell.self, forCellReuseIdentifier: "RepositoryListCell")
        tableView.rowHeight = 140
    }
    
    /// 새로고침 컨트롤에 의해 호출되는 메소드. 비동기적으로 리포지토리 목록을 가져옴.
    @objc func refresh() {
        // 백그라운드 스레드에서 실행.
        DispatchQueue.global(qos: .background).async { [weak self] in
            // self가 nil이 아닌 경우에만 코드 블록 실행.
            guard let self = self else { return }
            // 조직의 리포지토리 목록을 가져오는 메소드 호출.
            self.fetchRepositories(of: self.organization)
        }
    }
    
    /// - Parameter organization: 주어진 조직의 GitHub 리포지토리를 가져옵니다
    func fetchRepositories(of organization: String) {
        // Observable을 생성하여 주어진 organization을 시작점으로 사용합니다.
        Observable.from([organization])
            // organization을 이용하여 GitHub API의 URL을 생성합니다.
            .map { organization -> URL in
                return URL(string: "https://api.github.com/orgs/\(organization)/repos")!
            }
            // 생성된 URL을 기반으로 HTTP GET 요청을 구성합니다.
            .map { url -> URLRequest in
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                return request
            }
            // URLRequest를 사용하여 웹 요청을 수행하고, 응답과 데이터를 Observable로 반환합니다.
            .flatMap { request -> Observable<(response: HTTPURLResponse, data: Data)> in
                return URLSession.shared.rx.response(request: request)
            }
            // HTTP 응답 상태 코드가 성공(200-299) 범위에 있는지 확인합니다.
            .filter { response, _ in
                return 200..<300 ~= response.statusCode
            }
            // 받은 데이터를 JSON 객체로 변환합니다.
            .map { _, data -> [[String: Any]] in
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
                      let result = json as? [[String: Any]] else {
                    return []
                }
                return result
            }
            // 결과가 비어있지 않은지 확인합니다.
            .filter { result in
               return result.count > 0
            }
            // JSON 객체를 Repository 객체로 변환합니다.
            .map { objects in
                return objects.compactMap { dic -> Repository? in
                    guard let id = dic["id"] as? Int,
                          let name = dic["name"] as? String,
                          let description = dic["description"] as? String,
                          let stargazersCount = dic["stargazers_count"] as? Int,
                          let language = dic["language"] as? String else {
                        return nil
                    }
                    
                    return Repository(id: id, name: name, description: description, stargazersCount: stargazersCount, language: language)
                }
            }
            // 새로운 리포지토리 목록으로 BehaviorSubject를 업데이트합니다.
            .subscribe(onNext: { [weak self] newRepositories in
                self?.repositories.onNext(newRepositories)
                // 메인 스레드에서 테이블 뷰를 리로드하고, 새로고침 컨트롤을 종료합니다.
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.refreshControl?.endRefreshing()
                }
            })
            // disposeBag을 사용하여 구독을 관리합니다.
            .disposed(by: disposeBag)
    }


}

// MARK: - UITableViewDataSource
extension RepositoryListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        do {
            // BehaviorSubject 'repositories'에서 현재 값을 가져와 그 개수를 반환.
            // BehaviorSubject에 저장된 배열의 크기가 테이블 뷰의 행 개수가 됨.
            return try repositories.value().count
        } catch {
            // 에러 발생 시 행의 개수를 0으로 반환.
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryListCell", for: indexPath) as? RepositoryListCell else {
            return UITableViewCell()
        }

        // 현재 인덱스 패스에 해당하는 Repository 객체를 가져옴.
        var currentRepo: Repository? {
            do {
                return try repositories.value()[indexPath.row]
            } catch {
                // 에러 발생 시 nil 반환.
                return nil
            }
        }

        // 셀에 Repository 객체를 할당.
        cell.repository = currentRepo
        // 구성된 셀 반환.
        return cell
    }
}
