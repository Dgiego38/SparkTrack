import SwiftUI
import HealthKit

struct ContentView: View {
    private let healthStore = HKHealthStore()
    @State private var hrv: Double = 0
    @State private var rhr: Double = 0
    @State private var recoveryScore: Int = 0
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if isLoading {
                VStack(spacing: 15) {
                    ProgressView()
                        .tint(.blue)
                    Text("Analyse des métriques...")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            } else {
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
                                .foregroundColor(scoreColor(recoveryScore))

                            Text(scoreMessage(recoveryScore))
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                        .background(Color(white: 0.1))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(scoreColor(recoveryScore).opacity(0.5), lineWidth: 1.5)
                        )

                        // Grille des métriques VFC & Pouls
                        HStack(spacing: 15) {
                            MetricCard(title: "VFC (HRV)", value: "\(Int(hrv)) ms", subtitle: "Variabilité cardiaque")
                            MetricCard(title: "POULS AU REPOS", value: "\(Int(rhr)) bpm", subtitle: "Fréquence minimale")
                        }

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
        }
        .onAppear {
            requestHealthKitAccess()
        }
    }

    private func requestHealthKitAccess() {
        guard HKHealthStore.isHealthDataAvailable() else {
            self.errorMessage = "HealthKit n'est pas disponible sur cet appareil."
            self.isLoading = false
            return
        }

        guard let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN),
              let rhrType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            return
        }

        let typesToRead: Set<HKObjectType> = [hrvType, rhrType]

        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            DispatchQueue.main.async {
                if success {
                    fetchHealthData(hrvType: hrvType, rhrType: rhrType)
                } else {
                    self.errorMessage = "Autorisation HealthKit refusée."
                    self.isLoading = false
                }
            }
        }
    }

    private func fetchHealthData(hrvType: HKQuantityType, rhrType: HKQuantityType) {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let hrvQuery = HKSampleQuery(sampleType: hrvType, predicate: predicate, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { _, samples, _ in
            let hrvVal = (samples?.first as? HKQuantitySample)?.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli)) ?? 55.0

            let rhrQuery = HKSampleQuery(sampleType: rhrType, predicate: predicate, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { _, rhrSamples, _ in
                let rhrVal = (rhrSamples?.first as? HKQuantitySample)?.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute())) ?? 60.0

                DispatchQueue.main.async {
                    self.hrv = hrvVal
                    self.rhr = rhrVal
                    
                    // Calcul de score (Base VFC)
                    let baseScore = Int((hrvVal / 70.0) * 100)
                    self.recoveryScore = min(100, max(0, baseScore))
                    self.isLoading = false
                }
            }
            self.healthStore.execute(rhrQuery)
        }
        healthStore.execute(hrvQuery)
    }

    private func scoreColor(_ score: Int) -> Color {
        if score >= 67 { return .green }
        if score >= 34 { return .yellow }
        return .red
    }

    private func scoreMessage(_ score: Int) -> String {
        if score >= 67 { return "Prêt pour un effort intense" }
        if score >= 34 { return "Récupération modérée" }
        return "Repos recommandé aujourd'hui"
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            Text(subtitle)
                .font(.system(size: 10))
                .foregroundColor(.gray.opacity(0.8))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(white: 0.1))
        .cornerRadius(16)
    }
}