import UIKit
import RxSwift

// # Observable을 생성할 떄 사용되는 아이들


/*
 Observable를 만들려면 Observable로 작성하고 선택적으로 꺽새를 이용해서 어떤 타입의 element를 방출한 것인지 표현할 수 있다.
 .just라는 연산자를 통해서 만들 수 가있는데, just는 이름에서도 알 수 있듯이, 하나의 elemnet만 방출하는 단순한 Observable생성 operator이다.
 오직 하나의 요소를 포함하는 Observable시퀀스를 생성하는 것이다.
 그래서 여기에다가 1이라는 하나의 elmenter를 내뿜는 다면, Observable, 1이라는 하나의 element만 뽑는 Observable이 완성.
 */
print("----------just----")
Observable<Int>.just(1)
    .subscribe(onNext: {
        print($0)
    })

/*
 Observable 만들 수 있는 of라는 연산자도 있다. of를 통해서는 다양한 형태의 이벤트들을 넣을 수가 있다. 즉, 하나의 이상의 이벤트를 넣을 수 있다.
 예를 들면, 1, 2, 3, 4, 5
 그래서 어떤 Array를 Observable로 만들고싶다. Array안에 elment들을 넣으면 된다.
 */
print("----------Of1----")
Observable<Int>.of(1, 2, 3, 4, 5)
    .subscribe(onNext: {
        print($0)
    })


/*
 Observable은 타입추론을 통해서 Observable시퀀스 생성을 한다. 따라서 어떤 Array 전체를 of연산자안에 넣으면, 하나의 Array를 방출하는 Observable이 완성된다.
 이러면 사실상 just 쓴거랑 동일하다. 하나의 Array만 방출할 것이기 때문이다. 그래서 각각의 element들을 방출하고 싶다면 전체 Array를 넣치말고, element들을 하나씩 뺴서 쉼표로 구분해서
 Of에 넣으면 된다.
 */
print("----------Of2----")
Observable.of([1, 2, 3, 4, 5])
    .subscribe(onNext: {
        print($0)
    })


/*
 from은 Array만 받는다. from이라느 연산자는 자동적으로 자기가 받은 Array 속에 있는 element들을 방출하게 된다. 따라서 from 연산자는 오직 Array만 취하게 된다. Array 각각의 요소들을 방출하게 된다,
 */
print("----------from----")
Observable.from([1, 2, 3, 4, 5])
    .subscribe(onNext: {
        print($0)
    })

/*
 Observable은 그저 실제로는 시퀀스의 정의일뿐이다. subscriber, 구독되기 전애는 아무런 이벤트도 내보내지않는다. 그거 정의일뿐이다.
 제대로 동작하는 지 확인하려면 반드시 subscribe을 해야한다.
 */

/*
 이벤트를 그대로 보여준다. 지금까지는 onNext이벤트를 받아서 거기에서 받아지는 value값을 표현하도록 되어있었기 떄문에, 어떤 이벤트에 쌓여서 나오지는 않았던 것이고,
 그냥 subscribe를 이용하면 어떤 이벤트에 어떠한 값이 쌓여서 오고, completed이벤트가 발생했는 지 확인할 수 있다.
 */
print("----------subscribe1----")
Observable.of(1, 2, 3)
    .subscribe {
        print($0)
    }

/*
 기존의 onNext를 썼던 것처럼, element값만을 표현하게 된다.
 */
print("----------subscribe1----")
Observable.of(1, 2, 3)
    .subscribe {
        if let element = $0.element {
            print(element)
        }
    }

print("----------subscribe3----")
Observable.of(1, 2, 3)
    .subscribe (onNext: {
        print($0)
    })

/*
 Observable을 만들 수 있는 또다른 연산자
 Empty Observable; 자금까지는 하나 또는 여러개의 요소를 가진 Observable만 만들었는데, 요소를 하나도 가지지않은 count가 0인 observable을 만들 때 empty를 쓴다.
 */
print("----------empty1----")
Observable<Void>.empty()
    .subscribe {
        print($0)
    }

/*
 위와 동일한 함수이다. Void를 표현하지는 않았을 때는 Completed라는 것도 표현되지 않았는데, 여기서는 타입추론할 것이 없다. Observable 타입추론 할 것이 없다. Observable이 empty이기 때문에,
 따라서 타입을 명시적으로 표현해줘야한다.
 empty가 왜 필요할 지?
 1. 즉시 종료할 수 있는 Observable을 return하고 싶을 때,
 2. 의도적으로 0개의 값을 가진 Observable을 return하고 싶을 때,
 */
print("----------empty2----")
Observable<Void>.empty()
    .subscribe(onNext: {
        
    },
    onCompleted: {
        print("Completed")
    })

/*
 작동은 하지만, 아무것도 내뱉지 않는다.
 */
print("----------never----")
Observable<Void>.never()
    .debug("never")
    .subscribe(onNext: {
        print($0)
    },
               onCompleted: {
        print("Completed")
    }
    )

print("----------range----")
Observable.range(start: 1, count: 9)
    .subscribe(onNext: {
        print("2*\($0)=\(2*$0)")
    })
/*
 Observable은 subscribe없이는 방출할 수 없다. 즉, subscribe가 Observable의 방아쇠 역할을 하는 것이다.
 반대로 말해서, 방아쇠를 당겨서 구독을 했다면, 이를 취소를 해야되지않을까?
 구독을 취소함으로써, Observable을 수동적으로 종료시킬 수도 있다. 그것이 바로 dispose의 개념이다.
 */

print("----------dispose----")
Observable.of(1, 2, 3)
    .subscribe(onNext: {
        print($0)
    })
    .dispose()

