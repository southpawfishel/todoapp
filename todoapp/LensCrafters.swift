//
//  LensCrafters.swift
//  todoapp
//
//  Created by Dave Fishel on 4/7/19.
//  Copyright © 2019 Dave Fishel. All rights reserved.
//

import Foundation

public struct Lens<ParentType, ChildType> {
    public let get: (ParentType) -> ChildType
    public let set: (ParentType, ChildType) -> ParentType
}

public struct KeyLens<KeyType, ValueType> where KeyType: Hashable {
    public typealias ParentType = [KeyType: ValueType]
    
    public static func forKey(_ key: KeyType) -> Lens<ParentType, ValueType> {
        let lens = Lens<ParentType, ValueType>(
            get: { $0[key]! },
            set: { (dict, value) in
                var newDict = dict
                newDict[key] = value
                return newDict
            }
        )
        return lens
    }
}

public struct IndexLens<ValueType> {
    public typealias ArrayType = [ValueType]
    
    public static func forIndex(_ index: Int) -> Lens<ArrayType, ValueType> {
        let lens = Lens<ArrayType, ValueType>(
            get: { $0[index] },
            set: { (arr, value) in arr.enumerated().map{ (i, element) in index == i ? value : element } }
        )
        return lens
    }
}

// To use KVCLens, your object must be key-value-coding compliant, which means
// it must be exposed to objc and it also needs to be copyable since its not a
// value type
public struct KVCLens<ParentType, ChildType> where ParentType: NSObject, ParentType: NSCopying {
    public static func forProperty(named: String) -> Lens<ParentType, ChildType> {
        let lens = Lens<ParentType, ChildType>(
            get: { parent in
                guard let child:ChildType = parent.value(forKey: named) as? ChildType else {
                    fatalError("\(ParentType.self) has no property named \(named)")
                }
                return child
            },
            set: { parent, value in
                let newParent = parent.copy() as! ParentType
                newParent.setValue(value, forKey: named)
                return newParent
            }
        )
        return lens
    }
}

func * <ParentType, MiddleType, ChildType>(lhs: Lens<ParentType, MiddleType>, rhs: Lens<MiddleType, ChildType>) -> Lens<ParentType, ChildType> {
    
    return Lens(
        get: { parent in
            let middle = lhs.get(parent)
            let child = rhs.get(middle)
            return child
        },
        set: { (parent, child) in
            let middle = lhs.get(parent)
            let updatedMiddle = rhs.set(middle, child)
            return lhs.set(parent, updatedMiddle)
        }
    )
}

func lensGet<P, C>(lens: Lens<P, C>, parent: P) -> C {
    return lens.get(parent)
}

func lensSet<P, C>(lens: Lens<P, C>, parent: P, child: C) -> P {
    return lens.set(parent, child)
}

func lensOver<P, C>(lens: Lens<P, C>, parent: P, mapFunc: (C) -> C) -> P {
    return lens.set(parent, mapFunc(lens.get(parent)))
}
