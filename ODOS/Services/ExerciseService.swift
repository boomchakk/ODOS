import Foundation
import os.log

class ExerciseService {
    static let shared = ExerciseService()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "ODOS", category: "ExerciseService")
    private let baseURL = "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/dist"
    
    private init() {}
    
    func fetchExercises() async throws -> [DatabaseExercise] {
        let urlString = "\(baseURL)/exercises.json"
        logger.debug("Fetching exercises from: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            logger.error("Invalid URL: \(urlString)")
            throw NSError(domain: "ExerciseService", code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("Invalid response type")
                throw NSError(domain: "ExerciseService", code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Invalid response type"])
            }
            
            logger.debug("Response status code: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode != 200 {
                logger.error("Server returned status code \(httpResponse.statusCode)")
                throw NSError(domain: "ExerciseService", code: httpResponse.statusCode,
                            userInfo: [NSLocalizedDescriptionKey: "Server returned status code \(httpResponse.statusCode)"])
            }
            
            if let dataString = String(data: data.prefix(200), encoding: .utf8) {
                logger.debug("First 200 characters of response: \(dataString)")
            }
            
            let exercises = try JSONDecoder().decode([DatabaseExercise].self, from: data)
            logger.debug("Successfully decoded \(exercises.count) exercises")
            return exercises
            
        } catch {
            logger.error("Error fetching exercises: \(error.localizedDescription)")
            throw error
        }
    }
    
    func fetchExerciseImageURLs(for exercise: DatabaseExercise) -> [URL]? {
        return exercise.images?.compactMap { imagePath in
            URL(string: "\(baseURL)/\(imagePath)")
        }
    }
} 