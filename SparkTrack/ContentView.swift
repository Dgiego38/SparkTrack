import HealthKit
import SwiftUI

struct ContentView: View {
    @StateObject private var healthKit = HealthKitManager()

    var body: some View {
        ZStack {
            Color(red: 0.025, green: 0.035, blue: 0.055)
                .ignoresSafeArea()

            Circle()
                .fill(Color.orange.opacity(0.18))
                .frame(width: 260, height: 260)
                .blur(radius: 100)
                .offset(x: 150, y: -330)
                .allowsHitTesting(false)

            Circle()
                .fill(Color.cyan.opacity(0.12))
                .frame(width: 240, height: 240)
                .blur(radius: 100)
                .offset(x: -160, y: 120)
                .allowsHitTesting(false)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    recoveryCard
                    metrics
                    healthKitAction
                    footer
                }
                .padding(.horizontal, 22)
                .padding(.top, 18)
                .padding(.bottom, 32)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack(spacing: 14) {
            Image(systemName: "bolt.heart.fill")
                .font(.system(size: 23, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.orange, Color.pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 54, height: 54)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.16), lineWidth: 1)
                }

            VStack(alignment: .leading, spacing: 3) {
                Text("SPARKTRACK")
                    .font(.caption.weight(.bold))
                    .tracking(2.2)
                    .foregroundStyle(.orange)
                Text("Récupération")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            Spacer()

            Image(systemName: healthKit.isEnabled ? "checkmark.heart.fill" : "lock.shield")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(healthKit.isEnabled ? Color.green : Color.white.opacity(0.55))
                .frame(width: 42, height: 42)
                .background(.ultraThinMaterial, in: Circle())
                .overlay {
                    Circle().stroke(Color.white.opacity(0.12), lineWidth: 1)
                }
                .accessibilityLabel(healthKit.isEnabled ? "HealthKit configuré" : "HealthKit désactivé pour cette build")
        }
    }

    private var recoveryCard: some View {
        VStack(spacing: 18) {
            HStack {
                Label("RÉCUPÉRATION", systemImage: "waveform.path.ecg")
                    .font(.caption.weight(.bold))
                    .tracking(1.3)
                    .foregroundStyle(.white.opacity(0.72))
                Spacer()
                Text(healthKit.isEnabled ? "SANTÉ" : "APERÇU")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.1)
                    .foregroundStyle(healthKit.isEnabled ? Color.green : Color.orange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
            }

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.09), lineWidth: 13)
                    .frame(width: 172, height: 172)
                Circle()
                    .trim(from: 0.04, to: 0.72)
                    .stroke(
                        AngularGradient(
                            colors: [.orange, .pink, .purple, .orange],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 13, lineCap: .round)
                    )
                    .frame(width: 172, height: 172)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: .orange.opacity(0.3), radius: 12)

                VStack(spacing: 2) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.pink)
                    Text("—")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("SCORE")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(.white.opacity(0.55))
                }
            }
            .padding(.vertical, 4)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Score de récupération indisponible")

            Text(healthKit.isEnabled
                 ? "Autorisez l’accès pour commencer l’analyse de vos données."
                 : "Cette version n’a pas l’autorisation HealthKit intégrée.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.66))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(22)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.25), .white.opacity(0.04)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
        .shadow(color: .black.opacity(0.25), radius: 24, y: 12)
    }

    private var metrics: some View {
        HStack(spacing: 14) {
            metricCard(title: "VFC", subtitle: "Variabilité", symbol: "waveform.path", unit: "ms")
            metricCard(title: "POULS AU REPOS", subtitle: "Fréquence cardiaque", symbol: "heart", unit: "bpm")
        }
    }

    private func metricCard(title: String, subtitle: String, symbol: String, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.orange)
                .frame(width: 36, height: 36)
                .background(Color.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(.white.opacity(0.54))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("—")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                    Text(unit)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
                .foregroundStyle(.white)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.45))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        }
    }

    private var healthKitAction: some View {
        VStack(spacing: 12) {
            Button(action: healthKit.requestAccess) {
                HStack(spacing: 10) {
                    if healthKit.isRequesting {
                        ProgressView()
                            .tint(.black)
                    } else {
                        Image(systemName: healthKit.isEnabled ? "heart.text.square.fill" : "lock.fill")
                    }
                    Text(healthKit.isRequesting
                         ? "Connexion en cours…"
                         : (healthKit.isEnabled ? "Autoriser l’accès à Santé" : "Vérifier la configuration"))
                }
                .font(.system(size: 16, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .foregroundStyle(.black)
                .background(
                    LinearGradient(
                        colors: healthKit.isEnabled ? [.orange, Color(red: 1, green: 0.48, blue: 0.28)] : [.gray, .gray.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                }
                .shadow(color: healthKit.isEnabled ? .orange.opacity(0.22) : .clear, radius: 16, y: 8)
            }
            .buttonStyle(.plain)
            .disabled(healthKit.isRequesting)

            if let message = healthKit.errorMessage ?? healthKit.statusMessage {
                Label(message, systemImage: healthKit.errorMessage == nil ? "info.circle" : "exclamationmark.triangle")
                    .font(.footnote)
                    .foregroundStyle(healthKit.errorMessage == nil ? .white.opacity(0.7) : .orange)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    }
            }
        }
    }

    private var footer: some View {
        HStack(spacing: 8) {
            Image(systemName: "lock.shield")
            Text("Vos données de santé restent privées.")
        }
        .font(.caption)
        .foregroundStyle(.white.opacity(0.42))
        .frame(maxWidth: .infinity)
        .padding(.top, 2)
    }
}

private final class HealthKitManager: ObservableObject {
    let isEnabled: Bool

    @Published private(set) var isRequesting = false
    @Published private(set) var statusMessage: String?
    @Published private(set) var errorMessage: String?

    private var healthStore: HKHealthStore?

    init() {
        isEnabled = (Bundle.main.object(forInfoDictionaryKey: "SparkTrackHealthKitEnabled") as? String) == "YES"
    }

    func requestAccess() {
        guard !isRequesting else { return }

        guard isEnabled else {
            errorMessage = "Cette build est sans entitlement HealthKit. Pour éviter le crash, la demande n’est pas lancée. Il faut une signature et un profil qui autorisent HealthKit."
            return
        }

        guard HKHealthStore.isHealthDataAvailable() else {
            errorMessage = "HealthKit n’est pas disponible sur cet appareil."
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
                    self.statusMessage = "Demande traitée. L’autorisation de lecture peut rester refusée par confidentialité."
                } else {
                    self.errorMessage = "La demande d’autorisation HealthKit a échoué."
                }
            }
        }
    }
}
