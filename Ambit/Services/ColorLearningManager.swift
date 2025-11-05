//
//  ColorLearningManager.swift
//  Ambit
//
//  Created by Daniel on 2024.
//

import SwiftUI

enum ColorLearningManager {
    // MARK: - Learning Content

    static let learningModules: [LearningModule] = [
        LearningModule(
            id: "basics",
            title: "Color Basics",
            description: "Learn the fundamentals of color theory",
            icon: "circle.fill",
            color: .blue,
            lessons: [
                Lesson(
                    id: "what-is-color",
                    title: "What is Color?",
                    content: """
                    Color is the visual perception of different wavelengths of light. When light hits an object, some wavelengths are absorbed while others are reflected. The reflected wavelengths determine the color we see.

                    **Key Concepts:**
                    • **Hue**: The pure color (red, blue, yellow, etc.)
                    • **Saturation**: How pure or intense the color is
                    • **Brightness**: How light or dark the color is
                    • **Temperature**: Warm colors (reds, oranges) vs. cool colors (blues, greens)
                    """,
                    interactiveElements: [
                        InteractiveElement(type: .colorWheel, data: ["showLabels": true]),
                        InteractiveElement(type: .colorMixer, data: ["colors": ["red", "blue", "yellow"]])
                    ]
                ),
                Lesson(
                    id: "color-models",
                    title: "Color Models",
                    content: """
                    Different color models help us understand and work with colors in various contexts.

                    **RGB (Red, Green, Blue):**
                    • Used for digital displays
                    • Additive color model
                    • Values range from 0-255

                    **HSB (Hue, Saturation, Brightness):**
                    • More intuitive for artists
                    • Hue: 0-360° (color wheel position)
                    • Saturation: 0-100% (color purity)
                    • Brightness: 0-100% (lightness)

                    **CMYK (Cyan, Magenta, Yellow, Black):**
                    • Used for printing
                    • Subtractive color model
                    • Black (K) is added for deeper blacks
                    """,
                    interactiveElements: [
                        InteractiveElement(type: .colorSpaceConverter, data: ["from": "rgb", "to": "hsb"])
                    ]
                )
            ]
        ),

        LearningModule(
            id: "harmony",
            title: "Color Harmony",
            description: "Master the art of combining colors effectively",
            icon: "sparkles",
            color: .purple,
            lessons: [
                Lesson(
                    id: "harmony-principles",
                    title: "Principles of Harmony",
                    content: """
                    Color harmony is the pleasing arrangement of colors. Harmonious color combinations create visual balance and are aesthetically pleasing.

                    **Types of Color Harmony:**

                    **Complementary Colors:**
                    • Colors opposite each other on the color wheel
                    • Create high contrast and vibrancy
                    • Examples: Red-Green, Blue-Orange, Yellow-Purple

                    **Analogous Colors:**
                    • Colors adjacent to each other on the color wheel
                    • Create serene and comfortable designs
                    • Examples: Blue-Blue-Green-Green

                    **Triadic Colors:**
                    • Three colors equally spaced on the color wheel
                    • Create vibrant yet balanced compositions
                    • Examples: Red-Yellow-Blue, Orange-Green-Purple
                    """,
                    interactiveElements: [
                        InteractiveElement(type: .harmonyExplorer, data: ["types": ["complementary", "analogous", "triadic"]])
                    ]
                ),
                Lesson(
                    id: "creating-harmonies",
                    title: "Creating Color Harmonies",
                    content: """
                    Learn practical techniques for creating harmonious color palettes.

                    **Step 1: Choose a Base Color**
                    Start with a color that represents your brand, mood, or subject.

                    **Step 2: Select Harmony Type**
                    • **Monochromatic**: Variations of the same hue
                    • **Complementary**: High contrast combinations
                    • **Split-Complementary**: Softer complementary variations
                    • **Triadic**: Balanced three-color schemes
                    • **Tetradic**: Four-color schemes for complex designs

                    **Step 3: Adjust Values**
                    Modify brightness and saturation to create depth and hierarchy.

                    **Step 4: Test and Refine**
                    Always test your combinations in context and make adjustments as needed.
                    """,
                    interactiveElements: [
                        InteractiveElement(type: .paletteBuilder, data: ["baseColor": "#FF6B6B"])
                    ]
                )
            ]
        ),

        LearningModule(
            id: "accessibility",
            title: "Color Accessibility",
            description: "Ensure your colors are inclusive and accessible",
            icon: "accessibility",
            color: .green,
            lessons: [
                Lesson(
                    id: "contrast-basics",
                    title: "Contrast Fundamentals",
                    content: """
                    Color contrast is crucial for readability and accessibility. Poor contrast can make text difficult or impossible to read.

                    **WCAG Guidelines:**

                    **Level AA (Minimum):**
                    • Normal text: 4.5:1 contrast ratio
                    • Large text: 3:1 contrast ratio
                    • UI components: 3:1 contrast ratio

                    **Level AAA (Enhanced):**
                    • Normal text: 7:1 contrast ratio
                    • Large text: 4.5:1 contrast ratio

                    **Measuring Contrast:**
                    Contrast ratio is calculated using the relative luminance of two colors. Tools like this app can help you measure and ensure compliance.
                    """,
                    interactiveElements: [
                        InteractiveElement(type: .contrastChecker, data: ["text": "Sample Text", "background": "#FFFFFF"])
                    ]
                ),
                Lesson(
                    id: "color-blindness",
                    title: "Color Blindness Awareness",
                    content: """
                    Color blindness affects how people perceive colors. Understanding different types helps create inclusive designs.

                    **Common Types:**

                    **Deuteranopia (6% of males):**
                    • Reduced sensitivity to green light
                    • Difficulty distinguishing red and green

                    **Protanopia (2% of males):**
                    • Reduced sensitivity to red light
                    • Difficulty distinguishing red and green

                    **Tritanopia (0.003% of population):**
                    • Reduced sensitivity to blue light
                    • Difficulty distinguishing blue and yellow

                    **Design Considerations:**
                    • Don't rely solely on color to convey information
                    • Use patterns, shapes, and text labels
                    • Ensure sufficient contrast for all users
                    • Test designs with color blindness simulation tools
                    """,
                    interactiveElements: [
                        InteractiveElement(type: .visionSimulator, data: ["types": ["deuteranopia", "protanopia", "tritanopia"]])
                    ]
                )
            ]
        ),

        LearningModule(
            id: "advanced",
            title: "Advanced Techniques",
            description: "Professional color techniques and workflows",
            icon: "star.fill",
            color: .orange,
            lessons: [
                Lesson(
                    id: "color-psychology",
                    title: "Color Psychology",
                    content: """
                    Colors evoke emotional responses and can influence perception and behavior.

                    **Warm Colors (Reds, Oranges, Yellows):**
                    • Energy, passion, warmth
                    • Stimulating and attention-grabbing
                    • Associated with food, danger, excitement

                    **Cool Colors (Blues, Greens, Purples):**
                    • Calm, trust, professionalism
                    • Relaxing and trustworthy
                    • Associated with nature, technology, luxury

                    **Neutral Colors (Grays, Browns, Beiges):**
                    • Balance, sophistication, timelessness
                    • Background colors that don't compete
                    • Associated with stability and reliability

                    **Context Matters:**
                    Cultural differences affect color meanings. Always consider your audience and context.
                    """,
                    interactiveElements: [
                        InteractiveElement(type: .emotionColorMap, data: [:])
                    ]
                ),
                Lesson(
                    id: "professional-workflows",
                    title: "Professional Workflows",
                    content: """
                    Learn systematic approaches to color selection and application.

                    **1. Define Your Goals**
                    • What mood or message do you want to convey?
                    • Who is your target audience?
                    • What is the context of use?

                    **2. Research and Inspiration**
                    • Analyze successful designs in your field
                    • Study color trends and psychology
                    • Gather visual references

                    **3. Create and Test**
                    • Generate color palettes using harmony rules
                    • Test combinations in your actual design
                    • Check accessibility compliance

                    **4. Refine and Document**
                    • Make adjustments based on feedback
                    • Document your color choices
                    • Create guidelines for consistent application

                    **5. Maintain Consistency**
                    • Use design systems and style guides
                    • Regularly audit your color usage
                    • Update palettes as needed
                    """,
                    interactiveElements: [
                        InteractiveElement(type: .workflowGuide, data: ["steps": ["research", "create", "test", "refine"]])
                    ]
                )
            ]
        )
    ]

