import SwiftUI

struct UnitPicker: View {
    let title: String
    let units: [ConversionUnit]
    @Binding var selectedUnit: ConversionUnit
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppTypography.caption)
                .foregroundColor(AppColors.secondaryText)
            
            Menu {
                ForEach(units) { unit in
                    Button(action: {
                        selectedUnit = unit
                    }) {
                        HStack {
                            Text(unit.name)
                            Spacer()
                            if unit.id == selectedUnit.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppColors.yolkYellow)
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(selectedUnit.name)
                            .font(AppTypography.body)
                            .foregroundColor(AppColors.primaryText)
                        
                        Text(selectedUnit.symbol)
                            .font(AppTypography.small)
                            .foregroundColor(AppColors.secondaryText)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.secondaryText)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.cardBorder, lineWidth: 1)
                    )
                )
            }
        }
    }
}

#Preview {
    UnitPicker(
        title: "From Unit",
        units: UnitCategory.length.units,
        selectedUnit: .constant(UnitCategory.length.units[0])
    )
    .padding()
    .background(AppColors.primaryBackground)
}
