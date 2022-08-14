//  Created by Alfian Losari on 13/08/22.
//

import Foundation

public struct QuoteResponse: Decodable {
    
    public let data: [Quote]?
    public let error: ErrorResponse?
    
    enum RootKeys: String, CodingKey {
        case quoteResponse
    }
    
    enum QuoteResponseKeys: String, CodingKey {
        case result
        case error
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKeys.self)
        if let quoteResponseContainer = try? container.nestedContainer(keyedBy: QuoteResponseKeys.self, forKey: .quoteResponse) {
            self.data = try quoteResponseContainer.decodeIfPresent([Quote].self, forKey: .result)
            self.error = try quoteResponseContainer.decodeIfPresent(ErrorResponse.self, forKey: .error)
        } else {
            self.data = nil
            self.error = nil
        }
    }
}

public struct Quote: Decodable {
    
    public let regularMarketPrice: Double?
    public let regularMarketChange: Double?
    
    public let postMarketPrice: Double?
    public let postMarketChange: Double?
    
    public let regularMarketOpen: Double?
    public let regularMarketDayHigh: Double?
    public let regularMarketDayLow: Double?
    
    public let regularMarketVolume: Double?
    public let trailingPE: Double?
    public let marketCap: Double?
    
    public let fiftyTwoWeekLow: Double?
    public let fiftyTwoWeekHigh: Double?
    public let averageDailyVolume3Month: Double?
    
    public let trailingAnnualDividendYield: Double?
    public let epsTrailingTwelveMonths: Double?
    
}
