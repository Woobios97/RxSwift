import UIKit
import RxSwift
import RxCocoa
import PlaygroundSupport

let disposeBag = DisposeBag()

/*
TimeBasedOperator
시간의 흐름에 따라 Data를 변동하고, 조작하는, 제어하는 그런 Operator
*/

/*
Buffer연산자 계열, Buffering 연산자들은 과거에 요소들을 Subscriber에게 다시 재생하거나, 잠시 buffer를 두고 줄 수 있다.
 BehaviorSubject, ReplaySubject에서 Buffer를 뒀던 것처럼, 언제, 어떻게 과거와 새로운 요소들을 전달할 것인지, Control 할 수 있게 해준다.
 과거요소들을 Replay할 수 있는 방식이 있는 데, 이 시퀀스가 요소들을 방출했을 떄, 보통 미래의 구독자가 지난간 요소들을 받을 수 있는 지, 아닌 지에 대해서,
 전달을 해주는 것이다.
*/

print("---------------Replay-------")
let 인사말 = PublishSubject<String>()
let 반복하는앵무새 = 인사말.replay(2)
반복하는앵무새.connect() // replay관련한 연산자들은 쓸 때는 반드시, connect()를 해줘야한다.

인사말.onNext("1. Hello")
인사말.onNext("2. Hi")

반복하는앵무새
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

/*
 반복하는 앵무새가 구독한 시점이 인사말이 이벤트를 방출하고 나서 그 뒤에 시점에 구독을 시작했다. 그럼에도 불구하고, 2, hi 인사말 이벤트를 받은 것을 확인할 수 있다.
 왜냐면, 지나간 이벤트더라도 buffer하나를 두고 지나간 이벤트 중 최신의 하나는 받을 수 있도록 했기때문이다. 2로 바꾸면 2개의 해당하는 값이 나올 것이다.
 이런 방식으로 구독자가 과거의 요소들을 자기가 구독하기 전에 나왔던 이벤트들도, buffer의 갯수만큼 최신 순서대로 받을 수 있는 것을 확인할 수 있다.
*/


인사말.onNext("3. 안녕하세요")

/*
 당연히 구독 시점 이후 발생한 이벤트이기때문에, buffer의 크기와 상관없이 구독한 이후에 발생한 이벤트는 무조건 나타내게 된다.
*/

print("---------------replayAll-------")
let 닥터스트레인지 = PublishSubject<String>()
let 타임스톤 = 닥터스트레인지.replayAll() // 언제든지 replay할 수 있다. 시간을 되돌릴 수 있다.
타임스톤.connect()

닥터스트레인지.onNext("도르마무")
닥터스트레인지.onNext("거래를 하러왔다.")

타임스톤
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)


/*
 replayAll에서 가늠할 수 있듯이, 타임스톤이 구독한 시점 이 전에, 발생한 어떠한 값이라도 갯수 제한없이 나타내는 것을 확인할 수 있다.
 지나간 이벤트방출에 대해서 그 이후에 구독을 하더라도 그 전의 값들을 볼 수 있는 연산자
*/

//print("---------------buffer-------")
//let source = PublishSubject<String>()
//
//var count = 0
//let timer = DispatchSource.makeTimerSource()
///*
// 타이머를 왜 만드냐면? 시간흐름에 따라서 어떠한 함수를 작동시키는 기본 Swift Foundation 안에 있는 DispatchSource라는 것을 활용해서
// 특정 시간마다 어떠한 함수를 작동시키는 것을 만들려고 한다. 타이머는 deadline과 repeating를 가지는 데, 현재 시점부터 데드라인을 해서 매번 1초마다 반복된다.
//*/
//
//timer.schedule(deadline: .now() + 2, repeating: .seconds(1))
//timer.setEventHandler {
//    count += 1
//    source.onNext("\(count)")
//}
//timer.resume()
//
//source
//    .buffer(
//        timeSpan: .seconds(2),
//        count: 2,
//        scheduler: MainScheduler.instance
//    )    
//    .subscribe(onNext: {
//        print($0)
//    })
//    .disposed(by: disposeBag)

/*
 sourceObservable은 sourceObservable의 Array에 있는 Observable 이 안에 있는 Observable들을 받는데, 여기서 count를 통해서 많아서 count만큼 받게 되는 것이다.
 즉, 최대 2개를 넘어가지않는 Array의 형태로 방출을 하게 되는 것이다. 만약에 이 많은 요소들이 timeSpan 2초간 만료되기 전에 받아졌다면, 받은 만큼은 일단 내뱉은 다음에,
 다음 요소들을 받는 것이다. 2초 내에 두 가지의 타이머에 따라서, 받는 이벤트를 받는 것이다.
 buffer연산자는 sourceObservable에서 받을 것이 없다면, 일정 간격으로, 빈 Array를 방출하게 된다. 왜?
 max에 넘어가지않으면, 계속해서 빈 Array를 방출하게 된다.
*/

