//
//  Welcome.swift
//  MileMates
//
//  Created by QueenTesa Fuggett on 12/9/25.
//

import SwiftUI
import SwiftUIGIF

struct TipsAndTricks: View {
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
    TipsAndTricks()
}
