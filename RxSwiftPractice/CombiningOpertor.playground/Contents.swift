import UIKit
import RxSwift

print("----------Append: 추가하다-----")

/*
 Observable시퀀스를 어떻게 만들고, 필터링하고, 변형하는 지를 확인해봤다면, 이번에는 다양한 방법으로 시퀀스를 모으고,
 각각의 시퀀스 내에 데이터들을 병합하는 방법에 대해서 배울 것이다.
 RxSwift의 Filtering과 Transforming연산자들이 swift의 표준 연산자들 (ex. filter와 map 유사한 것처럼) CompbiningOpertor도 Swift표준라이브러리에서
 array를 핸들링할 때, 사용했던 몇가지 유사한 연산자들을 확인해볼 수 있다.
 */

let disposeBag = DisposeBag()

print("------------startWith------")
/*
 초기값을 받는 지 여부가 사실 Observable로 작업할 때, 중요하게 확인해야될 것 중 하나이다. 예를들면, 현재위치, 네트워크연결상태와 같이 현재상태, 초기값이 필요할 때가 있다.
 이럴 떄는 현재상태와 함께, 초기값을 붙일 수 있다. 그럴 때 사용하는 것이 startWith이다.
*/
let 노랑반 = Observable<String>.of("🧒🏻", "🧒🏼", "👧🏽")

노랑반
    .enumerated()
    .map{ index, element in
       return element + "어린이" + "\(index)"
    }
    .startWith("👨🏻‍🏫선생님") // String
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

/*
 startWith에 들어가는 타입은 Observable타입이 String타입이기 때문에, 동일한 StartWith에도 String타입이 들어가야한다.
 왜?
 해당 Observable 앞에 붙일 것이기 때문이다.
 startWith는 어떤 연산자의 순서에 영향을 받지 않는다. 어떤 순서에 있더라도, 구독 전에 startWith이라는 게 붙으면 항상 startWith안에 있는 값이 먼저 나오고,
 그 다음에 있는 시퀀스들이 순서대로 방출된다.
 사실 startWith는 좀 더 일반적인 concat의 연산자계열의 변형이다.
*/

print("------------concat1------")
/*
 concat은 컬렉션과 컬렉션, 시퀀스와 시퀀스에 조합으로 만들 수 있다.
*/
let 노랑반어린이들 = Observable<String>.of("🧒🏻", "🧒🏼", "👧🏽")
let 선생님 = Observable<String>.of("👨🏻‍🏫선생님")

let 줄서서걷기 = Observable
    .concat([선생님, 노랑반어린이들])

줄서서걷기
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

print("------------concat2------")

/*
 concat은 Observable.concat을 해서 컬렉션과 컬렉션, 시퀀스와 시퀀스에 조합으로 만들 수도 있지만,
 startWith형식으로 사용할 첫번째 Observable을 방출한 다음에, concat으로 쌓여진 두번째 Observable의 element들을 방출할 수 있다.
*/

선생님
    .concat(노랑반어린이들)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

print("------------concatMap------")
/*
 flatMap -> flatMap을 통과하면 Observable시퀀스가 구독을 위해서 return이 되고, 그렇게 방출된 Observable들은 합쳐지게 되는데,
 concatMap은 각각의 시퀀스가 다음 시퀀스가 구독되기 전에, 합쳐지는 것을 보증한다.
*/

let 어린이집: [String: Observable<String>] = [
    "노랑반": Observable.of("🧒🏻", "🧒🏼", "👧🏽"),
    "파랑반": Observable.of("👶🏻", "👶🏼")
]

Observable.of("노랑반", "파랑반")
    .concatMap { 반 in
        어린이집[반] ?? .empty()
        // 어린이집에 반을 넣어준다. 딕셔너리에 각각의 string에 대응하는 값들 Observable이 나오게된다.
    }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

/*
 어린이집은 노랑반과 파랑반을 나타낼 시퀀스를 준비한 것이다. 시퀀스는 해당 반의 어떤 아이들을 내보내는 시퀀스에 mapping되는 아기들을 내보내기 시작한다.
 그런다음, 특정 반에 노랑반, 파랑반에 해당하는 전체 시퀀스를 출력한 다음에, 두 개의 시퀀스를 어떻게 Append하는 지를 나타낸 것이 concatMap이라고 볼 수 있다.
*/


print("----------Combine: 합치다-----")

