import SwiftUI

struct EfficiencyScoreCard: View {
    let score: EfficiencyScore
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Efficiency Score")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("\(Int(score.overall))")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(scoreColor)
            }
            
            HStack(spacing: 20) {
                ScoreMetric(
                    title: "Acceleration",
                    value: score.acceleration,
                    icon: "speedometer"
                )
                
                ScoreMetric(
                    title: "Braking",
                    value: score.braking,
                    icon: "brake"
                )
                
                ScoreMetric(
                    title: "Energy",
                    value: score.energyUsage,
                    unit: "kWh/100km",
                    icon: "bolt.circle"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
        )
    }
    
    private var scoreColor: Color {
        switch score.overall {
        case 90...: return .green
        case 70...: return .yellow
        default: return .orange
        }
    }
}

private struct ScoreMetric: View {
    let title: String
    let value: Double
    var unit: String = ""
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.gray)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text("\(Int(value))\(unit)")
                .font(.system(.body, design: .rounded))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    EfficiencyScoreCard(score: EfficiencyScore.preview)
        .preferredColorScheme(.dark)
        .padding()
        .background(Color.black)
}
