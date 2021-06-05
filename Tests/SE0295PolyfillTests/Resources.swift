import Foundation

enum Resources {
    static var file: URL {
        URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .appendingPathComponent("Resources")
    }
}