print("----------merge1-----")
/*
 RxSwift에는 시퀀스를 합치는 다양한 방법들이 있다. 가장 쉬운 방식 중 하나가 merge가 있다.
*/

let 강북 = Observable.from(["강북구", "성북구", "동대문구", "종로구"])
let 강남 = Observable.from(["강남구", "강동구", "영등포구", "양천구"])

Observable.of(강북, 강남)
    .merge()
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

/*
 merge()는
 두 가지 경우가 순서를 보장하지 않고, 섞여서 나오는 것을 볼 수 있다.
 두 개의 Observable들을 합쳐서 구독하도록 하는 것이다. 따라서, 어떤 값이 먼저 나올지, 어떤 Observable 전체가 나오고, 그 다음 Observable이 나올 지
 순서를 보장하지는 않는다. Observable의 각각의 요소들이 도착하는 대로, 받아서 방출을 한다. 사전에 정의된 규칙같은 것이 없다.
 merge()로 묶어진 Observable이 전체 시퀀스가 언제 종료될 지 궁금할 수 있다. 소스가 되는 강북, 강남 Observable이 완료되었을 때 끝난다.
 내부에 있는 강북과 강남이라는 Observable들은 서로 아무 관계를 가지지않는다. 따라서 어떠한 강북, 강남 하나라도 에러를 방출하면 merge에 묶인 전체Observable 자체가 에러를 방출하고 즉시 종료가 된다.
*/

print("----------merge2-----")
Observable.of(강북, 강남)
    .merge(maxConcurrent: 1)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
/*
 merge()2는
 merge()1과 거의 동일해보이는데, 순서를 보장한다. maxConcurrent라는 것이 한번에 받아 낼 Observable의 수를 의미한다. 지금 1로 제한했기 때문에, 첫번째로 구독을 시작하게 된
 어떠한 Observable이 전부 도달해서 element를 뱉기 전까지는 동시에 다른 Observable들을 받지 않는 것이다.
 지금 maxConcurrent을 1이라고 했을 때, 처음 들어오는 것이 강북 Observable이기 때문에, 강북 Observable의 element가 다 끝날 때까지
 강남 Observable의 element을 받지않는다.
 merge()는 Observable의 갯수에 제한을 두지 않는다. 그러나, 간혹 쓰일 수도 있다.
 예를들어서, 네트워크요청이 많아져서 리소스를 제한하거나, 연결 수를 제한하기 위해서 maxConcurrent라는 것을 사용할 수는 있다.
*/

print("----------combineLatest1-----")
let 성 = PublishSubject<String>()
let 이름 = PublishSubject<String>()

let 성명 = Observable
    .combineLatest(성, 이름) { 성, 이름 in
        성 + 이름
    }

성명
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

성.onNext("김")
이름.onNext("똘똘")
이름.onNext("명수")
이름.onNext("은영")
성.onNext("이")
성.onNext("박")
성.onNext("조")

/*
 내부적으로 combineLatest로 결합된 시퀀스들은 값을 방출할 때마다 같이 제공되는 클로저를 호출하게 된다. 우리는 각각의 성과 이름의 시퀀스의 최종값들을 받게 된다.
 따라서 어떨 떄 자주쓰이냐면? 어러 텍스트필드를 한번에 관찰하고, 값을 결합하거나, 여러 소스들의 상태들을 보는 앱이 있을 때 많이 사용한다.
 갯수륾 맞춰서 쌍을 이루는 것이 아니라, 지금 현재 성이라는 onNext가 나타났을 떄는 '김'이라는 성이 가장 최신의 값이다. 하지만, '김'만 방출되지는 않는다.
 combineLatest를 했기 때문에, 두번째인 '이름'에 대한 next이벤트가 발생할 때까지 기다린다.
 '성'에 가장 최신값은 '김'이고, '이름'의 가장 최신값은 '똘똘'이기때문에, 이 두가지가 결합해서 첫번째값이 나오는 것이다.
 그다음에, 이름이 방출됐을 때는 '영수'라는 이름이 방출됐을 때는 '이름'의 최신값이 '명수'이기 때문에, '똘똘'은 이제 방출되지않는다.
 왜냐하면 이름의 가장 최신값이 '명수'이기 때문이다. 마찬가지로 '성'이 새로운 이벤트를 '이'라고 발생했기 때문에, 기존의 '성'이벤트인 '김'은 더이상 방출되지않는다.
 가장 최신값이 '이'가 나온다. 즉, 각각의 최신값이 방출되는 형태로 조합하게 된다.
*/

