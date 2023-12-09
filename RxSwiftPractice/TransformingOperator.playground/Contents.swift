import UIKit
import RxSwift

/*
TransformingOperator = 변환연산자
변환연산자는 subscriber를 통해서 Observable에서 데이터를 준비하는 것과 같은 모르는 상황에서 쓰일 수 있다.
FilteringOperato에 filter처럼 map, flatMap과 같이 기본 swift 표준라이브러리와 Rxswift의 유사점이 있는 연산자들을
확인할 수 있다.
Observable이 독립적으로 요소들을 방출하는 데, Observable을 테이블뷰 혹은 컬렉션뷰처럼 바인딩하는 것처럼,
어쩔 때는 독립적인 값들을 조합해서 쓰고 싶을 때가 있다. 그래서 조합할 떄 쓰는 변환연산자이다.
*/

let disposeBag = DisposeBag()

print("-----------toArray-----")
Observable.of("A", "B", "C")
    .toArray()
    .subscribe(onSuccess: {
      print($0)
    })
    .disposed(by: disposeBag)
/*
of 연산자를 통해서 각각으로 넣었던 것들이 하나의 Array로 들어간 것을 알 수 있다. 마치 just에 array를 넣은 것처럼 나온다.
 toArray를 통해서 Single로 변한다. Observable의 독립적 요소들을 Array로 만들 수 있는 방법이다.
*/

// just -> Array
//Observable.just(["A", "B", "C"])
//    .toArray()
//    .subscribe(onSuccess: {
//      print($0)
//    })
//    .disposed(by: disposeBag)

print("-----------RxSwift_Map-----")
/*
RxSwift의 map은 Observable에서 발생하는 것만 생각하면 swift에서 사용하는 것과 동일하다.
*/
Observable.of(Date())
    .map { date -> String in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "ko-KR")
        return dateFormatter.string(from: date)
        // 어떤 date값을 받았지만, map를 통해서 String으로 변환을 한다.
    }
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)

print("-----------swift_Map-----")
/*
 RxSwift의 Observable과 일반 Swift 컬렉션에서의 map 함수 사용은 다소 차이가 있습니다. RxSwift에서는 Observable 스트림을 통해 비동기적으로 데이터가 전달되며, 각 데이터에 대해 map을 사용하여 변환을 수행합니다. 반면, 일반 Swift 컬렉션에서 map을 사용할 때는 이미 존재하는 데이터 컬렉션에 대해 동기적으로 변환을 수행합니다.

 예제 코드에서 RxSwift의 Observable을 사용하여 Date 객체를 String으로 변환하는 작업을 수행하고 있습니다. 이를 RxSwift 없이 순수 Swift 코드로 구현하려면, 먼저 Date 객체의 배열이 필요합니다. 그런 다음, Swift의 map 함수를 사용하여 각 Date 객체를 원하는 문자열 형식으로 변환할 수 있습니다.
*/

let dates = [Date(), Date().addingTimeInterval(3600), Date().addingTimeInterval(7200)]  // 예시 날짜 배열

let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "yyyy-MM-dd"
dateFormatter.locale = Locale(identifier: "ko-KR")

let dateStrings = dates.map { dateFormatter.string(from: $0) }
dateStrings.forEach { print($0) }  // 각 날짜 문자열을 출력

print("-----------flatMap-----")

/*
 Observable속성을 갖는 Observable은 어떻게 사용할 수 있을까? 즉, 중첩된 Observable이면 어떻게 할까?
*/
//Observable<Observable<String>> // -> 중첩된 Observable
//[[String]] // -> Observable을 Array라고 한다면 이와 같은 형태

protocol 선수 {
    var 점수: BehaviorSubject<Int> { get }
}

struct 양궁선수: 선수 {
    var 점수: BehaviorSubject<Int>
}

let 🇰🇷국가대표 = 양궁선수(점수: BehaviorSubject<Int>(value: 10))
let 🇺🇸국가대표 = 양궁선수(점수: BehaviorSubject<Int>(value: 8))

let 올림픽경기 = PublishSubject<선수>()

/*
선수라는 것은 BehaviorSubject를 갖는 protocol이다. 따라서, BehaviorSubject protocol 준수하는 PublishSubject, 중첩된 Observable이다.
 중첩된 Observable에서 특정한 선수가 갖는 점수를 얻거나 그것을 핸들링하고 싶을 떄는 flatMap이라는 것을 사용할 수 있다.
*/

올림픽경기
    .flatMap { 선수 in
        선수.점수
    }
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)

올림픽경기.onNext(🇰🇷국가대표)
🇰🇷국가대표.점수.onNext(10)

올림픽경기.onNext(🇺🇸국가대표)
🇰🇷국가대표.점수.onNext(10)
🇺🇸국가대표.점수.onNext(9)

