//
//  Welcome.swift
//  MileMates
//
//  Created by 31-third team on 12/9/25.
//

import SwiftUI
import SwiftUIGIF

struct Activities: View {
    @State private var testActivities: [String] = ["Test1", "Test2", "Test3", "Test4"]
    @State private var activities = ""


    var body: some View {
        ZStack{
            VStack{
                List{
                    ForEach(testActivities, id: \.description) { activity in Text(activity) }
                }
            }
        }
        .padding()
      }
}

#Preview {
    Activities()
}