print("----------combineLatest2-----")
let 날짜표시형식 = Observable<DateFormatter.Style>.of(.short, .long)
let 현재날짜 = Observable<Date>.of(Date())

let 현재날짜표시 = Observable
    .combineLatest(날짜표시형식,
                   현재날짜,
                   resultSelector: { 형식, 날짜 -> String in
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = 형식
        return dateFormatter.string(from: 날짜)
        }
    )

현재날짜표시
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

/*
 첫번째 형식이었던 짧은 타입, 두번째 형식이었던 긴 타입 -> 각각의 타입이 표시되는 것을 확인할 수 있다.
 combineLatest에서 source를 총 8개까지 여러가지로 받을 수 있다. 갯수제한이 있는 연산자이다.
*/

print("----------combineLatest3-----")
/*
 combineLatest 중에서는 Array 내에 최종값을 받는 형태로 나타나지는 연산자도 있다. 똑같은 combineLatest이다.
*/

let lastName = PublishSubject<String>() // 성
let firstName = PublishSubject<String>() // 이름

let fullName = Observable
    .combineLatest([firstName, lastName]) { name in
        name.joined(separator: " ")
    }

fullName
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

lastName.onNext("Kim")
firstName.onNext("Paul")
firstName.onNext("Stella")
firstName.onNext("Lily")

/*
 각각의 값들에 대해서, lastName은 하나밖에 없기 때문에, 해당하는 값('Kim')이 최신값일 것이다. 그리고, firstName이 값을 내보낼 때마다,
 가장 최신의 lastName이라는 Observable의 값을 붙여서 'Paul Kim', 'Stella Kim', 'Lily Kim'을 방출하는 것을 볼 수 있다.
*/

print("----------zip-----")

enum 승패 {
    case 승
    case 패
}

let 승부 = Observable<승패>.of(.승, .승, .패, .승, .패)
let 선수 = Observable<String>.of("🇰🇷", "🇹🇷", "🇺🇸", "🇧🇷", "🇯🇵", "🇨🇳")

let 시합결과 = Observable
    .zip(승부, 선수) { 결과, 대표선수 in
        return 대표선수 + "선수" + "\(결과)"
    }

시합결과
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

/*
각각의 승부와 선수에 대한 element들이 하나씩 나와서 표현한대로 표현되는 것이 확인할 수 있다. 순서를 보장하면서 합쳐지는 것을 확인할 수 있다.
결과 값에 하나 다른 점은 중국의 결과가 없는데, .zip이라는 연산자의 특징이다. 일련의 Observable의 새 값을 서로가 방출할 때까지 기다리다가 둘 중 하나의 Observable이라도
완료되면, zip전체가 완료된다.
merge같은 경우, 두 가지 순서가 하나의 Observable이 짝이 안맞더라도, 다른 하나의 Observable의 element들이 못 방출되지는 않는다. 즉 모든 element들이 다 나오게 된다.
zip같은 경우, 둘 중 하나의 Observable이 끝나면, zip은 종료가 된다. 남아있는 element는 매칭되지않은 채, 끝나게 된다.
시퀀스에 따라서 단게별로 작동하는 방법을 가르쳐서 indexConcing?라고 한다. Swift에도 .zip연산자가 있다. 새로운 tuple조합을 두 조합으로 만드는 작업을 한다.
RxSwift에서도 똑같이 .zip이라는 연산자가 있다. .zip이라는 연산자도 combineLatest처럼 총 8개의 소스를 최대로 갖는다. resultSelector로 표현하는 방식 있다.
*/

print("----------Triger: 합치다-----")
print("----------시퀀스들의 합-----")
/*
1번과 2번의 Observable이 있으면, 둘 중의 하나의 Observable이 탕하고 트리거역할을 한 뒤에 조합을 시작하는 CombineOperator가 있다.
*/

print("----------withLatestFrom1-----")

let 💥🔫 = PublishSubject<Void>()
let 달리기선수 = PublishSubject<String>()

💥🔫
    .withLatestFrom(달리기선수)
//    .distinctUntilChanged()
// -> withLatestFrom를 sample처럼 사용하려면 distinctUntilChanged를 사용하면 동일한 값을 걸러주기 떄문에, 이벤트가 한번만 방출된다.
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

달리기선수.onNext("🏃🏻")
달리기선수.onNext("🏃🏻 🏃🏻‍♂️")
달리기선수.onNext("🏃🏻 🏃🏻‍♂️ 🏃🏻‍♀️")

