//  Created by Alfian Losari on 13/08/22.
//

import Foundation

public protocol IStocksAPI {
    func fetchChartData(tickerSymbol: String, range: ChartRange) async throws -> ChartData?
    func fetchChartRawData(symbol: String, range: ChartRange) async throws -> (Data, URLResponse)
    func searchTickers(query: String, isEquityTypeOnly: Bool) async throws -> [Ticker]
    func searchTickersRawData(query: String, isEquityTypeOnly: Bool) async throws -> (Data, URLResponse)
    func fetchQuotes(symbols: String) async throws -> [Quote]
    func fetchQuotesRawData(symbols: String) async throws -> (Data, URLResponse)
}

public struct XCAStocksAPI: IStocksAPI {
    private let session = URLSession.shared
    private let jsonDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }()
    
    public init() {}
    
    private let baseURL = "https://query1.finance.yahoo.com"
    public func fetchChartData(tickerSymbol: String, range: ChartRange) async throws -> ChartData? {
        guard let url = urlForChartData(symbol: tickerSymbol, range: range) else { throw APIServiceError.invalidURL }
        let (resp, statusCode): (ChartResponse, Int) = try await fetch(url: url)
        if let error = resp.error {
            throw APIServiceError.httpStatusCodeFailed(statusCode: statusCode, error: error)
        }
        return resp.data?.first
    }
    
    public func fetchChartRawData(symbol: String, range: ChartRange) async throws -> (Data, URLResponse) {
        guard let url = urlForChartData(symbol: symbol, range: range) else { throw APIServiceError.invalidURL }
        return try await session.data(from: url)
    }
    
    private func urlForChartData(symbol: String, range: ChartRange) -> URL? {
        guard var urlComp = URLComponents(string: "\(baseURL)/v8/finance/chart/\(symbol)") else {
            return nil
        }
        
        urlComp.queryItems = [
            URLQueryItem(name: "range", value: range.rawValue),
            URLQueryItem(name: "interval", value: range.interval),
            URLQueryItem(name: "indicators", value: "quote"),
            URLQueryItem(name: "includeTimestamps", value: "true")
        ]
        return urlComp.url
    }
    
    public func searchTickers(query: String, isEquityTypeOnly: Bool = true) async throws -> [Ticker] {
        guard let url = urlForSearchTickers(query: query) else { throw APIServiceError.invalidURL }
        let (resp, statusCode): (SearchTickersResponse, Int) = try await fetch(url: url)
        if let error = resp.error {
            throw APIServiceError.httpStatusCodeFailed(statusCode: statusCode, error: error)
        }
        let data = resp.data ?? []
        if isEquityTypeOnly {
            return data.filter { ($0.quoteType ?? "").localizedCaseInsensitiveCompare("equity") == .orderedSame }
        } else {
            return data
        }
    }
    
    public func searchTickersRawData(query: String, isEquityTypeOnly: Bool) async throws -> (Data, URLResponse) {
        guard let url = urlForSearchTickers(query: query) else { throw APIServiceError.invalidURL }
        return try await session.data(from: url)
    }
    
    private func urlForSearchTickers(query: String) -> URL? {
        guard var urlComp = URLComponents(string: "\(baseURL)/v1/finance/search") else {
            return nil
        }
        
        urlComp.queryItems = [
            URLQueryItem(name: "lang", value: "en-US"),
            URLQueryItem(name: "quotesCount", value: "20"),
            URLQueryItem(name: "q", value: query)
        ]
        return urlComp.url
    }
    
    public func fetchQuotes(symbols: String) async throws -> [Quote] {
        guard let url = urlForFetchQuotes(symbols: symbols) else { throw APIServiceError.invalidURL }
        let (resp, statusCode): (QuoteResponse, Int) = try await fetch(url: url)
        if let error = resp.error {
            throw APIServiceError.httpStatusCodeFailed(statusCode: statusCode, error: error)
        }
        return resp.data ?? []
    }
    
    public func fetchQuotesRawData(symbols: String) async throws -> (Data, URLResponse) {
        guard let url = urlForFetchQuotes(symbols: symbols) else { throw APIServiceError.invalidURL }
        return try await session.data(from: url)
    }
    
    private func urlForFetchQuotes(symbols: String) -> URL? {
        guard var urlComp = URLComponents(string: "\(baseURL)/v7/finance/quote") else {
            return nil
        }
        urlComp.queryItems = [ URLQueryItem(name: "symbols", value: symbols) ]
        return urlComp.url
    }
    
    private func fetch<D: Decodable>(url: URL) async throws -> (D, Int) {
        let (data, response) = try await session.data(from: url)
        let statusCode = try validateHTTPResponse(response: response)
        return (try jsonDecoder.decode(D.self, from: data), statusCode)
    }
    
    private func validateHTTPResponse(response: URLResponse) throws -> Int {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIServiceError.invalidResponseType
        }
        
        guard 200...299 ~= httpResponse.statusCode ||
              400...499 ~= httpResponse.statusCode
        else {
            throw APIServiceError.httpStatusCodeFailed(statusCode: httpResponse.statusCode, error: nil)
        }
        
        return httpResponse.statusCode
    }
}
