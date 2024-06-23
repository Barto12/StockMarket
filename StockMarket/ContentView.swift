//
//  ContentView.swift
//  StockMarket
//
//  Created by MACBOOK on 23/06/24.
//

import SwiftUI

struct ContentView: View {
    @State private var stockSymbol: String = ""
    @State private var stockPrice: String = "Ingrese un símbolo de acción"
    
    var body: some View {
        VStack {
            TextField("Símbolo de acción", text: $stockSymbol)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                fetchStockPrice(symbol: stockSymbol)
            }) {
                Text("Obtener Cotización")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Text(stockPrice)
                .padding()
        }
        .padding()
    }
    
    func fetchStockPrice(symbol: String) {
        let apiKey = "clave?apikey"
        let urlString = "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=\(symbol)&interval=1min&apikey=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            stockPrice = "URL no válida"
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    stockPrice = "Error: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    stockPrice = "No hay datos"
                }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let timeSeries = json["Time Series (1min)"] as? [String: Any],
                   let latestTime = timeSeries.keys.sorted().first,
                   let latestData = timeSeries[latestTime] as? [String: String],
                   let price = latestData["1. open"] {
                    DispatchQueue.main.async {
                        stockPrice = "Cotización: $\(price)"
                    }
                } else {
                    DispatchQueue.main.async {
                        stockPrice = "Datos no disponibles"
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    stockPrice = "Error al analizar los datos"
                }
            }
        }
        
        task.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
