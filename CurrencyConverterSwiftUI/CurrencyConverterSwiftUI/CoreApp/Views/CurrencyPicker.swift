//
//  CurrencyPicker.swift
//  CurrencyConverter
//
//  Created by Anmol Suneja on 05/05/24.
//

import SwiftUI

struct CurrencyPicker: View {
    @Binding var selection: String
    let currencies: [Currency]
    
    var body: some View {
        List {
            Picker(selection: $selection) {
                ForEach(currencies, id: \.symbol) { menu in
                    VStack(alignment: .leading) {
                        Text(menu.symbol)
                        Text(menu.name ?? Constants.notAvaiable)
                    }
                    .tag(menu.symbol)
                }
            } label: {
            }
            .pickerStyle(.inline)
        }
    }
}
