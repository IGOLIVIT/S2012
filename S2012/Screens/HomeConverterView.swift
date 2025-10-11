import SwiftUI

struct HomeConverterView: View {
    @StateObject private var viewModel = HomeViewModel()
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(AppColors.yolkYellow)
                            
                            Text("Unit Converter")
                                .font(AppTypography.title)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.primaryText)
                            
                            Spacer()
                        }
                        
                        Text("Convert between different units with precision")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.secondaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    
                    // Category Picker
                    VStack(spacing: 16) {
                        HStack {
                            Text("Category")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.secondaryText)
                            Spacer()
                        }
                        
                        CustomCategoryPicker(
                            selectedCategory: $viewModel.selectedCategory,
                            onCategoryChange: { category in
                                viewModel.updateCategory(category)
                            }
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    // Unit Pickers
                    VStack(spacing: 20) {
                        HStack(spacing: 16) {
                            UnitPicker(
                                title: "From Unit",
                                units: viewModel.selectedCategory.units,
                                selectedUnit: $viewModel.selectedFromUnit
                            )
                            .onChange(of: viewModel.selectedFromUnit) { unit in
                                viewModel.updateFromUnit(unit)
                            }
                            
                            // Swap button
                            VStack {
                                Spacer()
                                IconButton(icon: "arrow.2.squarepath", size: 48) {
                                    viewModel.swapUnits()
                                }
                                Spacer()
                            }
                            .frame(height: 80)
                            
                            UnitPicker(
                                title: "To Unit",
                                units: viewModel.selectedCategory.units,
                                selectedUnit: $viewModel.selectedToUnit
                            )
                            .onChange(of: viewModel.selectedToUnit) { unit in
                                viewModel.updateToUnit(unit)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Input Section
                    VStack(spacing: 16) {
                        HStack {
                            Text("Enter Value")
                                .font(AppTypography.caption)
                                .foregroundColor(AppColors.secondaryText)
                            Spacer()
                        }
                        
                        TextField("Enter a value", text: $viewModel.inputValue)
                            .textFieldStyle(InputFieldStyle())
                            .keyboardType(.decimalPad)
                            .focused($isInputFocused)
                            .onChange(of: viewModel.inputValue) { _ in
                                if viewModel.canConvert {
                                    viewModel.convert()
                                }
                            }
                        
                        PrimaryButton(
                            title: "Convert",
                            isEnabled: viewModel.canConvert,
                            isLoading: viewModel.isConverting
                        ) {
                            isInputFocused = false
                            viewModel.convert()
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Result Card
                    if viewModel.showResult {
                        ResultCard(result: viewModel.result, isVisible: viewModel.showResult)
                            .padding(.horizontal, 24)
                    }
                    
                    // Preset Conversions
                    VStack(spacing: 16) {
                        HStack {
                            Text("Quick Conversions")
                                .font(AppTypography.headline)
                                .foregroundColor(AppColors.primaryText)
                            Spacer()
                        }
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(viewModel.presetConversions, id: \.description) { preset in
                                PresetConversionCard(preset: preset) {
                                    viewModel.applyPreset(preset)
                                    isInputFocused = false
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Bottom spacing for tab bar
                    Spacer(minLength: 100)
                }
            }
            .background(AppColors.primaryBackground)
            .navigationBarHidden(true)
            .onTapGesture {
                isInputFocused = false
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

struct PresetConversionCard: View {
    let preset: PresetConversion
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                HStack {
                    Text(preset.value)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColors.yolkYellow)
                    
                    Text(preset.fromUnit)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.secondaryText)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.secondaryText)
                    
                    Text(preset.toUnit)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.secondaryText)
                    
                    Spacer()
                }
                
                HStack {
                    Text(preset.description)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.primaryText)
                    Spacer()
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.cardBorder, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeConverterView()
}
