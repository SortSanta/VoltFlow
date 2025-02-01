import SwiftUI

struct DrivingTipsView: View {
    let tips: [DrivingTip]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Smart Tips")
                .font(.headline)
                .foregroundColor(.white)
            
            ForEach(tips) { tip in
                TipCard(tip: tip)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
        )
    }
}

private struct TipCard: View {
    let tip: DrivingTip
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 40, height: 40)
                .background(iconColor.opacity(0.2))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(tip.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(tip.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                if tip.potentialSaving > 0 {
                    Text("Potential saving: \(String(format: "%.1f", tip.potentialSaving)) kWh")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private var iconName: String {
        switch tip.category {
        case .acceleration: return "speedometer"
        case .braking: return "brake"
        case .climate: return "thermometer"
        case .route: return "map"
        case .charging: return "bolt.circle"
        }
    }
    
    private var iconColor: Color {
        switch tip.category {
        case .acceleration: return .blue
        case .braking: return .purple
        case .climate: return .orange
        case .route: return .green
        case .charging: return .yellow
        }
    }
}

#Preview {
    DrivingTipsView(tips: [
        DrivingTip(
            title: "Smooth Acceleration",
            description: "Gradual acceleration can improve your efficiency by up to 10%",
            potentialSaving: 0.8,
            category: .acceleration
        ),
        DrivingTip(
            title: "Optimal Climate",
            description: "Using seat heaters instead of cabin heat can extend your range",
            potentialSaving: 1.2,
            category: .climate
        )
    ])
    .preferredColorScheme(.dark)
    .padding()
    .background(Color.black)
}
