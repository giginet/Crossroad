import Foundation

extension Collection where Element == String {
    func droppedSlashElement() -> [String] {
        filter { $0 != "/" }
    }
}

extension Collection where Element == String.SubSequence {
    func droppedSlashElement() -> [String] {
        map(String.init).filter { $0 != "/" }
    }
}