/*
 여기서는 dispose가 없어도 결과는 동일하다. Observable.of(1, 2, 3) -> 3개의 요소만 있기 때문이다. 만약에, 3개가 아니라 무한한 요소로 반복되는 시퀀스라면 반드시 dispose를 호출해야만 completed가 print된다.
 */
print("----------dispose1----")
Observable.of(1, 2, 3)
    .subscribe(onNext: {
        print($0)
    })

/*
 disposeBag은 구독들을 일일이 관리하는 것은 효율적이지 못한 방법이다. 따라서, RxSwift에서 제공하는 DisposeBag을 이용할 수 있는데, disposeBag에서는 .disposed(by: disposeBag) 이 메소드를 통해서 추가를 통해서 이 메서드는 disposeable를 갖고 있다. disposeBag이 할당해제할 때마다 dispose를 호출하게 된다.
 Observable에 대해서 구독을 하고 있을 때, 이것을 즉시 disposeBag에 추가를 하는 거다. disposeBag은 잘 갖고있다가 자신이 할당해제할 떄, 모든 구독에 대해서 .dispose를 날리는 것이다.
 disposeBag을 subscription에 추가하거나 수동적으로 dispose를 호출하는 것을 빼먹는다면, 당연히 메모리누수가 일어날 것이다. observable이 끝나지 않기 떄문이다.
 */

print("----------disposeBag----")
let disposeBag = DisposeBag()

Observable.of(1, 2, 3)
    .subscribe {
        print($0)
    }
    .disposed(by: disposeBag)


/*
create는 escaping클로저이다. AnyObserver<_>라는 escaping이 있다. AnyObserver를 취한다음에, disposable을 return하는 형식의 클로저이다.
 여기서 말하는 AnyObserver는 제네릭타입이고, Observable 시퀀스에 값을 추가할 수 있다. 이렇게 추가한 것은 subscribe을 했을 떄, 방출되게 된다.
 172줄과 173줄, 174줄과 175줄을 동일한 표현이다. 172줄은 방출되었으나, 176줄은 방출되지않았다. 이유는? onCompleted를 통해서 Observable이 종료되었기 때문이다.
 종료된 다음에 next이벤트를 날려도 그 next이벤트는 방출되지않는다.
 */

//print("----------create----")
//Observable.create{ observer -> Disposable in
//    observer.onNext(1)
////    observer.on(.next(1))
//    observer.onCompleted()
////    observer.on(.completed)
//    observer.onNext(2)
//    return Disposables.create()
//}
//.subscribe {
//    print($0)
//}
//.disposed(by: disposeBag)

/*
Error는 해당 에러를 방출시키고 종료시키기 때문에, 해당 observable을 종료시키기 때문에, 에더단에서 observable이 종료되었고, 그 아래에 completed, onNext는 종료된 상태에서 방출된 event이기 떄문에, 더이상 방출되지않는다라는 것을 알 수 있다.
 */
//print("----------create2----")
//enum MyError: Error {
//    case asError
//}
//
//Observable.create { observer -> Disposable in
//    observer.onNext(1)
//    observer.onError(MyError.asError)
//    observer.onCompleted()
//    observer.onNext(2)
//    return Disposables.create()
//}
//.subscribe(
//    onNext: {
//        print($0)
//    },
//    onError: {
//        print($0.localizedDescription)
//    },
//    onCompleted: {
//        print("completed")
//    },
//    onDisposed: {
//        print("disposed")
//    }
//)
//.disposed(by: disposeBag)

/*
두 개의 onNext요소인 1과 2가 모두 찍힐 것이다. 종료를 위한 어떠한 이벤트도 방출되지않고, dispose도 하지않기 때문에, 결과적으로는 메모리낭비가 발생하게 될 것이다. 따라서 반드시 dispose코드를 넣어줘야한다.
 */
//print("----------create2----")
//enum MyError: Error {
//    case asError
//}
//
//Observable.create { observer -> Disposable in
//    observer.onNext(1)
////    observer.onError(MyError.asError)
////    observer.onCompleted()
//    observer.onNext(2)
//    return Disposables.create()
//}
//.subscribe(
//    onNext: {
//        print($0)
//    },
//    onError: {
//        print($0.localizedDescription)
//    },
//    onCompleted: {
//        print("completed")
//    },
//    onDisposed: {
//        print("disposed")
//    }
//)
////.disposed(by: disposeBag)


/*
 subscribe를 기다리는 Observable를 만드는 대신에, 각 subscribe에게 새롭게 Observable항목을 제공하는 ObservableFactory를 만드는 방식이다.
 Observable.deffered가 있다고 했을 때, Observable을 감싸는 Observable이다. 이 내부에는 또다른 observable를 선언해서 만들 수 있다.
 Observable.deferred { .. } 내부에 observable들을 하니씩 내뱉는 것을 볼 수 있다. 마치 Observable.deferred { .. }가 없고, Observable.of(1, 2, 3)가 바로 작동한 것처럼 보인다.
 */
print("----------differed1----")
Observable.deferred {
    Observable.of(1, 2, 3)
}
.subscribe {
    print($0)
}
.disposed(by: disposeBag)


/*
 뒤집기에 따라서 fatory 내에 Observable 묶음 중에서, 여러가지가 조건문에 따라서 나올 수가 있다, Observable.deferred는 Observable factory를 통해서 Observable시퀀스를 생성할 수 있는 그러한 형태의 연산자로 보면 된다.
 */
print("----------differed2----")
var 뒤집기: Bool = false

let fatory: Observable<String> = Observable.deferred {
    뒤집기 = !뒤집기
    
    if 뒤집기 {
        return Observable.of("👆🏻")
    } else {
        return Observable.of("👇🏻")
    }
}

for _ in 0...3 {
    fatory.subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
}
