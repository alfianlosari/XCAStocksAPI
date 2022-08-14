//  Created by Alfian Losari on 13/08/22.

import Foundation
import XCAStocksAPI

@main
struct XCAStocksExec {
    
    private static let api = XCAStocksAPI()
    static func main() async {
        do {
            // Fetch AAPL stocks last 1 day
            let apple1dChart = try await api
                .fetchChartData(tickerSymbol: "AAPL", range: .oneDay)

            print(apple1dChart ?? "Not Found")
            
            // Search Ticker using "TESLA" as Query
            let tickers = try await api
                .searchTicker(query: "TESLA")
            print(tickers)
            
            // Fetch Quote Detail for multiple symbols
            // AAPL, TSLA, GOOG, MSFT
            let quotes = try await api
                .fetchQuotes(symbols: "AAPL,TSLA,GOOG,MSFT")
            print(quotes)
            
        } catch {
            print(error.localizedDescription)
        }
    }
}