/*
올림픽경기가 선수를 받아서 선수가 가지고 있는 점수에 해당하는 것만 이벤트로 발생시킨다. 즉, flatMap를 통해서 2개의 중첩된 Observable 속에 element를 뽑아낼 수 있는 것이다.
 따라서 결과를 보면, 올림픽경기가 시작을 하고, 국가대표를 배출을 하는데, 그랬을 때 국가대표가 가지고 있는 초기값을 나타내게 된다. 그다음에, 국가대표가 구독 이후에, 발생한 이벤트를 내보내게 된다. 그다음에, 미국 국가대표가 나오게 되는데, 그래서 미국 국가대표가 갖고있는 초기값을 8이 나오게 된 것이다. 그 다음에, 순차적으로 한국국가대표가 onNext이벤트를 내보내게 되면, 그 10점이 그대로 반영되고, 미국국가대표가 onNext를 하면, 그대로 나오게 되는 것이다. 여기서 BehaviorSubject의 특징에 따라서 초기값이 같이 표현되는 것도 있지만, 중요한 것은 PublishSubject라는 Observable 그리고 거기에 중첩되는 선수, 선수가 갖고있는 BehaviorSubject라는 점수Observable 이것들이 중첩을 해서 갖고있는데, flatMap를 통해서 꺼낼 수 있다.
 
*/

print("-----------flatMapLatest-----")
struct 높이뛰기선수: 선수 {
    var 점수: BehaviorSubject<Int>
}

let 서울 = 높이뛰기선수(점수: BehaviorSubject<Int>(value: 7))
let 제주 = 높이뛰기선수(점수: BehaviorSubject<Int>(value: 6))

let 전국체전 = PublishSubject<선수>()

전국체전
    .flatMapLatest { 선수 in
        선수.점수
    }
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)

전국체전.onNext(서울)
서울.점수.onNext(9)

전국체전.onNext(제주)
서울.점수.onNext(10)
제주.점수.onNext(8)

/*
 flatMapLatest가 아니고, flatMap이라면, 서울을 구독했으니까, 초기값인 (7), 그 다음 (9), 그다음 제주도 점수초기값 (6)이 나오고, 서울점수(10), 제주도점수가 나올 것이다.(8)
 하지만, flatMapLatest를 쓰면 조금 다르다. flatMapLatest는 표현해서 확인할 수 있는 것처럼, 가장 최신의 값만 확인하고 싶을 때, flatMapLatest을 쓴다.
 map과 switchLatest연산자를 합친 것이 flatMapLatest이다.
 switchLatest는 가장 최근의 Observable에서 값을 생성하고, 그 이전에 발생한 구독해제한다.
 flatMapLatest의 문서를 살펴보면 Observable의 시퀀스에 각 요소들을 Observable시퀀스들에 새로운 순서로 투영한 다음, 시퀀스 중에 가장 최근에 시퀀스에서만 값을 생성한다.
 전국체전이라는 시퀀스가 갖고있는 선수.점수라는 시퀀스가 있는데, 즉, 선수.점수라는 시퀀스에 가장 최신의 값만을 반영하겠다는 것이다. 첫번째 같은 경우 onNext를 서울을 했을 때,
 가장 최신의 값은 서울의 초기값인 7이었을 것이다. 그래서 7을 내뱉은 것이다. 그다음에, 서울점수인 9을 내뱉은 것이다. 제주선수가 onNext되었을 때는 제주선수의
 가장 최근의 값인 6점을 내뱉은 것이고, 그 다음에 제주선수가 발행한 최근의 값인 8을 내뱉은 것이다.
 이미 최근의 값을 내뱉었기 때문에, 서울선수가 새로운 10점이라는 점수를 내뱉어도, 그 값은 무시한다. 왜냐하면, 서울.점수.onNext(10)까지는 서울.점수.onNext(9)가 가장 최신의
 값이기 때문이다. 즉 변경된 값을 무시한다고 이해하면된다.
 중요한 것은 flatMapLatest는 가장 최근의 Observable로 전환한 이후, 즉 전국체전의 입장에서는 ,서울의 점수라는 시퀀스와 제주의 점수라는 시퀀스, 2가지 시퀀스가 있다.
 전국체전이 서울이라는 시퀀스를 갖고 있을 때는, 서울이 계속해서 새로운 값을 나타내도, 이 시퀀스가 최신의 값이기 때문에, 계속해서 서울의 값을 보여준다. 그런데,
 제주라는 새로운 시퀀스가 발생한 이후부터는 서울은 그냥 해제된다. 더 이상 서울이 아무리 점수를 내도, 받아주지않는다.
 flatMapLatest는 네트워크 핸들링에서 가장 많이 쓰인다. 예들들어, 사전에서 단어를 찾는다고 하자. 사용자가 어떤 swift라는 각 문자, 's', 'w', 'i', 'f', 't'를 입력하면,
 새 검색을 실행하고, 만약에 's'를 검색하고 'w'를 쳤을 때, 's'라는 검색값이 남아있지않는다. 새로운 string을 입력할 때마다 가장 최신의 string에 맞는 검색값을 보여주고 있다.
 이럴 경우에 flatMapLatest를 사용할 수 있다.
 */

