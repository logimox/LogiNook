// SPDX-License-Identifier: Apache-2.0

import Foundation

public struct WeatherSnapshot: Equatable, Sendable {
    public let temperatureCelsius: String
    public let summary: String
    public init(temperatureCelsius: String, summary: String) {
        self.temperatureCelsius = temperatureCelsius
        self.summary = summary
    }
}

@MainActor
public final class WeatherClient: ObservableObject {
    @Published public private(set) var snapshot: WeatherSnapshot?
    @Published public private(set) var errorMessage: String?

    public init() {}

    public func refresh(city: String) {
        let cleanCity = city.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanCity.isEmpty else { errorMessage = "Enter a city"; return }
        let escaped = cleanCity.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? cleanCity
        guard let url = URL(string: "https://wttr.in/\(escaped)?format=j1") else { return }
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let result = try JSONDecoder().decode(WTTRResponse.self, from: data)
                guard let current = result.currentCondition.first, let description = current.weatherDescription.first?.value else { return }
                snapshot = WeatherSnapshot(temperatureCelsius: current.temperatureCelsius, summary: description)
                errorMessage = nil
            } catch {
                errorMessage = "Could not load weather"
            }
        }
    }
}

private struct WTTRResponse: Decodable {
    let currentCondition: [Current]
    enum CodingKeys: String, CodingKey { case currentCondition = "current_condition" }
    struct Current: Decodable {
        let temperatureCelsius: String
        let weatherDescription: [Description]
        enum CodingKeys: String, CodingKey { case temperatureCelsius = "temp_C"; case weatherDescription = "weatherDesc" }
    }
    struct Description: Decodable { let value: String }
}
