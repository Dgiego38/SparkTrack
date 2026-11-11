import HealthKit
import SwiftUI

struct ContentView: View {
    @StateObject private var healthKit = HealthKitManager()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
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

                    VStack(spacing: 12) {
                        Text("SCORE DE RÉCUPÉRATION")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)

                        Text("—")
                            .font(.system(size: 64, weight: .heavy))
                            .foregroundColor(.green)

                        Text("Les données Santé ne sont pas encore chargées.")
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

                    Button(action: healthKit.requestAccess) {
                        HStack {
                            if healthKit.isRequesting {
                                ProgressView()
                                    .tint(.black)
                            }
                            Text(healthKit.isRequesting ? "Demande en cours…" : "Autoriser l'accès à Santé")
                        }
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.black)
                        .background(Color.orange)
                        .cornerRadius(12)
                    }
                    .disabled(healthKit.isRequesting)

                    if let status = healthKit.statusMessage {
                        Text(status)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    if let error = healthKit.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

private final class HealthKitManager: ObservableObject {
    @Published private(set) var isRequesting = false
    @Published private(set) var statusMessage: String?
    @Published private(set) var errorMessage: String?

    private var healthStore: HKHealthStore?

    func requestAccess() {
        guard !isRequesting else { return }

        guard HKHealthStore.isHealthDataAvailable() else {
            errorMessage = "HealthKit n'est pas disponible sur cet appareil."
            return
        }

        guard
            let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN),
            let restingHeartRateType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate)
        else {
            errorMessage = "Les types de données HealthKit requis ne sont pas disponibles."
            return
        }

        errorMessage = nil
        statusMessage = nil
        isRequesting = true

        let store = healthStore ?? HKHealthStore()
        healthStore = store
        let typesToRead: Set<HKObjectType> = [hrvType, restingHeartRateType]

        store.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isRequesting = false

                if let error {
                    self.errorMessage = "La demande HealthKit a échoué : \(error.localizedDescription)"
                } else if success {
                    self.statusMessage = "Demande traitée. L'autorisation de lecture peut rester refusée par confidentialité."
                } else {
                    self.errorMessage = "La demande d'autorisation HealthKit a échoué."
                }
            }
        }
    }
}
