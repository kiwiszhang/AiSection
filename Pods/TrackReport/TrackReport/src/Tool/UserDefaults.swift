//
//  UserDefaults.swift
//  collage
//
//  Created by 笔尚文化 on 2025/1/11.
//

import Foundation

private protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    var isNil: Bool { self == nil }
}

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T
    let storage: UserDefaults
    
    init(_ key: String, defaultValue: T, storage: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.storage = storage
    }
    
    var wrappedValue: T {
        get {
            // 如果键不存在，返回默认值
            if !storage.contains(key) {
                return defaultValue
            }
            
            // 根据类型使用对应的获取方法
            switch T.self {
            case is Bool.Type:
                return storage.bool(forKey: key) as! T
            case is Int.Type:
                return storage.integer(forKey: key) as! T
            case is Double.Type:
                return storage.double(forKey: key) as! T
            case is Float.Type:
                return storage.float(forKey: key) as! T
            case is String.Type:
                return storage.string(forKey: key) as? T ?? defaultValue
            case is Date.Type:
                return storage.object(forKey: key) as? T ?? defaultValue
            case is Data.Type:
                return storage.data(forKey: key) as? T ?? defaultValue
            case is Array<Any>.Type:
                return storage.array(forKey: key) as? T ?? defaultValue
            case is Dictionary<String, Any>.Type:
                return storage.dictionary(forKey: key) as? T ?? defaultValue
            default:
                return storage.object(forKey: key) as? T ?? defaultValue
            }
        }
        set {
            if let optional = newValue as? AnyOptional, optional.isNil {
                storage.removeObject(forKey: key)
            } else {
                storage.set(newValue, forKey: key)
            }
        }
    }
}

// 扩展 UserDefaults 添加 contains 方法
extension UserDefaults {
    func contains(_ key: String) -> Bool {
        return object(forKey: key) != nil
    }
}

extension UserDefault where T: ExpressibleByNilLiteral {
    init(_ key: String, storage: UserDefaults = .standard) {
        self.init(key, defaultValue: nil, storage: storage)
    }
}

// 定义可以存储在 UserDefaults 中的类型
protocol PropertyListValue {}

extension Data: PropertyListValue {}
extension String: PropertyListValue {}
extension Date: PropertyListValue {}
extension Bool: PropertyListValue {}
extension Int: PropertyListValue {}
extension Double: PropertyListValue {}
extension Float: PropertyListValue {}
extension Array: PropertyListValue where Element: PropertyListValue {}
extension Dictionary: PropertyListValue where Key == String, Value: PropertyListValue {}

// 支持 Codable 类型
extension UserDefault where T: Codable {
    init(_ key: String, defaultValue: T, storage: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.storage = storage
    }
    
    var wrappedValue: T {
        get {
            guard let data = storage.data(forKey: key) else { return defaultValue }
            return (try? JSONDecoder().decode(T.self, from: data)) ?? defaultValue
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            storage.set(data, forKey: key)
        }
    }
}