💥🔫.onNext(Void())
💥🔫.onNext(Void())

/*
 달리기선수가 onNext를 했음에도 불구하고, 맨 마지막 달리기선수가 두 번 발생된 것을 알 수 있다.
 💥🔫 방아쇠에 해당하는 PublishSubject<Void>()가 말그대로, 방아쇠 역할을 한 것이다. withLatestFrom의 첫번째 Observable이 그런 방아쇠의 역할을 하게된다. withLatestFrom 안에 들어가는 Observable이 다음에 두번째 역할을 하게 된다.
 💥🔫 역할을 하는 Observable이 방아쇠를 당기는 역할을 해야만, 그 두번째 들어가있는 Observable이벤트들이 나타나게 되는데, 그 중에서도 가장 최신의 값을 나타나게 되는 것이다.
 그래서 그 이전에 나타난 값들은 무시하게 된다. trigger가 발생한 시점에서 가장 최신의 값만 나오게 되는 것이다.
*/

print("----------sample-----")

let 🏁출발 = PublishSubject<Void>()
let F1선수 = PublishSubject<String>()

F1선수
    .sample(🏁출발)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

F1선수.onNext("🏎")
F1선수.onNext("🏎   🚗")
F1선수.onNext("🏎      🚗   🚙")
🏁출발.onNext(Void())
🏁출발.onNext(Void())
🏁출발.onNext(Void())

/*
 출발사인이 여러번 발생했음에도 불구하고, F1선수의 가장 최신 값이 🏎      🚗   🚙만 방출된다. sample은 withLatestFrom와 동일하게 발생하지만,
 단 한번만 방출한다는 것에 차이점이 있다. 즉, 여러번 새로운 이벤트들을 통해서 트리거를 해도 한번만 방출되는 것이다.
*/

print("----------amb-----")
/*
 amb는 모호함의 약자이다. 두 가지 시퀀스를 받을 때, 두 가지 시퀀스 중에서 어떤 구독할 지 애매모호할 때, 사용하는 방식이다.
*/
let 🚌버스1 = PublishSubject<String>()
let 🚌버스2 = PublishSubject<String>()

let 🚏버스정류장 = 🚌버스1.amb(🚌버스2)

🚏버스정류장
    .subscribe(onNext: {
    print($0)
    })
    .disposed(by: disposeBag)

🚌버스2.onNext("버스2-승객0: 👩🏾‍💼")
🚌버스1.onNext("버스1-승객0: 🧑🏼‍💼")
🚌버스1.onNext("버스1-승객1: 👨🏻‍💼")
🚌버스2.onNext("버스2-승객1: 👩🏻‍💼")
🚌버스1.onNext("버스1-승객1: 🧑🏻‍💼")
🚌버스2.onNext("버스2-승객2: 👩🏼‍💼")

/*
 버스 2번에 대한 승객들의 이벤트만 방출된 것을 확인할 수 있는데, 
 amb연산자는 두 가지 Observable을 구독하기는 한다. 이 2개 중에 어떤 것이든, 요소를 먼저 방출하는 Observable이 생기면 나머지에 대해서는 구독을 하지않는다.
 amb는 순서를 보장하지는 않는다. amb라는 것은 amb가 갖고 있는 두 가지 Observable을 지켜보겠다는 의미인데, 지켜보다가, 둘 중 하나라도 먼저 이벤트를 방출하면
 먼저 이벤트를 방출한 Observable의 이벤트만 방출하고, 나머지 Observable의 event는 방출하지 않는다.
 처음에 어떤 시퀀스에 관심있는 지 알 수 없기 떄문에, 일단 시작한 것을 보고 결정하는 Operator라고 할 수 있다.
*/

print("----------swichLatest-----")
let 👩🏻‍💻학생1 = PublishSubject<String>()
let 🧑🏽‍💻학생2 = PublishSubject<String>()
let 👨🏼‍💻학생3 = PublishSubject<String>()

let 손들기 = PublishSubject<Observable<String>>() // 이벤트로 Observable를 내뱉는다.

let 손든사람만말할수있는교실 = 손들기.switchLatest()

손든사람만말할수있는교실
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

손들기.onNext(👩🏻‍💻학생1)
👩🏻‍💻학생1.onNext("👩🏻‍💻학생1: 저는 1번 학생입니다.")
🧑🏽‍💻학생2.onNext("🧑🏽‍💻학생2: 저요 저요!!!")