    // MARK: - Progress Tracking

    static func getModuleProgress(for moduleId: String) -> ModuleProgress {
        // In a real app, this would load from persistent storage
        // For now, return mock progress
        return ModuleProgress(
            moduleId: moduleId,
            completedLessons: [],
            currentLesson: learningModules.first { $0.id == moduleId }?.lessons.first?.id,
            quizScores: [:],
            timeSpent: 0
        )
    }

    static func updateLessonProgress(moduleId: String, lessonId: String, completed: Bool) {
        // In a real app, this would save to persistent storage
        print("Updated progress for lesson \(lessonId) in module \(moduleId): \(completed)")
    }

    // MARK: - Quiz System

    static func getQuiz(for lessonId: String) -> Quiz? {
        // Mock quiz data - in a real app, this would be loaded from a database
        switch lessonId {
        case "what-is-color":
            return Quiz(
                questions: [
                    LearningQuizQuestion(
                        question: "What determines the color we see when light hits an object?",
                        options: ["The absorbed wavelengths", "The reflected wavelengths", "The object's temperature", "The air humidity"],
                        correctAnswer: 1,
                        explanation: "The reflected wavelengths determine the color we perceive."
                    ),
                    LearningQuizQuestion(
                        question: "Which component describes how pure or intense a color is?",
                        options: ["Hue", "Saturation", "Brightness", "Temperature"],
                        correctAnswer: 1,
                        explanation: "Saturation describes how pure or intense a color is."
                    )
                ]
            )
        case "harmony-principles":
            return Quiz(
                questions: [
                    LearningQuizQuestion(
                        question: "What type of harmony do colors opposite each other on the color wheel create?",
                        options: ["Analogous", "Complementary", "Triadic", "Monochromatic"],
                        correctAnswer: 1,
                        explanation: "Complementary colors are opposite each other on the color wheel."
                    )
                ]
            )
        default:
            return nil
        }
    }

