//
//  DataExtensions.swift
//  Ambit
//
//  Created by Daniel on 2024.
//

import Foundation
import SwiftUI

// MARK: - Array Extensions

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }

    func unique<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        var seen = Set<T>()
        return filter { seen.insert($0[keyPath: keyPath]).inserted }
    }

    func grouped<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [T: [Element]] {
        Dictionary(grouping: self, by: { $0[keyPath: keyPath] })
    }

    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }

    func randomElement() -> Element? {
        isEmpty ? nil : self[Int.random(in: 0..<count)]
    }

    func shuffled() -> [Element] {
        var array = self
        array.shuffle()
        return array
    }
}

extension Array where Element: Equatable {
    func unique() -> [Element] {
        var result: [Element] = []
        for element in self {
            if !result.contains(element) {
                result.append(element)
            }
        }
        return result
    }

    mutating func remove(_ element: Element) {
        if let index = firstIndex(of: element) {
            remove(at: index)
        }
    }

    func indices(of element: Element) -> [Int] {
        enumerated().compactMap { $0.element == element ? $0.offset : nil }
    }
}

extension Array where Element: Hashable {
    func unique() -> [Element] {
        Array(Set(self))
    }
}

// MARK: - Collection Extensions

extension Collection {
    var isNotEmpty: Bool {
        !isEmpty
    }
}

// MARK: - String Extensions

extension String {
    func capitalizingFirstLetter() -> String {
        prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = capitalizingFirstLetter()
    }

    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }

    var isValidURL: Bool {
        guard let url = URL(string: self) else { return false }
        return url.scheme != nil && url.host != nil
    }

    func trimmed() -> String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    mutating func trim() {
        self = trimmed()
    }

    func removingWhitespace() -> String {
        components(separatedBy: .whitespaces).joined()
    }

    func lines() -> [String] {
        components(separatedBy: .newlines)
    }

    func words() -> [String] {
        components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
    }

    func containsOnlyLetters() -> Bool {
        range(of: "[^a-zA-Z]", options: .regularExpression) == nil
    }

    func containsOnlyNumbers() -> Bool {
        range(of: "[^0-9]", options: .regularExpression) == nil
    }

    func containsOnlyAlphanumerics() -> Bool {
        range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }

    subscript(i: Int) -> Character {
        self[index(startIndex, offsetBy: i)]
    }

    subscript(bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start..<end]
    }

    subscript(bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start...end]
    }

    func replacingOccurrences(of targets: [String], with replacement: String) -> String {
        targets.reduce(self) { $0.replacingOccurrences(of: $1, with: replacement) }
    }

    func base64Encoded() -> String? {
        data(using: .utf8)?.base64EncodedString()
    }

    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func localized() -> String {
        NSLocalizedString(self, comment: "")
    }

    func localized(with arguments: CVarArg...) -> String {
        String(format: localized(), arguments: arguments)
    }
}

// MARK: - Date Extensions

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self) ?? self
    }

    var startOfWeek: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) ?? self
    }

    var endOfWeek: Date {
        Calendar.current.date(byAdding: .day, value: 6, to: startOfWeek)?.endOfDay ?? self
    }

    var startOfMonth: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self)) ?? self
    }

    var endOfMonth: Date {
        Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)?.endOfDay ?? self
    }

    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }

    func adding(months: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: months, to: self) ?? self
    }

    func adding(years: Int) -> Date {
        Calendar.current.date(byAdding: .year, value: years, to: self) ?? self
    }

    func isSameDay(as date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }

    func isToday() -> Bool {
        isSameDay(as: Date())
    }

    func isYesterday() -> Bool {
        isSameDay(as: Date().adding(days: -1))
    }

    func isTomorrow() -> Bool {
        isSameDay(as: Date().adding(days: 1))
    }

    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    func formatted(as format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }

    var shortDate: String {
        formatted(as: "MM/dd/yyyy")
    }

    var longDate: String {
        formatted(as: "MMMM dd, yyyy")
    }

    var timeOnly: String {
        formatted(as: "HH:mm")
    }

    var dateAndTime: String {
        formatted(as: "MM/dd/yyyy HH:mm")
    }
}

// MARK: - Double Extensions

