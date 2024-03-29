//
//  Interface.swift
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

/// A Convenience `protocol` to make the intent explicit that conforming `Type`s will be used as an `InjectableService`
/// Conformance to this `protocol` is not necessary for registration as an `InjectableService`. However it is necessary to
/// conform to some protocol. This empty protocol is available as a convenience for that purpose.
public protocol InjectableService { }

@propertyWrapper
public struct Injected<T> {
    
    public var wrappedValue: T { InjectableServices.resolve() }
    
    public init() {}
}

@propertyWrapper
public struct ScopedInjection<T> {
    
    public var wrappedValue: T { InjectableServices.storedResolve() }
    
    public init() {}
    
}

public typealias ServiceBuilder<Service> = () -> Service

public struct InjectableServices {
    
    public static func register<T>(service: T.Type, _ builder: @autoclosure @escaping ServiceBuilder<T>) {
        Services.root.register(builder)
    }
    
    public static func resolve<T>() -> T {
        Services.root.resolve()
    }
    
    public static func storedResolve<T>() -> T {
        guard let storedService = Services.root.getService(T.self) else {
            let resolvedService: T = Services.root.resolve()
            Services.root.storeService(resolvedService)
            return resolvedService
        }
        return storedService
    }
    
    public static func token<T>(for serviceType: T.Type) -> InjectableToken<T> {
        InjectableToken<T>()
    }
    
}

public final class InjectableToken<T> {
    
    public func removeService() { Services.root.removeService(T.self) }
    
    deinit { removeService() }
    
}
