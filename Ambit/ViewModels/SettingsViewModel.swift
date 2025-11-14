import Foundation
import SwiftUI

final class SettingsViewModel: ObservableObject {
    @Published var hapticsEnabled: Bool
    @Published var appearanceMode: AmbitAppearanceMode

    let appearanceModes: [AmbitAppearanceMode] = AmbitAppearanceMode.allCases

    private let defaults = UserDefaults.standard
    private let hapticsKey = "hapticsEnabled"
    private let appearanceKey = "ambitAppearanceMode"

    init() {
        if defaults.object(forKey: hapticsKey) == nil {
            defaults.set(true, forKey: hapticsKey)
        }
        if defaults.object(forKey: appearanceKey) == nil {
            defaults.set(AmbitAppearanceMode.studio.rawValue, forKey: appearanceKey)
        }

        hapticsEnabled = defaults.bool(forKey: hapticsKey)

        let storedMode = defaults.string(forKey: appearanceKey)
        let resolvedMode = AmbitAppearanceMode.resolved(from: storedMode ?? "")
        appearanceMode = resolvedMode
        if storedMode != resolvedMode.rawValue {
            defaults.set(resolvedMode.rawValue, forKey: appearanceKey)
        }
        defaults.removeObject(forKey: "ambitAccentHex")
        HapticManager.instance.setEnabled(hapticsEnabled)
    }

    func updateHaptics(_ enabled: Bool) {
        hapticsEnabled = enabled
        defaults.set(enabled, forKey: hapticsKey)
        HapticManager.instance.setEnabled(enabled)
    }

    func updateAppearance(_ mode: AmbitAppearanceMode) {
        appearanceMode = mode
        defaults.set(mode.rawValue, forKey: appearanceKey)
    }
}
