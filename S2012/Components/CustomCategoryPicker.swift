import SwiftUI

struct CustomCategoryPicker: View {
    @Binding var selectedCategory: UnitCategory
    let onCategoryChange: (UnitCategory) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(UnitCategory.allCases) { category in
                    CategoryButton(
                        category: category,
                        isSelected: selectedCategory == category,
                        action: {
                            selectedCategory = category
                            onCategoryChange(category)
                            
                            // Add haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }
                    )
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

struct CategoryButton: View {
    let category: UnitCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? AppColors.primaryBackground : AppColors.primaryText)
                
                Text(category.rawValue)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? AppColors.primaryBackground : AppColors.primaryText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? AppColors.yolkYellow : AppColors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isSelected ? AppColors.yolkYellow : AppColors.cardBorder,
                                lineWidth: 1
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.0 : 0.95)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 20) {
        CustomCategoryPicker(
            selectedCategory: .constant(.length),
            onCategoryChange: { _ in }
        )
        
        CustomCategoryPicker(
            selectedCategory: .constant(.temperature),
            onCategoryChange: { _ in }
        )
    }
    .padding()
    .background(AppColors.primaryBackground)
}
