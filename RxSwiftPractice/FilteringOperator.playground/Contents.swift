import UIKit
import RxSwift

let disposeBag = DisposeBag()

print("-----------igonreElements-----")
let 취침모드😴 = PublishSubject<String>()

취침모드😴
    .ignoreElements()
    .subscribe {
        print($0)
    }
    .disposed(by: disposeBag)

취침모드😴.onNext("📢")
취침모드😴.onNext("📢")
취침모드😴.onNext("📢")

/*
 .ignoreElements()는 Next이벤트를 무시한다. Completed 또는 Error 같은 정지이벤트는 허용한다.
*/

취침모드😴.onCompleted()

print("-----------elementAt-----")
let 두번울면깨는사람 = PublishSubject<String>()

두번울면깨는사람
    .element(at: 2)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

두번울면깨는사람.onNext("📢") // index 0
두번울면깨는사람.onNext("📢") // index 1
두번울면깨는사람.onNext("🤨") // index 2
두번울면깨는사람.onNext("📢") // index 3

/*
 element(at: )는 n번째 인덱스만 이벤트가 발생한다. element(at: )이 없다면, element을 구독한 시점 이후에 발생한 onNext이벤트를 방출해준다. 하지만, elment(at: ) 이라는 것은 해당 인덱스만 방출하겠다는 FilteringOperator이다.
*/

print("-----------filter-----")
Observable.of(1, 2, 3, 4, 5, 6, 7, 8) // [1, 2, 3, 4, 5, 6, 7, 8]
    .filter { $0 < 7 }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

/*
 ignoreElements()와 element(at: )는 Observable의 요소들을 필터링해서 방출했다면, filter는 필터링요구사항이 한가지 이상일 때, 클로저 구문 내에서 요청사항을 적은 후 사용할 수 있다. filter 클로저값이 true가 되는 것을 방출하게 된다.
 필터 내의 구문을 true로 통과하는 모든 아이들을 통과시키고 싶을 때는 filter을 사용한다.
*/

print("-----------skip-----")
/*
 skip연산자는 확실히 몇 개의 요소만을 skip할 수 있다. 첫번쨰요소부터 n번째요소까지 skip할 수 있게 해준다.
*/
Observable.of("😉", "☺️", "🤓", "🤬", "🥹", "🐶")
    .skip(5)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
/*
 skip(5)라고 하면 첫번째 요소부터 기준으로 해서, 처음부터 몇개의 요소를 skip할 것인지를 counter값에 적으면 그만큼을 무시하고 내뱉어주는 것이 skip연산자이다.
*/

print("-----------skipWhile-----")
Observable.of("😉", "☺️", "🤓", "🤬", "🥹", "🐶", "😑", "😡")
    .skip(while: {
        $0 != "🐶"
    })
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

/*
 .skip(while: )은 강아지를 기준으로 다음값이 출력된 것을 확인할 수 있는데, 구독하는 동안 모든 요소를 필터링하는 .filter연산자와 달리 skipWhile은 어떤 요소를 skip하지않을 때까지 skip하고 종료하는 연산자이다. 즉, skipWhile은 skip할 로직을 구성하고 해당로직이 false가 되었을 때부터 방출하게 된다. 즉, filter와 반대이다.
*/

print("-----------skipUntil-----")
let 손님 = PublishSubject<String>( )
let 문여는시간 = PublishSubject<String>( )

손님  // 현재 Observable
    .skip(until: 문여는시간) // 다른 Observable
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

손님.onNext("😌")
손님.onNext("😌")
문여는시간.onNext("땡!")
손님.onNext("🤬")

/*
 skipUntil을 보기 전까지는 고정조건이었다. 하지만 다른 요소들의 기반 Observable들을 Dynaminc하게 filter하고 싶다면, skipUntil같은 것을 사용할 수 있다. skipUntil은 현재 Observable은 다른 Observable의 onNext이벤트가 발생하기 전에 모든 이벤트를 무시하게되는 것이다. 따라서 위에 예시에서도 문여는시간이 땡을 하지않았기떄문에, 그 전의 손님이벤트가 발생했어도, 무시된다.
*/

print("-----------take-----")
Observable.of("🏅", "🥈", "🥉", "☺️", "😌")
    .take(3)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

/*
 take는 skip에 반대개념이다. RxSwift에서 어떤 요소를 취하고 싶을 떄, 사용하는 연산자는 take이다. 만약에 skip(3)이었다면, 
 메달들을 무시하고 선수들을 출력할 것이다. 내가 표현한 만큼만 출력하고, 그 다음부터는 무시하게 된다.
*/

print("-----------takeWhile-----")
Observable.of("🏅", "🥈", "🥉", "☺️", "😌")
    .take(while: {
        $0 != "🥉"
    })
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

/*
 takeWhile은 그 클로저, 그 조건 내에서 true 해당하는 값을 방출하게 된다 skipWhile과는 반대이다. 그 조건이 false가 되면 더 이상 구독을 안하게 되는 것이다.
*/

print("-----------enumerated-----")
Observable.of("🏅", "🥈", "🥉", "☺️", "😌")
    .enumerated()
    .takeWhile {
        $0.index < 3
    }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
/*
 index가 3이하일 때까지 방출을 해주게 된다. .enumerated()없이는 element만 방출했다면, .enumerated()와 같이는 index를 같이 표현해준다.
 .enumerated()는 방출된 요소의 index를 참고하고 싶을 때가 있을 것이다. 이럴때는 .enumerated()를 확인할 수 있다. 기존 swift에 .enumerated()연산자와 비슷하게 작동한다고 이해하면된다. Observable에서 각 나오는 요소들의 index값을 포함하는 튜플을 생성하게 되는 것이다.
*/

print("-----------takeUntil-----")
let 수강신청 = PublishSubject<String>()
let 신청마감 = PublishSubject<String>()

수강신청
    .take(until: 신청마감)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

수강신청.onNext("🙋🏻‍♂️")
수강신청.onNext("🙋🏻‍♀️")

신청마감.onNext("끝!")
수강신청.onNext("🙋🏻")
/*
 신청마감이 되기 전에 들어온 사람들은, 다행히 모두 들어왔지만, 마감이 끝이라는 onNext가 발생한 다음에 나타난 수강신청이벤트는 나타나지 않는다. skipUntil과 정확히 반대로 작동한다. 트리거가 되는 Observable이 구독되기 전까지의 값만 받는 것이다.
*/

print("-----------distinctUntilChanged-----")
Observable.of("저는", "저는", "앵무새", "앵무새", "앵무새", "입니다", "입니다", "입니다", "저는", "앵무새", "일까요?", "일까요?")
    .distinctUntilChanged()
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
/*
 distinctUntilChanged라는 것은 연달아 같은 값이 이어질 때 중복된 값을 막아주는 역할을 하는 편리한 연산자이다. '저는'을 살펴보면 "저는", "저는"처럼 연달아 반복적으로 이어졌기 때문에, "저는"만 사용된다. "입니다", "저는", "앵무새"의 "저는"는 앞서나온 "저는"과 반복적이긴 하지만, 연달아 반복된 것이 아니기떄문에, 필터링이 안된 것이다.
*/
