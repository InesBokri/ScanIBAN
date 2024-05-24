//
//  ScannerView.swift
//  bforBank
//
//  Created by Ines BOKRI on 23/05/2024.
//

import SwiftUI
import AVFoundation
import Vision

struct ScannerView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var cameraCoordinator: CameraView.Coordinator
    @EnvironmentObject var detectedIban: DetectedIban
    
    var body: some View {
        VStack {
            Text("Scanner votre IBAN")
                .foregroundColor(.white)
                .font(.largeTitle)
                .bold()
                .padding(.top, 10)
            
            Spacer().frame(height: 10)
            
            HStack {
                Text("Placer votre IBAN dans le cadre pour le scanner")
                    .foregroundColor(.white)
                    .bold()
                    .padding(.horizontal)
                Spacer()
            }
            .background(Color.gray)
            
            Spacer().frame(height: 30)
            
            ZStack {
                CameraView(coordinator: cameraCoordinator)
                    .frame(height: 100)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .environmentObject(cameraCoordinator)
            }
            .padding(.horizontal)
            
            if let iban = cameraCoordinator.detectedIban {
                Text("IBAN du bénéficiaire a été scanné")
                    .foregroundColor(.white)
                    .bold()
                    .padding()
                Spacer().frame(height: 10)
                Text("Pensez à le vérifier avant de valider :")
                    .foregroundColor(.white)
                    .padding()
                Spacer().frame(height: 10)
                Text("\(iban)")
                    .foregroundColor(.white)
                    .bold()
                    .padding()
                
                Button(action: {
                    detectedIban.iban = cameraCoordinator.detectedIban
                    cameraCoordinator.detectedIban = nil
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Valider")
                        .foregroundColor(.white)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(20)
                }
                .padding(.horizontal)
                
                Spacer().frame(height: 10)
                
                Button(action: {
                    cameraCoordinator.detectedIban = nil
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Recommencer")
                        .foregroundColor(.blue)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                }
                .padding(.horizontal)
                
                Spacer().frame(height: 10)
                
                
            }
            Spacer()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            cameraCoordinator.detectedIban = nil
        }
    }
}
