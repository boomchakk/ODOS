import Foundation

enum MuscleGroup: String, CaseIterable {
    case all = "All"
    case chest = "Chest"
    case upperBack = "Upper Back"
    case lowerBack = "Lower Back"
    case shoulders = "Shoulders"
    case biceps = "Biceps"
    case triceps = "Triceps"
    case forearms = "Forearms"
    case quads = "Quadriceps"
    case hamstrings = "Hamstrings"
    case calves = "Calves"
    case abs = "Abs"
    case obliques = "Obliques"
    
    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .chest: return "heart.fill"
        case .upperBack: return "arrow.up.to.line"
        case .lowerBack: return "arrow.down.to.line"
        case .shoulders: return "circle.grid.cross"
        case .biceps: return "arrow.up.forward"
        case .triceps: return "arrow.down.forward"
        case .forearms: return "hand.raised"
        case .quads: return "arrow.down.right"
        case .hamstrings: return "arrow.up.right"
        case .calves: return "arrow.down"
        case .abs: return "square.grid.3x3"
        case .obliques: return "square.grid.3x3.middle"
        }
    }
    
    func muscles() -> [String] {
        switch self {
        case .all:
            return []
        case .chest:
            return ["chest"]
        case .upperBack:
            return ["lats", "traps"]
        case .lowerBack:
            return ["lower_back"]
        case .shoulders:
            return ["shoulders", "delts"]
        case .biceps:
            return ["biceps"]
        case .triceps:
            return ["triceps"]
        case .forearms:
            return ["forearms"]
        case .quads:
            return ["quadriceps"]
        case .hamstrings:
            return ["hamstrings", "glutes"]
        case .calves:
            return ["calves"]
        case .abs:
            return ["abdominals"]
        case .obliques:
            return ["abductors", "adductors"]
        }
    }
} 