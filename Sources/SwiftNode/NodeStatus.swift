import CNodeAPI

extension napi_status {
    var status: NodeStatus {
        .init(rawValue: self.rawValue) ?? .invalidArg
    }
}

enum NodeStatus: UInt32 {
    var nativeStatus: napi_status {
        .init(self.rawValue)
    }
    case ok
    case invalidArg
    case objectExpected
    case stringExpected
    case nameExpected
    case functionExpected
    case numberExpected
    case booleanExpected
    case arrayExpected
    case genericFailure
    case pendingException
    case cancelled
    case escapeCalledTwice
    case handleScopeMismatch
    case callbackScopeMismatch
    case queueFull
    case closing
    case bigintExpected
    case dateExpected
    case arraybufferExpected
    case detachableArraybufferExpected
    case wouldDeadlock  // unused
    case noExternalBuffersAllowed
    case cannotRunJs
}
