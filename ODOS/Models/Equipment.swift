import Foundation

enum Equipment: String, CaseIterable {
    case all = "All"
    case bodyweight = "Bodyweight"
    case dumbbell = "Dumbbell"
    case barbell = "Barbell"
    case machine = "Machine"
    case cable = "Cable"
    case kettlebell = "Kettlebell"
    case bands = "Resistance Bands"
    
    static func match(_ equipmentString: String?) -> Equipment {
        guard let equipmentString = equipmentString?.lowercased() else {
            return .bodyweight
        }
        
        switch equipmentString {
        case let str where str.contains("dumbbell"):
            return .dumbbell
        case let str where str.contains("barbell"):
            return .barbell
        case let str where str.contains("machine"):
            return .machine
        case let str where str.contains("cable"):
            return .cable
        case let str where str.contains("kettlebell"):
            return .kettlebell
        case let str where str.contains("band"):
            return .bands
        default:
            return .bodyweight
        }
    }
} 