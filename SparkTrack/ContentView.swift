private func requestHealthKitAccess() {
    guard HKHealthStore.isHealthDataAvailable() else {
        self.errorMessage = "HealthKit indisponible."
        self.isLoading = false
        return
    }

    guard let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN),
          let rhrType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
        self.isLoading = false
        return
    }

    let typesToRead: Set<HKObjectType> = [hrvType, rhrType]

    // Exécuter impérativement sur le main thread si l'app vient d'ouvrir
    healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
        DispatchQueue.main.async {
            if success {
                fetchHealthData(hrvType: hrvType, rhrType: rhrType)
            } else {
                self.errorMessage = "Permission refusée."
                self.isLoading = false
            }
        }
    }
}