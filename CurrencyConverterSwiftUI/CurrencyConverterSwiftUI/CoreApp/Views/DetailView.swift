//
//  DetailView.swift
//  CurrencyConverter
//
//  Created by Anmol Suneja on 06/05/24.
//

import SwiftUI

struct DetailView: View {
    let currency: Currency
    @ObservedObject var viewModel: CurrencyViewModel
    @Environment(\.dismiss) var dimiss
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 15) {
                
                Text("\(viewModel.inputAmountValue) \(viewModel.selectedCurrency)")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(Constants.equivalentCurrencyText)
                    .font(.title2)
                                    
                Text("\(viewModel.getAmount(currencyRate: currency.rate)) \(currency.symbol)")
                    .font(.title)
                    .bold()
                
                Text("(\(currency.name ?? Constants.notAvaiable))")
                    .font(.title3)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray.opacity(0.1))
            
            Button(action: {
                dimiss.callAsFunction()
            }, label: {
                Image(systemName: "xmark")
                    .padding()
                    .font(.title)
                    .fontWeight(.bold)
                    .tint(Color.black)
            })
        }
    }
}
