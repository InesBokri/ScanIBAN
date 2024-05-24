//
//  AddBeneficiaryView.swift
//  bforBank
//
//  Created by Ines BOKRI on 23/05/2024.
//

import SwiftUI

struct AddBeneficiaryView: View {
    
    @State private var iban = ""
    @StateObject private var cameraCoordinator = CameraView.Coordinator()
    @EnvironmentObject var detectedIban: DetectedIban
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = .white
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Spacer()
                    .frame(height: 10)
                
                HStack {
                    Text("Scanner, importez ou saisissez l'IBAN")
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    Spacer()
                }
                .background(Color.black)
                
                Spacer()
                    .frame(height: 30)
                
                GeometryReader { geometry in
                    VStack {
                        HStack {
                            Spacer()
                            
                            NavigationLink(destination: ScannerView(cameraCoordinator: cameraCoordinator)) {
                                Text("Scanner")
                                    .foregroundColor(.blue)
                                    .lineLimit(1)
                                    .frame(width: (geometry.size.width / 2) - 30)
                                    .padding(.vertical, 20)
                                    .background(Color.black)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 28)
                                            .stroke(Color.blue, lineWidth: 2)
                                    )
                            }
                            
                            Spacer(minLength: 20)
                            
                            Button(action: {
                                /// No spec to do the action of this button
                            }) {
                                Text("Importer")
                                    .foregroundColor(.blue)
                                    .lineLimit(1)
                                    .frame(width: (geometry.size.width / 2) - 30)
                                    .padding(.vertical, 20)
                                    .background(Color.black)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 28)
                                            .stroke(Color.blue, lineWidth: 2)
                                    )
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                            .frame(height: 30)
                        
                        TextField("FR76 XXXX", text: Binding<String>(
                            get: { self.detectedIban.iban ?? "" },
                            set: { self.detectedIban.iban = $0 }
                        ))
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .accentColor(.blue)
                        .overlay(
                            Button(action: {
                                self.detectedIban.iban = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                                .padding(.trailing, 25),
                            alignment: .trailing
                        )
                    }
                }
                
                Spacer()
            }
            .navigationBarTitle("Ajouter un bénéficiaire", displayMode: .inline)
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
    }
}


struct AddBeneficiaryView_Previews: PreviewProvider {
    static var previews: some View {
        AddBeneficiaryView()
    }
}
