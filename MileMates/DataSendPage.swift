//
//  Welcome.swift
//  MileMates
//
//  Created by 31-third team on 12/9/25.
//

import SwiftUI
import SwiftUIGIF

struct DataSendPage: View {
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
            VStack {
                Spacer()

                Button(action: {
                    // navigate to activities list
                }) {
                    Label("Send Activities", systemImage: "list")
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
      
      private func loadData() {
        let task = URLSession.shared.dataTask(with: URL(string: "https://github.com/qfuggett/MileMates/blob/main/poleposition-2.gif?raw=true")!) { data, response, error in
          imageData = data
        }
        task.resume()
      }
}

#Preview {
    DataSendPage()
}
