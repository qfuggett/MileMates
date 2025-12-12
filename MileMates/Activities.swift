//
//  Activities.swift
//  MileMates
//
//  Created by 31-third team on 12/9/25.
//

import SwiftUI
import SwiftData
import SwiftUIGIF

struct Activities: View {
    @State private var imageData: Data? = nil
    @State private var isDone = false
    @Query(sort: \Activity.name) private var activities: [Activity]
    @Environment(\.modelContext) private var context

    var body: some View {
        ZStack {
            if let data = imageData {
                GIFImage(data: data)
                    .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
            }
            List {
                ForEach(activities) { activity in
                    HStack {
                        Text(activity.name)
                        Spacer()
                        Text("\(activity.miles, specifier: "%.1f") mi")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .navigationTitle("")
            .task {
                if activities.isEmpty {
                    context.insert(Activity(name: "Michigan Central Station", miles: 20))
                    context.insert(Activity(name: "Grand Rapids", miles: 160))
                    context.insert(Activity(name: "Anna Scripps Observatory", miles: 8))
                    context.insert(Activity(name: "Campus Martius Park", miles: 5))
                    context.insert(Activity(name: "Eastern Market", miles: 3))
                }
            }

            VStack {
                Spacer()

                NavigationLink(destination: TipsAndTricks()) {
                    Label("Send All", systemImage: "paperplane")
                        .font(.system(size: 18, weight: .semibold))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .padding(.bottom, 33)
            }
        }
        .onAppear {
            if imageData == nil {
                if let gifData = NSDataAsset(name: "poleposition")?.data {
                    imageData = gifData
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        Activities()
    }
    .modelContainer(for: Activity.self, inMemory: true)
}
