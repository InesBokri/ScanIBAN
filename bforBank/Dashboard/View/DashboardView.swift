//
//  DashboardView.swift
//  bforBank
//
//  Created by Ines BOKRI on 21/05/2024.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        TabView {
            AccountView()
                .tabItem {
                    Image(systemName: "creditcard.fill")
                    Text("Comptes")
                }
            AddBeneficiaryView().environmentObject(DetectedIban())
            .tabItem {
                Image(systemName: "arrow.left.arrow.right")
                Text("Virement")
            }
            HelpView()
                .tabItem {
                    Image(systemName: "questionmark.bubble")
                    Text("Aide")
                }
            Text("Plus")
                .tabItem {
                    Image(systemName: "ellipsis")
                    Text("Plus")
                }
        }
        .edgesIgnoringSafeArea(.top)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
