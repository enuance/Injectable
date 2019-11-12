//
//  Injectable.swift
//  Injectable
//
//  MIT License
//
//  Copyright (c) 2019 STEPHEN L. MARTINEZ
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


import Foundation

struct FatalInjectable {
    
    private static let tag = "Injectable Error: "
    
    static func serviceNotRegistered<T>(_ :T.Type) -> Never {
        let errorMessage = "\(T.self) was never registered!"
        return fatalError(tag + errorMessage)
    }
    
    static func serviceNotProtocol<T>(_ :T.Type) -> Never {
        let errorMessage = "\(T.self) is not a protocol! Services must be a protocol."
        return fatalError(tag + errorMessage)
    }
    
}

final class Services {
    
    private init() {}
    
    static let root = Services()
    
    private typealias AnyServiceBuilder = () -> Any
    
    private var builders = [ServiceIdentifier: AnyServiceBuilder]()
    private var serviceStorage = [ServiceIdentifier: Any]()
    
    func register<T>(_ serviceBuilder: @escaping () -> T) {
        
        guard isProtocol(type: T.self) else {
            FatalInjectable.serviceNotProtocol(T.self)
        }
        
        builders[identifier(for: T.self)] = serviceBuilder
    }
    
    func resolve<T>() -> T {
        
        guard isProtocol(type: T.self) else {
            FatalInjectable.serviceNotProtocol(T.self)
        }
        
        let serviceBuilder = builders[identifier(for: T.self)]
        let extractedService = serviceBuilder?() as? T
        
        guard let service = extractedService else {
            FatalInjectable.serviceNotRegistered(T.self)
        }
        
        return service
    }
    
    func getService<T>(_ serviceType: T.Type) -> T? {
        
        guard
            let anyService = serviceStorage[identifier(for: T.self)]
            let storedService = anyService as? T
            else { return nil }
        
        return storedService
    }
    
    func storeService<T>(_ service: T) {
        serviceStorage[identifier(for: T.self)] = service
    }
    
    func removeService<T>(_ serviceType: T.Type) {
        serviceStorage[identifier(for: T.self)] = nil
    }
    
}
