import SwiftUI

struct ContentView: View {
    @State private var recoveryScore: Int = 85

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // En-tête
                    HStack {
                        VStack(alignment: .leading) {
                            Text("SPARKTRACK")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.orange)
                            Text("Récupération (Test)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(.top, 20)

                    // Carte Score Principal
                    VStack(spacing: 12) {
                        Text("SCORE DE RÉCUPÉRATION")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)

                        Text("\(recoveryScore)%")
                            .font(.system(size: 64, weight: .heavy))
                            .foregroundColor(.green)

                        Text("Mode diagnostic : HealthKit désactivé")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                    .background(Color(white: 0.1))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.green.opacity(0.5), lineWidth: 1.5)
                    )
                }
                .padding(.horizontal, 20)
            }
        }
    }
}