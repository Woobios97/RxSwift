import RxSwift
import UIKit

let disposeBag = DisposeBag()

enum TraitsError: Error {
    case single
    case maybe
    case completable
}

/*
 Single의 onSuccess는 Obervable의 onNext와 onError를 합친 것과 같다. 즉, onNext 하나의 이벤트를 발생시킨다음에 바로 종료된다.
 onFailure도 onError와 비슷하다. 하나의 Error를 방출하고, 종료된다. Observable과 비슷한데 제한된 방식으로 제공되는 것이 싱글이다.
 */

print("--------------Single1-------")
Single<String>.just("✅")
    .subscribe(
        onSuccess: {
            print($0)
        },
        onFailure: {
            print("Error: \($0)")
        },
        onDisposed: {
            print("disposed")
        }
    )
    .disposed(by: disposeBag)

print("--------------Single2-------")
Observable<String>
    .create { observer -> Disposable in
        observer.onError(TraitsError.single)
        return Disposables.create()
    }
    .asSingle()
    .subscribe(
        onSuccess: {
            print($0)
        },
        onFailure: {
            print("Error: \($0.localizedDescription)")
        },
        onDisposed: {
            print("disposed")
        }
    )
    .disposed(by: disposeBag)

/*
 single은 네트워크환경에서도 많이 쓰인다. 실패 또는 성공 밖에 없는 두가지 경우에 대해서는 불필요하게 계속해서 발생할 여지가 있는 onNext가 없는 단순히 하나의 이벤트를 발생시키고, observable이 종료되는 Single을 이용할 수 있다.
 */
print("--------------Single3-------")
struct SomeJSON: Decodable {
    let name: String
}

enum JSONError: Error {
    case decodingError
}

let json1 = """
{"name": "park"}
"""

let json2 = """
{"my_name": "young"}
"""

func decode(json: String) -> Single<SomeJSON> {
    Single<SomeJSON>.create { observer -> Disposable in
        guard let data = json.data(using: .utf8),
              let json = try? JSONDecoder().decode(SomeJSON.self, from: data)
        else {
            observer(.failure(JSONError.decodingError))
            return Disposables.create()
        }
        observer(.success(json))
        return Disposables.create()
    }
}

decode(json: json1)
    .subscribe {
        switch $0 {
        case .success(let json):
            print(json.name)
        case .failure(let error):
            print(error)
        }
    }
    .disposed(by: disposeBag)

decode(json: json2)
    .subscribe {
        switch $0 {
        case .success(let json):
            print(json.name)
        case .failure(let error):
            print(error)
        }
    }
    .disposed(by: disposeBag)

/*
 Maybe는 Obervable에 대해서는 onNext를 onSuccess로 표현하는 것만 다르다.
 */

print("--------------Maybe1-------")
Maybe<String>.just("✅")
    .subscribe(
        onSuccess: {
            print($0)
        },
        onError: {
            print($0)
        },
        onCompleted: {
            print("completed")
        },
        onDisposed: {
            print("disposed")
        }
    )
    .disposed(by: disposeBag)

//Observable.just("3")
//    .subscribe(onNext: <#T##((Element) -> Void)?#>, onError: <#T##((Error) -> Void)?#>, onCompleted: <#T##(() -> Void)?#>, onDisposed: <#T##(() -> Void)?#>)

print("--------------Maybe2-------")
Observable<String>.create { observer -> Disposable in
    observer.onError(TraitsError.maybe)
    return Disposables.create()
}
.asMaybe()
.subscribe(
    onSuccess: {
        print("성공: \($0)")
    },
    onError: {
        print("에러: \($0)")
    },
    onCompleted: {
        print("completed")
    },
    onDisposed: {
        print("disposed")
    }
)
.disposed(by: disposeBag)


/*
 completable은 asSingle, asMaybe와 같은 observable을 바로 completable로 전환해주는 게 없다.
 */

print("--------------Completable1-------")
Completable.create { observer -> Disposable in
    observer(.error(TraitsError.completable))
    return Disposables.create()
}
.subscribe(
    onCompleted: {
        print("completed")
    },
    onError: {
        print("error: \($0)")
    },
    onDisposed: {
        print("disposed")
    }
)
.disposed(by: disposeBag)

print("--------------Completable2-------")
Completable.create { observer -> Disposable in
    observer(.completed)
    return Disposables.create()
}
.subscribe {
    print($0)
}
.disposed(by: disposeBag)

/*
 네트워크 환경에서 Single과 completable, maybe을 자주 사용하게 된다. 그냥 observable로 사용해도 되지만, 직관적이고 제한적인 역할을 하는 trait들을 사용하면 코드의 가독성이 좋어진다.
 */
