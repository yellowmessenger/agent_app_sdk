import Foundation
import RxSwift

public final class RxBus {
    var bus = PublishSubject<String>()
    
    public func send(s: String) -> Void{
        bus.onNext(s)
    }
    public func toObservable() -> Observable<String>{
        return bus
    }
    public func hasObservers() -> Bool{
        return bus.hasObservers
    }
}
