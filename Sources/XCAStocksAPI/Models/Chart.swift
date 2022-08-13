//  Created by Alfian Losari on 13/08/22.
//

import Foundation

public struct ChartResponse: Decodable {
    
    let data: [ChartData]?
    let error: ErrorResponse?
    
    enum RootKeys: String, CodingKey {
        case chart
    }
    
    enum ChartKeys: String, CodingKey {
        case result
        case error
    }
    
    public init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: RootKeys.self)
        if let chartContainer = try? rootContainer.nestedContainer(keyedBy: ChartKeys.self, forKey: .chart) {
            data = try chartContainer.decodeIfPresent([ChartData].self, forKey: .result)
            error = try chartContainer.decodeIfPresent(ErrorResponse.self, forKey: .error)
        } else {
            data = nil
            error = nil
        }
    }
    
}

public struct ChartData: Decodable {
    
    public let metadata: Metadata
    public let indicators: [Indicator]    
    
    public struct Metadata: Decodable {
        
        public let currency: String
        public let symbol: String
        public let regularMarketPrice: Double?
        public let previousClose: Double?
        public let gmtOffset: Int
        
        public let regularTradingPeriodStartDate: Date
        public let regularTradingPeriodEndDate: Date
        
        enum RootKeys: String, CodingKey {
            case currency
            case symbol
            case regularMarketPrice
            case currentTradingPeriod
            case previousClose
            case gmtOffset = "gmtoffset"
        }
        
        enum RootTradingPeriodKeys: String, CodingKey {
            case pre
            case regular
            case post
        }
        
        enum TradingPeriodKeys: String, CodingKey {
            case start
            case end
        }
        
        enum CodingKeys: CodingKey {
            case currency
            case symbol
            case regularMarketPrice
            case previousClose
            case gmtoffset
            case regularTradingPeriodStartDate
            case regularTradingPeriodEndDate
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: RootKeys.self)
            self.currency = try container.decodeIfPresent(String.self, forKey: .currency) ?? ""
            self.symbol = try container.decodeIfPresent(String.self, forKey: .symbol) ?? ""
            self.regularMarketPrice = try container.decodeIfPresent(Double.self, forKey: .regularMarketPrice)
            self.previousClose = try container.decodeIfPresent(Double.self, forKey: .previousClose)
            self.gmtOffset = try container.decodeIfPresent(Int.self, forKey: .gmtOffset) ?? 0
            
            let rootTradingPeriodContainer = try? container.nestedContainer(keyedBy: RootTradingPeriodKeys.self, forKey: .currentTradingPeriod)
            let regularTradingPeriodContainer = try? rootTradingPeriodContainer?.nestedContainer(keyedBy: TradingPeriodKeys.self, forKey: .regular)
            self.regularTradingPeriodStartDate = try regularTradingPeriodContainer?.decode(Date.self, forKey: .start) ?? Date()
            self.regularTradingPeriodEndDate = try regularTradingPeriodContainer?.decode(Date.self, forKey: .end) ?? Date()
        }
    }
    
    public struct Indicator: Decodable {
        public let timestamp: Date
        public let open: Double
        public let high: Double
        public let low: Double
        public let close: Double
    }
    
    enum RootKeys: String, CodingKey {
        case meta
        case timestamp
        case indicators
    }
    
    enum IndicatorsKeys: String, CodingKey {
        case quote
    }
    
    enum QuoteKeys: String, CodingKey {
        case high
        case close
        case low
        case open
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKeys.self)
        metadata = try container.decode(Metadata.self, forKey: .meta)
        
        let timestamps = try container.decodeIfPresent([Date].self, forKey: .timestamp) ?? []
        if let indicatorContainer = try? container.nestedContainer(keyedBy: IndicatorsKeys.self, forKey: .indicators),
           var quotes = try? indicatorContainer.nestedUnkeyedContainer(forKey: .quote),
           let quoteContainer = try? quotes.nestedContainer(keyedBy: QuoteKeys.self) {
            
            let highs = try quoteContainer.decodeIfPresent([Double?].self, forKey: .high) ?? []
            let lows = try quoteContainer.decodeIfPresent([Double?].self, forKey: .low) ?? []
            let opens = try quoteContainer.decodeIfPresent([Double?].self, forKey: .open) ?? []
            let closes = try quoteContainer.decodeIfPresent([Double?].self, forKey: .close) ?? []
            
            indicators = timestamps.enumerated().compactMap { (offset, timestamp) in
                guard
                    let open = opens[offset],
                    let low = lows[offset],
                    let close = closes[offset],
                    let high = highs[offset]
                else { return nil}
                return .init(timestamp: timestamp, open: open, high: high, low: low, close: close)
            }
        } else {
            self.indicators = []
        }
    }
}
