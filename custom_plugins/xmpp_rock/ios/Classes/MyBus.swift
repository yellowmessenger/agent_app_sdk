
import Foundation

public class MyBus{
    static let shared = MyBus()
    private var bus: RxBus
    
    init(){
        bus = RxBus();
    }
    
    
    public func myBus() -> RxBus{
        return bus
    }
    
}
