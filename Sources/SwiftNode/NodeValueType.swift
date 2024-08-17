import CNodeAPI

extension napi_valuetype {
    var valueType: NodeValueType {
        NodeValueType(rawValue: self.rawValue) ?? .undefined
    }
}

enum NodeValueType: UInt32 {
    typealias RawValue = UInt32
    case undefined
    case null
    case boolean
    case number
    case string
    case symbol
    case object
    case function
    case external
    case bigint

    static func convenienceInit(_ nativeValue: napi_valuetype) -> NodeValueType {
        NodeValueType(rawValue: nativeValue.rawValue) ?? .undefined
    }
}
