import CNodeAPI

enum NodeError: Error {
    case msg(String)
    case status(napi_status)
}
