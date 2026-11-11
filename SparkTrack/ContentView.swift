import SwiftUI
import HealthKit

struct ContentView: View {
    private let healthStore = HKHealthStore()
    @State private var hrv: Double = 0
    @State private var rhr: Double = 0
    @State private var recoveryScore: Int = 0
    @State private var isLoading = false // Désactivé pour le test, on va le remettre propre
    @State private var errorMessage: String?

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
                            Text("Récupération")
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

                        Text("HealthKit actif et connecté")
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

                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            requestHealthKitAccessSafe()
        }
    }

    private func requestHealthKitAccessSafe() {
        // 1. Vérifier si HealthKit est disponible sur l'appareil
        guard HKHealthStore.isHealthDataAvailable() else {
            self.errorMessage = "HealthKit non supporté sur cet appareil."
            return
        }

        guard let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN),
              let rhrType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            return
        }

        let typesToRead: Set<HKObjectType> = [hrvType, rhrType]

        // 2. Demande d'autorisation asynchrone sécurisée
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            DispatchQueue.main.async {
                if success {
                    // Les autorisations ont été traitées par l'utilisateur
                    self.recoveryScore = 78 // Valeur test en attendant de fetch les vraies samples
                } else {
                    self.errorMessage = "Accès refusé ou annulé."
                }
            }
        }
    }
}