//
//  TipsAndTricks.swift
//  MileMates
//
//  Created by 31-third team on 12/9/25.
//

import SwiftUI
import SwiftUIGIF

struct TipsAndTricks: View {
    @State private var imageData: Data? = nil
    @State private var isDone = false
    @State private var currentTip: String = ""

    var body: some View {
        NavigationStack {
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
                    // Load today's tip
                    currentTip = TipsData.getTipForToday()
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
                    Text(currentTip.isEmpty ? "Loading tip..." : currentTip)
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
                        Label("Home", systemImage: "house")
                            .font(.system(size: 18, weight: .semibold))
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    .padding(.bottom, 33)
                }
            }
        }
    }
}

#Preview {
    TipsAndTricks()
}
