//
//  Welcome.swift
//  MileMates
//
//  Created by QueenTesa Fuggett on 12/9/25.
//

import SwiftUI
import SwiftUIGIF

struct Welcome: View {
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
                Image("start")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .offset(x: -20, y:-250)
                Image("stop")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .offset(x: 20, y:-250)
            }
            Rectangle()
                .border(Color.white, width: 2)
                .frame(width: 200, height: 50)
                .offset(y:-40)
            Image("stopLines")
                .resizable()
                .scaledToFit()
                .frame(width: 75, height: 75)
                .offset(y:250)
            
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