손들기.onNext(🧑🏽‍💻학생2)
🧑🏽‍💻학생2.onNext("🧑🏽‍💻학생2: 저는 2번이예요!")
👩🏻‍💻학생1.onNext("👩🏻‍💻학생1: 아.. 나 아직 할말 있는데")

손들기.onNext(👨🏼‍💻학생3)
🧑🏽‍💻학생2.onNext("🧑🏽‍💻학생2: 아니 잠깐만! 내가! ")
👩🏻‍💻학생1.onNext("👩🏻‍💻학생1: 언제 말할 수 있죠")
👨🏼‍💻학생3.onNext("👨🏼‍💻학생3: 저는 3번 입니다~ 아무래도 제가 이긴 것 같네요.")

손들기.onNext(👩🏻‍💻학생1)
👩🏻‍💻학생1.onNext("👩🏻‍💻학생1: 아니, 틀렸어. 승자는 나야.")
🧑🏽‍💻학생2.onNext("🧑🏽‍💻학생2: ㅠㅠ")
👨🏼‍💻학생3.onNext("👨🏼‍💻학생3: 이긴 줄 알았는데")
🧑🏽‍💻학생2.onNext("🧑🏽‍💻학생2: 이거 이기고 지는 손들기였나요?")

/*
 손들기 이벤트가 학생들을 내뿜고, 학생들은 자신의 이벤트를 내뿜는 손든사람만말할수있는교실이 어떤 식으로 표현하는 지 확인해보겠다.
 .switchLatest()의 목적은 sourceObservable, 즉 여기서 sourceObservable은 '손들기'이다.
 '손들기'라는 sourceObservable로 들어온 마지막 시퀀스의 Item만 구독하는 것이 .switchLatest()의 특징이다. 따라서,
 손들기.onNext(👩🏻‍💻학생1)처럼 손들기에서 👩🏻‍💻학생1을 내뿜었기 때문에, 현재 상태에서 손들기라는 sourceObservable에서 들어온 마지막 시퀀스는 👩🏻‍💻학생1이다.
 그럴 경우에는 들어온 👩🏻‍💻학생1만 구독하고, 들어오지않은 🧑🏽‍💻학생2에 대한 이벤트는 무시한다.
 그리고 손들기.onNext(🧑🏽‍💻학생2)가 두번째 source가 두번째이벤트를 발생했는데, 그러면 더 이상 최신의 값은 👩🏻‍💻학생1이 아니고, 🧑🏽‍💻학생2가 될 것이다. 
 따라서, 🧑🏽‍💻학생2가 내뿜는 최신의 값은 방출하지만, 👩🏻‍💻학생1.onNext("👩🏻‍💻학생1: 아.. 나 아직 할말 있는데")이라는 👩🏻‍💻학생1의 대화는 무시한다.
 그래서 최신의 값을 보여준다.
*/

print("----------시퀀스 내의 요소들 간의 결합을 해주는 연산자-----")

print("----------reduce----------")
/*
 swift의 reduce와 동일하다.
*/

Observable.from((1...10))
    .reduce(0, accumulator: { summary, newValue in
        return summary + newValue
    })
//    .reduce(0) { summary, newValue in
//        return summary + newValue
//    }
//    .reduce(0, accumulator: +)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

/*
 Observable의 element들을 결합해주는 것이 reduce이다.
 reduce의 역할은 제공되는 초기값에서 시작해서, sourceObservable이 1부터 10까지의 array를 갖는 observable.from에 있는 값들이 방출될 떄마다 그 값을 가공한다.
 Observable이 완료되었을 떄, reduce라는 것도 결과값을 방출하고 완료되게된다.
*/

print("----------scan----------")

Observable.from((1...10))
    .scan(0, accumulator: +)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

/*
 reduce의 경우에는 결과 값만을 방출하지만, scan같은 경우는 매번 값이 들어올 때마다 값들을, 변형된 값들을 방출하게 된다. 
 reduce와 동일하게 작동하지만, return값이 Observable이라는 것을 알 수 있다.
 scan의 쓰임은 광범위하다. 총합이나 통계, 상태를 계산할 때 등 다양하게 쓰일 수 있다.
 scan은 Observable타입으로 매 번 새로운값이 들어올 때마다 새로운 형태의 element들을, 현재 상태의 element들을 내뱉으면서 종료된다.
*/
