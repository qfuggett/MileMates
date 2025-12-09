//
//  Welcome.swift
//  MileMates
//
//  Created by the 31-third team on 12/9/25.
//

import SwiftUI
import SwiftUIGIF

struct Welcome: View {
    @StateObject private var tracker = LocationTracker()
    @State private var imageData: Data? = nil
    @State private var isDone = false

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
                  .onAppear(perform: loadData)
              }
            }
            HStack{
                Button {
                    tracker.startTracking()
                } label: {
                    Image("start")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                }
                .offset(x: -20, y: -250)
                .buttonStyle(.plain)
                Button {
                    tracker.stopTracking()
                } label: {
                    Image("stop")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                }
                .offset(x: 20, y: -250)
                .buttonStyle(.plain)
            }
            Rectangle()
                .border(Color.white, width: 2)
                .frame(width: 200, height: 60)
                .offset(y:-40)
            Button {
                tracker.pauseTracking()
            } label: {
                Image("stopLines")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 75, height: 75)
            }
            .offset(y: 250)
            .buttonStyle(.plain)
            VStack {
                Spacer()

                Button(action: {
                    // navigate to activities list
                }) {
                    Label("All Activities", systemImage: "list")
                        .font(.system(size: 18, weight: .semibold))
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .padding(.bottom, 33)
            }
            .onAppear {
                tracker.requestAuthorization()
            }
        }
      }
      
      private func loadData() {
        let task = URLSession.shared.dataTask(with: URL(string: "https://github.com/qfuggett/MileMates/blob/main/poleposition-2.gif?raw=true")!) { data, response, error in
          imageData = data
        }
        task.resume()
      }
}

#Preview {
    Welcome()
}
