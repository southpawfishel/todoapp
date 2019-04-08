//
//  LensCrafters.swift
//  todoapp
//
//  Created by Dave Fishel on 4/7/19.
//  Copyright © 2019 Dave Fishel. All rights reserved.
//

public struct Lens<ParentType, ChildType> {
    public let get: (ParentType) -> ChildType
    public let set: (ParentType, ChildType) -> ParentType
}

public struct KeyLens<KeyType, ValueType> where KeyType: Hashable {
    public typealias ParentType = [KeyType: ValueType]
    
    public static func ForKey(_ key: KeyType) -> Lens<ParentType, ValueType> {
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
    
    public static func ForIndex(_ index: Int) -> Lens<ArrayType, ValueType> {
        let lens = Lens<ArrayType, ValueType>(
            get: { $0[index] },
            set: { (arr, value) in arr.enumerated().map{ (i, element) in index == i ? value : element } }
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
