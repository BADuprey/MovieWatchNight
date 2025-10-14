//
//  ContentView.swift
//  sprint_1
//
//  Created by Sasha Jazmin Abuin on 10/12/25.
//

import SwiftUI
//Content view --> bring app together

struct ContentView: View {
    var body: some View {
        TabView {
            RecommendationsView()
                .tabItem {
                    Image(systemName: "sparkles")
                    Text("Recs")
                }

            ListsView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Lists")
                }

            HubView() 
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Hub")
                }

            SchedulesView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Schedules")
                }

            AccountView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Account")
                }
        }
    }
}

#Preview {
    ContentView()
}