extension Double {
    func rounded(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

    var percentageString: String {
        String(format: "%.1f%%", self * 100)
    }

    var currencyString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: self)) ?? "$0.00"
    }

    func clamped(to range: ClosedRange<Double>) -> Double {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

extension Float {
    func rounded(to places: Int) -> Float {
        let divisor = powf(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }

    func clamped(to range: ClosedRange<Float>) -> Float {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

extension CGFloat {
    func rounded(to places: Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(places))
        return (self * divisor).rounded() / divisor
    }

    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

// MARK: - Int Extensions

extension Int {
    var ordinal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }

    var romanNumeral: String? {
        // Simple Roman numeral conversion for numbers 1-3999
        guard self > 0 && self < 4000 else { return nil }

        let romanValues = [
            (1000, "M"), (900, "CM"), (500, "D"), (400, "CD"),
            (100, "C"), (90, "XC"), (50, "L"), (40, "XL"),
            (10, "X"), (9, "IX"), (5, "V"), (4, "IV"), (1, "I")
        ]

        var result = ""
        var number = self

        for (value, symbol) in romanValues {
            while number >= value {
                result += symbol
                number -= value
            }
        }

        return result
    }

    func times(_ closure: () -> Void) {
        for _ in 0..<self {
            closure()
        }
    }

    func times(_ closure: (Int) -> Void) {
        for i in 0..<self {
            closure(i)
        }
    }
}

// MARK: - Dictionary Extensions

extension Dictionary {
    func merged(with other: [Key: Value]) -> [Key: Value] {
        var copy = self
        for (key, value) in other {
            copy[key] = value
        }
        return copy
    }

    mutating func merge(with other: [Key: Value]) {
        for (key, value) in other {
            self[key] = value
        }
    }

    func mapKeys<T: Hashable>(_ transform: (Key) -> T) -> [T: Value] {
        var result: [T: Value] = [:]
        for (key, value) in self {
            result[transform(key)] = value
        }
        return result
    }

    func mapValues<T>(_ transform: (Value) -> T) -> [Key: T] {
        var result: [Key: T] = [:]
        for (key, value) in self {
            result[key] = transform(value)
        }
        return result
    }
}

// MARK: - Optional Extensions

extension Optional {
    func or(_ defaultValue: Wrapped) -> Wrapped {
        self ?? defaultValue
    }

    func or(else closure: () -> Wrapped) -> Wrapped {
        self ?? closure()
    }

    var isNil: Bool {
        self == nil
    }

    var isNotNil: Bool {
        self != nil
    }
}

extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        self?.isEmpty ?? true
    }

    var isNotNilOrEmpty: Bool {
        !isNilOrEmpty
    }
}

extension Optional where Wrapped: Collection {
    var isNilOrEmpty: Bool {
        self?.isEmpty ?? true
    }

    var isNotNilOrEmpty: Bool {
        !isNilOrEmpty
    }
}

// MARK: - Result Extensions

extension Result {
    var isSuccess: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }

    var isFailure: Bool {
        !isSuccess
    }

    func mapSuccess<T>(_ transform: (Success) -> T) -> Result<T, Failure> {
        switch self {
        case .success(let value): return .success(transform(value))
        case .failure(let error): return .failure(error)
        }
    }

    func mapFailure<T>(_ transform: (Failure) -> T) -> Result<Success, T> {
        switch self {
        case .success(let value): return .success(value)
        case .failure(let error): return .failure(transform(error))
        }
    }
}

// MARK: - URL Extensions

extension URL {
    var queryParameters: [String: String] {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return [:]
        }

        return Dictionary(uniqueKeysWithValues: queryItems.compactMap {
            guard let value = $0.value else { return nil }
            return ($0.name, value)
        })
    }

    func appendingQueryParameters(_ parameters: [String: String]) -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false) ?? URLComponents()
        var queryItems = components.queryItems ?? []

        for (key, value) in parameters {
            queryItems.append(URLQueryItem(name: key, value: value))
        }

        components.queryItems = queryItems
        return components.url ?? self
    }

    var isImage: Bool {
        let imageExtensions = ["jpg", "jpeg", "png", "gif", "bmp", "tiff", "webp"]
        return imageExtensions.contains(pathExtension.lowercased())
    }

    var isVideo: Bool {
        let videoExtensions = ["mp4", "mov", "avi", "mkv", "wmv", "flv", "webm"]
        return videoExtensions.contains(pathExtension.lowercased())
    }
}

// MARK: - Color Extensions for Data

extension Color {
    init?(hex: String) {
        guard let uiColor = UIColor(hex: hex) else { return nil }
        self.init(uiColor)
    }

    var hexString: String {
        UIColor(self).hexString
    }
}