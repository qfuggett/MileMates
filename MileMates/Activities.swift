//
//  Welcome.swift
//  MileMates
//
//  Created by 31-third team on 12/9/25.
//

import SwiftUI
import SwiftUIGIF

struct Activities: View {
    @State private var activities: [String] = ["Michigan Central Station:  20 miles", "Grand Rapids:  200 miles", "Anna Scripps Observatory:  8 miles", "Campus Martius Park:  10 miles", "Eastern Market:  3 miles"]


    var body: some View {
        ZStack{
            VStack{
                List{
                    ForEach(activities, id: \.description) { activity in Text(activity) }
                }
            }
        }
        .padding()
      }
}

#Preview {
    Activities()
}