//print("---------------window-------")
///*
// window는 buffer와 굉장히 비슷하다. 대충보면, 같아보이는데, 유일하게 다른 점은 buffer가 Array를 방출하는 대신에 window는 Observable을 방출한다는 것이다.
//*/
//let 만들어낼최대Observable수 = 5
//let 만들시간 = RxTimeInterval.seconds(2)
//
//let window = PublishSubject<String>()
//
//var windowCount = 0
//let windowTimerSource = DispatchSource.makeTimerSource()
//windowTimerSource.schedule(deadline: .now() + 2, repeating: .seconds(1))
//windowTimerSource.setEventHandler {
//    windowCount += 1
//    window.onNext("\(windowCount)")
//}
//windowTimerSource.resume()
//
//window
//    .window(
//        timeSpan: 만들시간,
//        count: 만들어낼최대Observable수,
//        scheduler: MainScheduler.instance
//    )
//    .flatMap { windowObservable -> Observable<(index: Int, element: String)> in
//        return windowObservable.enumerated()
//    }
//    .subscribe(onNext: {
//        print("\($0.index)번째 Observable의 요소 \($0.element)")
//    })
//    .disposed(by: disposeBag)
/*
 window 역시 Observable을 내뱉게 되는데, 최대 Observable의 수를 하나로 뒀기 때문에, 하나의 Observable수만 방출하게 된다.
 그러면, 만약에 Observable을 5개로 늘렸다고 하면, 최대 Observable을 만들 수가 5개이고, 이 요소가 방출됨에 따라서,
 요소가 방출되는 event의 간격과 우리가 설정한 만들시간과 만들어낼최대Observable수에 맞춰서 다수의 Observable들을 만들어 내게 된다.
 buffer같은 경우, 제안한 count에 따라서 Array로 묶어서 count만큼의 Array를 묶어서 내뱉어줬다면, window는 똑같이 작동은 하지만,
 return값이 Observable이라는 것에서 다르게 된다.
*/
//
//print("---------------delaySubscription-------")
///*
// 구독을 지연시키는 Operator
//*/
//let delaySource = PublishSubject<String>()
//
//var delayCount = 0
//let delayTimeSource = DispatchSource.makeTimerSource()
//delayTimeSource.schedule(deadline: .now() + 2, repeating: .seconds(1))
//delayTimeSource.setEventHandler {
//    delayCount += 1
//    delaySource.onNext("\(delayCount)")
//}
//delayTimeSource.resume()
//
//delaySource
//    .delaySubscription(.seconds(5), scheduler: MainScheduler.instance)
//    .subscribe(onNext: {
//        print($0)
//    })
//    .disposed(by: disposeBag)
/*
 delaySource라는 얘가 어떠한 이벤트를 방출시킬 것인데, 이 이벤트를 방출할 떄, 2초 정도 delay를 시키겠다. 라고 선언을 하는 것이다.
 구독을 천천히 하겠다
 delaySubscription을 하면 그 시간만큼 delay되어서 구독을 시작하는 것이다.
 delaySubscription라는 Operator는 delaySubscription라는 명칭에서도 알 수 있듯이 source가 되는 Observable이 방출하는 이벤트를 정해진, 커스텀하는 시점이
 지난 다음부터 구독을 하겠다라고 구독지연을 해주는 Operator이다.
*/

//print("---------------delay-------")
///*
// delaySubscription이 구독을 지연시켰다면, delay는 전체시퀀스를 뒤로 미루는 작업을 한다. 그래서 구독을 지연시키는 sourceObservable을 즉시, 구독은 한다.
// 하지만, 요소의 방출을 설정한 시간만큼 미루는 것이다.
//*/
//let delaySubject = PublishSubject<Int>()
//
//var delayCount = 0
//let delayTimeSource = DispatchSource.makeTimerSource()
//delayTimeSource.schedule(deadline: .now() + 2, repeating: .seconds(1))
//delayTimeSource.setEventHandler {
//    delayCount += 1
//    delaySubject.onNext(delayCount)
//}
//delayTimeSource.resume()
//
//delaySubject
//    .delay(.seconds(3), scheduler: MainScheduler.instance)
//    .subscribe(onNext: {
//        print($0)
//    })
//    .disposed(by: disposeBag)
/*
 이벤트는 계속해서 방출되고 있지만, 3초가 지난 시점부터, 실제로 구독을 하게되고, 그 시점부터 이벤트를 방출하기 때문에, 
 기존의 delaySubscription이 정상적으로 source가 되는 이벤트가 방출되지만, 구독 만을 뒤로 미룬 느낌이라면,
 delay Operator는 전체 시퀀스, 시퀀스 자체를 뒤로 미루는 TimeBasedOpertor이다.
*/

