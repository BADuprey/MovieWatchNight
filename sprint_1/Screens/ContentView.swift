import SwiftUI
//Content view --> bring app together

enum Tab : Hashable {
    case hub
    case recs
    case lists
    case schedules
    case account
    case manager
}

struct ContentView: View {
    @State private var selectedTab: Tab = .hub
    @State private var isLoggedIn: Bool = false

    var body: some View {
        if isLoggedIn {
            TabView(selection: $selectedTab) {

                RecommendationsView()
                    .tabItem {
                        Image(systemName: "sparkles")
                        Text("Recs")
                    }.tag(Tab.recs)

                ListsView()
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("Lists")
                    }.tag(Tab.lists)
                
                HubView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Hub")
                    }.tag(Tab.hub)

                SchedulesView()
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Schedules")
                    }.tag(Tab.schedules)

                AccountView()
                    .tabItem {
                        Image(systemName: "person.circle")
                        Text("Account")
                    }.tag(Tab.account)

                ViewManagerView(isLoggedIn: $isLoggedIn)
                    .tabItem {
                        Image(systemName: "person.crop.circle")
                        Text("Manager")
                    }.tag(Tab.manager)
            }
        } else {
            // Show login/signup manager
            ViewManagerView(isLoggedIn: $isLoggedIn)
        }
    }
}

#Preview {
    ContentView()
}

