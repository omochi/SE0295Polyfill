enum Command: Codable {
    case load(key: String)
    case store(key: String, value: Int)
}