    // MARK: - Interactive Elements

    static func createInteractiveElement(_ element: InteractiveElement) -> AnyView {
        switch element.type {
        case .colorWheel:
            return AnyView(ColorWheelView(showLabels: element.data["showLabels"] as? Bool ?? false))
        case .colorMixer:
            return AnyView(ColorMixerView(availableColors: element.data["colors"] as? [String] ?? []))
        case .harmonyExplorer:
            return AnyView(HarmonyExplorerView(harmonyTypes: element.data["types"] as? [String] ?? []))
        case .contrastChecker:
            return AnyView(ContrastCheckerView(
                text: element.data["text"] as? String ?? "Sample Text",
                backgroundColor: Color(hex: element.data["background"] as? String ?? "#FFFFFF") ?? .white
            ))
        case .visionSimulator:
            return AnyView(VisionSimulatorView(visionTypes: element.data["types"] as? [String] ?? []))
        default:
            return AnyView(Text("Interactive element not implemented"))
        }
    }

    // MARK: - Learning Analytics

    static func getLearningAnalytics() -> LearningAnalytics {
        // Mock analytics - in a real app, this would aggregate user data
        return LearningAnalytics(
            totalModules: learningModules.count,
            completedModules: 0,
            totalLessons: learningModules.reduce(0) { $0 + $1.lessons.count },
            completedLessons: 0,
            averageQuizScore: 0.0,
            totalTimeSpent: 0,
            favoriteTopics: [],
            areasForImprovement: []
        )
    }
}

// MARK: - Supporting Types

struct LearningModule: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let color: Color
    let lessons: [Lesson]
}

struct Lesson: Identifiable {
    let id: String
    let title: String
    let content: String
    let interactiveElements: [InteractiveElement]
}

struct InteractiveElement {
    let type: InteractiveType
    let data: [String: Any]
}

enum InteractiveType {
    case colorWheel
    case colorMixer
    case colorSpaceConverter
    case harmonyExplorer
    case paletteBuilder
    case contrastChecker
    case visionSimulator
    case emotionColorMap
    case workflowGuide
}

struct Quiz {
    let questions: [LearningQuizQuestion]
}

struct LearningQuizQuestion {
    let question: String
    let options: [String]
    let correctAnswer: Int
    let explanation: String
}

struct ModuleProgress {
    let moduleId: String
    var completedLessons: [String]
    var currentLesson: String?
    var quizScores: [String: Double]
    var timeSpent: TimeInterval

    var completionPercentage: Double {
        guard let totalLessons = ColorLearningManager.learningModules.first(where: { $0.id == moduleId })?.lessons.count else {
            return 0.0
        }
        return Double(completedLessons.count) / Double(totalLessons)
    }
}

struct LearningAnalytics {
    let totalModules: Int
    let completedModules: Int
    let totalLessons: Int
    let completedLessons: Int
    let averageQuizScore: Double
    let totalTimeSpent: TimeInterval
    let favoriteTopics: [String]
    let areasForImprovement: [String]

    var overallProgress: Double {
        Double(completedLessons) / Double(totalLessons)
    }
}

// MARK: - Mock Views (These would be implemented as actual SwiftUI views)

struct ColorWheelView: View {
    let showLabels: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            .red, .orange, .yellow, .green, .blue, .purple, .red
                        ]),
                        center: .center
                    )
                )
            if showLabels {
                Text("Hue")
                    .font(.caption)
                    .foregroundColor(.white)
            }
        }
        .frame(width: 200, height: 200)
    }
}

struct ColorMixerView: View {
    let availableColors: [String]

    var body: some View {
        VStack {
            Text("Color Mixer")
            HStack {
                ForEach(availableColors, id: \.self) { colorName in
                    Circle()
                        .fill(Color(colorName))
                        .frame(width: 50, height: 50)
                }
            }
        }
    }
}

struct HarmonyExplorerView: View {
    let harmonyTypes: [String]

    var body: some View {
        VStack {
            Text("Harmony Explorer")
            ForEach(harmonyTypes, id: \.self) { type in
                Text(type.capitalized)
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
            }
        }
    }
}

struct ContrastCheckerView: View {
    let text: String
    let backgroundColor: Color

    var body: some View {
        ZStack {
            backgroundColor
            Text(text)
                .foregroundColor(.black)
                .padding()
        }
        .frame(height: 100)
        .cornerRadius(8)
    }
}

struct VisionSimulatorView: View {
    let visionTypes: [String]

    var body: some View {
        VStack {
            Text("Vision Simulator")
            ForEach(visionTypes, id: \.self) { type in
                Text("Simulating: \(type)")
                    .padding()
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
            }
        }
    }
}