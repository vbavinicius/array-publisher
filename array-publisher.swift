import Combine

extension Publishers {
    struct _Array<Element>: Publisher {
        typealias Output = Element
        typealias Failure = Never
        
        private let value: [Element]
        
        init(_ value: [Element]) {
            self.value = value
        }
        
        func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Element == S.Input {
            let subscription = ArraySubscription(subscriber)
            subscriber.receive(subscription: subscription)
            
            subscription.value = value
        }
    }
}

extension Publishers._Array {
    private class ArraySubscription<Element, S: Subscriber>: Subscription where S.Input == Element {
        var subscriber: S?
        var value: [Element] = [] {
            didSet {
                value.forEach { _ = subscriber?.receive($0) }
                _ = subscriber?.receive(completion: .finished)
            }
        }

        init(_ subscriber: S) {
            self.subscriber = subscriber
        }

        func request(_ demand: Subscribers.Demand) {}
        
        func cancel() { subscriber = nil }
    }
}

extension Array {
    func publisher() -> AnyPublisher<Element, Never> {
        Publishers
            ._Array(self)
            .eraseToAnyPublisher()
    }
}

_ = [1, 2, 3].publisher.collect().sink { print($0) } // [1, 2, 3] and complete
_ = ["A", "B", "C"].publisher.sink { print($0) } // A\nB\n\C and complete