//print("---------------interval-------")
///*
// 어떠한 애플리케이션이든지, timer를 필요로 한다. 이에 ios에는 다양한 solution을 제공을 하고 있고, DispatchSource라는 것을 통해서 timer를 만들 수도 있다.
// 통상적으로 커스텀한 타이머를 통해서, 타이머 역할을 하는 작업을 수행했지만, 적절한 사용이 어렵다.
// 좀 더 최근에는 Dispatch Framework가 DispatchSource를 통해서 timer를 제공했다. 기존에는 NSTimer보다 나은 솔루션이지만, API는 EventHandler라는 맵핑없이는 복잡하게 된다.
// 이러한 역할을 할 수 있는 간단한 솔루션이 타이머 관련된 interval Operator이다.
//*/
//Observable<Int>
//    .interval(.seconds(3), scheduler: MainScheduler.instance)
//    .subscribe(onNext: {
//        print($0)
//    })
//    .disposed(by: disposeBag)
/*
 interval이 3초 간격으로 Int 해당하는 값을 순차적으로 내뱉는 것을 알 수 있다. 놀랍게도, Observable은 of나 from이나 어떠한 형태의 생성자도 사용하지 않았다.
 그럼에도 불구하고 Int타입 만을 이용해서, interval이라는 Operator와 타입추론을 통해서, 0부터 초기값을 가지는 일련의 element들을 3초간격으로 내뱉어주는 것이다.
 3초 간격으로 어떻게 카운트를 올리면서, 이벤트를 방출해달라고 했던 것을 interval이라는 것으로 바로 만들어낼 수 있는 것이다.
*/

//print("---------------timer-------")
///*
// 특정 간격으로 생성해주는 interval이 있다면, timer도 있다. timer는 interval보다 좀 더 강력한 형태이다. 앞서 사용한 interval과 유사하지만, 두 가지 차이점이 있다.
// 구독과 첫 번째 값을 방출하는 사이에, 마감일을 설정할 수 있다. 반복할 수 있는 기간이 Optional이다. 만약에 반복을 설정하지 않으면, timer Oberservable은 한번만 방출되고,
// 완료가 된다.
//*/
//Observable<Int>
//    .timer(
//        .seconds(5),
//        period: .seconds(2),
//        scheduler: MainScheduler.instance
//    )
//    .subscribe(onNext: {
//        print($0)
//    })
//    .disposed(by: disposeBag)
/*
 5초가 지난 뒤에 2초 간격으로 이벤트를 방출하는 것을 확인할 수 있다. duetime이라는 것은 timer가 마감되는 시간을 의미하는 것이 아니라,
 구독한 이후, 구독하고 나서, 첫번째값 사이에 duetime을 의미한다. 따라서 이 간격을 줄이면 구독한 시점부터, 1초의 간격 만을 갖고, 바로 내보내게 된다.
 이렇게 다른 timer를 트리거하게되는 timer가 어떻게 하면 이점이 있을까?
 번잡하게 count를 따로 정한 다음에, 하나씩 더해주고, 어떠한 이벤트핸들러를 따로주고, 실행하는 코드 따로주고, 일련의 타이머코드를 작성하는 것보다,
 훨씬 직관적이다. 어떤 interval을 가져라, 어떤 timer를 설정한다.라고 했을 때, 직관적이다.
*/

print("---------------timeOut-------")
let 누르지않으면에러 = UIButton(type: .system)
누르지않으면에러.setTitle("눌러주세요!", for: .normal)
누르지않으면에러.sizeToFit()

PlaygroundPage.current.liveView = 누르지않으면에러

/*
 do연산자를 사용하면, 전체적인 Observable stream에 아무런 영향을 주지않고, 이 과정에서 지나가는 이벤트들을 볼 수 있게 할 수 있다.
*/

누르지않으면에러.rx.tap
    .do(onNext: {
        print($0)
    })
    .timeout(.seconds(5), scheduler: MainScheduler.instance)
    .subscribe {
        print($0)
    }
    .disposed(by: disposeBag)
/*
 .timeout Operator의 주된 목적은 시간초과 우리가 정해진 이 시간을 초과하게 된다면, 에러를 발생시키고, 전체 Observable을 종료시켜버린다.
 따라서 timeOut연산자가 실행되면, 이 시간 내에 어떠한 이벤트도 방출하지않았을 때, 시퀀스 타임아웃이라는 rx에러를 방출하게 된다. 따라서 지금까지,
 5초가 지났음에도 불구하고, 계속 새로운 이벤트가 발생하면 상관없다. 하지만, 아무런 이벤트가 발생하지않은 채로, 5초가 지나버리면, .timeout에러가 발생하게 되는 것이다.
*/
