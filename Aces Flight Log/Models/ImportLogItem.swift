import Foundation

struct ImportLogItem: Codable, Identifiable {
    let id: String
    let dof: TimeInterval
    let acft: String
    let duty: String
    let condition: String
    let seat: String
    let hours: Double
    let createdDate: TimeInterval
    let comments: String
}
