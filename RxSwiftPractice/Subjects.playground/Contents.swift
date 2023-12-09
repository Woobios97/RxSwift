import UIKit
import RxSwift

let disposeBag = DisposeBag()


print("-----------PublishSubject-----")
let publishSubject = PublishSubject<String>()

publishSubject.onNext("1. 여러분 안녕하세요?")

/*
 subject도 observer이긴 하지만, observable이기도 하기 때문에, 구독을 해야만 의미가 잇다.
 */

let 구독자1 = publishSubject
    .subscribe(onNext: {
        print("구독자1 - \($0)")
    })

/*
 구독을 시작한 다음에, 이벤트를 한번 더 내뱉어보겠다.
 */

publishSubject.onNext("2. 들리세요?")
publishSubject.on(.next("3. 안들리시나요?"))

구독자1.dispose()

/*
 구독자1은 첫번째이벤트가 발생한 이후부터 구독을 시작하지만, 구독자2은 3가지의 이벤트를 다 방출한 다음에, 구독을 시작한다.
 */

let 구독자2 = publishSubject
    .subscribe(onNext: {
        print("구독자2 - \($0)")
    })

publishSubject.onNext("4. 여보세요")
publishSubject.onCompleted()

publishSubject.onNext("5. 끝났어요?")

구독자2.dispose()

publishSubject
    .subscribe {
        print("구독자3 -", $0.element ?? $0)
    }
    .disposed(by: disposeBag)

publishSubject.onNext("6. 찍힐까요?")

/*
 구독자1과 구독자2가 publishSubject이기 때문에, 자신들이 구독을 시작한 시점 이전에 발생한 이벤트에 대해서는 전혀 받아들이지 못하고 있다.
 구독자 1번은 2, 3번 이벤트까지 받은 다음에 dispose된다.
 구독자 2번은 1, 2, 3번 이벤트는 구독자2번이 구독을 하기 이전의 이벤틀이기 때문에, 받아들이지 못한다. 구독을 시작한 이후에 시작한 4번째 이벤트는 잘 받고 있다.
 publishSubject자체가 onCompleted되었기 때문에, 아무리 onNext를 보내도 구독자2번은 읽을 수 없다. 따라서 구독자2는 읽을 수 없는 상태로 dispose 되었다.
 publishSubject가 onCompleted가 된다음에, 즉, completed된 subject에 구독을 시작한 것이다. 그런 다음에, subject에 next이벤트를 방출하도록하면 구독자3은 6번째 이벤트를 읽을 수 있을까?
 구독자3은 6번째이벤트를 읽을 수 없다. 바라보고 있는 Observable이 이미 completed되었기때문이다. completed된 이후에 구독을 시작하고, 구독한 이후에 onNext를 받았다고 해서, 그 next이벤트를 받을 수는 없다.
 */

print("-----------behaviopSubject-----")
enum SubjectError: Error {
    case error1
}

/*
 PublishSubject는 아무런 초기값 없이 만들 수 있었지만, behaviorSubject는 반드시 초기값을 갖는다.
 */

let behaviorSubject = BehaviorSubject<String>(value: "0. 초기값")
behaviorSubject.onNext("1. 첫번째값")

behaviorSubject.subscribe {
    print("구독자1 -", $0.element ?? $0) 
    //  $0.element -> 구독한 것의 element을 표현한 것이다. 만약에 element가 없다면, 어떠한 이벤트를 받았는 지를 표현할 수 있도록 적었다
}
.disposed(by: disposeBag)

/*
 구독자1은 첫번째이벤트가 발생한 이후에 구독을 시작했음에도, 첫번째값 잘받고있다. 하지만, 그 전의 이벤트는 받지 못하고 있다.
 behaviorSubject는 구독자가 그 직전에 값을 전달을 해주기 때문에, pubilshSubject와 달리, 자신이 구독한 시점이 이벤트가 발생한 시점 이후라고 하더라도, 그 직전의 발생한 이벤트를 받을 수가 있다.
 구독자1이 구독한 시점 이후에 에러가 발생했기 때문에, 에러 역시도 잘 받고 있다.
 */

//behaviorSubject.onError(SubjectError.error1)

behaviorSubject.subscribe {
    print("구독자2 -", $0.element ?? $0)
}
.disposed(by: disposeBag)