print("-----------materialize and dematerlize-----")
/*
Observable을 Observable이벤트로 변환해야할 때가 있을 수 있다. 보통 Observable속성을 가진 Observable항목을 제어할 수가 없고, 외부적으로 Observable이 종료되는 것을
 방지하기 위해 Error이벤트를 처리하고 싶을 수가 있다.
*/

enum 반칙: Error {
    case 부정출발
}

struct 달리기선수: 선수 {
    var 점수: BehaviorSubject<Int>
}

let 김토끼 = 달리기선수(점수: BehaviorSubject<Int>(value: 0))
let 박치타 = 달리기선수(점수: BehaviorSubject<Int>(value: 1))

let 달리기100M = BehaviorSubject<선수>(value: 김토끼)

달리기100M
    .flatMapLatest() { 선수 in
        선수.점수
            .materialize()
    }
    .filter {
        guard let error = $0.error else {
            return true
        }
        print(error)
        return false
    }
    .dematerialize()
    .subscribe(onNext: {
      print($0)
    })
    .disposed(by: disposeBag)

김토끼.점수.onNext(1)
김토끼.점수.onError(반칙.부정출발)
김토끼.점수.onNext(2)

달리기100M.onNext(박치타)
/*
가장 초반값인 '0'이라는 것은 토끼선수가 갖고있는 첫번째 초기값이다. 그리고 구독을 시작한 이후에, next이벤트 일정을 받고, 반칙.부정출발을 한다음에 시합은 끝나버렸다.
 그래서, 토끼선수가 아무리 점수를 내도 아무런 반응이 없는 것을 확인할 수 있다.
*/
/*
 materialize()를 추가를 하게되면, materialize()를 통해서 선수.점수를 주는 것이 아니라, 이벤트들을 함께 받을 수 있다.
 .subscribe를 해도 이벤트와 이벤트가 갖고 있는 element를 포함한 방식으로 print가 되는 것을 확인할 수 있다.
 선수의 점수에 .materialize()를 해서 이벤트와 함께 결과값이 도출되도록 했다. 그렇게 결과값을 받은 .filter라는 연산자는 error가 발생했을 때는 error를 표시하게만 하고,
 .filter를 벗어나지않도록한다.
 만약에, 에러가 없을 때는 true를 주기 때문에, error가 없을 때만, 통과를 하도록 한다. 그리고 .dematerialize()를 했다.
 0번은 김토끼 선수의 초기값이다. 그다음에 나온 것은 구독을 한 이후에(onNext) 나온 1번이다. 그렇게 하고, 부정출발이라는 print는 filter 안에 print(error)에서 나오는 것이다.
 그리고 1번은 박치타 선수의 초기값이다. 김토끼 선수의 onNext 즉, 2는 표현되지않는다. 왜냐면, 박치타선수라는 새로운시퀀스가 나왔기 때문에, flatMapLatest가 무시를 하게 되는 것이다. 여기서 중요한 것은 flatMapLatest를 한번 더 이해하는 것에도 있지만, materialize()와 dematerialize()의 역할이다.
 materialize -> 이벤트를 element로 감싸서 표현해주는 것을 볼 수 있다.
 dematerialize -> 다시 원래의 상태로 되돌려주는 역할을 하는 것이다.
*/

print("-----------전화번호 11자리-----")
let input = PublishSubject<Int?>()

let list: [Int] = [1]

/*
 전화번호가 11자리, 숫자로 11자리를 입력하면, 이거를 전화번호의 형태로 보이게, 변형해서 print해주는 어떤 Observable을 만들 것이다.
*/

input
    .flatMap {
        $0 == nil ? Observable.empty() : Observable.just($0)
    }
    .map { $0! }
    .skip(while: { $0 != 0 })
    .take(11)
    .toArray()
    .asObservable()
    .map {
        $0.map { "\($0)" }
    }
    .map { number in
        var numberList = number
        numberList.insert("-", at: 3) // 010-
        numberList.insert("-", at: 8)  // 010-1234-
        let number = numberList.reduce(" ", +)
        return number
    }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

input.onNext(10)
input.onNext(0)
input.onNext(nil)
input.onNext(1)
input.onNext(0)
input.onNext(4)
input.onNext(5)
input.onNext(6)
input.onNext(7)
input.onNext(nil)
input.onNext(9)
input.onNext(1)
input.onNext(5)
input.onNext(7)
