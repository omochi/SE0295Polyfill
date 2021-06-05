import Foundation

extension URL {
    static var resources: URL {
        URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .appendingPathComponent("Resources")
    }
}