/*
 구독자2는 이미 subject가 있고, 자신이 구독을 시작한 시점 이후에는 아무런 이벤트가 발생하지 않았다. 다만, 구독하기 시점 이 전의 바로 직전인 이벤트인 onError라는 이벤트가 있다. onError이벤트는 자연스럽게 받고 있다. 자신이 구독한 시점, 이 전의 이벤트임에도 불구하고, 직전의 이벤트이기 때문에, 그 이벤트를 구독자2는 받고 있다.
 */

//Observable.of(1)
//    .subscribe(onNext: {
//        $0
//    })

/*
 behaviorSubject 특징 중 하나가 value값을 뽑아낼 수 있다는 것이다.
 behaviorSubject, Observable 전부 다 어떠한 형태로 구독을 하게되면, 구독하는 클로저 내에서는 클로저 내에서만 이 값(1)을 가지고
 표현할 수 있다. 근데 내가 subscribe구문이 아니라 명령형에서 익숙했던 방식처럼 이 '1'이라는 값을 그대로 꺼내보고싶다. 그러면 어떻게 할 수 있을까? 이 방법으로써 behaviorSubject는 value라는 것을 제공해준다.
 */

let value = try! behaviorSubject.value()
print("behaviorSubject - \(value)")

/*
 아직 종료되지 않았기 떄문에, 가장 최신의 onNext값인 첫번째값을 value로 꺼내주는 것을 확인할 수 있다.
 이런 방식으로, behaviorSubject가 갖는 element만을 뽑아낼 수 있는 value라는 쓰로우가 있다.
 Rx의 경우 왠만하면 사용하지 않는데, value값을 뽑아낼 수 있다는 방법으로 이해하면 될 것 같다.
*/

print("-----------ReplaySubject1-----")

/*
 내가 타입의 시퀀스로 만들겠다라는 것을 만들어준다음에, initializing이나 value값을 넣는 것이 아니라 create라는 것을 통해서 만들어줘야한다.
 bufferSize가 있는데, bufferSize를 설정해주면 몇 개의 Int값으로 buffer을 가질 것이냐?를 알 수 있다.
 */

let replaySubject = ReplaySubject<String>.create(bufferSize: 2)

replaySubject.onNext("1. 여러분")
replaySubject.onNext("2. 힘내세요")
replaySubject.onNext("3. 어렵지만")

replaySubject.subscribe {
    print("구독자1 -", $0.element ?? $0)
}
.disposed(by: disposeBag)

replaySubject.subscribe {
    print("구독자2 -", $0.element ?? $0)
}
.disposed(by: disposeBag)

replaySubject.onNext("4. 할 수 있다!")
replaySubject.onError(SubjectError.error1)
replaySubject.dispose()

replaySubject.subscribe {
    print("구독자3 -", $0.element ?? $0)
}
.disposed(by: disposeBag)

/*
 구독자1은 3개의 이벤트가 발생한 후에, 구독을 시작했지만, replaySubject덕분에 2개의 buffer값을 가져서 두 개의 이벤트를 그대로 가져온다.
 구독자2도 마찬가지이다. 같은 시점에 시작했기 때문에,replaySubject덕분에 2개의 buffer값을 가져서 두 개의 이벤트를 그대로 가져온다.
 이후, 구독자들이 구독을 시작한 이후에 발생한 4번쨰 이벤트는 잘 받는다. 이후에 에러도 똑같이 받는다. 하지만,
 구독자3은 에러를 받았는 데, 우리가 작성한 에러가 아닌 RxSwift에서 발생시킨 에러이다. 이미 dispose가 되었는 데, 다시 subscribe를 하니까 RxSwift가 에러를 내뱉어 준 것이다.
 이런 방식으로 replaySubject는 bufferSize을 통해서 구독자가 발생했을 때, 지나간 이벤트라도 bufferSize에 따라서 받을 수 있게 해준다.
*/


print("-----------ReplaySubject2-----")
let replaySubject1 = ReplaySubject<String>.create(bufferSize: 3)

replaySubject1.onNext("1. 여러분")
replaySubject1.onNext("2. 힘내세요")
replaySubject1.onNext("3. 어렵지만")

replaySubject1.subscribe {
    print("구독자1 -", $0.element ?? $0)
}
.disposed(by: disposeBag)

replaySubject1.subscribe {
    print("구독자2 -", $0.element ?? $0)
}
.disposed(by: disposeBag)

replaySubject1.onNext("4. 할 수 있다!")
replaySubject1.onError(SubjectError.error1)
replaySubject1.dispose()

replaySubject1.subscribe {
    print("구독자3 -", $0.element ?? $0)
}
.disposed(by: disposeBag)
