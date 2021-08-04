import Foundation

let fm = FileManager.default

extension FileManager {
    func withCurrentDirectory<R>(_ dir: URL, _ f: () throws -> R) rethrows -> R {
        let oldDir = currentDirectoryPath
        changeCurrentDirectoryPath(dir.path)
        defer {
            changeCurrentDirectoryPath(oldDir)
        }
        return try f()
    }
}

func createTempDir() throws -> URL {
    let name = String(
        format: "%0x%0x",
        Int.random(in: 0...Int.max),
        Int.random(in: 0...Int.max)
    )
    let path = fm.temporaryDirectory
        .appendingPathComponent(name)
    try fm.createDirectory(at: path, withIntermediateDirectories: false)
    return path
}

struct ProcessError: Error {
    var stdError: String
}
