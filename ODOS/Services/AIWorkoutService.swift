import Foundation

struct WorkoutRequest {
    let type: String
    let equipment: [String]
    let experienceLevel: String
    let duration: Int // in minutes
}

struct ExerciseRecommendation: Codable {
    let name: String
    let sets: Int
    let repsRange: String
    let muscleGroup: String
    let notes: String?
}

actor AIWorkoutService {
    static let shared = AIWorkoutService()
    private var apiKey: String = "" // Store this securely in production
    
    private init() {}
    
    func generateWorkout(request: WorkoutRequest) async throws -> [ExerciseRecommendation] {
        let prompt = """
        Generate a detailed \(request.type) workout plan with the following criteria:
        - Duration: \(request.duration) minutes
        - Equipment available: \(request.equipment.joined(separator: ", "))
        - Experience level: \(request.experienceLevel)
        
        For a \(request.type) workout, include exercises for all relevant muscle groups with appropriate volume and intensity.
        Format the response as a JSON array with each exercise containing:
        - name: exercise name
        - sets: number of sets
        - repsRange: rep range (e.g., "8-12")
        - muscleGroup: primary muscle group
        - notes: any special instructions or tips
        
        Ensure exercises are balanced across muscle groups and follow proper workout structure.
        """
        
        let messages: [[String: Any]] = [
            ["role": "system", "content": "You are a professional fitness coach specializing in workout program design."],
            ["role": "user", "content": prompt]
        ]
        
        let parameters: [String: Any] = [
            "model": "gpt-4",
            "messages": messages,
            "temperature": 0.7,
            "max_tokens": 1000
        ]
        
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let result = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        guard let content = result.choices.first?.message.content,
              let jsonData = content.data(using: .utf8) else {
            throw URLError(.badServerResponse)
        }
        
        let recommendations = try JSONDecoder().decode([ExerciseRecommendation].self, from: jsonData)
        return recommendations
    }
}

// OpenAI API Response structures
private struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let content: String
    }
} 