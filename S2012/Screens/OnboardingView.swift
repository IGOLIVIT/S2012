import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @State private var currentPage = 0
    @State private var animationOffset: CGFloat = 0
    
    private let pages = [
        OnboardingPage(
            title: "Convert with Confidence",
            subtitle: "Master everyday unit conversions fast.",
            icon: "ruler.fill",
            color: AppColors.yolkYellow
        ),
        OnboardingPage(
            title: "Learn by Doing",
            subtitle: "Interactive tasks across length, mass, temperature, volume, speed.",
            icon: "brain.head.profile",
            color: AppColors.yolkYellow
        ),
        OnboardingPage(
            title: "Challenge Yourself",
            subtitle: "Timed mini-game and badges to keep you sharp.",
            icon: "trophy.fill",
            color: AppColors.yolkYellow
        )
    ]
    
    var body: some View {
        ZStack {
            // Background gradient
            AppColors.backgroundGradient
                .ignoresSafeArea()
            
            // Floating background shapes
            FloatingShapes()
            
            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.5), value: currentPage)
                
                // Custom page indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? AppColors.yolkYellow : AppColors.secondaryText.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == currentPage ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 40)
                
                // Action buttons
                VStack(spacing: 16) {
                    PrimaryButton(title: "Get Started") {
                        completeOnboarding()
                    }
                    
                    Button("Skip") {
                        completeOnboarding()
                    }
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.secondaryText)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            startFloatingAnimation()
        }
    }
    
    private func completeOnboarding() {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        withAnimation(.easeInOut(duration: 0.5)) {
            showOnboarding = false
        }
        
        // Save that onboarding was completed
        UserDefaults.standard.set(true, forKey: "OnboardingCompleted")
    }
    
    private func startFloatingAnimation() {
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            animationOffset = 20
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var iconScale: CGFloat = 0.8
    @State private var textOpacity: Double = 0
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon with animation
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                
                Circle()
                    .fill(page.color.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: page.icon)
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(page.color)
            }
            .scaleEffect(iconScale)
            
            // Text content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(AppTypography.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primaryText)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(AppTypography.body)
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, 32)
            }
            .opacity(textOpacity)
            
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2)) {
                iconScale = 1.0
            }
            
            withAnimation(.easeInOut(duration: 0.6).delay(0.4)) {
                textOpacity = 1.0
            }
        }
    }
}

struct FloatingShapes: View {
    @State private var positions: [CGPoint] = []
    @State private var scales: [CGFloat] = []
    @State private var opacities: [Double] = []
    
    private let shapeCount = 6
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<shapeCount, id: \.self) { index in
                    Circle()
                        .fill(AppColors.yolkYellow.opacity(opacities.indices.contains(index) ? opacities[index] : 0.1))
                        .frame(width: 60, height: 60)
                        .scaleEffect(scales.indices.contains(index) ? scales[index] : 1.0)
                        .position(positions.indices.contains(index) ? positions[index] : CGPoint(x: 50, y: 50))
                        .blur(radius: 10)
                }
            }
        }
        .onAppear {
            setupInitialPositions()
            startFloatingAnimation()
        }
    }
    
    private func setupInitialPositions() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        positions = (0..<shapeCount).map { _ in
            CGPoint(
                x: CGFloat.random(in: 50...(screenWidth - 50)),
                y: CGFloat.random(in: 100...(screenHeight - 200))
            )
        }
        
        scales = (0..<shapeCount).map { _ in
            CGFloat.random(in: 0.5...1.5)
        }
        
        opacities = (0..<shapeCount).map { _ in
            Double.random(in: 0.05...0.15)
        }
    }
    
    private func startFloatingAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation(.easeInOut(duration: Double.random(in: 2...4))) {
                for i in 0..<shapeCount {
                    if positions.indices.contains(i) {
                        positions[i].x += CGFloat.random(in: -2...2)
                        positions[i].y += CGFloat.random(in: -2...2)
                    }
                    
                    if scales.indices.contains(i) {
                        scales[i] = CGFloat.random(in: 0.5...1.5)
                    }
                    
                    if opacities.indices.contains(i) {
                        opacities[i] = Double.random(in: 0.05...0.15)
                    }
                }
            }
        }
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
}

#Preview {
    OnboardingView(showOnboarding: .constant(true))
}
