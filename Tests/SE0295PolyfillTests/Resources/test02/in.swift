enum Command: Codable {
  case load(String)
  case store(key: String, Int)
}
