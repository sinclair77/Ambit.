//
//  HapticManager.swift
//  Ambit
//
//  Created by Daniel on 2024.
//

import UIKit

final class HapticManager {
    static let instance = HapticManager()

    private let defaults = UserDefaults.standard
    private let hapticsPreferenceKey = "hapticsEnabled"

    private var isHapticsEnabled: Bool {
        guard defaults.object(forKey: hapticsPreferenceKey) != nil else {
            return true
        }
        return defaults.bool(forKey: hapticsPreferenceKey)
    }

    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard isHapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isHapticsEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }

    func setEnabled(_ enabled: Bool) {
        defaults.set(enabled, forKey: hapticsPreferenceKey)
    }
}
