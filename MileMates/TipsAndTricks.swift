//
//  Welcome.swift
//  MileMates
//
//  Created by 31-third team on 12/9/25.
//

import SwiftUI
import SwiftUIGIF

struct TipsAndTricks: View {
    @State private var imageData: Data? = nil
    @State private var isDone = false
    // Controls whether the success popup is visible
    @State private var showSuccessPopup = false

    var body: some View {
        ZStack{
            VStack {
              if let data = imageData {
                GIFImage(data: data) {
                    isDone = true
                  }
                  .frame(width: 400)
                } else {
                Text("Loading...")
              }
            }
            .onAppear {
                // Load GIF from Asset Catalog
                if let gifData = NSDataAsset(name: "poleposition")?.data {
                    imageData = gifData
                }
                // Simulate data being sent successfully
                // TODO: Replace this with real send / export logic later
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    showSuccessPopup = true
                }
            }
            Image("bigCloud")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .offset(x: 20, y:-240)
            Image("smallCloud")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .offset(x: -150, y:-350)
            Text("Tips")
                .font(.title)
                .bold()
                .offset(x: -120, y:-305)
            Text("Tricks")
                .font(.title)
                .bold()
                .offset(x: 20, y:-275)
            Image(systemName: "info.circle")
                .foregroundStyle(.white)
                .offset(x: 170, y:-320)
            ZStack {
                VStack{
                    Rectangle()
                        .frame(width: 300, height: 150)
                        .foregroundColor(Color.white.opacity(0.9))
                }
                Text("Did you know? \n\nYou have two options for calculating the deduction: the Standard Mileage method and the Actual Expense Method.")
                    .font(.system(size: 16))
                    .bold()
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .padding(.horizontal, 20)
                    .frame(width: 300)
                    .offset(y: 0)
            }
            .offset(y: -80)
            VStack {
                Spacer()

                NavigationLink(destination: Welcome()) {
                    Label("Home", systemImage: "list")
                        .font(.system(size: 18, weight: .semibold))
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .padding(.bottom, 33)
            }
            // Success popup overlay
            if showSuccessPopup {
                ZStack {
                    // Dimmed background
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()

                    // Popup card
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.green)

                        Text("Data Sent Successfully")
                            .font(.headline)
                            .foregroundColor(.black)

                        Button("OK") {
                            showSuccessPopup = false
                        }
                        .padding(.horizontal, 32)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    }
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(radius: 20)
                }
            }
          }
            
        }
        
      
//      private func loadData() {
//        let task = URLSession.shared.dataTask(with: URL(string: "https://github.com/qfuggett/MileMates/blob/main/poleposition-2.gif?raw=true")!) { data, response, error in
//          imageData = data
//        }
//        task.resume()
//      }
}

#Preview {
    TipsAndTricks()
}
