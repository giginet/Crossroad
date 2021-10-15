import Foundation

extension Collection where Element == String {
    func droppedSlashElement() -> [String] {
        filter { $0 != "/" }
    }
}
