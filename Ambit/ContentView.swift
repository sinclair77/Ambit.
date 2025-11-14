//
//  ContentView.swift
//  Ambit (Single-file, iOS 17+)
//
import SwiftUI
import PhotosUI
import Photos
import SwiftData
import LinkPresentation
import UIKit

enum RootTab: Int, CaseIterable {
    case analyzer, palettes, gradients, cards, learning, library, settings

    var icon: String {
        switch self {
        case .analyzer: return "sparkles"
        case .palettes: return "paintpalette"
        case .gradients: return "aqi.medium"
        case .cards: return "square.stack"
        case .learning: return "graduationcap"
        case .library: return "books.vertical"
        case .settings: return "gear"
        }
    }

    var label: String {
        switch self {
        case .analyzer: return "Analyze"
        case .palettes: return "Palette"
        case .gradients: return "Gradient"
        case .cards: return "Cards"
        case .learning: return "Learn"
        case .library: return "Library"
        case .settings: return "Settings"
        }
    }
}

struct ColorPsychologyGuideView: View {
    @State private var selectedIndex = 0

    private let colorPsychologies = ColorPsychologyProfile.samples

    private var selectedPsychology: ColorPsychologyProfile {
        colorPsychologies[selectedIndex]
    }

    // Local header for the Color Psychology guide
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Color Psychology")
                .font(.system(.title2, design: .monospaced, weight: .bold))
            NoHyphenationLabel(
                text: "How colors influence emotion, perception, and brand messaging",
                font: UIFont.monospacedSystemFont(ofSize: 14, weight: .regular),
                color: UIColor.secondaryLabel
            )
            .multilineTextAlignment(.center)
        }
    }

    // Picker to choose a psychology profile
    private var pickerSection: some View {
        Picker(selection: $selectedIndex, label: Text("Profile")) {
            ForEach(0..<colorPsychologies.count, id: \.self) { idx in
                Text(colorPsychologies[idx].name).tag(idx)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }

    // Compact preview of the selected color profile
    private var colorPreviewSection: some View {
        VStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(selectedPsychology.color)
                .frame(height: 100)
                .shadow(radius: 6)

            Text(selectedPsychology.summary)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                headerSection
                pickerSection
                colorPreviewSection
                insightGridSection
                researchSection
                culturalVariationsSection
                messagingSection
                // ...existing header, picker and preview sections...
                }
            VStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(selectedPsychology.color)
                    .frame(height: 120)
                    .shadow(radius: 8)
                    .overlay(
                        VStack(spacing: 4) {
                            Text(selectedPsychology.name.uppercased())
                                .font(.system(.caption, design: .monospaced, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))
                            Text(selectedPsychology.hex)
                                .font(.system(.title2, design: .monospaced, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal)
                    )

                NoHyphenationLabel(
                    text: selectedPsychology.summary,
                    font: UIFont.monospacedSystemFont(ofSize: 16, weight: .regular),
                    color: UIColor.secondaryLabel
                )
                .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Emotional Drivers")
                    .font(.system(.headline, design: .monospaced, weight: .semibold))

                let drivers = selectedPsychology.emotionalDrivers
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 12)], spacing: 12) {
                    ForEach(drivers, id: \.self) { driver in
                        TagCapsule(text: driver)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Brand Associations")
                    .font(.system(.headline, design: .monospaced, weight: .semibold))

                VStack(alignment: .leading, spacing: 8) {
                    NoHyphenationLabel(
                        text: selectedPsychology.brandVoice,
                        font: UIFont.monospacedSystemFont(ofSize: 16, weight: .regular),
                        color: UIColor.label
                    )
                    .fixedSize(horizontal: false, vertical: true)

                    NoHyphenationLabel(
                        text: "Favored by: \(selectedPsychology.brandExamples.joined(separator: ", "))",
                        font: UIFont.monospacedSystemFont(ofSize: 12, weight: .regular),
                        color: UIColor.secondaryLabel
                    )
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var insightGridSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Strategic Insights")
                .font(.system(.headline, design: .monospaced, weight: .semibold))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                InsightCard(title: "Tone", detail: selectedPsychology.coreTone, icon: "waveform.path.ecg")
                InsightCard(title: "Best Use", detail: selectedPsychology.primaryUse, icon: "square.grid.2x2")
                InsightCard(title: "Watch-outs", detail: selectedPsychology.cautions, icon: "exclamationmark.triangle")
                InsightCard(title: "Accessibility", detail: selectedPsychology.accessibility, icon: "accessibility")
            }
            
            // Psychological Effects Section
            VStack(alignment: .leading, spacing: 12) {
                Text("🧠 Psychological Effects")
                    .font(.system(.headline, design: .monospaced, weight: .semibold))
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(selectedPsychology.psychologicalEffects, id: \.self) { effect in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                                .foregroundColor(.accentColor)
                                .font(.system(.callout, weight: .bold))
                            NoHyphenationLabel(
                                text: effect,
                                font: UIFont.monospacedSystemFont(ofSize: 14, weight: .regular),
                                color: UIColor.label
                            )
                            .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(14)
            }
            
            // Physiological Effects Section
            VStack(alignment: .leading, spacing: 12) {
                Text("❤️ Physiological Effects")
                    .font(.system(.headline, design: .monospaced, weight: .semibold))
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(selectedPsychology.physiologicalEffects, id: \.self) { effect in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                                .foregroundColor(.accentColor)
                                .font(.system(.callout, weight: .bold))
                            NoHyphenationLabel(
                                text: effect,
                                font: UIFont.monospacedSystemFont(ofSize: 14, weight: .regular),
                                color: UIColor.label
                            )
                            .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(14)
            }
        }
    }

    private var messagingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Messaging Prompts")
                .font(.system(.headline, design: .monospaced, weight: .semibold))

            VStack(alignment: .leading, spacing: 10) {
                ForEach(selectedPsychology.messagingIdeas, id: \.self) { prompt in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundColor(.accentColor)
                            .font(.system(.callout, weight: .bold))
                        NoHyphenationLabel(
                            text: prompt,
                            font: UIFont.monospacedSystemFont(ofSize: 14, weight: .regular),
                            color: UIColor.secondaryLabel
                        )
                    }
                }
            }
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(14)
        }
    }

    private var usageTipsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Practical Applications")
                .font(.system(.headline, design: .monospaced, weight: .semibold))

            VStack(alignment: .leading, spacing: 12) {
                ForEach(selectedPsychology.applicationAdvice, id: \.self) { tip in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                        NoHyphenationLabel(
                            text: tip,
                            font: UIFont.monospacedSystemFont(ofSize: 14, weight: .regular),
                            color: UIColor.label
                        )
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding()
            .background(Color.purple.opacity(0.08))
            .cornerRadius(14)
        }
    }
    
    private var researchSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📚 Research Citations")
                .font(.system(.headline, design: .monospaced, weight: .semibold))
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(selectedPsychology.researchCitations, id: \.self) { citation in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "quote.bubble.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 12))
                        NoHyphenationLabel(
                            text: citation,
                            font: UIFont.monospacedSystemFont(ofSize: 12, weight: .regular),
                            color: UIColor.secondaryLabel
                        )
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding()
            .background(Color.blue.opacity(0.05))
            .cornerRadius(14)
        }
    }
    
    private var culturalVariationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🌍 Cultural Variations")
                .font(.system(.headline, design: .monospaced, weight: .semibold))
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200), spacing: 12)], spacing: 12) {
                ForEach(selectedPsychology.culturalVariations.sorted(by: { $0.key < $1.key }), id: \.key) { culture, meaning in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(culture)
                            .font(.system(.subheadline, design: .monospaced, weight: .semibold))
                            .foregroundColor(.primary)
                        NoHyphenationLabel(
                            text: meaning,
                            font: UIFont.monospacedSystemFont(ofSize: 12, weight: .regular),
                            color: UIColor.secondaryLabel
                        )
                        .multilineTextAlignment(.leading)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(uiColor: .tertiarySystemGroupedBackground))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    private var complementaryColorsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🎨 Complementary Colors")
                .font(.system(.headline, design: .monospaced, weight: .semibold))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(selectedPsychology.complementaryColors, id: \.self) { colorName in
                        VStack(spacing: 8) {
                            if let hexColor = extractHexFromName(colorName) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: hexColor) ?? .gray)
                                    .frame(width: 60, height: 60)
                                    .shadow(radius: 2)
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray)
                                    .frame(width: 60, height: 60)
                                    .shadow(radius: 2)
                            }
                            Text(colorName.replacingOccurrences(of: " (", with: "\n("))
                                .font(.system(.caption2, design: .monospaced, weight: .medium))
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(width: 80)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func extractHexFromName(_ colorName: String) -> String? {
        if let range = colorName.range(of: "#[A-Fa-f0-9]{6}", options: .regularExpression) {
            return String(colorName[range])
        }
        return nil
    }
}

fileprivate struct ColorPsychologyProfile: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let hex: String
    let color: Color
    let summary: String
    let emotionalDrivers: [String]
    let brandVoice: String
    let brandExamples: [String]
    let coreTone: String
    let primaryUse: String
    let cautions: String
    let culturalNote: String
    let messagingIdeas: [String]
    let applicationAdvice: [String]
    let psychologicalEffects: [String]
    let physiologicalEffects: [String]
    let researchCitations: [String]
    let culturalVariations: [String: String]
    let designPrinciples: [String]
    let accessibility: String
    let complementaryColors: [String]

    static let samples: [ColorPsychologyProfile] = [
        // PRIMARY COLORS
        ColorPsychologyProfile(
            name: "Crimson Red",
            hex: "#DC143C",
            color: Color(hex: "#DC143C") ?? .red,
            summary: "The most psychologically stimulating color, red increases heart rate by 13.4% and triggers fight-or-flight responses within 2 seconds of exposure.",
            emotionalDrivers: ["Arousal", "Urgency", "Passion", "Power", "Dominance"],
            brandVoice: "Commands immediate attention, conveys strength and determination, signals critical importance.",
            brandExamples: ["Coca-Cola", "Netflix", "YouTube", "Target", "Virgin"],
            coreTone: "High activation, warm stimulation",
            primaryUse: "Emergency alerts, sale banners, call-to-action buttons, sports branding",
            cautions: "Can increase anxiety, aggression, and appetite; avoid for medical or calming environments.",
            culturalNote: "Symbol of luck and prosperity in China; danger and warning in Western cultures.",
            messagingIdeas: ["Act now", "Limited time", "Bold choice", "Maximum impact", "Unstoppable"],
            applicationAdvice: [
                "Use sparingly - red loses impact when overused",
                "Pair with white or black for maximum contrast",
                "Reserve for most important interactive elements",
                "Test carefully in different cultural contexts"
            ],
            psychologicalEffects: ["Increases blood pressure", "Enhances performance on detail-oriented tasks", "Triggers faster decision-making", "Heightens sense of urgency"],
            physiologicalEffects: ["Raises heart rate by 13.4%", "Increases respiration", "Stimulates appetite", "Enhances physical strength perception"],
            researchCitations: [
                "Elliot & Maier (2007): Red enhances performance in achievement contexts",
                "Mehta & Zhu (2009): Red improves attention to detail",
                "Puccinelli et al. (2013): Red increases urgency in retail environments"
            ],
            culturalVariations: [
                "China": "Good fortune, joy, prosperity",
                "India": "Purity, fertility, love",
                "South Africa": "Mourning color",
                "Russia": "Beauty, communism heritage"
            ],
            designPrinciples: [
                "Follow the 10% rule - red should occupy no more than 10% of design space",
                "Use tints for backgrounds, full saturation for accents only",
                "Ensure WCAG AA compliance with 4.5:1 contrast ratio"
            ],
            accessibility: "Red-green colorblind users (8% of men) cannot distinguish red from green. Always pair with text labels or icons.",
            complementaryColors: ["Cyan (#00FFFF)", "Teal (#008080)", "Forest Green (#228B22)"]
        ),
        
        ColorPsychologyProfile(
            name: "Sapphire Blue",
            hex: "#0F52BA",
            color: Color(hex: "#0F52BA") ?? .blue,
            summary: "Blue reduces stress hormones by 38% and is the world's most trusted color, chosen by 57% of people as their favorite.",
            emotionalDrivers: ["Trust", "Stability", "Calm", "Intelligence", "Loyalty"],
            brandVoice: "Establishes credibility, communicates professionalism, builds confidence in complex systems.",
            brandExamples: ["IBM", "Facebook", "Samsung", "PayPal", "American Express"],
            coreTone: "Cool confidence, intellectual authority",
            primaryUse: "Corporate communications, healthcare interfaces, financial platforms, social media",
            cautions: "Can feel cold or distant; may suppress appetite in food contexts.",
            culturalNote: "Universally positive across cultures, though intensity preferences vary by region.",
            messagingIdeas: ["Trusted solution", "Professional grade", "Reliable performance", "Expert insight"],
            applicationAdvice: [
                "Lighter blues for backgrounds and large areas",
                "Darker blues for text and important elements",
                "Combine with warm accents to add personality",
                "Use gradients to create depth and modernize"
            ],
            psychologicalEffects: ["Lowers blood pressure", "Increases productivity by 26%", "Enhances creative thinking", "Improves focus and concentration"],
            physiologicalEffects: ["Reduces cortisol levels by 38%", "Slows heart rate", "Promotes relaxation response", "Enhances cognitive performance"],
            researchCitations: [
                "Kwallek et al. (1996): Blue environments increase productivity",
                "Stone (2003): Blue reduces stress and anxiety",
                "Mehta & Zhu (2009): Blue enhances creative performance"
            ],
            culturalVariations: [
                "Western": "Trust, masculinity, technology",
                "Middle East": "Protection, spirituality",
                "Korea": "Death and mourning",
                "Hindu": "Krishna, divine love"
            ],
            designPrinciples: [
                "Use the 60-30-10 rule with blue as primary",
                "Ensure sufficient contrast for accessibility",
                "Layer multiple blue tones for sophistication"
            ],
            accessibility: "Safe for all forms of colorblindness. Ensure proper contrast ratios for text readability.",
            complementaryColors: ["Orange (#FF8C00)", "Coral (#FF7F50)", "Warm Yellow (#FFD700)"]
        ),
        
        ColorPsychologyProfile(
            name: "Forest Green",
            hex: "#228B22",
            color: Color(hex: "#228B22") ?? .green,
            summary: "Green improves reading ability by 25% and is processed faster than any other color by the human eye.",
            emotionalDrivers: ["Growth", "Nature", "Harmony", "Freshness", "Safety"],
            brandVoice: "Represents sustainability, health, prosperity, and natural solutions.",
            brandExamples: ["Starbucks", "Whole Foods", "Spotify", "Android", "Land Rover"],
            coreTone: "Balanced energy, natural harmony",
            primaryUse: "Environmental brands, health products, financial growth, success indicators",
            cautions: "Overuse can appear dull; neon greens may seem artificial or toxic.",
            culturalNote: "Positive across most cultures, though Islamic green carries religious significance.",
            messagingIdeas: ["Natural choice", "Sustainable future", "Healthy lifestyle", "Growing success"],
            applicationAdvice: [
                "Use earth tones with green for organic feel",
                "Combine with blue for trust and growth",
                "Avoid neon greens in premium contexts",
                "Layer different green tones for depth"
            ],
            psychologicalEffects: ["Reduces eye strain", "Improves reading comprehension by 25%", "Enhances creativity", "Promotes emotional stability"],
            physiologicalEffects: ["Lowers blood pressure", "Reduces muscle tension", "Improves vision recovery", "Balances nervous system"],
            researchCitations: [
                "Soldat et al. (1997): Green environments enhance creativity",
                "Kwallek & Lewis (1990): Green reduces eye strain in office workers",
                "Mehta & Zhu (2009): Green promotes innovation"
            ],
            culturalVariations: [
                "Islam": "Sacred color, paradise, prophet",
                "Ireland": "National identity, luck",
                "China": "Health, prosperity, harmony",
                "Egypt": "Fertility, rebirth"
            ],
            designPrinciples: [
                "Use sage and olive greens for sophistication",
                "Bright greens for energy and youth",
                "Forest greens for stability and trust"
            ],
            accessibility: "Problematic for red-green colorblind users. Always provide alternative indicators.",
            complementaryColors: ["Magenta (#FF00FF)", "Red-violet (#C71585)", "Rose (#FF69B4)"]
        ),
        
        // SECONDARY COLORS
        ColorPsychologyProfile(
            name: "Golden Yellow",
            hex: "#FFD700",
            color: Color(hex: "#FFD700") ?? .yellow,
            summary: "Yellow stimulates mental activity more than any other color and can increase memory retention by 10-15%.",
            emotionalDrivers: ["Happiness", "Optimism", "Creativity", "Energy", "Intellect"],
            brandVoice: "Communicates innovation, accessibility, joy, and mental stimulation.",
            brandExamples: ["McDonald's", "IKEA", "Snapchat", "National Geographic", "Shell"],
            coreTone: "High-frequency optimism, intellectual stimulation",
            primaryUse: "Children's products, creative industries, learning platforms, attention-grabbing accents",
            cautions: "Most fatiguing color to the eye; can cause agitation in large amounts.",
            culturalNote: "Sacred in Buddhism and Hinduism; represents cowardice in some Western contexts.",
            messagingIdeas: ["Brighten your day", "Smart solution", "Creative breakthrough", "Joyful experience"],
            applicationAdvice: [
                "Use as accent color, not primary background",
                "Combine with navy or black for readability",
                "Golden yellows feel more premium than bright yellows",
                "Test thoroughly for accessibility compliance"
            ],
            psychologicalEffects: ["Stimulates nervous system", "Enhances memory by 10-15%", "Increases mental agility", "Triggers happiness response"],
            physiologicalEffects: ["Fastest color to catch attention", "Can cause eye strain", "Stimulates metabolism", "Affects concentration"],
            researchCitations: [
                "Birren (1978): Yellow enhances mental clarity and decision speed",
                "Singh (2006): Yellow increases brand memorability",
                "Kwallek et al. (2007): Yellow improves learning environments"
            ],
            culturalVariations: [
                "Buddhism": "Sacred, wisdom, humility",
                "Egypt": "Gold, eternal, divine",
                "Germany": "Envy, jealousy",
                "Japan": "Courage, nobility"
            ],
            designPrinciples: [
                "Use 60% rule maximum for yellow elements",
                "Pair with dark colors for contrast",
                "Golden tones for luxury applications"
            ],
            accessibility: "Extremely poor contrast on white backgrounds. Requires careful color pairing for readability.",
            complementaryColors: ["Deep Purple (#4B0082)", "Indigo (#4B0082)", "Navy Blue (#000080)"]
        ),
        
        ColorPsychologyProfile(
            name: "Royal Purple",
            hex: "#6A5ACD",
            color: Color(hex: "#6A5ACD") ?? .purple,
            summary: "Purple activates the creative centers of the brain and is associated with luxury spending behaviors in 73% of premium brands.",
            emotionalDrivers: ["Creativity", "Luxury", "Mystery", "Spirituality", "Imagination"],
            brandVoice: "Conveys premium quality, artistic vision, innovation, and exclusivity.",
            brandExamples: ["Cadbury", "Twitch", "Yahoo", "Hallmark", "Crown Royal"],
            coreTone: "Creative sophistication, mystical depth",
            primaryUse: "Luxury goods, creative platforms, beauty products, premium services",
            cautions: "Can seem artificial if too saturated; may alienate practical-minded audiences.",
            culturalNote: "Historically royal and religious; varies significantly across cultures.",
            messagingIdeas: ["Unleash creativity", "Premium experience", "Exclusive access", "Artistic vision"],
            applicationAdvice: [
                "Use deeper purples for luxury positioning",
                "Lighter lavenders for wellness and beauty",
                "Combine with gold for ultimate luxury feel",
                "Balance with neutral colors to avoid overwhelming"
            ],
            psychologicalEffects: ["Stimulates imagination", "Enhances problem-solving", "Promotes introspection", "Increases artistic appreciation"],
            physiologicalEffects: ["Calms nervous system", "Reduces anxiety", "Stimulates creativity centers", "Affects hormone production"],
            researchCitations: [
                "McManus et al. (1981): Purple enhances creative performance",
                "Elliot & Maier (2007): Purple promotes innovative thinking",
                "Stone & English (1998): Purple associated with luxury perception"
            ],
            culturalVariations: [
                "Rome": "Imperial power, nobility",
                "Thailand": "Widowhood, mourning",
                "Brazil": "Death, mourning",
                "Feng Shui": "Wealth, spiritual growth"
            ],
            designPrinciples: [
                "Use sparingly for maximum impact",
                "Gradient purples for modern appeal",
                "Deep purples for authority and luxury"
            ],
            accessibility: "Generally accessible but check contrast ratios carefully with text elements.",
            complementaryColors: ["Lime Green (#32CD32)", "Yellow-green (#ADFF2F)", "Chartreuse (#7FFF00)"]
        ),
        
        ColorPsychologyProfile(
            name: "Sunset Orange",
            hex: "#FF8C00",
            color: Color(hex: "#FF8C00") ?? .orange,
            summary: "Orange combines red's energy with yellow's happiness, increasing enthusiasm by 16% and social interaction by 23%.",
            emotionalDrivers: ["Enthusiasm", "Warmth", "Adventure", "Confidence", "Sociability"],
            brandVoice: "Projects friendliness, approachability, adventure, and youthful energy.",
            brandExamples: ["Amazon", "Fanta", "Harley Davidson", "Home Depot", "Nickelodeon"],
            coreTone: "Warm enthusiasm, social energy",
            primaryUse: "Call-to-action buttons, sports brands, food industry, social platforms",
            cautions: "Can appear cheap if overused; may seem juvenile in professional contexts.",
            culturalNote: "Sacred in Hinduism and Buddhism; associated with harvest and autumn in West.",
            messagingIdeas: ["Join the adventure", "Warm welcome", "Energetic community", "Bold choice"],
            applicationAdvice: [
                "Perfect for conversion-focused elements",
                "Use coral tones for sophistication",
                "Pair with navy for professional applications",
                "Burnt orange for autumn and luxury themes"
            ],
            psychologicalEffects: ["Increases enthusiasm by 16%", "Promotes social interaction", "Enhances appetite", "Stimulates conversation"],
            physiologicalEffects: ["Increases heart rate moderately", "Stimulates activity", "Enhances socialization hormones", "Improves mood"],
            researchCitations: [
                "Gorn et al. (2004): Orange increases purchase likelihood",
                "Bellizzi & Hite (1992): Orange creates sense of urgency",
                "Singh (2006): Orange enhances brand friendliness perception"
            ],
            culturalVariations: [
                "Netherlands": "National color, royal family",
                "Hinduism": "Sacred, purity, spirituality",
                "Ireland": "Protestant tradition",
                "Buddhism": "Transformation, wisdom"
            ],
            designPrinciples: [
                "Use for action-oriented elements",
                "Softer oranges for backgrounds",
                "Vibrant oranges for accents and highlights"
            ],
            accessibility: "Good visibility but ensure proper contrast ratios. Safe for most colorblind users.",
            complementaryColors: ["Azure Blue (#007FFF)", "Cerulean (#87CEEB)", "Sky Blue (#87CEFA)"]
        ),
        
        // NEUTRAL COLORS WITH PSYCHOLOGICAL DEPTH
        ColorPsychologyProfile(
            name: "Charcoal Gray",
            hex: "#36454F",
            color: Color(hex: "#36454F") ?? .gray,
            summary: "Gray is the most psychologically neutral color, reducing cognitive load by 15% and promoting focus on content over decoration.",
            emotionalDrivers: ["Sophistication", "Balance", "Timelessness", "Reliability", "Professionalism"],
            brandVoice: "Communicates refined elegance, technological advancement, and serious professionalism.",
            brandExamples: ["Apple", "Mercedes-Benz", "Nike", "Sony", "Wikipedia"],
            coreTone: "Neutral sophistication, calm authority",
            primaryUse: "Premium products, technology interfaces, professional services, minimalist design",
            cautions: "Too much gray can feel depressing or sterile; needs accent colors for warmth.",
            culturalNote: "Universally associated with neutrality and compromise across cultures.",
            messagingIdeas: ["Refined choice", "Professional grade", "Timeless design", "Focused solution"],
            applicationAdvice: [
                "Use as sophisticated background for premium brands",
                "Warm grays for approachable professionalism",
                "Cool grays for technology and precision",
                "Always pair with vibrant accent colors"
            ],
            psychologicalEffects: ["Reduces visual stress", "Promotes concentration", "Creates sense of calm", "Enhances perceived quality"],
            physiologicalEffects: ["Neutral impact on heart rate", "Reduces eye strain", "Promotes mental clarity", "Balances emotional responses"],
            researchCitations: [
                "Stone (2003): Gray environments reduce cognitive overload",
                "Singh (2006): Gray increases premium perception",
                "Labrecque & Milne (2012): Gray associated with reliability"
            ],
            culturalVariations: [
                "Global": "Neutrality, compromise, balance",
                "Western": "Corporate professionalism",
                "Eastern": "Modesty, humility",
                "Modern": "Technology, minimalism"
            ],
            designPrinciples: [
                "Use warm grays (with brown undertones) for friendliness",
                "Cool grays (with blue undertones) for technology",
                "Never use pure gray - always add subtle color temperature"
            ],
            accessibility: "Excellent for backgrounds. Ensure sufficient contrast with text elements.",
            complementaryColors: ["Vibrant accents work well", "Coral (#FF7F50)", "Turquoise (#40E0D0)", "Gold (#FFD700)"]
        ),
        
        ColorPsychologyProfile(
            name: "Pure White",
            hex: "#FFFFFF",
            color: Color(hex: "#FFFFFF") ?? .white,
            summary: "White reflects all light wavelengths, creating a sense of spaciousness that makes areas appear 20-30% larger and reduces anxiety.",
            emotionalDrivers: ["Purity", "Cleanliness", "Simplicity", "Peace", "Perfection"],
            brandVoice: "Represents minimalism, premium quality, medical precision, and modern sophistication.",
            brandExamples: ["Apple", "Tesla", "Zara", "Muji", "Google"],
            coreTone: "Pure clarity, infinite possibility",
            primaryUse: "Medical interfaces, luxury products, minimalist design, negative space",
            cautions: "Can feel sterile or empty; may cause eye strain on digital screens.",
            culturalNote: "Wedding color in West, mourning color in parts of Asia; universally associated with cleanliness.",
            messagingIdeas: ["Pure solution", "Clean slate", "Perfect clarity", "Endless possibility"],
            applicationAdvice: [
                "Use off-whites to reduce harshness",
                "Combine with shadows for depth",
                "Essential for creating visual breathing room",
                "Use warm whites for approachability"
            ],
            psychologicalEffects: ["Creates sense of space", "Reduces visual clutter", "Promotes clarity of thought", "Enhances other colors"],
            physiologicalEffects: ["Can cause eye strain in pure digital form", "Reflects maximum light", "Creates cooling sensation", "Promotes sense of cleanliness"],
            researchCitations: [
                "Mehta & Zhu (2009): White enhances focus and attention",
                "Stone (2003): White spaces reduce cognitive load",
                "Labrecque & Milne (2012): White associated with premium positioning"
            ],
            culturalVariations: [
                "Western": "Purity, weddings, peace",
                "Eastern": "Death, mourning, ghosts",
                "Medical": "Cleanliness, sterility",
                "Modern": "Minimalism, sophistication"
            ],
            designPrinciples: [
                "Never use pure white on screens - use off-whites",
                "Provide adequate contrast for accessibility",
                "Use white space strategically for visual hierarchy"
            ],
            accessibility: "Excellent background color but can cause strain. Use #FAFAFA or similar for digital interfaces.",
            complementaryColors: ["Any color works with white", "Creates maximum contrast with black", "Enhances vibrancy of all colors"]
        ),
        
        ColorPsychologyProfile(
            name: "Deep Black",
            hex: "#000000",
            color: Color(hex: "#000000") ?? .black,
            summary: "Black absorbs all light wavelengths, creating the strongest visual contrast and conveying premium positioning in 84% of luxury brands.",
            emotionalDrivers: ["Elegance", "Authority", "Mystery", "Power", "Sophistication"],
            brandVoice: "Projects premium quality, serious professionalism, timeless elegance, and powerful authority.",
            brandExamples: ["Chanel", "Nike", "Uber", "Netflix", "Adidas"],
            coreTone: "Ultimate sophistication, authoritative power",
            primaryUse: "Luxury goods, professional services, high-end technology, formal communications",
            cautions: "Can feel overwhelming or depressing in large amounts; may seem unfriendly.",
            culturalNote: "Mourning color in West, elegance globally; power and authority across cultures.",
            messagingIdeas: ["Premium quality", "Powerful performance", "Elegant solution", "Professional excellence"],
            applicationAdvice: [
                "Use for text and key elements for maximum impact",
                "Combine with white for classic sophistication",
                "Add metallic accents for luxury appeal",
                "Use sparingly to maintain power"
            ],
            psychologicalEffects: ["Creates sense of authority", "Enhances perceived value", "Promotes serious focus", "Conveys permanence"],
            physiologicalEffects: ["Maximum visual contrast", "Can reduce eye strain as background", "Creates cooling sensation", "Absorbs heat and light"],
            researchCitations: [
                "Labrecque & Milne (2012): Black strongly associated with luxury",
                "Singh (2006): Black increases premium perception by 73%",
                "Bellizzi & Hite (1992): Black creates sense of exclusivity"
            ],
            culturalVariations: [
                "Western": "Formal, mourning, elegance",
                "Fashion": "Sophistication, slimming",
                "Business": "Authority, professionalism",
                "Gothic": "Mystery, rebellion"
            ],
            designPrinciples: [
                "Use rich black (#0A0A0A) instead of pure black for digital",
                "Ensure WCAG compliance with sufficient contrast",
                "Balance with lighter elements to prevent oppression"
            ],
            accessibility: "Excellent for text on light backgrounds. Provides maximum contrast for readability.",
            complementaryColors: ["White (#FFFFFF)", "Gold (#FFD700)", "Silver (#C0C0C0)", "Bright accent colors"]
        ),
        
        // SOPHISTICATED TERTIARY COLORS
        ColorPsychologyProfile(
            name: "Teal",
            hex: "#008080",
            color: Color(hex: "#008080") ?? Color.teal,
            summary: "Teal combines blue's calming effects with green's rejuvenating properties, reducing mental fatigue by 23% in workplace studies.",
            emotionalDrivers: ["Balance", "Sophistication", "Clarity", "Rejuvenation", "Communication"],
            brandVoice: "Communicates thoughtful innovation, balanced wisdom, and sophisticated clarity.",
            brandExamples: ["Mailchimp", "Vimeo", "Spotify", "WordPress", "Canva"],
            coreTone: "Sophisticated balance, intelligent calm",
            primaryUse: "Healthcare technology, communication platforms, wellness brands, professional services",
            cautions: "Can appear cold without warm accents; may seem clinical in some contexts.",
            culturalNote: "Associated with healing and communication across many cultures.",
            messagingIdeas: ["Balanced approach", "Clear communication", "Thoughtful innovation", "Healing solution"],
            applicationAdvice: [
                "Perfect for healthcare and wellness applications",
                "Use darker teals for professional authority",
                "Lighter teals for approachable technology",
                "Combine with coral or orange for warmth"
            ],
            psychologicalEffects: ["Reduces mental fatigue by 23%", "Enhances communication clarity", "Promotes emotional balance", "Increases focus"],
            physiologicalEffects: ["Lowers blood pressure", "Reduces eye strain", "Promotes healing response", "Balances nervous system"],
            researchCitations: [
                "Kwallek & Lewis (1990): Teal improves workplace concentration",
                "Stone (2003): Teal environments reduce stress markers",
                "Mehta & Zhu (2009): Teal enhances analytical thinking"
            ],
            culturalVariations: [
                "Healing traditions": "Balance, restoration",
                "Ocean cultures": "Depth, mystery, life",
                "Modern design": "Sophistication, technology",
                "Wellness": "Mental clarity, emotional balance"
            ],
            designPrinciples: [
                "Use as primary in healthcare and wellness designs",
                "Darker teals for authority and trust",
                "Pair with warm accents to prevent coldness"
            ],
            accessibility: "Generally good accessibility. Ensure proper contrast ratios for text readability.",
            complementaryColors: ["Coral (#FF7F50)", "Peach (#FFCBA4)", "Warm Orange (#FF8C00)"]
        ),
        
        ColorPsychologyProfile(
            name: "Burgundy",
            hex: "#800020",
            color: Color(hex: "#800020") ?? Color(red: 0.5, green: 0, blue: 0.125),
            summary: "Burgundy evokes sophistication and tradition, increasing perceived value by 34% in premium product studies.",
            emotionalDrivers: ["Sophistication", "Tradition", "Luxury", "Maturity", "Refinement"],
            brandVoice: "Projects established excellence, refined taste, premium heritage, and mature wisdom.",
            brandExamples: ["Harvard University", "Bordeaux wines", "Maroon 5", "Arizona State", "Premium hotels"],
            coreTone: "Mature sophistication, established authority",
            primaryUse: "Educational institutions, wine industry, luxury hospitality, traditional brands",
            cautions: "Can appear old-fashioned or overly serious; may limit appeal to younger demographics.",
            culturalNote: "Associated with aristocracy and fine wine culture globally.",
            messagingIdeas: ["Established excellence", "Refined tradition", "Premium heritage", "Mature wisdom"],
            applicationAdvice: [
                "Excellent for educational and institutional branding",
                "Use in wine and luxury food contexts",
                "Combine with gold for ultimate luxury appeal",
                "Balance with contemporary elements for modern relevance"
            ],
            psychologicalEffects: ["Increases perceived value by 34%", "Conveys stability and reliability", "Promotes serious contemplation", "Enhances appetite for fine foods"],
            physiologicalEffects: ["Calming yet sophisticated", "Stimulates appetite moderately", "Creates sense of warmth", "Promotes contemplative mood"],
            researchCitations: [
                "Singh (2006): Burgundy associated with premium positioning",
                "Gorn et al. (2004): Deep reds increase luxury perception",
                "Stone & English (1998): Burgundy conveys tradition and quality"
            ],
            culturalVariations: [
                "Wine culture": "Quality, tradition, sophistication",
                "Academia": "Learning, tradition, authority",
                "Royalty": "Noble bearing, established power",
                "Hospitality": "Warmth, luxury, comfort"
            ],
            designPrinciples: [
                "Use as accent color for premium positioning",
                "Excellent for backgrounds in luxury contexts",
                "Pair with cream and gold for elegant combinations"
            ],
            accessibility: "Good contrast potential but test carefully. May be difficult for some colorblind users.",
            complementaryColors: ["Cream (#F5F5DC)", "Gold (#FFD700)", "Forest Green (#228B22)"]
        )
    ]
}

fileprivate struct InsightCard: View {
    let title: String
    let detail: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.accentColor)

            Text(title)
                .font(.system(.headline, design: .monospaced, weight: .semibold))

            NoHyphenationLabel(
                text: detail,
                font: UIFont.monospacedSystemFont(ofSize: 14, weight: .regular),
                color: UIColor.secondaryLabel
            )
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(14)
    }
}

fileprivate struct TagCapsule: View {
    let text: String
    let action: (() -> Void)?

    init(text: String, action: (() -> Void)? = nil) {
        self.text = text
        self.action = action
    }

    var body: some View {
        Group {
            if let action = action {
                Button(action: action) {
                    NoHyphenationLabel(
                        text: text,
                        font: UIFont.monospacedSystemFont(ofSize: 12, weight: .semibold),
                        color: UIColor.label,
                        numberOfLines: 1,
                        lineBreakMode: .byTruncatingTail
                    )
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(uiColor: .tertiarySystemGroupedBackground))
                    .cornerRadius(18)
                }
                .buttonStyle(.plain)
            } else {
                NoHyphenationLabel(
                    text: text,
                    font: UIFont.monospacedSystemFont(ofSize: 12, weight: .semibold),
                    color: UIColor.label,
                    numberOfLines: 1,
                    lineBreakMode: .byTruncatingTail
                )
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                .cornerRadius(18)
            }
        }
    }
}

struct ColorBlindnessGuideView: View {
    @State private var selectedType = 0
    @State private var showSimulation = false
    
    let colorBlindnessTypes = [
        (
            name: "Normal Vision",
            description: "Full color vision with all three cone types functioning normally.",
            prevalence: "Standard reference",
            simulation: "Original colors"
        ),
        (
            name: "Protanopia",
            description: "Red-blindness. Missing red cones, making it hard to distinguish reds from greens.",
            prevalence: "1.3% of males, 0.02% of females",
            simulation: "Reds appear as dark greens, oranges as yellows"
        ),
        (
            name: "Deuteranopia",
            description: "Green-blindness. Missing green cones, the most common type of color blindness.",
            prevalence: "5.0% of males, 0.35% of females",
            simulation: "Greens appear as yellows, reds as oranges"
        ),
        (
            name: "Tritanopia",
            description: "Blue-blindness. Missing blue cones, rare but affects blue-yellow discrimination.",
            prevalence: "0.003% of males and females",
            simulation: "Blues appear as greens, yellows as reds"
        ),
        (
            name: "Protanomaly",
            description: "Reduced red sensitivity. Reds appear duller and shifted towards green.",
            prevalence: "1.3% of males, 0.02% of females",
            simulation: "Reds appear greenish, difficulty distinguishing red from green"
        ),
        (
            name: "Deuteranomaly",
            description: "Reduced green sensitivity. Greens appear duller and shifted towards red.",
            prevalence: "5.0% of males, 0.35% of females",
            simulation: "Greens appear reddish, difficulty distinguishing red from green"
        ),
        (
            name: "Tritanomaly",
            description: "Reduced blue sensitivity. Blues appear duller and shifted towards green.",
            prevalence: "0.003% of males and females",
            simulation: "Blues appear greenish, yellows appear reddish"
        ),
        (
            name: "Monochromacy",
            description: "Complete color blindness. Only sees shades of gray.",
            prevalence: "Very rare (< 0.0001%)",
            simulation: "All colors appear as various shades of gray"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.teal.opacity(0.1))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "eye.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.teal)
                    }
                    
                    Text("Color Blindness")
                        .font(.system(.title, design: .monospaced, weight: .bold))
                    
                    Text("Designing for accessibility and inclusivity")
                        .font(.system(.subheadline, design: .monospaced))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Type Selector
                VStack(alignment: .leading, spacing: 16) {
                    Text("Color Vision Types")
                        .font(.system(.headline, design: .monospaced, weight: .semibold))
                    
                    Picker("Type", selection: $selectedType) {
                        ForEach(0..<colorBlindnessTypes.count, id: \.self) { index in
                            Text(colorBlindnessTypes[index].name).tag(index)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)
                }
                
                // Details
                let type = colorBlindnessTypes[selectedType]
                
                VStack(alignment: .leading, spacing: 20) {
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.system(.headline, design: .monospaced, weight: .semibold))
                        
                        NoHyphenationLabel(
                            text: type.description,
                            font: UIFont.monospacedSystemFont(ofSize: 16, weight: .regular),
                            color: UIColor.label
                        )
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    // Prevalence
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Prevalence")
                            .font(.system(.headline, design: .monospaced, weight: .semibold))
                        
                        NoHyphenationLabel(
                            text: type.prevalence,
                            font: UIFont.monospacedSystemFont(ofSize: 14, weight: .regular),
                            color: UIColor.secondaryLabel
                        )
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    // Simulation
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How Colors Appear")
                            .font(.system(.headline, design: .monospaced, weight: .semibold))
                        
                        NoHyphenationLabel(
                            text: type.simulation,
                            font: UIFont.monospacedSystemFont(ofSize: 14, weight: .regular),
                            color: UIColor.label
                        )
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(16)
                
                // Design Guidelines
                VStack(alignment: .leading, spacing: 16) {
                    Text("🎨 Design Guidelines")
                        .font(.system(.headline, design: .monospaced, weight: .semibold))
                    
                    VStack(alignment: .leading, spacing: 12) {
                        GuidelineItem(
                            icon: "checkmark.circle.fill",
                            color: .green,
                            title: "Use Color + Pattern",
                            description: "Don't rely on color alone - combine with patterns, shapes, or text labels"
                        )
                        
                        GuidelineItem(
                            icon: "contrast",
                            color: .blue,
                            title: "Ensure Contrast",
                            description: "Maintain sufficient contrast ratios for text and interactive elements"
                        )
                        
                        GuidelineItem(
                            icon: "text.bubble.fill",
                            color: .orange,
                            title: "Add Text Labels",
                            description: "Include descriptive text for charts, graphs, and status indicators"
                        )
                        
                        GuidelineItem(
                            icon: "paintbrush.fill",
                            color: .purple,
                            title: "Test with Tools",
                            description: "Use color blindness simulation tools to test your designs"
                        )
                        
                        GuidelineItem(
                            icon: "checkmark.shield.fill",
                            color: .teal,
                            title: "Follow WCAG",
                            description: "Adhere to Web Content Accessibility Guidelines for color usage"
                        )
                    }
                }
                .padding()
                .background(Color.teal.opacity(0.1))
                .cornerRadius(16)
                
                // Test Your Design
                VStack(alignment: .leading, spacing: 16) {
                    Text("🧪 Test Your Designs")
                        .font(.system(.headline, design: .monospaced, weight: .semibold))
                    
                    VStack(spacing: 12) {
                        Button(action: { showSimulation.toggle() }) {
                            HStack {
                                Image(systemName: "eye.fill")
                                Text("Color Blindness Simulator")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .font(.system(.body, design: .monospaced, weight: .medium))
                            .foregroundColor(.teal)
                            .padding(14)
                            .background(Color.teal.opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                        NavigationLink(destination: ColorCalculatorView()) {
                            HStack {
                                Image(systemName: "calculator")
                                Text("Contrast Calculator")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .font(.system(.body, design: .monospaced, weight: .medium))
                            .foregroundColor(.blue)
                            .padding(14)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $showSimulation) {
            ColorBlindnessSimulatorView()
        }
        .toolbar { ToolbarItem(placement: .principal) { AppNavTitle(text: "Color Blindness") } }
    }
}

struct GuidelineItem: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 20))
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.callout, design: .monospaced, weight: .semibold))
                
                NoHyphenationLabel(
                    text: description,
                    font: UIFont.monospacedSystemFont(ofSize: 14, weight: .regular),
                    color: UIColor.secondaryLabel
                )
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct ColorBlindnessSimulatorView: View {
    @State private var selectedImage = 0
    @State private var selectedType = 0
    
    let testImages = [
        "Test Pattern 1: Traffic Light",
        "Test Pattern 2: Color Chart",
        "Test Pattern 3: UI Elements"
    ]
    
    let simulationTypes = [
        "Normal Vision",
        "Protanopia (Red-blind)",
        "Deuteranopia (Green-blind)",
        "Tritanopia (Blue-blind)"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    Text("Color Blindness Simulator")
                        .font(.system(.title2, design: .monospaced, weight: .bold))
                        .padding(.top)
                    
                    // Image Selector
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Test Image")
                            .font(.system(.headline, design: .monospaced, weight: .semibold))
                        
                        Menu {
                            ForEach(0..<testImages.count, id: \.self) { index in
                                Button {
                                    selectedImage = index
                                } label: {
                                    Label(testImages[index], systemImage: selectedImage == index ? "checkmark" : "")
                                }
                            }
                        } label: {
                            HStack {
                                Text(testImages[selectedImage])
                                    .font(.system(.body, design: .monospaced, weight: .medium))
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color(uiColor: .secondarySystemBackground))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Vision Type
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Vision Type")
                            .font(.system(.headline, design: .monospaced, weight: .semibold))
                        
                        Menu {
                            ForEach(0..<simulationTypes.count, id: \.self) { index in
                                Button {
                                    selectedType = index
                                } label: {
                                    Label(simulationTypes[index], systemImage: selectedType == index ? "checkmark" : "")
                                }
                            }
                        } label: {
                            HStack {
                                Text(simulationTypes[selectedType])
                                    .font(.system(.body, design: .monospaced, weight: .medium))
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color(uiColor: .secondarySystemBackground))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Simulated Image Placeholder
                    VStack(spacing: 16) {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 200)
                            .overlay(
                                VStack {
                                    Image(systemName: "photo.fill")
                                        .font(.system(size: 48))
                                        .foregroundColor(.gray)
                                    
                                    Text("Simulated View")
                                        .font(.system(.headline, design: .monospaced, weight: .medium))
                                        .foregroundColor(.gray)
                                }
                            )
                        
                        Text("This would show how the selected image appears to someone with \(simulationTypes[selectedType].lowercased())")
                            .font(.system(.callout, design: .monospaced))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("How to Use:")
                            .font(.system(.headline, design: .monospaced, weight: .semibold))
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("1. Select a test image pattern")
                            Text("2. Choose a vision deficiency type")
                            Text("3. Observe how colors appear differently")
                            Text("4. Use this insight to improve your designs")
                        }
                        .font(.system(.callout, design: .monospaced))
                        .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(12)
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Dismiss sheet
                    }
                }
            }
        }
    }
}

// Additional Learning Views
struct BrandColorsGuideView: View {
    @State private var selectedBrand = 0
    
    let brandColors: [(name: String, colors: [Color], description: String)] = [
        (
            name: "Apple",
            colors: [Color(hex: "#000000") ?? .black, Color(hex: "#FFFFFF") ?? .white, Color(hex: "#007AFF") ?? .blue],
            description: "Apple uses a minimalist approach with black, white, and a signature blue for accent elements."
        ),
        (
            name: "Google",
            colors: [Color(hex: "#4285F4") ?? .blue, Color(hex: "#DB4437") ?? .red, Color(hex: "#F4B400") ?? .yellow, Color(hex: "#0F9D58") ?? .green],
            description: "Google's Material Design uses four primary colors representing search, Gmail, YouTube, and Maps."
        ),
        (
            name: "Coca-Cola",
            colors: [Color(hex: "#ED1C24") ?? .red, Color(hex: "#000000") ?? .black, Color(hex: "#FFFFFF") ?? .white],
            description: "The iconic red is instantly recognizable, paired with black and white for contrast."
        ),
        (
            name: "Nike",
            colors: [Color(hex: "#000000") ?? .black, Color(hex: "#FFFFFF") ?? .white, Color(hex: "#DC2626") ?? .red],
            description: "Nike's 'Just Do It' campaign uses black as primary with white and red accents."
        ),
        (
            name: "Spotify",
            colors: [Color(hex: "#1DB954") ?? .green, Color(hex: "#191414") ?? .black, Color(hex: "#FFFFFF") ?? .white],
            description: "Spotify's signature green represents growth and energy in the music industry."
        ),
        (
            name: "Netflix",
            colors: [Color(hex: "#E50914") ?? .red, Color(hex: "#000000") ?? .black, Color(hex: "#FFFFFF") ?? .white],
            description: "Netflix uses a bold red that stands out against black and white backgrounds."
        ),
        (
            name: "Amazon",
            colors: [Color(hex: "#FF9900") ?? .orange, Color(hex: "#232F3E") ?? .black, Color(hex: "#146EB4") ?? .blue],
            description: "Amazon pairs its signature smile orange with deep navy hues for clarity and trust."
        ),
        (
            name: "Adobe",
            colors: [Color(hex: "#FF0000") ?? .red, Color(hex: "#2C2C2C") ?? .black, Color(hex: "#FFFFFF") ?? .white],
            description: "Adobe leans on a powerful red to signal creativity, anchored by neutral black and white."
        ),
        (
            name: "Airbnb",
            colors: [Color(hex: "#FF5A5F") ?? .pink, Color(hex: "#484848") ?? .gray, Color(hex: "#FFFFFF") ?? .white],
            description: "Airbnb's palette balances its friendly Rausch coral with grounded neutrals for readability."
        ),
        (
            name: "Microsoft",
            colors: [Color(hex: "#F35325") ?? .orange, Color(hex: "#81BC06") ?? .green, Color(hex: "#05A6F0") ?? .blue, Color(hex: "#FFBA08") ?? .yellow],
            description: "Microsoft's four-color square celebrates product diversity with vibrant, balanced tones."
        ),
        (
            name: "Meta",
            colors: [Color(hex: "#0866FF") ?? .blue, Color(hex: "#1C1E21") ?? .black, Color(hex: "#FFFFFF") ?? .white],
            description: "Meta modernized Facebook blue with deep charcoal accents for a more mature product suite."
        ),
        (
            name: "Instagram",
            colors: [Color(hex: "#833AB4") ?? .purple, Color(hex: "#FD1D1D") ?? .red, Color(hex: "#FCAF45") ?? .orange, Color(hex: "#FFDC80") ?? .yellow],
            description: "Instagram blends a warm gradient that mirrors the energy and diversity of shared moments."
        ),
        (
            name: "Starbucks",
            colors: [Color(hex: "#00704A") ?? .green, Color(hex: "#FFFFFF") ?? .white, Color(hex: "#000000") ?? .black],
            description: "Starbucks relies on a rich green to signal sustainability, contrasted with crisp neutrals."
        ),
        (
            name: "Tesla",
            colors: [Color(hex: "#CC0000") ?? .red, Color(hex: "#171A20") ?? .black, Color(hex: "#FFFFFF") ?? .white],
            description: "Tesla's minimalist palette mixes performance red with high-contrast monochromatic tones."
        ),
        (
            name: "Twitter",
            colors: [Color(hex: "#1DA1F2") ?? .blue, Color(hex: "#14171A") ?? .black, Color(hex: "#FFFFFF") ?? .white],
            description: "Twitter blue evokes clarity and openness, balanced by dark and light neutrals for hierarchy."
        ),
        (
            name: "McDonald's",
            colors: [Color(hex: "#DA291C") ?? .red, Color(hex: "#FFC72C") ?? .yellow, Color(hex: "#FFFFFF") ?? .white],
            description: "McDonald's golden arches pairing with energetic red reinforces speed and familiarity."
        ),
        (
            name: "Samsung",
            colors: [Color(hex: "#1428A0") ?? .blue, Color(hex: "#000000") ?? .black, Color(hex: "#FFFFFF") ?? .white],
            description: "Samsung leverages a confident royal blue to underscore innovation across devices."
        ),
        (
            name: "IBM",
            colors: [Color(hex: "#052FAD") ?? .blue, Color(hex: "#FFFFFF") ?? .white, Color(hex: "#000000") ?? .black],
            description: "IBM's classic blue communicates reliability and enterprise-grade expertise."
        ),
        (
            name: "Dropbox",
            colors: [Color(hex: "#0061FF") ?? .blue, Color(hex: "#007EE5") ?? .blue, Color(hex: "#FFFFFF") ?? .white],
            description: "Dropbox uses a bright, playful blue spectrum to emphasize simplicity and openness."
        ),
        (
            name: "LinkedIn",
            colors: [Color(hex: "#0A66C2") ?? .blue, Color(hex: "#313335") ?? .gray, Color(hex: "#FFFFFF") ?? .white],
            description: "LinkedIn keeps a professional tone with dependable blues and neutral supporting shades."
        )
    ]
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.indigo.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "building.2.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.indigo)
            }
            
            Text("Brand Colors")
                .font(.system(.title, design: .monospaced, weight: .bold))
            
            Text("Iconic color palettes from world-famous brands")
                .font(.system(.subheadline, design: .monospaced))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var brandPickerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose a Brand")
                .font(.system(.headline, design: .monospaced, weight: .semibold))
            
            Picker("Brand", selection: $selectedBrand) {
                ForEach(0..<brandColors.count, id: \.self) { index in
                    Text(brandColors[index].name).tag(index)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 120)
        }
    }
    
    private func brandDetailsSection(brand: (name: String, colors: [Color], description: String)) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Color Palette
            VStack(spacing: 12) {
                HStack(spacing: 0) {
                    ForEach(brand.colors, id: \.self) { color in
                        color
                    }
                }
                .frame(height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 4)
                
                Text("\(brand.name) Color Palette")
                    .font(.system(.caption, design: .monospaced, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            // Individual Colors
            VStack(alignment: .leading, spacing: 12) {
                Text("Colors")
                    .font(.system(.headline, design: .monospaced, weight: .semibold))
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
                    ForEach(brand.colors.indices, id: \.self) { index in
                        VStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(brand.colors[index])
                                .frame(width: 60, height: 60)
                                .shadow(radius: 2)
                            
                            Text(UIColor(brand.colors[index]).hexString)
                                .font(.system(.caption, design: .monospaced, weight: .medium))
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }
            
            // Description
            VStack(alignment: .leading, spacing: 8) {
                Text("Brand Strategy")
                    .font(.system(.headline, design: .monospaced, weight: .semibold))
                
                NoHyphenationLabel(
                    text: brand.description,
                    font: UIFont.monospacedSystemFont(ofSize: 14, weight: .regular),
                    color: UIColor.label
                )
                .fixedSize(horizontal: false, vertical: true)
            }
            
            // Lessons
            VStack(alignment: .leading, spacing: 8) {
                Text("Key Lessons")
                    .font(.system(.headline, design: .monospaced, weight: .semibold))
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("• Consistency across all brand touchpoints")
                    Text("• Colors that reflect brand personality")
                    Text("• Limited palette for strong recognition")
                    Text("• Cultural considerations in color choice")
                    Text("• Accessibility and readability")
                }
                .font(.system(.callout, design: .monospaced))
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private var savePaletteButton: some View {
        let brand = brandColors[selectedBrand]
        return Button(action: {
            // Save logic would go here
            HapticManager.instance.notification(type: .success)
        }) {
            HStack {
                Image(systemName: "bookmark.fill")
                Text("Save \(brand.name) Palette")
            }
            .font(.system(.body, design: .monospaced, weight: .medium))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(14)
            .background(Color.indigo)
            .cornerRadius(12)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                headerSection
                brandPickerSection
                brandDetailsSection(brand: brandColors[selectedBrand])
                savePaletteButton
            }
            .padding()
        }
        .toolbar { ToolbarItem(placement: .principal) { AppNavTitle(text: "Brand Colors") } }
    }
}

struct ColorSpacesGuideView: View {
    @State private var selectedSpace = 0
    
    let colorSpaces = [
        (
            name: "sRGB",
            description: "Standard RGB color space used for web and digital displays. Most common color space for digital content.",
            gamut: "Wide color gamut suitable for most applications",
            useCase: "Web design, digital photography, consumer displays",
            primaries: "Standard RGB primaries with D65 white point"
        ),
        (
            name: "Adobe RGB",
            description: "Larger color gamut than sRGB, designed for professional photography and printing workflows.",
            gamut: "20% larger than sRGB, especially in cyan-green range",
            useCase: "Professional photography, high-end printing",
            primaries: "Wider primaries with D65 white point"
        ),
        (
            name: "Display P3",
            description: "Color space used by modern Apple devices and some high-end displays. Wider gamut than sRGB.",
            gamut: "25% larger than sRGB, excellent for wide color displays",
            useCase: "iOS/macOS apps, HDR content, professional displays",
            primaries: "P3 primaries with D65 white point"
        ),
        (
            name: "DCI-P3",
            description: "Digital Cinema color space used in movie theaters and some displays. Optimized for cinematic content.",
            gamut: "Similar to Display P3 but with DCI white point",
            useCase: "Digital cinema, HDR video, professional video production",
            primaries: "P3 primaries with DCI white point (6300K)"
        ),
        (
            name: "Rec. 2020",
            description: "Ultra-wide color gamut for 4K and 8K HDR content. Much larger than traditional color spaces.",
            gamut: "4x larger than sRGB, covers almost all visible colors",
            useCase: "4K/8K HDR video, future-proof content creation",
            primaries: "Very wide BT.2020 primaries with D65 white point"
        ),
        (
            name: "ProPhoto RGB",
            description: "Extremely wide color gamut designed for professional photography. Can represent almost all real-world colors.",
            gamut: "Largest practical RGB color space",
            useCase: "Professional photography, archival storage",
            primaries: "Very wide primaries with D50 white point"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.mint.opacity(0.1))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "rectangle.3.group.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.mint)
                    }
                    
                    Text("Color Spaces")
                        .font(.system(.title, design: .monospaced, weight: .bold))
                    
                    Text("Understanding different color gamuts and their uses")
                        .font(.system(.subheadline, design: .monospaced))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Space Picker
                VStack(alignment: .leading, spacing: 16) {
                    Text("Choose a Color Space")
                        .font(.system(.headline, design: .monospaced, weight: .semibold))
                    
                    Picker("Space", selection: $selectedSpace) {
                        ForEach(0..<colorSpaces.count, id: \.self) { index in
                            Text(colorSpaces[index].name).tag(index)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)
                }
                
                // Space Details
                let space = colorSpaces[selectedSpace]
                
                VStack(alignment: .leading, spacing: 20) {
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.system(.headline, design: .monospaced, weight: .semibold))
                        
                        Text(space.description)
                            .font(.system(.body, design: .monospaced))
                            .lineSpacing(6)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    // Gamut
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Color Gamut")
                            .font(.system(.headline, design: .monospaced, weight: .semibold))
                        
                        Text(space.gamut)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    
                    // Use Case
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Primary Use")
                            .font(.system(.headline, design: .monospaced, weight: .semibold))
                        
                        Text(space.useCase)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    
                    // Technical Details
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Technical Details")
                            .font(.system(.headline, design: .monospaced, weight: .semibold))
                        
                        Text(space.primaries)
                            .font(.system(.body, design: .monospaced))
                            .lineSpacing(6)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(16)
                
                // Color Space Comparison
                VStack(alignment: .leading, spacing: 16) {
                    Text("🎯 Choosing the Right Color Space")
                        .font(.system(.headline, design: .monospaced, weight: .semibold))
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("• **sRGB**: Best for web and general digital use")
                        Text("• **Adobe RGB**: Ideal for photography and printing")
                        Text("• **Display P3**: Perfect for modern Apple devices")
                        Text("• **Rec. 2020**: Future-proof for HDR and 4K content")
                        Text("• **ProPhoto RGB**: Maximum color accuracy for professionals")
                    }
                    .font(.system(.callout, design: .monospaced))
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.mint.opacity(0.1))
                .cornerRadius(12)
                
                // Conversion Tool
                NavigationLink(destination: ColorCalculatorView()) {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Color Space Converter")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(.body, design: .monospaced, weight: .medium))
                    .foregroundColor(.mint)
                    .padding(14)
                    .background(Color.mint.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .toolbar { ToolbarItem(placement: .principal) { AppNavTitle(text: "Color Spaces") } }
    }
}

struct TypographyGuideView: View {
    @State private var selectedTopic = 0
    
    let typographyTopics = [
        (
            title: "Font Families",
            content: "Typography begins with choosing the right font family. Serif fonts (with small lines at stroke ends) convey tradition and reliability. Sans-serif fonts (without serifs) feel modern and clean. Script fonts add personality but should be used sparingly.",
            examples: ["Serif: Times New Roman, Georgia", "Sans-serif: Helvetica, Arial", "Script: Brush Script, Lucida Handwriting"],
            tips: "Limit to 2-3 font families per design. Ensure good readability across different sizes and devices."
        ),
        (
            title: "Hierarchy & Scale",
            content: "Typography hierarchy creates visual organization. Use size, weight, and spacing to guide readers through content. Headlines should be largest, followed by subheadings, then body text. Maintain consistent scale relationships.",
            examples: ["H1: 32-48pt", "H2: 24-32pt", "Body: 14-18pt", "Caption: 12-14pt"],
            tips: "Use a modular scale (like 1.25 or 1.5 ratios) for consistent sizing. Ensure adequate contrast between text sizes."
        ),
        (
            title: "Spacing & Alignment",
            content: "Proper spacing improves readability. Line height (leading) should be 1.4-1.6 times font size. Letter spacing (tracking) affects density. Alignment affects flow - left-aligned for body text, centered for headlines.",
            examples: ["Line height: 1.5x font size", "Letter spacing: -2% to +5%", "Paragraph spacing: 1.5x line height"],
            tips: "Avoid justified text for small screens. Use consistent spacing throughout your design."
        ),
        (
            title: "Color & Contrast",
            content: "Text color affects readability and mood. Dark text on light backgrounds provides best readability. Consider color psychology - blue for trust, red for urgency. Ensure sufficient contrast ratios for accessibility.",
            examples: ["Primary text: High contrast", "Secondary text: Medium contrast", "Links: Distinctive color + underline"],
            tips: "Test contrast ratios with tools. Consider color blindness when choosing text colors."
        ),
        (
            title: "Responsive Typography",
            content: "Typography must adapt to different screen sizes. Use relative units like em or rem. Implement fluid typography that scales smoothly. Consider touch targets for mobile interfaces.",
            examples: ["Mobile: 14-16pt minimum", "Tablet: 16-18pt", "Desktop: 16-24pt"],
            tips: "Test readability on actual devices. Use system fonts when possible for better performance."
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.brown.opacity(0.1))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "textformat.size")
                            .font(.system(size: 32))
                            .foregroundColor(.brown)
                    }
                    
                    Text("Typography")
                        .font(.system(.title, design: .monospaced, weight: .bold))
                    
                    Text("The art and science of arranging type")
                        .font(.system(.subheadline, design: .monospaced))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Topic Picker
                VStack(alignment: .leading, spacing: 16) {
                    Text("Choose a Topic")
                        .font(.system(.headline, design: .monospaced, weight: .semibold))
                    
                    Picker("Topic", selection: $selectedTopic) {
                        ForEach(0..<typographyTopics.count, id: \.self) { index in
                            Text(typographyTopics[index].title).tag(index)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)
                }
                
                // Topic Details
                let topic = typographyTopics[selectedTopic]
                
                VStack(alignment: .leading, spacing: 20) {
                    // Content
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Overview")
                            .font(.system(.headline, design: .monospaced, weight: .semibold))
                        
                        Text(topic.content)
                            .font(.system(.body, design: .monospaced))
                            .lineSpacing(6)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    // Examples
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Examples")
                            .font(.system(.headline, design: .monospaced, weight: .semibold))
                        
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(topic.examples, id: \.self) { example in
                                Text("• \(example)")
                                    .font(.system(.callout, design: .monospaced))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Tips
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Best Practices")
                            .font(.system(.headline, design: .monospaced, weight: .semibold))
                        
                        Text(topic.tips)
                            .font(.system(.body, design: .monospaced))
                            .lineSpacing(6)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(16)
                
                // Interactive Demo
                VStack(alignment: .leading, spacing: 16) {
                    Text("🎨 Typography Playground")
                        .font(.system(.headline, design: .monospaced, weight: .semibold))
                    
                    NavigationLink(destination: TypographyPlaygroundView()) {
                        HStack {
                            Image(systemName: "textformat")
                            Text("Try Typography Playground")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .font(.system(.body, design: .monospaced, weight: .medium))
                        .foregroundColor(.brown)
                        .padding(14)
                        .background(Color.brown.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
            }
            .padding()
        }
        .toolbar { ToolbarItem(placement: .principal) { AppNavTitle(text: "Typography") } }
    }
}

struct TypographyPlaygroundView: View {
    @State private var fontSize: CGFloat = 16
    @State private var lineHeight: CGFloat = 1.5
    @State private var letterSpacing: CGFloat = 0
    @State private var fontWeight: Font.Weight = .regular
    
    let sampleText = "Typography is the art and technique of arranging type to make written language legible, readable and appealing when displayed. The arrangement of type involves selecting typefaces, point sizes, line lengths, line-spacing, and letter-spacing, as well as adjusting the space between pairs of letters."
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                Text("Typography Playground")
                    .font(.system(.title, design: .monospaced, weight: .bold))
                
                // Controls
                VStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("Font Size: \(Int(fontSize))pt")
                        Slider(value: $fontSize, in: 12...48, step: 1)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Line Height: \(String(format: "%.1f", lineHeight))x")
                        Slider(value: $lineHeight, in: 1.0...2.0, step: 0.1)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Letter Spacing: \(Int(letterSpacing))%")
                        Slider(value: $letterSpacing, in: -10...20, step: 1)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Font Weight")
                            .font(.system(.subheadline, design: .monospaced, weight: .semibold))
                        
                        HStack(spacing: 8) {
                            ForEach([Font.Weight.light, Font.Weight.regular, Font.Weight.medium, Font.Weight.bold, Font.Weight.heavy], id: \.self) { weight in
                                Button {
                                    fontWeight = weight
                                } label: {
                                    Text(weightLabel(weight))
                                        .font(.system(.caption, design: .monospaced, weight: .medium))
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 10)
                                        .background(
                                            Capsule()
                                                .fill(fontWeight == weight ? Color.accentColor.opacity(0.2) : Color(uiColor: .tertiarySystemBackground))
                                        )
                                        .overlay(
                                            Capsule()
                                                .stroke(fontWeight == weight ? Color.accentColor.opacity(0.4) : Color.clear, lineWidth: 1)
                                        )
                                        .foregroundColor(fontWeight == weight ? .accentColor : .secondary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(12)
                
                // Preview
                VStack(alignment: .leading, spacing: 16) {
                    Text("Preview")
                        .font(.system(.headline, design: .monospaced, weight: .semibold))
                    
                    Text(sampleText)
                        .font(.system(size: fontSize, weight: fontWeight, design: .monospaced))
                        .lineSpacing((lineHeight - 1.0) * fontSize)
                        .kerning(letterSpacing)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(uiColor: .systemBackground))
                        .cornerRadius(8)
                        .shadow(radius: 2)
                }
                
                // Metrics
                VStack(alignment: .leading, spacing: 12) {
                    Text("Typography Metrics")
                        .font(.system(.headline, design: .monospaced, weight: .semibold))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Font Size: \(Int(fontSize)) points")
                        Text("Line Height: \(String(format: "%.1f", lineHeight * fontSize)) points")
                        Text("Leading: \(String(format: "%.1f", (lineHeight - 1.0) * fontSize)) points")
                        Text("Character Spacing: \(Int(letterSpacing))%")
                    }
                    .font(.system(.callout, design: .monospaced))
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.brown.opacity(0.1))
                .cornerRadius(12)
            }
            .padding()
        }
        .toolbar { ToolbarItem(placement: .principal) { AppNavTitle(text: "Typography") } }
    }
    
    private func weightLabel(_ weight: Font.Weight) -> String {
        switch weight {
        case .light: return "Light"
        case .regular: return "Regular"
        case .medium: return "Medium"
        case .bold: return "Bold"
        case .heavy: return "Heavy"
        default: return "Regular"
        }
    }
}

struct DigitalPrintGuideView: View {
    @State private var selectedTopic = 0
    
    let printTopics = [
        (
            title: "RGB vs CMYK",
            content: "RGB is for digital screens, CMYK is for printing. RGB uses light emission, CMYK uses ink absorption. Converting RGB to CMYK can result in color shifts due to different gamuts.",
            considerations: ["Color shifts during conversion", "Different color gamuts", "Ink limitations", "Paper type affects final color"],
            tips: "Design in CMYK when possible. Use color profiles. Proof on actual printing conditions."
        ),
        (
            title: "Color Profiles",
            content: "ICC color profiles ensure consistent color reproduction across devices. sRGB for web, Adobe RGB for photography, specific profiles for printing presses.",
            considerations: ["Device color capabilities", "Viewing conditions", "Color management workflow", "Profile embedding"],
            tips: "Use correct profiles from start. Calibrate monitors. Soft-proof before printing."
        ),
        (
            title: "Paper & Ink",
            content: "Paper type affects color appearance. Coated papers show more vibrant colors, uncoated papers absorb more ink. Different ink types have varying color ranges.",
            considerations: ["Paper finish (coated/uncoated)", "Paper weight and thickness", "Ink type and coverage", "Environmental conditions"],
            tips: "Specify paper type early. Consider viewing distance. Test prints on actual materials."
        ),
        (
            title: "Bleed & Safe Areas",
            content: "Bleed extends design beyond final trim size. Safe area keeps important elements away from trim edge. Different printers have different requirements.",
            considerations: ["Bleed requirements (typically 1/8 inch)", "Safe margin (typically 1/4 inch)", "Printer capabilities", "Binding requirements"],
            tips: "Always include bleed. Keep text away from trim edge. Check printer specifications."
        ),
        (
            title: "Resolution & File Prep",
            content: "Print resolution is typically 300 DPI. Images should be high resolution. Use correct file formats and color modes for printing.",
            considerations: ["300 DPI minimum for images", "Vector vs raster elements", "File format compatibility", "Font embedding"],
            tips: "Prepare high-res images. Convert text to outlines if needed. Use CMYK color mode."
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.cyan.opacity(0.1))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "printer.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.cyan)
                    }
                    
                    Text("Digital to Print")
                        .font(.system(.title, design: .monospaced, weight: .bold))
                    
                    Text("Bridging the gap between digital design and physical printing")
                        .font(.system(.subheadline, design: .monospaced))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Topic Picker
                VStack(alignment: .leading, spacing: 16) {
                    Text("Choose a Topic")
                        .font(.system(.headline, design: .monospaced, weight: .semibold))
                    
                    Picker("Topic", selection: $selectedTopic) {
                        ForEach(0..<printTopics.count, id: \.self) { index in
                            Text(printTopics[index].title).tag(index)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)
                }
                
                // Topic Details
                let topic = printTopics[selectedTopic]
                
                VStack(alignment: .leading, spacing: 20) {
                    // Content
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Overview")
                            .font(.system(.headline, design: .monospaced, weight: .semibold))
                        
                        Text(topic.content)
                            .font(.system(.body, design: .monospaced))
                            .lineSpacing(6)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    // Considerations
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Key Considerations")
                            .font(.system(.headline, design: .monospaced, weight: .semibold))
                        
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(topic.considerations, id: \.self) { consideration in
                                Text("• \(consideration)")
                                    .font(.system(.callout, design: .monospaced))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Tips
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Best Practices")
                            .font(.system(.headline, design: .monospaced, weight: .semibold))
                        
                        Text(topic.tips)
                            .font(.system(.body, design: .monospaced))
                            .lineSpacing(6)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(16)
                
                // Print Checklist
                VStack(alignment: .leading, spacing: 16) {
                    Text("📋 Pre-Press Checklist")
                        .font(.system(.headline, design: .monospaced, weight: .semibold))
                    
                    VStack(alignment: .leading, spacing: 12) {
                        ChecklistItem(checked: true, text: "Convert to CMYK color mode")
                        ChecklistItem(checked: true, text: "Include bleed (1/8 inch minimum)")
                        ChecklistItem(checked: true, text: "Embed all fonts or convert to outlines")
                        ChecklistItem(checked: true, text: "Check resolution (300 DPI minimum)")
                        ChecklistItem(checked: true, text: "Remove spot colors if not supported")
                        ChecklistItem(checked: true, text: "Save in print-ready format (PDF/PDF)")
                    }
                }
                .padding()
                .background(Color.cyan.opacity(0.1))
                .cornerRadius(12)
            }
            .padding()
        }
        .toolbar { ToolbarItem(placement: .principal) { AppNavTitle(text: "Digital to Print") } }
    }
}

struct ChecklistItem: View {
    let checked: Bool
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: checked ? "checkmark.circle.fill" : "circle")
                .foregroundColor(checked ? .green : .gray)
                .font(.system(size: 18))
            
            Text(text)
                .font(.system(.callout, design: .monospaced))
                .foregroundColor(checked ? .primary : .secondary)
        }
    }
}

struct ColorTrendsGuideView: View {
    @State private var selectedYear = 0
    
    let colorTrends: [(year: String, colors: [Color], names: [String], description: String)] = [
        (
            year: "2024",
            colors: [Color(hex: "#8B5A3C") ?? .brown, Color(hex: "#D4AF37") ?? .yellow, Color(hex: "#36454F") ?? .gray, Color(hex: "#50C878") ?? .green, Color(hex: "#FF6B6B") ?? .red],
            names: ["Warm Taupe", "Gold", "Charcoal", "Emerald", "Coral"],
            description: "2024 trends focus on earthy, sustainable colors with metallic accents. Warm taupe and gold represent luxury and nature, while coral adds energy."
        ),
        (
            year: "2023",
            colors: [Color(hex: "#E6BEAE") ?? .pink, Color(hex: "#A8DADC") ?? .blue, Color(hex: "#F4A261") ?? .orange, Color(hex: "#2A9D8F") ?? .green, Color(hex: "#264653") ?? .gray],
            names: ["Peach Fuzz", "Arctic Blue", "Orange Sherbet", "Jungle Green", "Charcoal"],
            description: "2023 brought soft, comforting colors inspired by nature and wellness. Pastel tones dominated with peach and blue as favorites."
        ),
        (
            year: "2022",
            colors: [Color(hex: "#F8B195") ?? .pink, Color(hex: "#F67280") ?? .red, Color(hex: "#C06C84") ?? .pink, Color(hex: "#6C5B7B") ?? .purple, Color(hex: "#355C7D") ?? .blue],
            names: ["Peach", "Rose", "Mauve", "Purple", "Blue"],
            description: "2022 embraced romantic, nostalgic colors. Soft pinks and purples created a dreamy, comforting atmosphere."
        ),
        (
            year: "2021",
            colors: [Color(hex: "#FFE5B4") ?? .orange, Color(hex: "#D4F1F4") ?? .blue, Color(hex: "#B8E6B8") ?? .green, Color(hex: "#F7DC6F") ?? .yellow, Color(hex: "#BB8FCE") ?? .purple],
            names: ["Creamy Peach", "Sky Blue", "Mint", "Sunshine", "Lavender"],
            description: "2021 colors reflected optimism and renewal post-pandemic. Soft, cheerful tones dominated the palette."
        ),
        (
            year: "2020",
            colors: [Color(hex: "#FF6B6B") ?? .red, Color(hex: "#4ECDC4") ?? .blue, Color(hex: "#45B7D1") ?? .blue, Color(hex: "#96CEB4") ?? .green, Color(hex: "#FFEAA7") ?? .yellow],
            names: ["Coral", "Turquoise", "Sky Blue", "Sage Green", "Pale Yellow"],
            description: "2020 embraced bold, vibrant colors for a sense of energy and hope during challenging times."
        )
    ]
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.pink.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 32))
                    .foregroundColor(.pink)
            }
            
            Text("Color Trends")
                .font(.system(.title, design: .monospaced, weight: .bold))
            
            Text("Evolution of color preferences over the years")
                .font(.system(.subheadline, design: .monospaced))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var yearPickerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose a Year")
                .font(.system(.headline, design: .monospaced, weight: .semibold))
            
            Picker("Year", selection: $selectedYear) {
                ForEach(0..<colorTrends.count, id: \.self) { index in
                    Text(colorTrends[index].year).tag(index)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 120)
        }
    }
    
    private func trendDetailsSection(trend: (year: String, colors: [Color], names: [String], description: String)) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Color Palette
            VStack(spacing: 12) {
                HStack(spacing: 0) {
                    ForEach(trend.colors, id: \.self) { color in
                        color
                    }
                }
                .frame(height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 4)
                
                Text("\(trend.year) Color Trends")
                    .font(.system(.caption, design: .monospaced, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            // Individual Colors
            VStack(alignment: .leading, spacing: 12) {
                Text("Trend Colors")
                    .font(.system(.headline, design: .monospaced, weight: .semibold))
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
                    ForEach(trend.colors.indices, id: \.self) { index in
                        VStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(trend.colors[index])
                                .frame(width: 60, height: 60)
                                .shadow(radius: 2)
                            
                            Text(trend.names[index])
                                .font(.system(.caption, design: .monospaced, weight: .medium))
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                                .multilineTextAlignment(.center)
                            
                            Text(UIColor(trend.colors[index]).hexString)
                                .font(.system(.caption, design: .monospaced, weight: .medium))
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }
            
            // Description
            VStack(alignment: .leading, spacing: 8) {
                Text("Trend Analysis")
                    .font(.system(.headline, design: .monospaced, weight: .semibold))
                
                Text(trend.description)
                    .font(.system(.body, design: .monospaced))
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Insights
            VStack(alignment: .leading, spacing: 8) {
                Text("Key Insights")
                    .font(.system(.headline, design: .monospaced, weight: .semibold))
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("• Colors reflect cultural and social trends")
                    Text("• Earthy, natural tones are consistently popular")
                    Text("• Technology influences color preferences")
                    Text("• Seasonal and emotional factors play a role")
                    Text("• Sustainability drives color choices")
                }
                .font(.system(.callout, design: .monospaced))
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private var saveTrendButton: some View {
        let trend = colorTrends[selectedYear]
        return Button(action: {
            // Save logic would go here
            HapticManager.instance.notification(type: .success)
        }) {
            HStack {
                Image(systemName: "bookmark.fill")
                Text("Save \(trend.year) Trend Palette")
            }
            .font(.system(.body, design: .monospaced, weight: .medium))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(14)
            .background(Color.pink)
            .cornerRadius(12)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                headerSection
                yearPickerSection
                trendDetailsSection(trend: colorTrends[selectedYear])
                saveTrendButton
            }
            .padding()
        }
        .toolbar { ToolbarItem(placement: .principal) { AppNavTitle(text: "Color Trends") } }
    }
}

struct ColorGlossaryView: View {
    @State private var searchText = ""
    
    let glossaryTerms = [
        "Hue": "The pure color itself, identified by names like red, blue, green, etc.",
        "Saturation": "The intensity or purity of a color. High saturation = vivid, low saturation = muted.",
        "Value": "The lightness or darkness of a color. Also called brightness or tone.",
        "Chroma": "The colorfulness of a color relative to its brightness. Similar to saturation.",
        "Tint": "A color mixed with white, making it lighter.",
        "Shade": "A color mixed with black, making it darker.",
        "Tone": "A color mixed with gray, changing its value while maintaining hue.",
        "Gamut": "The complete range of colors that can be reproduced by a device or color space.",
        "Color Temperature": "The warmth or coolness of a color, measured in Kelvin.",
        "Complementary Colors": "Colors opposite each other on the color wheel that create high contrast.",
        "Analogous Colors": "Colors next to each other on the color wheel that create harmony.",
        "Triadic Colors": "Three colors equally spaced around the color wheel.",
        "Monochromatic": "Variations of a single hue using different saturations and values.",
        "Warm Colors": "Colors associated with heat: reds, oranges, yellows.",
        "Cool Colors": "Colors associated with cold: blues, greens, purples.",
        "Primary Colors": "Red, blue, and yellow - cannot be created by mixing other colors.",
        "Secondary Colors": "Orange, green, and purple - created by mixing primary colors.",
        "Tertiary Colors": "Created by mixing primary and secondary colors.",
        "CMYK": "Cyan, Magenta, Yellow, Black - the color model used for printing.",
        "RGB": "Red, Green, Blue - the color model used for digital displays.",
        "HSL": "Hue, Saturation, Lightness - an alternative to RGB for digital colors.",
        "Hex Code": "A six-digit code representing RGB values in hexadecimal format.",
        "Color Blindness": "Vision deficiency affecting color perception, most commonly red-green.",
        "Contrast Ratio": "The difference in luminance between two colors, important for accessibility.",
        "WCAG": "Web Content Accessibility Guidelines for color and contrast requirements."
    ]
    
    var filteredTerms: [Dictionary<String, String>.Element] {
        if searchText.isEmpty {
            return Array(glossaryTerms)
        } else {
            return glossaryTerms.filter { $0.key.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        VStack {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search terms...", text: $searchText)
                    .font(.system(.body, design: .monospaced))
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(14)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(12)
            .padding(.horizontal)
            
            // Results Count
            if !searchText.isEmpty {
                Text("\(filteredTerms.count) terms found")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            
            // Glossary List
            List(filteredTerms, id: \.key) { term, definition in
                VStack(alignment: .leading, spacing: 8) {
                    Text(term)
                        .font(.system(.headline, design: .monospaced, weight: .semibold))
                    
                    Text(definition)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 8)
            }
            .listStyle(.plain)
        }
        .toolbar { ToolbarItem(placement: .principal) { AppNavTitle(text: "Color Glossary") } }
    }
}

struct NamedColorsView: View {
    @State private var searchText = ""
    @State private var selectedCategory = 0
    
    let colorCategories = ["All", "Web Safe", "Material Design", "CSS Named", "Pantone"]
    
    var namedColors: [(String, String, Color)] {
        [
            ("Alice Blue", "#F0F8FF", Color(hex: "#F0F8FF") ?? .gray),
            ("Antique White", "#FAEBD7", Color(hex: "#FAEBD7") ?? .gray),
            ("Aqua", "#00FFFF", Color(hex: "#00FFFF") ?? .gray),
            ("Aquamarine", "#7FFFD4", Color(hex: "#7FFFD4") ?? .gray),
            ("Azure", "#F0FFFF", Color(hex: "#F0FFFF") ?? .gray),
            ("Beige", "#F5F5DC", Color(hex: "#F5F5DC") ?? .gray),
            ("Bisque", "#FFE4C4", Color(hex: "#FFE4C4") ?? .gray),
            ("Black", "#000000", Color(hex: "#000000") ?? .gray),
            ("Blanched Almond", "#FFEBCD", Color(hex: "#FFEBCD") ?? .gray),
            ("Blue", "#0000FF", Color(hex: "#0000FF") ?? .gray),
            ("Blue Violet", "#8A2BE2", Color(hex: "#8A2BE2") ?? .gray),
            ("Brown", "#A52A2A", Color(hex: "#A52A2A") ?? .gray),
            ("Burlywood", "#DEB887", Color(hex: "#DEB887") ?? .gray),
            ("Cadet Blue", "#5F9EA0", Color(hex: "#5F9EA0") ?? .gray),
            ("Chartreuse", "#7FFF00", Color(hex: "#7FFF00") ?? .gray),
            ("Chocolate", "#D2691E", Color(hex: "#D2691E") ?? .gray),
            ("Coral", "#FF7F50", Color(hex: "#FF7F50") ?? .gray),
            ("Cornflower Blue", "#6495ED", Color(hex: "#6495ED") ?? .gray),
            ("Cornsilk", "#FFF8DC", Color(hex: "#FFF8DC") ?? .gray),
            ("Crimson", "#DC143C", Color(hex: "#DC143C") ?? .gray),
            ("Cyan", "#00FFFF", Color(hex: "#00FFFF") ?? .gray),
            ("Dark Blue", "#00008B", Color(hex: "#00008B") ?? .gray),
            ("Dark Cyan", "#008B8B", Color(hex: "#008B8B") ?? .gray),
            ("Dark Goldenrod", "#B8860B", Color(hex: "#B8860B") ?? .gray),
            ("Dark Gray", "#A9A9A9", Color(hex: "#A9A9A9") ?? .gray),
            ("Dark Green", "#006400", Color(hex: "#006400") ?? .gray),
            ("Dark Khaki", "#BDB76B", Color(hex: "#BDB76B") ?? .gray),
            ("Dark Magenta", "#8B008B", Color(hex: "#8B008B") ?? .gray),
            ("Dark Olive Green", "#556B2F", Color(hex: "#556B2F") ?? .gray),
            ("Dark Orange", "#FF8C00", Color(hex: "#FF8C00") ?? .gray),
            ("Dark Orchid", "#9932CC", Color(hex: "#9932CC") ?? .gray),
            ("Dark Red", "#8B0000", Color(hex: "#8B0000") ?? .gray),
            ("Dark Salmon", "#E9967A", Color(hex: "#E9967A") ?? .gray),
            ("Dark Sea Green", "#8FBC8F", Color(hex: "#8FBC8F") ?? .gray),
            ("Dark Slate Blue", "#483D8B", Color(hex: "#483D8B") ?? .gray),
            ("Dark Slate Gray", "#2F4F4F", Color(hex: "#2F4F4F") ?? .gray),
            ("Dark Turquoise", "#00CED1", Color(hex: "#00CED1") ?? .gray),
            ("Dark Violet", "#9400D3", Color(hex: "#9400D3") ?? .gray),
            ("Deep Pink", "#FF1493", Color(hex: "#FF1493") ?? .gray),
            ("Deep Sky Blue", "#00BFFF", Color(hex: "#00BFFF") ?? .gray),
            ("Dim Gray", "#696969", Color(hex: "#696969") ?? .gray),
            ("Dodger Blue", "#1E90FF", Color(hex: "#1E90FF") ?? .gray),
            ("Firebrick", "#B22222", Color(hex: "#B22222") ?? .gray),
            ("Floral White", "#FFFAF0", Color(hex: "#FFFAF0") ?? .gray),
            ("Forest Green", "#228B22", Color(hex: "#228B22") ?? .gray),
            ("Fuchsia", "#FF00FF", Color(hex: "#FF00FF") ?? .gray),
            ("Gainsboro", "#DCDCDC", Color(hex: "#DCDCDC") ?? .gray),
            ("Ghost White", "#F8F8FF", Color(hex: "#F8F8FF") ?? .gray),
            ("Gold", "#FFD700", Color(hex: "#FFD700") ?? .gray),
            ("Goldenrod", "#DAA520", Color(hex: "#DAA520") ?? .gray),
            ("Gray", "#808080", Color(hex: "#808080") ?? .gray),
            ("Green", "#008000", Color(hex: "#008000") ?? .gray),
            ("Green Yellow", "#ADFF2F", Color(hex: "#ADFF2F") ?? .gray),
            ("Honeydew", "#F0FFF0", Color(hex: "#F0FFF0") ?? .gray),
            ("Hot Pink", "#FF69B4", Color(hex: "#FF69B4") ?? .gray),
            ("Indian Red", "#CD5C5C", Color(hex: "#CD5C5C") ?? .gray),
            ("Indigo", "#4B0082", Color(hex: "#4B0082") ?? .gray),
            ("Ivory", "#FFFFF0", Color(hex: "#FFFFF0") ?? .gray),
            ("Khaki", "#F0E68C", Color(hex: "#F0E68C") ?? .gray),
            ("Lavender", "#E6E6FA", Color(hex: "#E6E6FA") ?? .gray),
            ("Lavender Blush", "#FFF0F5", Color(hex: "#FFF0F5") ?? .gray),
            ("Lawn Green", "#7CFC00", Color(hex: "#7CFC00") ?? .gray),
            ("Lemon Chiffon", "#FFFACD", Color(hex: "#FFFACD") ?? .gray),
            ("Light Blue", "#ADD8E6", Color(hex: "#ADD8E6") ?? .gray),
            ("Light Coral", "#F08080", Color(hex: "#F08080") ?? .gray),
            ("Light Cyan", "#E0FFFF", Color(hex: "#E0FFFF") ?? .gray),
            ("Light Goldenrod Yellow", "#FAFAD2", Color(hex: "#FAFAD2") ?? .gray),
            ("Light Gray", "#D3D3D3", Color(hex: "#D3D3D3") ?? .gray),
            ("Light Green", "#90EE90", Color(hex: "#90EE90") ?? .gray),
            ("Light Pink", "#FFB6C1", Color(hex: "#FFB6C1") ?? .gray),
            ("Light Salmon", "#FFA07A", Color(hex: "#FFA07A") ?? .gray),
            ("Light Sea Green", "#20B2AA", Color(hex: "#20B2AA") ?? .gray),
            ("Light Sky Blue", "#87CEEB", Color(hex: "#87CEEB") ?? .gray),
            ("Light Slate Gray", "#778899", Color(hex: "#778899") ?? .gray),
            ("Light Steel Blue", "#B0C4DE", Color(hex: "#B0C4DE") ?? .gray),
            ("Light Yellow", "#FFFFE0", Color(hex: "#FFFFE0") ?? .gray),
            ("Lime", "#00FF00", Color(hex: "#00FF00") ?? .gray),
            ("Lime Green", "#32CD32", Color(hex: "#32CD32") ?? .gray),
            ("Linen", "#FAF0E6", Color(hex: "#FAF0E6") ?? .gray),
            ("Magenta", "#FF00FF", Color(hex: "#FF00FF") ?? .gray),
            ("Maroon", "#800000", Color(hex: "#800000") ?? .gray),
            ("Medium Aquamarine", "#66CDAA", Color(hex: "#66CDAA") ?? .gray),
            ("Medium Blue", "#0000CD", Color(hex: "#0000CD") ?? .gray),
            ("Medium Orchid", "#BA55D3", Color(hex: "#BA55D3") ?? .gray),
            ("Medium Purple", "#9370DB", Color(hex: "#9370DB") ?? .gray),
            ("Medium Sea Green", "#3CB371", Color(hex: "#3CB371") ?? .gray),
            ("Medium Slate Blue", "#7B68EE", Color(hex: "#7B68EE") ?? .gray),
            ("Medium Spring Green", "#00FA9A", Color(hex: "#00FA9A") ?? .gray),
            ("Medium Turquoise", "#48D1CC", Color(hex: "#48D1CC") ?? .gray),
            ("Medium Violet Red", "#C71585", Color(hex: "#C71585") ?? .gray),
            ("Midnight Blue", "#191970", Color(hex: "#191970") ?? .gray),
            ("Mint Cream", "#F5FFFA", Color(hex: "#F5FFFA") ?? .gray),
            ("Misty Rose", "#FFE4E1", Color(hex: "#FFE4E1") ?? .gray),
            ("Moccasin", "#FFE4B5", Color(hex: "#FFE4B5") ?? .gray),
            ("Navajo White", "#FFDEAD", Color(hex: "#FFDEAD") ?? .gray),
            ("Navy", "#000080", Color(hex: "#000080") ?? .gray),
            ("Old Lace", "#FDF5E6", Color(hex: "#FDF5E6") ?? .gray),
            ("Olive", "#808000", Color(hex: "#808000") ?? .gray),
            ("Olive Drab", "#6B8E23", Color(hex: "#6B8E23") ?? .gray),
            ("Orange", "#FFA500", Color(hex: "#FFA500") ?? .gray),
            ("Orange Red", "#FF4500", Color(hex: "#FF4500") ?? .gray),
            ("Orchid", "#DA70D6", Color(hex: "#DA70D6") ?? .gray),
            ("Pale Goldenrod", "#EEE8AA", Color(hex: "#EEE8AA") ?? .gray),
            ("Pale Green", "#98FB98", Color(hex: "#98FB98") ?? .gray),
            ("Pale Turquoise", "#AFEEEE", Color(hex: "#AFEEEE") ?? .gray),
            ("Pale Violet Red", "#DB7093", Color(hex: "#DB7093") ?? .gray),
            ("Papaya Whip", "#FFEFD5", Color(hex: "#FFEFD5") ?? .gray),
            ("Peach Puff", "#FFDAB9", Color(hex: "#FFDAB9") ?? .gray),
            ("Peru", "#CD853F", Color(hex: "#CD853F") ?? .gray),
            ("Pink", "#FFC0CB", Color(hex: "#FFC0CB") ?? .gray),
            ("Plum", "#DDA0DD", Color(hex: "#DDA0DD") ?? .gray),
            ("Powder Blue", "#B0E0E6", Color(hex: "#B0E0E6") ?? .gray),
            ("Purple", "#800080", Color(hex: "#800080") ?? .gray),
            ("Red", "#FF0000", Color(hex: "#FF0000") ?? .gray),
            ("Rosy Brown", "#BC8F8F", Color(hex: "#BC8F8F") ?? .gray),
            ("Royal Blue", "#4169E1", Color(hex: "#4169E1") ?? .gray),
            ("Saddle Brown", "#8B4513", Color(hex: "#8B4513") ?? .gray),
            ("Salmon", "#FA8072", Color(hex: "#FA8072") ?? .gray),
            ("Sandy Brown", "#F4A460", Color(hex: "#F4A460") ?? .gray),
            ("Sea Green", "#2E8B57", Color(hex: "#2E8B57") ?? .gray),
            ("Seashell", "#FFF5EE", Color(hex: "#FFF5EE") ?? .gray),
            ("Sienna", "#A0522D", Color(hex: "#A0522D") ?? .gray),
            ("Silver", "#C0C0C0", Color(hex: "#C0C0C0") ?? .gray),
            ("Sky Blue", "#87CEEB", Color(hex: "#87CEEB") ?? .gray),
            ("Slate Blue", "#6A5ACD", Color(hex: "#6A5ACD") ?? .gray),
            ("Slate Gray", "#708090", Color(hex: "#708090") ?? .gray),
            ("Snow", "#FFFAFA", Color(hex: "#FFFAFA") ?? .gray),
            ("Spring Green", "#00FF7F", Color(hex: "#00FF7F") ?? .gray),
            ("Steel Blue", "#4682B4", Color(hex: "#4682B4") ?? .gray),
            ("Tan", "#D2B48C", Color(hex: "#D2B48C") ?? .gray),
            ("Teal", "#008080", Color(hex: "#008080") ?? .gray),
            ("Thyme", "#D8BFD8", Color(hex: "#D8BFD8") ?? .gray),
            ("Tomato", "#FF6347", Color(hex: "#FF6347") ?? .gray),
            ("Turquoise", "#40E0D0", Color(hex: "#40E0D0") ?? .gray),
            ("Violet", "#EE82EE", Color(hex: "#EE82EE") ?? .gray),
            ("Wheat", "#F5DEB3", Color(hex: "#F5DEB3") ?? .gray),
            ("White", "#FFFFFF", Color(hex: "#FFFFFF") ?? .gray),
            ("White Smoke", "#F5F5F5", Color(hex: "#F5F5F5") ?? .gray),
            ("Yellow", "#FFFF00", Color(hex: "#FFFF00") ?? .gray),
            ("Yellow Green", "#9ACD32", Color(hex: "#9ACD32") ?? .gray)
        ]
    }
    
    var filteredColors: [(String, String, Color)] {
        let allColors = namedColors
        if searchText.isEmpty && selectedCategory == 0 {
            return allColors
        }
        
        var filtered = allColors
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.0.lowercased().contains(searchText.lowercased()) }
        }
        
        // Filter by category (simplified - in real app would have proper categorization)
        if selectedCategory > 0 {
            // For demo, just show first N colors for each category
            let categorySize = 20
            let startIndex = (selectedCategory - 1) * categorySize
            let endIndex = min(startIndex + categorySize, filtered.count)
            if startIndex < filtered.count {
                filtered = Array(filtered[startIndex..<endIndex])
            }
        }
        
        return filtered
    }
    
    var body: some View {
        VStack {
            // Search and Filter
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search colors...", text: $searchText)
                        .font(.system(.body, design: .monospaced))
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(14)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(12)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(0..<colorCategories.count, id: \.self) { index in
                            Button {
                                selectedCategory = index
                            } label: {
                                Text(colorCategories[index])
                                    .font(.system(.caption, design: .monospaced, weight: .medium))
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(
                                        Capsule()
                                            .fill(selectedCategory == index ? Color.accentColor.opacity(0.2) : Color(uiColor: .tertiarySystemBackground))
                                    )
                                    .overlay(
                                        Capsule()
                                            .stroke(selectedCategory == index ? Color.accentColor.opacity(0.4) : Color.clear, lineWidth: 1)
                                    )
                                    .foregroundColor(selectedCategory == index ? .accentColor : .secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.horizontal)
            
            // Results Count
            Text("\(filteredColors.count) colors found")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            // Colors Grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 16) {
                    ForEach(filteredColors, id: \.0) { name, hex, color in
                        VStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(color)
                                .frame(height: 80)
                                .shadow(radius: 4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                                )
                            
                            Text(name)
                                .font(.system(.callout, design: .monospaced, weight: .medium))
                                .lineLimit(2)
                                .minimumScaleFactor(0.7)
                                .multilineTextAlignment(.center)
                            
                            Text(hex)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        .onTapGesture {
                            // Copy hex to clipboard
                            UIPasteboard.general.string = hex
                            HapticManager.instance.notification(type: .success)
                        }
                    }
                }
                .padding()
            }
        }
        .toolbar { ToolbarItem(placement: .principal) { AppNavTitle(text: "Named Colors") } }
    }
}

struct ColorCalculatorView: View {
    @State private var inputColor = Color.red
    @State private var calculationType = 0
    @State private var result: String = ""
    
    let calculationTypes = ["RGB to HSL", "HSL to RGB", "Color Temperature", "Contrast Ratio", "Color Distance"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.1))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "function")
                            .font(.system(size: 32))
                            .foregroundColor(.orange)
                    }
                    
                    Text("Color Calculator")
                        .font(.system(.title, design: .monospaced, weight: .bold))
                    
                    Text("Convert and calculate color values")
                        .font(.system(.subheadline, design: .monospaced))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Color Picker
                VStack(alignment: .leading, spacing: 16) {
                    Text("Select Base Color")
                        .font(.system(.headline, design: .monospaced, weight: .semibold))
                    
                    ColorPicker("Color", selection: $inputColor)
                        .padding()
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .cornerRadius(12)
                }
                
                // Calculation Type
                VStack(alignment: .leading, spacing: 16) {
                    Text("Calculation Type")
                        .font(.system(.headline, design: .monospaced, weight: .semibold))
                    
                    Picker("Type", selection: $calculationType) {
                        ForEach(0..<calculationTypes.count, id: \.self) { index in
                            Text(calculationTypes[index]).tag(index)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 120)
                }
                
                // Calculate Button
                Button(action: performCalculation) {
                    HStack {
                        Image(systemName: "equal")
                        Text("Calculate")
                    }
                    .font(.system(.body, design: .monospaced, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(Color.orange)
                    .cornerRadius(12)
                }
                
                // Results
                if !result.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Results")
                            .font(.system(.headline, design: .monospaced, weight: .semibold))
                        
                        Text(result)
                            .font(.system(.body, design: .monospaced))
                            .lineSpacing(6)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding()
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .cornerRadius(12)
                    }
                }
                
                // Color Preview
                VStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(inputColor)
                        .frame(height: 100)
                        .shadow(radius: 8)
                    
                    Text("Selected Color")
                        .font(.system(.caption, design: .monospaced, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .onChange(of: inputColor) { performCalculation() }
            .onChange(of: calculationType) { performCalculation() }
        }
        .toolbar { ToolbarItem(placement: .principal) { AppNavTitle(text: "Calculator") } }
    }
    
    private func performCalculation() {
        let uiColor = UIColor(inputColor)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        switch calculationType {
        case 0: // RGB to HSL
            var h: CGFloat = 0, s: CGFloat = 0, l: CGFloat = 0
            uiColor.getHue(&h, saturation: &s, brightness: &l, alpha: &a)
            result = String(format: "HSL: %.0f°, %.0f%%, %.0f%%", h * 360, s * 100, l * 100)
            
        case 1: // HSL to RGB (simplified - would need proper conversion)
            result = "HSL to RGB conversion requires specific HSL input values. Use the RGB to HSL calculator above to see HSL values."
            
        case 2: // Color Temperature (rough estimation)
            let warmth = (r * 0.3 + g * 0.6 + b * 0.1)
            if warmth > 0.6 {
                result = "Warm color (estimated \(String(format: "%.0f", warmth * 5000 + 2000))K)"
            } else if warmth > 0.4 {
                result = "Neutral color (estimated \(String(format: "%.0f", warmth * 5000 + 2000))K)"
            } else {
                result = "Cool color (estimated \(String(format: "%.0f", warmth * 5000 + 2000))K)"
            }
            
        case 3: // Contrast Ratio (against white)
            let whiteLuminance = 1.0
            let colorLuminance = calculateLuminance(r: r, g: g, b: b)
            let ratio = (max(whiteLuminance, colorLuminance) + 0.05) / (min(whiteLuminance, colorLuminance) + 0.05)
            result = String(format: "Contrast ratio against white: %.2f:1", ratio)
            
        case 4: // Color Distance (from red - example)
            let redColor = UIColor.red
            var rr: CGFloat = 0, rg: CGFloat = 0, rb: CGFloat = 0
            redColor.getRed(&rr, green: &rg, blue: &rb, alpha: &a)
            
            let distance = sqrt(pow(r - rr, 2) + pow(g - rg, 2) + pow(b - rb, 2))
            result = String(format: "Distance from pure red: %.3f", distance)
            
        default:
            result = ""
        }
    }
    
    private func calculateLuminance(r: CGFloat, g: CGFloat, b: CGFloat) -> CGFloat {
        let toLinear = { (c: CGFloat) -> CGFloat in
            c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * toLinear(r) + 0.7152 * toLinear(g) + 0.0722 * toLinear(b)
    }
}

struct InspirationGalleryView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedCategory = 0
    @State private var refreshToken = UUID()

    private let categories = DailyInspirationLibrary.categories

    private var todaysCurations: [DailyInspirationEntry] {
        guard categories.indices.contains(selectedCategory) else { return [] }
        let category = categories[selectedCategory]
        return DailyInspirationLibrary.curatedEntries(for: category)
    }

    private var featuredEntry: DailyInspirationEntry? {
        todaysCurations.first
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                header
                categoryPicker
                galleryGrid
                featuredSection
            }
            .padding()
        }
        .toolbar { ToolbarItem(placement: .principal) { AppNavTitle(text: "Daily Inspiration") } }
        .refreshable { refreshToken = UUID() }
        .id(refreshToken)
    }

    private var header: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.12))
                    .frame(width: 84, height: 84)

                Image(systemName: "sparkles")
                    .font(.system(size: 34))
                    .foregroundColor(.purple)
            }

            Text("Daily Inspiration Gallery")
                .font(.system(.title, design: .monospaced, weight: .bold))

            Text("Fresh, colorful case studies cycling every day")
                .font(.system(.subheadline, design: .monospaced))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var categoryPicker: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Curated Themes")
                .font(.system(.headline, design: .monospaced, weight: .semibold))

            Picker("Category", selection: $selectedCategory) {
                ForEach(categories.indices, id: \.self) { index in
                    Text(categories[index].title).tag(index)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var galleryGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Spotlight")
                .font(.system(.headline, design: .monospaced, weight: .semibold))

            LazyVGrid(columns: gridColumns, spacing: 18) {
                ForEach(todaysCurations) { entry in
                    InspirationTile(entry: entry)
                }
            }
        }
    }

    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("✨ Featured Cue")
                .font(.system(.headline, design: .monospaced, weight: .semibold))

            if let featuredEntry {
                InspirationHero(entry: featuredEntry)
            } else {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.gray.opacity(0.12))
                    .frame(height: 220)
                    .overlay(
                        VStack(spacing: 8) {
                            ProgressView().tint(.primary)
                            Text("Loading today's set")
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                    )
            }
        }
    }

    private var gridColumns: [GridItem] {
        if horizontalSizeClass == .compact {
            return [GridItem(.flexible(), spacing: 16)]
        }
        return [GridItem(.adaptive(minimum: 220), spacing: 20)]
    }
}

// MARK: - Gallery Image Loading Helpers

fileprivate final class GalleryImageLoader: ObservableObject {
    enum Phase {
        case idle
        case loading
        case success(UIImage)
        case failure
    }

    @Published private(set) var phase: Phase = .idle

    private static let cache: NSCache<NSURL, UIImage> = {
        let cache = NSCache<NSURL, UIImage>()
        cache.countLimit = 60
        cache.totalCostLimit = 60 * 1024 * 1024
        return cache
    }()

    private var task: URLSessionDataTask?
    private var currentURL: URL?

    func load(url: URL) {
        if currentURL == url {
            if case .loading = phase { return }
            if case .success = phase { return }
        } else {
            currentURL = url
            phase = .idle
        }

        if let cached = Self.cache.object(forKey: url as NSURL) {
            phase = .success(cached)
            return
        }

        phase = .loading
        fetch(url: url, attempt: 0)
    }

    func retry() {
        guard let url = currentURL else { return }
        phase = .loading
        fetch(url: url, attempt: 0)
    }

    private func fetch(url: URL, attempt: Int) {
        task?.cancel()

        var request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 25)
        request.setValue("Mozilla/5.0 (iOS) Ambit/1.0", forHTTPHeaderField: "User-Agent")

        task = URLSession.shared.dataTask(with: request) { [weak self] data, _, _ in
            guard let self else { return }

            if let data, let image = UIImage(data: data) {
                Self.cache.setObject(image, forKey: url as NSURL, cost: data.count)
                DispatchQueue.main.async {
                    self.phase = .success(image)
                }
                return
            }

            if attempt < 2 {
                let nextAttempt = attempt + 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                    self.fetch(url: url, attempt: nextAttempt)
                }
            } else {
                DispatchQueue.main.async {
                    self.phase = .failure
                }
            }
        }
        task?.resume()
    }

    deinit {
        task?.cancel()
    }
}

fileprivate struct GalleryImageView<Content: View, Placeholder: View, Failure: View>: View {
    let url: URL
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: () -> Placeholder
    @ViewBuilder let failure: (_ retry: @escaping () -> Void) -> Failure

    @StateObject private var loader = GalleryImageLoader()

    var body: some View {
        Group {
            switch loader.phase {
            case .idle, .loading:
                placeholder()
            case .success(let image):
                content(Image(uiImage: image))
            case .failure:
                failure { loader.retry() }
            }
        }
        .task(id: url) {
            loader.load(url: url)
        }
    }
}

fileprivate struct InspirationTile: View {
    @Environment(\.openURL) private var openURL
    let entry: DailyInspirationEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            GalleryImageView(
                url: entry.imageURL,
                content: { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 160)
                        .overlay(alignment: .bottomLeading) {
                            ZStack(alignment: .bottomLeading) {
                                LinearGradient(colors: [.black.opacity(0.0), .black.opacity(0.55)], startPoint: .top, endPoint: .bottom)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.title)
                                        .font(.system(.callout, design: .monospaced, weight: .semibold))
                                        .foregroundColor(.white)
                                    Text(entry.location)
                                        .font(.system(.caption, design: .monospaced))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding(12)
                            }
                        }
                },
                placeholder: {
                    ZStack {
                        Color.gray.opacity(0.12)
                        ProgressView().tint(.primary)
                    }
                    .frame(height: 160)
                },
                failure: { retry in
                    fallbackView(retry: retry)
                        .frame(height: 160)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 4)
            VStack(alignment: .leading, spacing: 6) {
                Text(entry.caption)
                    .font(.system(.callout, design: .monospaced))
                    .foregroundColor(.primary)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    ForEach(entry.paletteIndices, id: \.self) { index in
                        if let color = entry.color(at: index) {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(color)
                                .frame(width: 28, height: 20)
                        }
                    }
                    Spacer()
                    Text(entry.credit)
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }
        }
        .onTapGesture {
            HapticManager.instance.impact(style: .light)
            openURL(entry.sourceURL)
        }
        .contextMenu {
            Button("Open Source") {
                openURL(entry.sourceURL)
            }
            Button("Copy Hex Palette") {
                UIPasteboard.general.string = entry.palette.joined(separator: ", ")
                HapticManager.instance.notification(type: .success)
            }
        }
    }

    private func fallbackView(retry: @escaping () -> Void) -> some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(LinearGradient(colors: [.gray.opacity(0.25), .gray.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(height: 160)
            .overlay(
                VStack(spacing: 6) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 22))
                        .foregroundColor(.secondary)
                    Text("Image unavailable")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)
                    Button("Retry") { retry() }
                        .font(.system(.caption, design: .monospaced, weight: .semibold))
                        .buttonStyle(.bordered)
                        .tint(.secondary)
                }
            )
    }
}

fileprivate struct InspirationHero: View {
    @Environment(\.openURL) private var openURL
    let entry: DailyInspirationEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            GalleryImageView(
                url: entry.imageURL,
                content: { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 220)
                        .overlay(
                            LinearGradient(colors: [.black.opacity(0.0), .black.opacity(0.65)], startPoint: .center, endPoint: .bottom)
                        )
                        .overlay(alignment: .bottomLeading) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(entry.title)
                                    .font(.system(.title3, design: .monospaced, weight: .bold))
                                    .foregroundColor(.white)
                                Text(entry.caption)
                                    .font(.system(.callout, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.85))
                                    .lineLimit(2)
                                Text(entry.creditDetail)
                                    .font(.system(.caption2, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(18)
                        }
                },
                placeholder: {
                    ZStack {
                        Color.gray.opacity(0.12)
                        ProgressView().tint(.primary)
                    }
                    .frame(height: 220)
                },
                failure: { retry in
                    fallback(retry: retry)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 6)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(entry.palette, id: \.self) { swatch in
                        PaletteSwatchChip(hex: swatch)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .onTapGesture {
            HapticManager.instance.impact(style: .rigid)
            openURL(entry.sourceURL)
        }
        .contextMenu {
            Button("Open Source") {
                openURL(entry.sourceURL)
            }
            Button("Copy Hex Palette") {
                UIPasteboard.general.string = entry.palette.joined(separator: ", ")
                HapticManager.instance.notification(type: .success)
            }
        }
    }

    private func fallback(retry: @escaping () -> Void) -> some View {
        RoundedRectangle(cornerRadius: 26, style: .continuous)
            .fill(LinearGradient(colors: [.gray.opacity(0.25), .gray.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(height: 220)
            .overlay(
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.secondary)
                    Text("Featured image unavailable")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)
                    Button("Retry") { retry() }
                        .font(.system(.caption, design: .monospaced, weight: .semibold))
                        .buttonStyle(.bordered)
                        .tint(.secondary)
                }
            )
    }
}

fileprivate struct PaletteSwatchChip: View {
    let hex: String

    var body: some View {
        VStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(hex: hex) ?? .clear)
                .frame(width: 52, height: 28)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
                )

            Text(hex.uppercased())
                .font(.system(.caption2, design: .monospaced, weight: .semibold))
                .foregroundColor(.secondary)
                .lineLimit(2)
                .minimumScaleFactor(0.6)
                .multilineTextAlignment(.center)
                .frame(width: 64)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(Color(uiColor: .secondarySystemBackground).opacity(0.9))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

fileprivate struct DailyInspirationEntry: Identifiable {
    let id = UUID()
    let category: DailyInspirationCategory
    let title: String
    let caption: String
    let location: String
    let photographer: String
    let palette: [String]
    let sourceURL: URL
    let imageURL: URL

    var credit: String { "© \(photographer)" }
    var creditDetail: String { "Shot by \(photographer) — \(location)" }

    var paletteIndices: [Int] {
        Array(palette.indices.prefix(3))
    }

    func color(at index: Int) -> Color? {
        guard palette.indices.contains(index) else { return nil }
        return Color(hex: palette[index])
    }
}

fileprivate struct DailyInspirationCategory: Identifiable {
    let id = UUID()
    let title: String
    let seed: Int
}

fileprivate enum DailyInspirationLibrary {
    static let categories: [DailyInspirationCategory] = [
        DailyInspirationCategory(title: "Nature", seed: 11),
        DailyInspirationCategory(title: "Urban", seed: 29),
        DailyInspirationCategory(title: "Abstract", seed: 47),
        DailyInspirationCategory(title: "Textures", seed: 61),
        DailyInspirationCategory(title: "Gradients", seed: 73)
    ]

    static func curatedEntries(for category: DailyInspirationCategory) -> [DailyInspirationEntry] {
        let library = curatedLibrary[category.title] ?? []
        guard !library.isEmpty else { return [] }

        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        let window = 6
        let offset = (dayOfYear + category.seed) % library.count

        return (0..<min(window, library.count)).map { index in
            let resolvedIndex = (offset + index) % library.count
            return library[resolvedIndex]
        }
    }

    private static let curatedLibrary: [String: [DailyInspirationEntry]] = {
        let nature: [DailyInspirationEntry] = [
            DailyInspirationEntry(
                category: categories[0],
                title: "Aurora Silence",
                caption: "Emerald auroras wrap snow-capped peaks in the Lofoten Islands.",
                location: "Lofoten, Norway",
                photographer: "Johny Goerend",
                palette: ["#0C1C2C", "#1F6756", "#77D4C1", "#F5FEFF"],
                sourceURL: URL(string: "https://unsplash.com/photos/8N0NnEzpT7A")!,
                imageURL: URL(string: "https://images.unsplash.com/photo-1470770841072-f978cf4d019e?auto=format&fit=crop&w=1600&q=80")!
            ),
            DailyInspirationEntry(
                category: categories[0],
                title: "Sunset Amphitheatre",
                caption: "Layered dunes glow in burnt ochres and rose gold.",
                location: "Namib Desert, Namibia",
                photographer: "Dan Grinwis",
                palette: ["#53160C", "#C65B2F", "#FF9E63", "#FFE1C8"],
                sourceURL: URL(string: "https://unsplash.com/photos/hjsV4B-HnfQ")!,
                imageURL: URL(string: "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1600&q=80")!
            ),
            DailyInspirationEntry(
                category: categories[0],
                title: "Misty Forest Rise",
                caption: "Fog lifts to reveal verdant slopes drenched in morning light.",
                location: "Jiuzhaigou, China",
                photographer: "Roberto Nickson",
                palette: ["#0C2F24", "#145C47", "#3DA778", "#E2F5EC"],
                sourceURL: URL(string: "https://unsplash.com/photos/ZG3AlXw9FB0")!,
                imageURL: URL(string: "https://images.unsplash.com/photo-1476041800959-2f6bb412c8ce?auto=format&fit=crop&w=1600&q=80")!
            ),
            DailyInspirationEntry(
                category: categories[0],
                title: "Lavender Horizon",
                caption: "Rows of lavender lead to a tangerine twilight.",
                location: "Provence, France",
                photographer: "Leonard Cotte",
                palette: ["#422266", "#9E5CF2", "#F6B1C3", "#FFDCB3"],
                sourceURL: URL(string: "https://unsplash.com/photos/R5scocnOOdM")!,
                imageURL: URL(string: "https://images.unsplash.com/photo-1496317899792-9d7dbcd928a1?auto=format&fit=crop&w=1600&q=80")!
            ),
            DailyInspirationEntry(
                category: categories[0],
                title: "Coral Reef Symphony",
                caption: "Turquoise tides crash over coral shades of peach and coral.",
                location: "Great Barrier Reef, Australia",
                photographer: "Samantha Gades",
                palette: ["#00546E", "#00A6B6", "#FF7C70", "#FFE4D3"],
                sourceURL: URL(string: "https://unsplash.com/photos/FklMyq__9xY")!,
                imageURL: URL(string: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1600&q=80")!
            )
        ]

        let urban: [DailyInspirationEntry] = [
            DailyInspirationEntry(
                category: categories[1],
                title: "Neon Alley",
                caption: "Vivid kanji signage reflects in late-night rain puddles.",
                location: "Shinjuku, Tokyo",
                photographer: "Steven Roe",
                palette: ["#041320", "#0B5DD7", "#F03B9E", "#F5F2F7"],
                sourceURL: URL(string: "https://unsplash.com/photos/g819psF84Lc")!,
                imageURL: URL(string: "https://images.unsplash.com/photo-1526402468629-1754f369489d?auto=format&fit=crop&w=1600&q=80")!
            ),
            DailyInspirationEntry(
                category: categories[1],
                title: "Desert Modernism",
                caption: "Palm Springs angles painted in mid-century sherbets.",
                location: "Palm Springs, USA",
                photographer: "Daniil Vnoutchkov",
                palette: ["#F4F8FF", "#FCD3D1", "#F98771", "#374A90"],
                sourceURL: URL(string: "https://unsplash.com/photos/3WAMh1omVAY")!,
                imageURL: URL(string: "https://images.unsplash.com/photo-1494526585095-c41746248156?auto=format&fit=crop&w=1600&q=80")!
            ),
            DailyInspirationEntry(
                category: categories[1],
                title: "Golden Commute",
                caption: "Sunrise warms rusting steel across the Manhattan Bridge.",
                location: "New York City, USA",
                photographer: "Colton Duke",
                palette: ["#0C1321", "#1B3A4B", "#F2A541", "#F7F0E5"],
                sourceURL: URL(string: "https://unsplash.com/photos/2lH1Hzq1T5E")!,
                imageURL: URL(string: "https://images.unsplash.com/photo-1500534305150-69f9f3019891?auto=format&fit=crop&w=1600&q=80")!
            ),
            DailyInspirationEntry(
                category: categories[1],
                title: "Pastel Facades",
                caption: "Lisbon townhouses painted in gelato hues.",
                location: "Lisbon, Portugal",
                photographer: "Annie Spratt",
                palette: ["#F7F0E9", "#F8A7A1", "#7BCDD2", "#2D4F6C"],
                sourceURL: URL(string: "https://unsplash.com/photos/QPhMS8W6K7g")!,
                imageURL: URL(string: "https://images.unsplash.com/photo-1496247749665-49cf5b1022e9?auto=format&fit=crop&w=1600&q=80")!
            )
        ]

        let abstract: [DailyInspirationEntry] = [
            DailyInspirationEntry(
                category: categories[2],
                title: "Chromatic Cloud",
                caption: "Ink suspended in water morphs into a cosmic bloom.",
                location: "Berlin, Germany",
                photographer: "Paola Galimberti",
                palette: ["#1B1F3B", "#7225E6", "#F76C9E", "#FEEAFA"],
                sourceURL: URL(string: "https://unsplash.com/photos/cX_44c9rng4")!,
                imageURL: URL(string: "https://images.unsplash.com/photo-1526317891728-36969a67d4e5?auto=format&fit=crop&w=1600&q=80")!
            ),
            DailyInspirationEntry(
                category: categories[2],
                title: "Prismatic Peaks",
                caption: "Diffuse lighting fractures across folded acrylic.",
                location: "Reykjavík, Iceland",
                photographer: "Noah Buscher",
                palette: ["#090910", "#1F4E88", "#86E3CE", "#FF9F9F"],
                sourceURL: URL(string: "https://unsplash.com/photos/x8ZStukS2PM")!,
                imageURL: URL(string: "https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?auto=format&fit=crop&w=1600&q=80")!
            ),
            DailyInspirationEntry(
                category: categories[2],
                title: "Spectrum Flow",
                caption: "Blended pigments create a holographic ribbon.",
                location: "Barcelona, Spain",
                photographer: "Sasha Matic",
                palette: ["#130721", "#4B38F4", "#DE5BFE", "#FFCEFA"],
                sourceURL: URL(string: "https://unsplash.com/photos/BRkikoNP0KQ")!,
                imageURL: URL(string: "https://images.unsplash.com/photo-1525104698733-6d2e1b8d0bbf?auto=format&fit=crop&w=1600&q=80")!
            )
        ]

        let textures: [DailyInspirationEntry] = [
            DailyInspirationEntry(
                category: categories[3],
                title: "Terracotta Tiers",
                caption: "Handmade ceramic tiles glow in desert neutrals.",
                location: "Marrakesh, Morocco",
                photographer: "Toa Heftiba",
                palette: ["#5C3D2E", "#C7795D", "#E4A788", "#F8EFE9"],
                sourceURL: URL(string: "https://unsplash.com/photos/_UIN-pFfJ7c")!,
                imageURL: URL(string: "https://images.unsplash.com/photo-1489515217757-5fd1be406fef?auto=format&fit=crop&w=1600&q=80")!
            ),
            DailyInspirationEntry(
                category: categories[3],
                title: "Ocean Stone",
                caption: "Polished agate slices reveal turquoise gradients.",
                location: "Ubatuba, Brazil",
                photographer: "Brad Helmink",
                palette: ["#0B2A3A", "#107896", "#39A9DB", "#F4F9FB"],
                sourceURL: URL(string: "https://unsplash.com/photos/NkQD-RHhbvY")!,
                imageURL: URL(string: "https://images.unsplash.com/photo-1441974231531-c6227db76b6e?auto=format&fit=crop&w=1600&q=80")!
            ),
            DailyInspirationEntry(
                category: categories[3],
                title: "Velvet Bloom",
                caption: "Macro petals show petal-to-petal color shifts.",
                location: "Portland, USA",
                photographer: "Debby Hudson",
                palette: ["#381129", "#8B2C53", "#EB6383", "#FFD9E0"],
                sourceURL: URL(string: "https://unsplash.com/photos/1UY8UuUkids")!,
                imageURL: URL(string: "https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1600&q=80")!
            )
        ]

        let gradients: [DailyInspirationEntry] = [
            DailyInspirationEntry(
                category: categories[4],
                title: "Dawn Horizon",
                caption: "Soft gradients bridge blush skies into calm seas.",
                location: "Santorini, Greece",
                photographer: "Eberhard Grossgasteiger",
                palette: ["#1C2C44", "#465A7C", "#FF9A9E", "#FAD0C4"],
                sourceURL: URL(string: "https://unsplash.com/photos/vt8gA8-0FZk")!,
                imageURL: URL(string: "https://images.unsplash.com/photo-1505483531331-42723563d2fb?auto=format&fit=crop&w=1600&q=80")!
            ),
            DailyInspirationEntry(
                category: categories[4],
                title: "Skyline Fade",
                caption: "City haze dissolves into evening violets and ambers.",
                location: "Seoul, South Korea",
                photographer: "Lance Asper",
                palette: ["#0F1A2B", "#41295A", "#F2A65A", "#F7CED7"],
                sourceURL: URL(string: "https://unsplash.com/photos/msMck-OKISg")!,
                imageURL: URL(string: "https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?auto=format&fit=crop&w=1600&q=80")!
            ),
            DailyInspirationEntry(
                category: categories[4],
                title: "Aurora Veil",
                caption: "Polar light cascades in teal, amethyst, and rose.",
                location: "Tromsø, Norway",
                photographer: "Giuseppe Milo",
                palette: ["#0A1320", "#133A4A", "#3F7D9F", "#D4B8FF"],
                sourceURL: URL(string: "https://unsplash.com/photos/XMcohCf7wRw")!,
                imageURL: URL(string: "https://images.unsplash.com/photo-1519683108660-7e25aa0c528b?auto=format&fit=crop&w=1600&q=80")!
            )
        ]

        return [
            categories[0].title: nature,
            categories[1].title: urban,
            categories[2].title: abstract,
            categories[3].title: textures,
            categories[4].title: gradients
        ]
    }()
}

// MARK: - Missing Learning Views
// =============================

struct ColorTheoryGuideView: View {
    @State private var selectedLessonIndex = 0
    @State private var quizScore = 0
    @State private var showQuiz = false
    
    let tabs = ["Basics", "Color Wheel", "Harmony", "Psychology", "Quiz"]
    
    var body: some View {
        NavigationStack {
            VStack {
                // Progress Indicator
                HStack(spacing: 8) {
                    ForEach(0..<tabs.count, id: \.self) { index in
                        Circle()
                            .fill(index <= selectedLessonIndex ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 8)
                
                TabView(selection: $selectedLessonIndex) {
                    basicsTab.tag(0)
                    colorWheelTab.tag(1)
                    harmonyTab.tag(2)
                    psychologyTab.tag(3)
                    quizTab.tag(4)
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .never))
            }
            .toolbar { ToolbarItem(placement: .principal) { AppNavTitle(text: "Color Theory") } }
        }
    }
    
    private var basicsTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("🎨 What is Color Theory?")
                        .font(.system(.title, design: .monospaced, weight: .bold))
                    
                    Text("Color theory is the science and art of using color. It explains how humans perceive color and the visual effects of how colors mix, match, or contrast with each other.")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineSpacing(6)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Primary Colors")
                        .font(.system(.title2, design: .monospaced, weight: .semibold))
                    
                    HStack(spacing: 16) {
                        ColorCircle(color: .red, name: "Red")
                        ColorCircle(color: .blue, name: "Blue")
                        ColorCircle(color: .yellow, name: "Yellow")
                    }
                    
                    Text("Primary colors cannot be created by mixing other colors. All other colors are derived from these three.")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Secondary Colors")
                        .font(.system(.title2, design: .monospaced, weight: .semibold))
                    
                    HStack(spacing: 16) {
                        ColorCircle(color: .green, name: "Green")
                        ColorCircle(color: .orange, name: "Orange")
                        ColorCircle(color: .purple, name: "Purple")
                    }
                    
                    Text("Secondary colors are created by mixing two primary colors together.")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Tertiary Colors")
                        .font(.system(.title2, design: .monospaced, weight: .semibold))
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                        ColorCircle(color: Color(red: 1, green: 0.5, blue: 0), name: "Red-Orange")
                        ColorCircle(color: Color(red: 1, green: 1, blue: 0), name: "Yellow-Orange")
                        ColorCircle(color: Color(red: 0.5, green: 1, blue: 0), name: "Yellow-Green")
                        ColorCircle(color: Color(red: 0, green: 1, blue: 0.5), name: "Blue-Green")
                        ColorCircle(color: Color(red: 0, green: 0.5, blue: 1), name: "Blue-Purple")
                        ColorCircle(color: Color(red: 0.5, green: 0, blue: 1), name: "Red-Purple")
                    }
                    
                    Text("Tertiary colors are created by mixing a primary and secondary color together.")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
    }
    
    private var colorWheelTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("🎯 The Color Wheel")
                        .font(.system(.title, design: .monospaced, weight: .bold))
                    
                    Text("The color wheel is a visual representation of colors arranged according to their chromatic relationship.")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineSpacing(6)
                }
                
                // Interactive Color Wheel
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 250, height: 250)
                    
                    // Primary colors
                    ColorWheelSegment(angle: 0, color: .red, name: "Red")
                    ColorWheelSegment(angle: 120, color: .green, name: "Green")
                    ColorWheelSegment(angle: 240, color: .blue, name: "Blue")
                    
                    // Secondary colors
                    ColorWheelSegment(angle: 60, color: .yellow, name: "Yellow")
                    ColorWheelSegment(angle: 180, color: .cyan, name: "Cyan")
                    ColorWheelSegment(angle: 300, color: Color(red: 1, green: 0, blue: 1), name: "Magenta")
                    
                    // Tertiary colors
                    ForEach(0..<12) { i in
                        if i % 3 != 0 { // Skip primaries
                            let angle = Double(i) * 30
                            let hue = Double(i) / 12.0
                            ColorWheelSegment(angle: angle, color: Color(hue: hue, saturation: 1, brightness: 1), name: "")
                        }
                    }
                }
                .frame(width: 250, height: 250)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Color Relationships")
                        .font(.system(.title2, design: .monospaced, weight: .semibold))
                    
                    VStack(alignment: .leading, spacing: 12) {
                        RelationshipRow(title: "Complementary", description: "Colors opposite each other", example: "Red & Green")
                        RelationshipRow(title: "Analogous", description: "Colors next to each other", example: "Blue, Blue-Green, Green")
                        RelationshipRow(title: "Triadic", description: "Three colors equally spaced", example: "Red, Yellow, Blue")
                        RelationshipRow(title: "Split-Complementary", description: "Base + two adjacent to complement", example: "Blue, Red-Orange, Yellow-Orange")
                    }
                }
            }
            .padding()
        }
    }
    
    private var harmonyTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("✨ Color Harmony")
                        .font(.system(.title, design: .monospaced, weight: .bold))
                    
                    Text("Color harmony refers to the pleasing arrangement of colors. Harmonious color schemes create visual balance and cohesion.")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineSpacing(6)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Harmony Types")
                        .font(.system(.title2, design: .monospaced, weight: .semibold))
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 16) {
                        HarmonyExample(type: "Complementary", colors: [.red, .green], description: "High contrast, vibrant")
                        HarmonyExample(type: "Analogous", colors: [.blue, Color(hue: 0.6, saturation: 1, brightness: 1), .green], description: "Peaceful, serene")
                        HarmonyExample(type: "Triadic", colors: [.red, .yellow, .blue], description: "Balanced, vibrant")
                        HarmonyExample(type: "Monochromatic", colors: [Color(hue: 0.5, saturation: 1, brightness: 1), Color(hue: 0.5, saturation: 0.7, brightness: 0.8), Color(hue: 0.5, saturation: 0.4, brightness: 0.6)], description: "Sophisticated, elegant")
                    }
                }
            }
            .padding()
        }
    }
    
    private var psychologyTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("🧠 Color Psychology")
                        .font(.system(.title, design: .monospaced, weight: .bold))
                    
                    Text("Colors can evoke different emotions and associations. Understanding color psychology helps create more effective designs.")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineSpacing(6)
                }
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 16) {
                    ColorPsychologyCard(color: .red, emotion: "Energy", associations: "Passion, urgency, excitement")
                    ColorPsychologyCard(color: .blue, emotion: "Trust", associations: "Calm, reliability, professionalism")
                    ColorPsychologyCard(color: .green, emotion: "Growth", associations: "Nature, harmony, freshness")
                    ColorPsychologyCard(color: .yellow, emotion: "Optimism", associations: "Happiness, creativity, warmth")
                    ColorPsychologyCard(color: .purple, emotion: "Luxury", associations: "Creativity, wisdom, mystery")
                    ColorPsychologyCard(color: .orange, emotion: "Confidence", associations: "Enthusiasm, success, vitality")
                }
            }
            .padding()
        }
    }
    
    private var quizTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("🧠 Color Theory Quiz")
                        .font(.system(.title, design: .monospaced, weight: .bold))
                    
                    Text("Test your knowledge of color theory with this interactive quiz!")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 20) {
                    Text("Score: \(quizScore)/5")
                        .font(.system(.title2, design: .monospaced, weight: .bold))
                        .foregroundColor(.blue)
                    
                    QuizQuestion(
                        question: "What are the three primary colors?",
                        options: ["Red, Yellow, Blue", "Red, Green, Blue", "Cyan, Magenta, Yellow"],
                        correctAnswer: 0,
                        score: $quizScore
                    )
                    
                    QuizQuestion(
                        question: "Which color harmony uses colors opposite each other on the color wheel?",
                        options: ["Analogous", "Complementary", "Triadic"],
                        correctAnswer: 1,
                        score: $quizScore
                    )
                    
                    QuizQuestion(
                        question: "What emotion is commonly associated with the color blue?",
                        options: ["Energy", "Trust", "Luxury"],
                        correctAnswer: 1,
                        score: $quizScore
                    )
                    
                    QuizQuestion(
                        question: "How many tertiary colors are there?",
                        options: ["3", "6", "12"],
                        correctAnswer: 1,
                        score: $quizScore
                    )
                    
                    QuizQuestion(
                        question: "Which harmony type uses three colors equally spaced on the color wheel?",
                        options: ["Complementary", "Split-Complementary", "Triadic"],
                        correctAnswer: 2,
                        score: $quizScore
                    )
                }
                
                if quizScore == 5 {
                    VStack(spacing: 12) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.yellow)
                        
                        Text("Perfect Score!")
                            .font(.system(.title, design: .monospaced, weight: .bold))
                        
                        Text("You're a color theory expert!")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(16)
                }
            }
            .padding()
        }
    }
}

struct ColorCircle: View {
    let color: Color
    let name: String
    
    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 60, height: 60)
                .shadow(radius: 4)
            
            Text(name)
                .font(.system(.caption, design: .monospaced, weight: .medium))
                .foregroundColor(.primary)
        }
    }
}

struct ColorWheelSegment: View {
    let angle: Double
    let color: Color
    let name: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: 60, height: 60)
                .offset(x: 95 * cos((angle - 90) * .pi / 180), y: 95 * sin((angle - 90) * .pi / 180))
            
            if !name.isEmpty {
                Text(name)
                    .font(.system(.caption, design: .monospaced, weight: .bold))
                    .foregroundColor(.white)
                    .offset(x: 95 * cos((angle - 90) * .pi / 180), y: 95 * sin((angle - 90) * .pi / 180))
            }
        }
    }
}

struct RelationshipRow: View {
    let title: String
    let description: String
    let example: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(.headline, design: .monospaced, weight: .semibold))
            
            NoHyphenationLabel(
                text: description,
                font: UIFont.monospacedSystemFont(ofSize: 14, weight: .regular),
                color: UIColor.secondaryLabel
            )
            
            Text("Example: \(example)")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(8)
    }
}

struct HarmonyExample: View {
    let type: String
    let colors: [Color]
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(type)
                .font(.system(.headline, design: .monospaced, weight: .semibold))
            
            HStack(spacing: 0) {
                ForEach(colors, id: \.self) { color in
                    color.frame(height: 40)
                }
            }
            .cornerRadius(8)
            
            NoHyphenationLabel(
                text: description,
                font: UIFont.monospacedSystemFont(ofSize: 12, weight: .regular),
                color: UIColor.secondaryLabel
            )
            .lineLimit(2)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct ColorPsychologyCard: View {
    let color: Color
    let emotion: String
    let associations: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 40, height: 40)
                .shadow(radius: 4)
            
            Text(emotion)
                .font(.system(.headline, design: .monospaced, weight: .semibold))
            
            NoHyphenationLabel(
                text: associations,
                font: UIFont.monospacedSystemFont(ofSize: 12, weight: .regular),
                color: UIColor.secondaryLabel
            )
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct QuizQuestion: View {
    let question: String
    let options: [String]
    let correctAnswer: Int
    @Binding var score: Int
    @State private var selectedAnswer: Int? = nil
    @State private var hasAnswered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(question)
                .font(.system(.headline, design: .monospaced, weight: .semibold))
            
            VStack(spacing: 8) {
                ForEach(0..<options.count, id: \.self) { index in
                    Button(action: {
                        if !hasAnswered {
                            selectedAnswer = index
                            hasAnswered = true
                            if index == correctAnswer {
                                score += 1
                            }
                        }
                    }) {
                        HStack {
                            Text(options[index])
                                .font(.system(.body, design: .monospaced))
                            
                            Spacer()
                            
                            if hasAnswered && index == correctAnswer {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else if hasAnswered && selectedAnswer == index && index != correctAnswer {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding()
                        .background(
                            hasAnswered ?
                                (index == correctAnswer ? Color.green.opacity(0.2) :
                                 selectedAnswer == index ? Color.red.opacity(0.2) :
                                 Color.gray.opacity(0.1)) :
                                Color.gray.opacity(0.1)
                        )
                        .cornerRadius(8)
                        .disabled(hasAnswered)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

// MARK: - Missing Tool Views
// ========================

struct ColorTrendsView: View {
    @State private var selectedCategory = 0
    @State private var selectedTimeframe = 0
    
    let categories = ["Popular", "Seasonal", "Industry", "Global"]
    let timeframes = ["This Week", "This Month", "This Year", "All Time"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text("📊 Color Trends")
                            .font(.system(.title, design: .monospaced, weight: .bold))
                        
                        Text("Discover the most popular colors and emerging trends")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    
                    // Category Picker
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(0..<categories.count, id: \.self) { index in
                            Text(categories[index]).tag(index)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    // Timeframe Picker
                    Picker("Timeframe", selection: $selectedTimeframe) {
                        ForEach(0..<timeframes.count, id: \.self) { index in
                            Text(timeframes[index]).tag(index)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    // Trending Colors
                    VStack(alignment: .leading, spacing: 16) {
                        Text("🔥 Trending Now")
                            .font(.system(.title2, design: .monospaced, weight: .semibold))
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 16) {
                            TrendingColorCard(
                                color: Color(hex: "#FF6B6B") ?? .red,
                                name: "Coral Pink",
                                trend: "+45%",
                                rank: 1
                            )
                            
                            TrendingColorCard(
                                color: Color(hex: "#4ECDC4") ?? .teal,
                                name: "Mint Green",
                                trend: "+32%",
                                rank: 2
                            )
                            
                            TrendingColorCard(
                                color: Color(hex: "#45B7D1") ?? .blue,
                                name: "Sky Blue",
                                trend: "+28%",
                                rank: 3
                            )
                            
                            TrendingColorCard(
                                color: Color(hex: "#FFA07A") ?? .orange,
                                name: "Peach",
                                trend: "+24%",
                                rank: 4
                            )
                            
                            TrendingColorCard(
                                color: Color(hex: "#98D8C8") ?? .green,
                                name: "Sage Green",
                                trend: "+19%",
                                rank: 5
                            )
                        }
                    }
                    
                    // Seasonal Trends
                    VStack(alignment: .leading, spacing: 16) {
                        Text("🌸 Seasonal Colors")
                            .font(.system(.title2, design: .monospaced, weight: .semibold))
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 16) {
                            SeasonalTrendCard(
                                season: "Spring",
                                colors: [
                                    Color(hex: "#FFB3BA") ?? .pink,
                                    Color(hex: "#FFDFBA") ?? .yellow,
                                    Color(hex: "#FFFFBA") ?? .yellow,
                                    Color(hex: "#BAFFBA") ?? .green
                                ],
                                description: "Fresh, vibrant colors inspired by new growth"
                            )
                            
                            SeasonalTrendCard(
                                season: "Summer",
                                colors: [
                                    Color(hex: "#BAE1FF") ?? .blue,
                                    Color(hex: "#A8E6CF") ?? .green,
                                    Color(hex: "#FFD3A5") ?? .orange,
                                    Color(hex: "#FFAAA5") ?? .pink
                                ],
                                description: "Bright, energetic colors for warm weather"
                            )
                            
                            SeasonalTrendCard(
                                season: "Fall",
                                colors: [
                                    Color(hex: "#D4A574") ?? .orange,
                                    Color(hex: "#A64B2A") ?? .brown,
                                    Color(hex: "#8B4513") ?? .brown,
                                    Color(hex: "#654321") ?? .brown
                                ],
                                description: "Warm, earthy tones reflecting autumn foliage"
                            )
                            
                            SeasonalTrendCard(
                                season: "Winter",
                                colors: [
                                    Color(hex: "#2C3E50") ?? .blue,
                                    Color(hex: "#34495E") ?? .blue,
                                    Color(hex: "#7F8C8D") ?? .gray,
                                    Color(hex: "#BDC3C7") ?? .gray
                                ],
                                description: "Cool, sophisticated colors for colder months"
                            )
                        }
                    }
                    
                    // Industry Trends
                    VStack(alignment: .leading, spacing: 16) {
                        Text("🏢 Industry Trends")
                            .font(.system(.title2, design: .monospaced, weight: .semibold))
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 16) {
                            IndustryTrendCard(
                                industry: "Tech",
                                colors: [
                                    Color(hex: "#007AFF") ?? .blue,
                                    Color(hex: "#34C759") ?? .green,
                                    Color(hex: "#FF9500") ?? .orange,
                                    Color(hex: "#FF3B30") ?? .red
                                ],
                                description: "Clean, modern colors for digital interfaces"
                            )
                            
                            IndustryTrendCard(
                                industry: "Fashion",
                                colors: [
                                    Color(hex: "#E91E63") ?? .pink,
                                    Color(hex: "#9C27B0") ?? .purple,
                                    Color(hex: "#3F51B5") ?? .blue,
                                    Color(hex: "#009688") ?? .teal
                                ],
                                description: "Bold, expressive colors for apparel design"
                            )
                            
                            IndustryTrendCard(
                                industry: "Food",
                                colors: [
                                    Color(hex: "#FF6B35") ?? .orange,
                                    Color(hex: "#F7931E") ?? .orange,
                                    Color(hex: "#FFD23F") ?? .yellow,
                                    Color(hex: "#06FFA5") ?? .green
                                ],
                                description: "Appetizing colors that stimulate hunger"
                            )
                        }
                    }
                }
                .padding()
            }
            .toolbar { ToolbarItem(placement: .principal) { AppNavTitle(text: "Color Trends") } }
        }
    }
}

struct TrendingColorCard: View {
    let color: Color
    let name: String
    let trend: String
    let rank: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
                    .frame(height: 80)
                    .shadow(radius: 4)
                
                VStack {
                    Text("#\(rank)")
                        .font(.system(.title, design: .monospaced, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(trend)
                        .font(.system(.caption, design: .monospaced, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(.headline, design: .monospaced, weight: .semibold))
                
                Text("Trending \(trend)")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct SeasonalTrendCard: View {
    let season: String
    let colors: [Color]
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(season)
                .font(.system(.headline, design: .monospaced, weight: .semibold))
            
            HStack(spacing: 0) {
                ForEach(colors, id: \.self) { color in
                    color
                }
            }
            .frame(height: 40)
            .cornerRadius(8)
            
            NoHyphenationLabel(
                text: description,
                font: UIFont.monospacedSystemFont(ofSize: 12, weight: .regular),
                color: UIColor.secondaryLabel
            )
            .lineLimit(3)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct IndustryTrendCard: View {
    let industry: String
    let colors: [Color]
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(industry)
                .font(.system(.headline, design: .monospaced, weight: .semibold))
            
            HStack(spacing: 0) {
                ForEach(colors, id: \.self) { color in
                    color
                }
            }
            .frame(height: 40)
            .cornerRadius(8)
            
            NoHyphenationLabel(
                text: description,
                font: UIFont.monospacedSystemFont(ofSize: 12, weight: .regular),
                color: UIColor.secondaryLabel
            )
            .lineLimit(3)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct BrandColorExtractorView: View {
    @State private var selectedImage: UIImage?
    @State private var extractedColors: [Color] = []
    @State private var optimizedColors: [Color] = []
    @State private var isProcessing = false
    @State private var showImagePicker = false
    @State private var showSaveSheet = false

    @State private var paletteStyle: PaletteStyle = .adaptive
    @State private var palettePurpose: PalettePurpose = .branding
    @State private var generatedPalette: ColorPalette?
    @State private var optimizedPalette: ColorPalette?
    @State private var analysis: PaletteAnalysis?
    @State private var optimizedAnalysis: PaletteAnalysis?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    headerSection
                    imageSelectionSection
                    paletteControlsSection
                    extractButtonSection
                    paletteResultsSection
                    tipsSection
                }
                .padding()
            }
            .toolbar { ToolbarItem(placement: .principal) { AppNavTitle(text: "Brand Extractor") } }
            .sheet(isPresented: $showImagePicker) { ImagePickerSimple(selectedImage: $selectedImage) }
            .sheet(isPresented: $showSaveSheet) {
                if colorsToPersist.isEmpty {
                    VStack(spacing: 16) {
                        AppNavTitle(text: "No Palette", size: 24, weight: .bold)
                        Text("Extract colors from a brand asset before saving.")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    SaveGeneratedPaletteView(colors: colorsToPersist)
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🏢 Brand Color Extractor")
                .font(.system(.title, design: .monospaced, weight: .bold))

            Text("Analyze logos to extract hero colors, balance harmony, and build accessible brand palettes.")
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.secondary)
        }
    }

    private var imageSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Brand Asset")
                .font(.system(.headline, design: .monospaced, weight: .semibold))

            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
                    .frame(height: 220)

                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(18)
                        .padding()
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)

                        Text("Tap to upload a logo or marketing asset")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
            }
            .onTapGesture { showImagePicker = true }

            Button {
                showImagePicker = true
            } label: {
                HStack {
                    Image(systemName: "photo.on.rectangle.angled")
                    Text("Choose Image")
                }
                .font(.system(.body, design: .monospaced, weight: .medium))
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding(14)
                .background(Color.blue.opacity(0.12))
                .cornerRadius(12)
            }
        }
    }

    private var paletteControlsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Palette Strategy")
                .font(.system(.headline, design: .monospaced, weight: .semibold))

            Picker("Palette Style", selection: $paletteStyle) {
                ForEach(PaletteStyle.allCases, id: \.self) { style in
                    Text(style.displayName).tag(style)
                }
            }
            .pickerStyle(.segmented)

            Picker("Optimize For", selection: $palettePurpose) {
                ForEach(PalettePurpose.allCases, id: \.self) { purpose in
                    Text(purpose.displayName).tag(purpose)
                }
            }
            .pickerStyle(.menu)

            Text(palettePurpose.guidance)
                .font(.system(.footnote, design: .monospaced))
                .foregroundColor(.secondary)
        }
    }

    private var extractButtonSection: some View {
        Group {
            if selectedImage != nil {
                Button(action: extractColors) {
                    HStack(spacing: 10) {
                        if isProcessing {
                            ProgressView().tint(.white)
                        } else {
                            Image(systemName: "wand.and.stars")
                        }
                        Text(isProcessing ? "Extracting..." : "Extract Brand Colors")
                    }
                    .font(.system(.body, design: .monospaced, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(Color.blue)
                    .cornerRadius(14)
                }
                .disabled(isProcessing)
                .animation(.easeInOut, value: isProcessing)
            }
        }
    }

    private var paletteResultsSection: some View {
        Group {
            if !extractedColors.isEmpty {
                VStack(alignment: .leading, spacing: 24) {
                    colorGridSection(title: "Extracted Palette", subtitle: generatedPalette?.name, colors: extractedColors)

                    if !optimizedColors.isEmpty, let optimizedPalette {
                        VStack(alignment: .leading, spacing: 12) {
                            colorGridSection(title: "Optimized for \(palettePurpose.displayName)", subtitle: optimizedPalette.name, colors: optimizedColors)

                            Button("Apply Optimized Palette", systemImage: "arrow.triangle.2.circlepath") {
                                withAnimation(.spring()) { extractedColors = optimizedColors }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.primary)
                        }
                    }

                    if let analysis {
                        analysisSection(original: analysis, optimized: optimizedAnalysis)
                    }

                    savePaletteButton
                }
            }
        }
    }

    private func colorGridSection(title: String, subtitle: String?, colors: [Color]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(.headline, design: .monospaced, weight: .semibold))

            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.system(.subheadline, design: .monospaced))
                    .foregroundColor(.secondary)
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 16) {
                ForEach(Array(colors.enumerated()), id: \.offset) { index, color in
                    BrandColorCard(color: color, index: index + 1, hexValue: UIColor(color).hexString)
                }
            }
        }
    }

    private func analysisSection(original: PaletteAnalysis, optimized: PaletteAnalysis?) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📊 Palette Intelligence")
                .font(.system(.title3, design: .monospaced, weight: .semibold))

            VStack(alignment: .leading, spacing: 10) {
                improvementRow(title: "Harmony", original: original.harmonyScore, optimized: optimized?.harmonyScore)
                improvementRow(title: "Max Contrast", original: original.maxContrastRatio, optimized: optimized?.maxContrastRatio, suffix: ":1")
                improvementRow(title: "Accessibility Issues", original: Double(original.accessibilityIssues.count), optimized: optimized.map { Double($0.accessibilityIssues.count) }, inverted: true)

                HStack {
                    Label("Avg Brightness", systemImage: "sun.max")
                    Spacer()
                    Text(percentageString(original.averageBrightness))
                        .font(.system(.footnote, design: .monospaced))
                        .foregroundColor(.secondary)
                }

                HStack {
                    Label("Avg Saturation", systemImage: "drop")
                    Spacer()
                    Text(percentageString(original.averageSaturation))
                        .font(.system(.footnote, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }

            if !original.harmonyStrengths.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Harmony Highlights")
                        .font(.system(.headline, design: .monospaced))
                    ForEach(Array(original.harmonyStrengths.enumerated()), id: \.offset) { _, strength in
                        Text("• \(strength)")
                            .font(.system(.footnote, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }
            }

            if !original.harmonySuggestions.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Improvement Ideas")
                        .font(.system(.headline, design: .monospaced))
                    ForEach(Array(original.harmonySuggestions.enumerated()), id: \.offset) { _, suggestion in
                        Text("• \(suggestion)")
                            .font(.system(.footnote, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }
            }

            if !original.accessibilityIssues.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Accessibility Alerts")
                        .font(.system(.headline, design: .monospaced))
                    ForEach(Array(original.accessibilityIssues.enumerated()), id: \.offset) { _, issue in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(issue.message)
                                .font(.system(.footnote, design: .monospaced, weight: .semibold))
                            Text(issue.suggestion)
                                .font(.system(.footnote, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(18)
    }

    private var savePaletteButton: some View {
        Button {
            showSaveSheet = true
        } label: {
            HStack {
                Image(systemName: "bookmark.fill")
                Text("Save Palette to Library")
            }
            .font(.system(.body, design: .monospaced, weight: .medium))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(14)
            .background(colorsToPersist.isEmpty ? Color.gray : Color.green)
            .cornerRadius(12)
        }
        .disabled(colorsToPersist.isEmpty)
    }

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("💡 Tips for Best Results")
                .font(.system(.headline, design: .monospaced, weight: .semibold))

            VStack(alignment: .leading, spacing: 8) {
                TipRow(text: "Use high-resolution vector logos for sharper sampling.")
                TipRow(text: "Avoid heavy gradients; flat assets yield clearer palettes.")
                TipRow(text: "Review palettes in both light and dark UI contexts.")
                TipRow(text: "Document usage rules so teams stay on-brand.")
            }
        }
    }

    private var colorsToPersist: [UIColor] {
        optimizedPalette?.colors ?? generatedPalette?.colors ?? []
    }

    private func extractColors() {
        guard let image = selectedImage, !isProcessing else { return }

        isProcessing = true
        extractedColors = []
        optimizedColors = []
        analysis = nil
        optimizedAnalysis = nil

        let style = paletteStyle
        let purpose = palettePurpose

        DispatchQueue.global(qos: .userInitiated).async {
            let palette = ColorPaletteGenerator.generatePalette(from: image, style: style, count: 6)
            let paletteAnalysis = ColorPaletteGenerator.analyzePalette(palette)
            let optimized = ColorPaletteGenerator.optimizePalette(palette, for: purpose)
            let optimizedAnalysis = ColorPaletteGenerator.analyzePalette(optimized)

            DispatchQueue.main.async {
                generatedPalette = palette
                optimizedPalette = optimized
                analysis = paletteAnalysis
                self.optimizedAnalysis = optimizedAnalysis
                extractedColors = palette.swiftUIColors
                optimizedColors = optimized.swiftUIColors
                isProcessing = false
                HapticManager.instance.notification(type: .success)
            }
        }
    }

    private func improvementRow(title: String, original: Double, optimized: Double?, suffix: String = "", inverted: Bool = false) -> some View {
        let formattedOriginal = String(format: "%.1f%@", original, suffix)
        let formattedOptimized: String = {
            guard let optimized else { return formattedOriginal }
            return String(format: "%.1f%@", optimized, suffix)
        }()

        let improved: Bool? = optimized.map { inverted ? $0 < original : $0 > original }

        return HStack {
            Text(title)
                .font(.system(.subheadline, design: .monospaced, weight: .semibold))
            Spacer()
            Text("\(formattedOriginal) → \(formattedOptimized)")
                .font(.system(.footnote, design: .monospaced))
                .foregroundColor(improved == true ? .green : .secondary)
        }
    }

    private func percentageString(_ value: Double) -> String {
        String(format: "%.0f%%", value * 100)
    }

}


struct BrandColorCard: View {
    let color: Color
    let index: Int
    let hexValue: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
                    .frame(height: 60)
                    .shadow(radius: 2)
                
                VStack {
                    Text("#\(index)")
                        .font(.system(.title2, design: .monospaced, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(hexValue)
                    .font(.system(.caption, design: .monospaced, weight: .semibold))
                
                Text("Brand Color \(index)")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct TipRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.yellow)
                .font(.system(size: 16))
            
            Text(text)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
    }
}

// MARK: - Image Picker Helper
struct ImagePickerSimple: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerSimple
        
        init(_ parent: ImagePickerSimple) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image.normalizedImage().resizedIfNecessary(maxDimension: 2048)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - AppNavTitle View
struct AppNavTitle: View {
    let text: String
    var size: CGFloat = 28
    var weight: Font.Weight = .bold
    
    var body: some View {
        Text(text)
            .font(.system(size: size, weight: weight, design: .monospaced))
            .italic()
            .fontWeight(weight)
            .minimumScaleFactor(0.7)
            .lineLimit(2)
            .multilineTextAlignment(.center)
    }
}

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("ambitAppearanceMode") private var storedAppearanceMode = AmbitAppearanceMode.studio.rawValue
    @State private var selectedTab: RootTab = .analyzer

    private var appearanceMode: AmbitAppearanceMode {
        AmbitAppearanceMode.resolved(from: storedAppearanceMode)
    }

    private var accentColor: Color {
        appearanceMode.accentColor
    }
    
    var body: some View {
        Group {
            if hasCompletedOnboarding {
                ZStack {
                    // Apply custom theme background
                    appearanceMode.backgroundColor
                        .ignoresSafeArea()
                    
                    // Soft ambient gradient for depth that respects the selected accent
                    LinearGradient(
                        colors: [
                            accentColor.opacity(appearanceMode.isDarkStyle ? 0.08 : 0.04),
                            accentColor.opacity(appearanceMode.isDarkStyle ? 0.04 : 0.015)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        // Main Content Area
                        Group {
                            switch selectedTab {
                            case .analyzer:
                                AnalyzerView(selectedTab: $selectedTab)
                            case .palettes:
                                PaletteView()
                            case .gradients:
                                GradientView()
                            case .cards:
                                CardView()
                            case .learning:
                                LearningView()
                            case .library:
                                LibraryView(selectedTab: $selectedTab)
                            case .settings:
                                SettingsView()
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(appearanceMode.backgroundColor)
                        
                        // Custom Scrollable Tab Bar
                        ScrollableTabBar(selectedTab: $selectedTab)
                    }
                }
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .background(appearanceMode.backgroundColor.ignoresSafeArea())
            }
        }
        .tint(accentColor)
        .preferredColorScheme(appearanceMode.preferredColorScheme)
        .environment(\.ambitAccentColor, accentColor)
        .environment(\.ambitTheme, appearanceMode)
        .environment(\.ambitTextPrimary, appearanceMode.textPrimaryColor)
        .environment(\.ambitTextSecondary, appearanceMode.textSecondaryColor)
        .onAppear { PreferenceSyncCoordinator.shared.startSync() }
        .animation(.easeInOut, value: hasCompletedOnboarding)
    }
}

// MARK: - Analyzer
struct AnalyzerView: View {
    @Binding var selectedTab: RootTab
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.ambitAccentColor) private var accentColor
    @AppStorage("numberOfColorsToExtract") private var numberOfColors: Int = 8
    @AppStorage("avoidDarkColors") private var avoidDark: Bool = true

    @Query(sort: \SavedPalette.timestamp, order: .reverse, animation: .easeInOut) private var savedPalettes: [SavedPalette]
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var extractedColors: [UIColor] = []
    @State private var photoAccessStatus: PHAuthorizationStatus = .notDetermined

    @State private var isDropperActive = false
    @State private var isLoading = false
    @State private var isShowingSaveToast = false

    @State private var showSaveSheet = false
    @State private var showCardCreator = false
    @State private var showSettingsSheet = false
    @State private var showPhotoPermissionAlert = false

    private var recentPaletteImports: [SavedPalette] {
        Array(savedPalettes.prefix(6))
    }

    private var overlayBottomPadding: CGFloat {
        recentPaletteImports.isEmpty ? 160 : 220
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if let selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                        .blur(radius: 30)
                        .opacity(0.3)
                        .ignoresSafeArea()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Color.clear
                        .ignoresSafeArea()
                }

                VStack(spacing: 0) {
                    if let selectedImage {
                        ImageWorkspace(image: selectedImage,
                                       colors: $extractedColors,
                                       isDropperActive: $isDropperActive)
                            .transition(.scale.animation(.spring()))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                    } else {
                        PlaceholderView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }

                    if !extractedColors.isEmpty {
                        VStack(spacing: 16) {
                            Button(action: resampleColors) {
                                HStack {
                                    Image(systemName: "shuffle")
                                    Text("Resample Colors")
                                }
                                .font(.system(.subheadline, design: .monospaced, weight: .semibold))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(12)
                            }
                            .buttonStyle(PlainButtonStyle())

                            PaletteStripView(colors: $extractedColors)
                        }
                        .padding(.vertical, 8)
                    }
                }

                overlayMessages
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                analyzerDeck
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar { toolbarContent }
            .onAppear(perform: checkPhotoAccess)
            .onChange(of: scenePhase) { _, newValue in
                if newValue == .active { checkPhotoAccess() }
            }
            .onChange(of: selectedItem) { _, _ in analyzeNewItem() }
            .alert("Enable Photo Access", isPresented: $showPhotoPermissionAlert, actions: {
                Button("Open Settings") { openAppSettings() }
                Button("Cancel", role: .cancel) { }
            }, message: {
                Text("Ambit needs access to your photo library to analyze images. You can enable access in Settings.")
            })
            .sheet(isPresented: $showSettingsSheet) { SettingsView() }
            .sheet(isPresented: $showSaveSheet) {
                SavePaletteSheetView(image: selectedImage,
                                     colors: extractedColors,
                                     showToast: $isShowingSaveToast)
            }
            .sheet(isPresented: $showCardCreator) {
                CardCreatorView(originalImage: selectedImage,
                                extractedColors: extractedColors)
            }
        }
    }

    private var analyzerDeck: some View {
        VStack(alignment: .leading, spacing: 16) {
            analyzerHero
            analyzerQuickActions
            if !recentPaletteImports.isEmpty {
                analyzerRecentRail
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 14, y: 8)
        .padding(.horizontal)
        .padding(.bottom, 12)
    }

    private var analyzerHero: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(LinearGradient(colors: [accentColor.opacity(0.24), accentColor.opacity(0.08)],
                                         startPoint: .topLeading,
                                         endPoint: .bottomTrailing))
                    .frame(width: 68, height: 68)
                Image(systemName: selectedImage == nil ? "sparkles" : "camera.metering.spot")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(accentColor)
            }

            VStack(alignment: .leading, spacing: 6) {
             Text(selectedImage == nil ? "Kick off a new analysis" : "Active analyzer ready")
                    .font(.system(.headline, design: .monospaced, weight: .semibold))
             Text(selectedImage == nil ? "Import an image to map its palette."
                 : "\(extractedColors.count) swatches sampled • toggle the dropper to refine.")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
    }

    private var analyzerQuickActions: some View {
        ViewThatFits {
            HStack(spacing: 12) { analyzerQuickActionContent }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) { analyzerQuickActionContent }
                    .padding(.horizontal, 2)
            }
        }
    }

    @ViewBuilder
    private var analyzerQuickActionContent: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            AnalyzerActionCard(icon: "photo.on.rectangle", title: "Import Photo", subtitle: "Use your camera roll", tint: .blue)
        }

        Button(action: toggleDropper) {
            AnalyzerActionCard(icon: "eyedropper.halffull",
                               title: "Color Dropper",
                               subtitle: selectedImage == nil ? "Add an image first" : (isDropperActive ? "Tap the photo to sample" : "Tap to enable sampling"),
                               tint: .teal,
                               isDisabled: selectedImage == nil)
        }
        .disabled(selectedImage == nil)

        Button {
            showSaveSheet = true
        } label: {
            AnalyzerActionCard(icon: "bookmark.fill",
                               title: "Save Palette",
                               subtitle: extractedColors.isEmpty ? "Add colors first" : "\(extractedColors.count) shades ready",
                               tint: .orange,
                               isDisabled: extractedColors.isEmpty)
        }
        .disabled(extractedColors.isEmpty)

        Button {
            showCardCreator = true
        } label: {
            AnalyzerActionCard(icon: "rectangle.portrait.on.rectangle",
                               title: "Make a Card",
                               subtitle: extractedColors.isEmpty ? "Need swatches to export" : "Send palette to showcase",
                               tint: .purple,
                               isDisabled: extractedColors.isEmpty)
        }
        .disabled(extractedColors.isEmpty)

        Button {
            selectedTab = .palettes
        } label: {
            AnalyzerActionCard(icon: "paintpalette",
                               title: "Open Palettes",
                               subtitle: "Remix imported hues",
                               tint: .pink)
        }
    }

    private var analyzerRecentRail: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Imports")
                    .font(.system(.subheadline, design: .monospaced, weight: .semibold))
                Spacer()
                Text("Latest \(recentPaletteImports.count) imports")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(recentPaletteImports) { palette in
                        NavigationLink { PaletteDetailView(palette: palette) } label: {
                            AnalyzerRecentImportCard(palette: palette)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.75))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.primary.opacity(0.04), lineWidth: 1)
        )
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Text("Ambit.")
                .font(.system(size: 44, weight: .black, design: .monospaced)).italic()
                .padding(.leading, -8)
                .shadow(radius: 1)
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
            if photoAccessStatus == .denied || photoAccessStatus == .restricted {
                Button { showPhotoPermissionAlert = true } label: {
                    Image(systemName: "photo.on.rectangle.angled")
                        .foregroundStyle(.primary)
                }
            } else {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .foregroundStyle(.primary)
                }
            }

            if selectedImage != nil {
                Menu {
                    Button { showSaveSheet = true } label: {
                        Label("Save", systemImage: "square.and.arrow.down")
                    }
                    Button { isDropperActive.toggle() } label: {
                        Label(isDropperActive ? "Disable Eyedropper" : "Enable Eyedropper",
                              systemImage: "eyedropper.full")
                    }
                    Button { showCardCreator = true } label: {
                        Label("Create Card", systemImage: "square.and.pencil")
                    }
                    Divider()
                    Button { showSettingsSheet = true } label: {
                        Label("Settings", systemImage: "gear")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(.primary)
                }
            }
        }
    }

    @ViewBuilder
    private var overlayMessages: some View {
        if isDropperActive {
            VStack {
                Spacer()
                Text("Tap the image to add a color to the palette.")
                    .font(.system(.body, design: .monospaced))
                    .padding(12)
                    .background(.thinMaterial)
                    .cornerRadius(12)
                    .padding(.bottom, overlayBottomPadding)
            }
        }

        if isShowingSaveToast {
            VStack {
                Spacer()
                Text("Saved to Library!")
                    .font(.system(.body, design: .monospaced).weight(.bold))
                    .padding(12)
                    .background(Color.green)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
                    .padding(.bottom, overlayBottomPadding + 48)
            }
        }

        if isLoading { LoadingView() }
    }

    private func toggleDropper() {
        guard selectedImage != nil else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isDropperActive.toggle()
        }
        HapticManager.instance.impact(style: .soft)
    }

    private func resampleColors() {
        guard let selectedImage else { return }
        Task {
            withAnimation { isLoading = true }
            let colors = await ColorExtractor.extractRandomColors(from: selectedImage,
                                                                  count: numberOfColors,
                                                                  avoidDark: avoidDark)
            await MainActor.run {
                withAnimation(.spring()) {
                    extractedColors = colors
                }
                withAnimation { isLoading = false }
            }
        }
    }

    private func checkPhotoAccess() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        photoAccessStatus = status
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                DispatchQueue.main.async {
                    photoAccessStatus = status
                    if status == .denied { showPhotoPermissionAlert = true }
                }
            }
        }
    }

    private func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsURL)
    }

    private func analyzeNewItem() {
        guard let selectedItem else { return }
        Task {
            withAnimation { isLoading = true }
            HapticManager.instance.impact(style: .light)
            if let data = try? await selectedItem.loadTransferable(type: Data.self),
               let uiImage = ImageProcessor.loadImage(from: data) {
                let colors = await ColorExtractor.extractRandomColors(from: uiImage,
                                                                      count: numberOfColors,
                                                                      avoidDark: avoidDark)
                await MainActor.run {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        selectedImage = uiImage
                        extractedColors = colors
                    }
                    HapticManager.instance.notification(type: .success)
                }
            }
            withAnimation { isLoading = false }
        }
    }
}

// MARK: - Save Palette Sheet
struct SavePaletteSheetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var paletteName: String = ""
    let image: UIImage?
    let colors: [UIColor]
    @Binding var showToast: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                AppNavTitle(text: "Save Palette", size: 24, weight: .bold)
                HStack(spacing: 0) {
                    ForEach(colors.indices, id: \.self) { i in
                        Color(uiColor: colors[i])
                    }
                }
                .frame(height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 5)

                TextField("Palette Name", text: $paletteName)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
                    .padding(.horizontal)

                Button("Save to Library", systemImage: "bookmark.fill") {
                    let name = paletteName.isEmpty ? "Palette from Image" : paletteName
                    let newPalette = SavedPalette(name: name, image: image, colors: colors)
                    modelContext.insert(newPalette)
                    HapticManager.instance.notification(type: .success)
                    withAnimation { showToast = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation { showToast = false }
                    }
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.primary)
                .font(.system(.body, design: .monospaced, weight: .bold))

                Spacer()
            }
            .padding(.top, 20)
            .toolbar {
                ToolbarItem(placement: .principal) { AppNavTitle(text: "Save", size: 22, weight: .bold) }
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
        }
    }
}

// MARK: - Analyzer Helpers
struct ImageWorkspace: View {
    let image: UIImage
    @Binding var colors: [UIColor]
    @Binding var isDropperActive: Bool
    
    var body: some View {
        GeometryReader { geometry in
            let metrics = displayMetrics(for: geometry)
            ZStack(alignment: .center) {
                Color.clear
                    .background(
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .blur(radius: 30)
                            .opacity(0.3)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .ignoresSafeArea()
                    )
                
                VStack(spacing: 0) {
                    Spacer(minLength: 20)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color(.systemBackground).opacity(0.92))
                            .shadow(radius: 10, y: 5)
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(image.size, contentMode: .fit)
                            .frame(width: metrics.displaySize.width, height: metrics.displaySize.height)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                    .frame(width: metrics.containerSize.width, height: metrics.containerSize.height)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { value in
                                guard isDropperActive else { return }
                                handleDropperGesture(location: value.location, metrics: metrics)
                            }
                    )
                    
                    Spacer(minLength: 20)
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 1)
    }
    
    private func handleDropperGesture(location: CGPoint, metrics: ImageDisplayMetrics) {
        let imageSize = image.size
        let safeX = location.x - metrics.letterboxOffset.x
        let safeY = location.y - metrics.letterboxOffset.y
        guard safeX >= 0, safeY >= 0,
              safeX <= metrics.displaySize.width,
              safeY <= metrics.displaySize.height else { return }
    let normalizedX = safeX / metrics.displaySize.width
    let normalizedY = safeY / metrics.displaySize.height
    let pixelPoint = image.pixelPoint(forNormalizedPoint: CGPoint(x: normalizedX, y: normalizedY))
    let x = pixelPoint.x
    let y = pixelPoint.y
        
        guard x >= 0, y >= 0, x < imageSize.width, y < imageSize.height else { return }
        
        HapticManager.instance.impact(style: .light)
        if let color = image.color(at: CGPoint(x: x, y: y)) {
            withAnimation(.spring()) {
                colors.insert(color, at: 0)
                if colors.count > 12 { colors.removeLast() }
            }
        }
    }

    private func displayMetrics(for geometry: GeometryProxy) -> ImageDisplayMetrics {
        let containerSize = CGSize(
            width: min(geometry.size.width - 40, 500),
            height: min(geometry.size.height * 0.7, 500)
        )
        let imageAspect = image.size.width / image.size.height
        let containerAspect = containerSize.width / containerSize.height
        if imageAspect > containerAspect {
            let displayHeight = containerSize.width / imageAspect
            let verticalOffset = (containerSize.height - displayHeight) / 2
            return ImageDisplayMetrics(
                containerSize: containerSize,
                displaySize: CGSize(width: containerSize.width, height: displayHeight),
                letterboxOffset: CGPoint(x: 0, y: max(verticalOffset, 0))
            )
        } else {
            let displayWidth = containerSize.height * imageAspect
            let horizontalOffset = (containerSize.width - displayWidth) / 2
            return ImageDisplayMetrics(
                containerSize: containerSize,
                displaySize: CGSize(width: displayWidth, height: containerSize.height),
                letterboxOffset: CGPoint(x: max(horizontalOffset, 0), y: 0)
            )
        }
    }
}

private struct ImageDisplayMetrics {
    let containerSize: CGSize
    let displaySize: CGSize
    let letterboxOffset: CGPoint
}

struct PaletteStripView: View {
    @Binding var colors: [UIColor]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(colors.indices, id: \.self) { i in
                    ColorCardView(color: colors[i]).frame(minWidth: 100)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
        .transition(.slide.combined(with: .opacity))
    }
}

struct AnalyzerActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let tint: Color
    var isDisabled: Bool = false
    @Environment(\.ambitAccentColor) private var accentColor

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(accentColor.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(tint)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.headline, design: .monospaced, weight: .semibold))
                Text(subtitle)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: 220)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(uiColor: .systemBackground).opacity(0.95))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(accentColor.opacity(0.18), lineWidth: 1)
        )
        .opacity(isDisabled ? 0.4 : 1)
    }
}

struct AnalyzerRecentImportCard: View {
    let palette: SavedPalette

    private var formattedTimestamp: String {
        palette.timestamp.formatted(date: .abbreviated, time: .shortened)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 0) {
                ForEach(palette.uiColors.indices, id: \.self) { index in
                    Color(uiColor: palette.uiColors[index])
                        .frame(width: 32, height: 48)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(palette.name)
                    .font(.system(.subheadline, design: .monospaced, weight: .semibold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.leading)
                Text(formattedTimestamp)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 8) {
                Label("\(palette.uiColors.count) colors", systemImage: "swatchpalette")
                Spacer()
                Image(systemName: palette.isFavorite ? "star.fill" : "star")
                    .foregroundColor(palette.isFavorite ? .yellow : .secondary.opacity(0.7))
            }
            .font(.system(.caption2, design: .monospaced))
        }
        .padding(14)
        .frame(width: 180, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(uiColor: .systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.primary.opacity(0.04), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 6, y: 4)
    }
}

struct ColorCardView: View {
    let color: UIColor
    @State private var showDetail = false

    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(uiColor: color))
                .frame(width: 80, height: 80)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.1), lineWidth: 1))
                .onTapGesture { showDetail = true; HapticManager.instance.impact(style: .light) }

            VStack(spacing: 4) {
                Text(color.toHex() ?? "#000000").font(.system(.caption, design: .monospaced).weight(.bold)).lineLimit(2).minimumScaleFactor(0.8).multilineTextAlignment(.center)
                Text(color.toRGBString()).font(.system(.caption, design: .monospaced)).foregroundStyle(.secondary).lineLimit(2).minimumScaleFactor(0.8).multilineTextAlignment(.center)
            }
        }
        .padding(8)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 2)
        .sheet(isPresented: $showDetail) { ColorDetailSheetView(color: color) }
    }
}

struct ColorDetailSheetView: View {
    @Environment(\.dismiss) private var dismiss
    let color: UIColor
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                AppNavTitle(text: "Color Details", size: 24, weight: .bold)
                RoundedRectangle(cornerRadius: 12).fill(Color(uiColor: color)).frame(height: 150).shadow(radius: 5)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Hex: \(color.toHex() ?? "N/A")").font(.system(.headline, design: .monospaced))
                    Text("RGB: \(color.toRGBString())").font(.system(.headline, design: .monospaced))
                    Text("HSL: \(color.toHSLString())").font(.system(.headline, design: .monospaced))
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .principal) { AppNavTitle(text: "Details", size: 22, weight: .bold) }
                ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } }
            }
        }
    }
}

// MARK: - Learning Hub

struct LearningView: View {
    @Environment(\.ambitAccentColor) private var accentColor
    private let modules = LearningGuide.defaultModules
    @State private var searchText = ""
    @AppStorage("learningFavoriteModuleIDs") private var favoriteModuleIDsData: Data = Data()
    @AppStorage("learningLastModuleID") private var lastModuleID: String = ""

    private var favoriteIDs: [String] {
        guard let decoded = try? JSONDecoder().decode([String].self, from: favoriteModuleIDsData) else { return [] }
        return decoded
    }

    private var favoriteSet: Set<String> { Set(favoriteIDs) }

    private var favoriteModules: [LearningGuide] {
        modules.filter { favoriteSet.contains($0.id.uuidString) }
    }

    private var lastModule: LearningGuide? {
        modules.first { $0.id.uuidString == lastModuleID }
    }

    private var filteredModules: [LearningGuide] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return modules }
        return modules.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.subtitle.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    learningHero
                    learningQuickActions
                    if !favoriteModules.isEmpty {
                        learningFavoritesStrip
                    }
                    featuredCollection
                    learningModuleGrid
                }
                .padding(.horizontal)
                .padding(.top, 32)
            }
            .toolbar { ToolbarItem(placement: .principal) { AppNavTitle(text: "Learning", size: 26, weight: .bold) } }
            .searchable(text: $searchText, prompt: "Search guides or skills")
        }
    }

    private var learningModuleGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 240), spacing: 18)], spacing: 18) {
            ForEach(filteredModules) { module in
                NavigationLink(destination: module.destination) {
                    LearningGuideCard(module: module,
                                      isFavorite: favoriteSet.contains(module.id.uuidString),
                                      favoriteAction: { toggleFavorite(module) })
                }
                .buttonStyle(.plain)
                .simultaneousGesture(TapGesture().onEnded { recordAccess(for: module) })
            }
        }
    }

    private var learningHero: some View {
        VStack(spacing: 16) {
            HStack(alignment: .center, spacing: 18) {
                ZStack {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(LinearGradient(colors: [accentColor.opacity(0.22), accentColor.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 96, height: 96)

                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 40))
                        .foregroundColor(accentColor)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Color Academy")
                        .font(.system(.title2, design: .monospaced, weight: .bold))
                    Text("Deep-dive modules packed with psychology, storytelling, and production craft.")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HStack(spacing: 12) {
                LearningPill(text: "Guided Lessons", icon: "list.bullet.rectangle.portrait")
                LearningPill(text: "Interactive Labs", icon: "hands.sparkles")
                LearningPill(text: "Expert Playbooks", icon: "lightbulb")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(LinearGradient(colors: [accentColor.opacity(0.16), accentColor.opacity(0.04)], startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(accentColor.opacity(0.18), lineWidth: 1)
        )
    }

    private var learningQuickActions: some View {
        ViewThatFits {
            HStack(spacing: 12) { quickActionContent }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) { quickActionContent }
                    .padding(.horizontal, 2)
            }
        }
    }

    @ViewBuilder
    private var quickActionContent: some View {
        LearningQuickActionButton(icon: "play.circle.fill",
                                  title: "Resume Last",
                                  subtitle: lastModule?.title ?? "No recent lessons",
                                  tint: .mint,
                                  isDisabled: lastModule == nil) {
            guard let module = lastModule else { return }
            recordAccess(for: module)
        }

        LearningQuickActionButton(icon: "die.face.5.fill",
                                  title: "Random Lab",
                                  subtitle: "Mix up your practice",
                                  tint: .purple) {
            if let module = modules.randomElement() {
                recordAccess(for: module)
                lastModuleID = module.id.uuidString
            }
        }

        LearningQuickActionButton(icon: "star", title: "Show Favorites", subtitle: "\(favoriteModules.count) pinned", tint: .orange, isDisabled: favoriteModules.isEmpty) {
            // no-op, visual indicator only
        }
    }

    private var learningFavoritesStrip: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Pinned Labs")
                .font(.system(.title3, design: .monospaced, weight: .bold))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(favoriteModules) { module in
                        FavoriteLearningBadge(module: module,
                                              isCompleted: false,
                                              favoriteAction: { toggleFavorite(module) })
                            .frame(width: 220)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }

    private var featuredCollection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Featured Tracks")
                .font(.system(.title3, design: .monospaced, weight: .bold))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    LearningShowcaseCard(title: "Brand Systems", description: "Craft palettes with cultural context and accessibility baked in.", colors: [.purple, .pink], badge: "6 Modules")
                    LearningShowcaseCard(title: "Production Readiness", description: "Bridge digital to print and manage color spaces with precision.", colors: [.blue, .mint], badge: "4 Modules")
                    LearningShowcaseCard(title: "Behavioral Color", description: "Leverage psychology, trends, and storytelling frameworks.", colors: [.orange, .yellow], badge: "5 Modules")
                }
                .padding(.horizontal, 4)
            }
        }
    }

    private func toggleFavorite(_ module: LearningGuide) {
        var ids = favoriteIDs
        let moduleID = module.id.uuidString
        if let idx = ids.firstIndex(of: moduleID) {
            ids.remove(at: idx)
        } else {
            ids.insert(moduleID, at: 0)
        }
        if let data = try? JSONEncoder().encode(ids) {
            favoriteModuleIDsData = data
        }
    }

    private func recordAccess(for module: LearningGuide) {
        lastModuleID = module.id.uuidString
    }
}

fileprivate struct LearningGuideCard: View {
    let module: LearningGuide
    var isFavorite: Bool
    var favoriteAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(module.accent.opacity(0.15))
                        .frame(width: 52, height: 52)
                    Image(systemName: module.icon)
                        .font(.system(size: 24))
                        .foregroundColor(module.accent)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(module.title)
                        .font(.system(.headline, design: .monospaced, weight: .semibold))
                        .foregroundColor(.primary)
                    Text(module.subtitle)
                        .font(.system(.callout, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }

                Spacer()
                Button(action: favoriteAction) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .foregroundColor(isFavorite ? .yellow : .secondary)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 16) {
                Label(module.experienceTier, systemImage: "sparkles")
                    .font(.system(.caption, design: .monospaced, weight: .semibold))
                    .foregroundColor(module.accent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(module.accent.opacity(0.12))
                    .cornerRadius(14)

                Spacer()
                Label("\(module.estimatedMinutes) min", systemImage: "clock")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(.secondary)
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

fileprivate struct LearningShowcaseCard: View {
    let title: String
    let description: String
    let colors: [Color]
    let badge: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(badge)
                    .font(.system(.caption, design: .monospaced, weight: .semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(12)
                Spacer()
            }

            Text(title)
                .font(.system(.title3, design: .monospaced, weight: .bold))
                .foregroundColor(.white)

            NoHyphenationLabel(
                text: description,
                font: UIFont.monospacedSystemFont(ofSize: 14, weight: .regular),
                color: UIColor.white.withAlphaComponent(0.85)
            )
            .lineLimit(3)

            Spacer(minLength: 12)

            HStack(spacing: 8) {
                ForEach(0..<4) { index in
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 24, height: 6)
                        .opacity(Double(index + 1) * 0.2)
                }
                Spacer()
            }
        }
        .padding(22)
        .frame(width: 260, height: 180)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(LinearGradient(colors: colors.map { $0.opacity(0.85) }, startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: colors.first?.opacity(0.4) ?? .black.opacity(0.3), radius: 16, x: 0, y: 8)
    }
}

fileprivate struct FavoriteLearningBadge: View {
    let module: LearningGuide
    let isCompleted: Bool
    let favoriteAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(module.title)
                    .font(.system(.headline, design: .monospaced, weight: .semibold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.leading)
                Spacer()
                Button(action: favoriteAction) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                }
                .buttonStyle(.plain)
            }

            Text(module.subtitle)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack(spacing: 8) {
                Label(module.experienceTier, systemImage: "sparkles")
                Label("\(module.estimatedMinutes) min", systemImage: "clock")
            }
            .font(.system(.caption2, design: .monospaced, weight: .semibold))
            .foregroundStyle(.secondary)

            if isCompleted {
                Label("Completed", systemImage: "checkmark.circle.fill")
                    .font(.system(.caption, design: .monospaced, weight: .semibold))
                    .foregroundColor(module.accent)
            }
        }
        .padding(16)
        .frame(width: 220, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
    }
}

fileprivate struct LearningQuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let tint: Color
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(tint.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(tint)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(.headline, design: .monospaced, weight: .semibold))
                        .foregroundColor(.primary.opacity(isDisabled ? 0.4 : 1))
                    Text(subtitle)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Spacer()
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemBackground).opacity(isDisabled ? 0.6 : 0.95))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.primary.opacity(0.05), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.45 : 1)
    }
}

fileprivate struct LearningPill: View {
    let text: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
            Text(text)
                .font(.system(.caption, design: .monospaced, weight: .semibold))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color(uiColor: .systemBackground).opacity(0.92)))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.primary.opacity(0.05), lineWidth: 1))
    }
}

fileprivate struct LearningGuide: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let accent: Color
    let experienceTier: String
    let estimatedMinutes: Int
    let destination: AnyView

    init<T: View>(title: String, subtitle: String, icon: String, accent: Color, experienceTier: String, estimatedMinutes: Int = 15, destination: T) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.accent = accent
        self.experienceTier = experienceTier
        self.estimatedMinutes = estimatedMinutes
        self.destination = AnyView(destination)
    }

    static let defaultModules: [LearningGuide] = [
        LearningGuide(title: "Color Theory Guide", subtitle: "Master harmony, hierarchy, and palette structure through immersive lessons.", icon: "circle.hexagongrid", accent: .purple, experienceTier: "Designer", estimatedMinutes: 18, destination: ColorTheoryGuideView()),
        LearningGuide(title: "Color Psychology", subtitle: "Comprehensive research-based guide to color's psychological and physiological effects with authentic citations.", icon: "brain.head.profile", accent: .pink, experienceTier: "Strategist", estimatedMinutes: 35, destination: ColorPsychologyGuideView()),
        LearningGuide(title: "Color Spaces", subtitle: "Navigate sRGB, Display P3, and print workflows with confidence.", icon: "rectangle.3.group", accent: .mint, experienceTier: "Production", estimatedMinutes: 22, destination: ColorSpacesGuideView()),
        LearningGuide(title: "Color Blindness", subtitle: "Design accessible experiences with simulations and best practices.", icon: "eye.fill", accent: .teal, experienceTier: "Accessibility", estimatedMinutes: 14, destination: ColorBlindnessGuideView()),
        LearningGuide(title: "Color Glossary", subtitle: "Reference the essential terminology powering professional color work.", icon: "book", accent: .blue, experienceTier: "Reference", estimatedMinutes: 10, destination: ColorGlossaryView()),
        LearningGuide(title: "Typography Guide", subtitle: "Align hues with type systems to create expressive visual language.", icon: "textformat", accent: .orange, experienceTier: "Brand", estimatedMinutes: 17, destination: TypographyGuideView()),
        LearningGuide(title: "Digital ↔ Print", subtitle: "Translate pixels to paper with calibrated, reliable conversions.", icon: "printer.fill", accent: .indigo, experienceTier: "Ops", estimatedMinutes: 20, destination: DigitalPrintGuideView()),
        LearningGuide(title: "Brand Color Library", subtitle: "Study iconic palettes and save favorites to your workspace.", icon: "building.2.fill", accent: .red, experienceTier: "Inspiration", estimatedMinutes: 12, destination: BrandColorsGuideView()),
        LearningGuide(title: "Named Colors", subtitle: "Explore extended color sets with searchable metadata and swatches.", icon: "list.bullet", accent: .yellow, experienceTier: "Explorer", estimatedMinutes: 9, destination: NamedColorsView())
    ]
}

struct RandomColorView: View {
    @State private var color: Color = .blue
    var body: some View {
        VStack(spacing: 30) {
            Text("Tap to Generate").font(.system(.body, design: .monospaced))
            RoundedRectangle(cornerRadius: 25).fill(color).frame(width: 200, height: 200).shadow(radius: 10)
                .onTapGesture {
                    withAnimation {
                        color = Color(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1))
                        HapticManager.instance.impact(style: .light)
                    }
                }
            Text(UIColor(color).toHex() ?? "#000000").font(.system(.title2, design: .monospaced).bold())
            Text(UIColor(color).toRGBString()).font(.system(.title3, design: .monospaced)).foregroundStyle(.secondary)
            Spacer()
        }
        .padding()
        .toolbar { ToolbarItem(placement: .principal) { AppNavTitle(text: "Random Color", size: 24, weight: .bold) } }
    }
}

struct InteractiveColorMixerView: View {
    @State private var color1: Color = .red
    @State private var color2: Color = .blue
    @State private var mixed: Color = .purple

    private func update() {
        let c1 = UIColor(color1); let c2 = UIColor(color2)
        var r1: CGFloat=0,g1:CGFloat=0,b1:CGFloat=0,a1:CGFloat=0
        var r2: CGFloat=0,g2:CGFloat=0,b2:CGFloat=0,a2:CGFloat=0
        c1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        c2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        mixed = Color(UIColor(red: (r1+r2)/2, green: (g1+g2)/2, blue: (b1+b2)/2, alpha: 1))
    }

    var body: some View {
        VStack(spacing: 30) {
            HStack {
                VStack { ColorPicker("Color 1", selection: $color1).labelsHidden(); Text("Color 1").font(.system(.caption, design: .monospaced)) }
                Text("+").font(.largeTitle).bold()
                VStack { ColorPicker("Color 2", selection: $color2).labelsHidden(); Text("Color 2").font(.system(.caption, design: .monospaced)) }
            }
            .onChange(of: color1) { _, _ in update() }
            .onChange(of: color2) { _, _ in update() }
            Text("Result").font(.system(.headline, design: .monospaced))
            RoundedRectangle(cornerRadius: 25).fill(mixed).frame(width: 200, height: 200).shadow(radius: 10)
                .overlay(
                    VStack {
                        Text(UIColor(mixed).toHex() ?? "#000000").font(.system(.title2, design: .monospaced).bold())
                        Text(UIColor(mixed).toRGBString()).font(.system(.title3, design: .monospaced)).foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .opacity(0.85)
                )
            Spacer()
        }
        .padding()
        .onAppear(perform: update)
        .toolbar { ToolbarItem(placement: .principal) { AppNavTitle(text: "Color Mixer", size: 24, weight: .bold) } }
    }
}

struct InteractiveContrastCheckerView: View {
    @State private var fg: Color = .black
    @State private var bg: Color = .white
    @State private var ratio: Double = 21
    @State private var passes: Bool = true

    private func check() {
        guard let f = UIColor(fg).toHex(), let b = UIColor(bg).toHex() else { return }
        func comp(_ hex: String, _ i: Int) -> Int {
            let s = hex.index(hex.startIndex, offsetBy: i)
            let e = hex.index(s, offsetBy: 2)
            return Int(String(hex[s..<e]), radix: 16) ?? 0
        }
        let r1 = Double(comp(f, 1))/255, g1 = Double(comp(f, 3))/255, b1 = Double(comp(f, 5))/255
        let r2 = Double(comp(b, 1))/255, g2 = Double(comp(b, 3))/255, b2 = Double(comp(b, 5))/255
        func L(_ r: Double,_ g: Double,_ b: Double) -> Double {
            func transform(_ v: Double) -> Double { v <= 0.03928 ? v/12.92 : pow((v + 0.055) / 1.055, 2.4) }
            let r = transform(r), g = transform(g), b = transform(b)
            return 0.2126 * r + 0.7152 * g + 0.0722 * b
        }
        let L1 = L(r1,g1,b1), L2 = L(r2,g2,b2)
        ratio = (max(L1,L2)+0.05)/(min(L1,L2)+0.05)
        passes = ratio >= 4.5
    }

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                bg.ignoresSafeArea()
                Text("This is sample text.")
                    .font(.system(.title, design: .monospaced).bold())
                    .foregroundColor(fg)
            }
            .frame(height: 150)
            .cornerRadius(12)
            .shadow(radius: 5)
            .padding()

            ColorPicker("Foreground Color", selection: $fg)
            ColorPicker("Background Color", selection: $bg)

            Text(String(format: "Ratio: %.2f", ratio))
                .font(.system(.title2, design: .monospaced).bold())
                .foregroundColor(passes ? .green : .red)
            Text(passes ? "Passes WCAG AA" : "Fails WCAG AA")
                .font(.system(.body, design: .monospaced))
                .foregroundColor(passes ? .green : .red)
            Spacer()
        }
        .padding()
        .onChange(of: fg) { _, _ in check() }
        .onChange(of: bg) { _, _ in check() }
        .onAppear(perform: check)
        .toolbar { ToolbarItem(placement: .principal) { AppNavTitle(text: "Contrast Checker", size: 24, weight: .bold) } }
    }
}

enum VisionColorBlindnessFilter { case deuteranopia, protanopia, tritanopia, none }

struct ColorblindSimulatorView: View {
    @State private var colors: [Color] = [.red, .green, .blue]
    @State private var filter: VisionColorBlindnessFilter = .deuteranopia

    private func filtered(_ c: Color) -> Color {
        let ui = UIColor(c); var h: CGFloat=0,s:CGFloat=0,b:CGFloat=0,a:CGFloat=0
        ui.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        switch filter {
        case .deuteranopia: return Color(hue: h, saturation: s*0.7, brightness: b)
        case .protanopia:   return Color(hue: h, saturation: s*0.5, brightness: b)
        case .tritanopia:   return Color(hue: h, saturation: s,     brightness: b)
        case .none: return c
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 0) { ForEach(colors, id: \.self) { Rectangle().fill($0) } }.frame(height: 80).cornerRadius(12)
            Text("Normal Vision").font(.system(.body, design: .monospaced)).bold()
            HStack(spacing: 0) { ForEach(colors, id: \.self) { Rectangle().fill(filtered($0)) } }.frame(height: 80).cornerRadius(12)
            Picker("Simulation", selection: $filter) {
                Text("Deuteranopia").tag(VisionColorBlindnessFilter.deuteranopia)
                Text("Protanopia").tag(VisionColorBlindnessFilter.protanopia)
                Text("Tritanopia").tag(VisionColorBlindnessFilter.tritanopia)
                Text("None").tag(VisionColorBlindnessFilter.none)
            }
            .pickerStyle(.segmented)
            Button("Add Color", systemImage: "plus.circle.fill") {
                colors.append(Color(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1)))
            }
            Spacer()
        }
        .padding()
        .toolbar { ToolbarItem(placement: .principal) { AppNavTitle(text: "Colorblind Simulator", size: 24, weight: .bold) } }
    }
}

struct GradientCreatorView: View {
    @State private var a: Color = .red
    @State private var b: Color = .blue
    var body: some View {
        VStack(spacing: 20) {
            LinearGradient(colors: [a,b], startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(height: 200).cornerRadius(12).shadow(radius: 5)
            ColorPicker("Start Color", selection: $a)
            ColorPicker("End Color", selection: $b)
            Spacer()
        }
        .padding()
        .toolbar { ToolbarItem(placement: .principal) { AppNavTitle(text: "Gradient Creator", size: 24, weight: .bold) } }
    }
}

// MARK: - Legacy Tools

struct AIPaletteGeneratorView: View {
    @State private var baseColor = Color.accentColor
    @State private var generated: [Color] = []
    @State private var harmonyType: String = ""
    @State private var showSave = false

    var body: some View {
        VStack(spacing: 20) {
            ColorPicker("Select a Base Color", selection: $baseColor, supportsOpacity: false)
            Button("Generate Palette", systemImage: "sparkles") {
                let result = ColorTheory.generateHarmonizedPalette(from: UIColor(baseColor))
                generated = result.palette.map { Color($0) }
                harmonyType = result.harmony
            }
            .buttonStyle(.borderedProminent)
            .tint(.primary)

            if !generated.isEmpty {
                VStack(spacing: 15) {
                    Text("Generated a \(harmonyType) palette.")
                    HStack(spacing: 0) { ForEach(generated.indices, id: \.self) { generated[$0] } }
                        .frame(height: 100).clipShape(RoundedRectangle(cornerRadius: 12)).shadow(radius: 5)
                    Button("Save Palette", systemImage: "bookmark") { showSave = true }
                        .buttonStyle(.bordered)
                }
            }
            Spacer()
        }
        .padding()
        .toolbar { ToolbarItem(placement: .principal) { AppNavTitle(text: "AI Palette Generator", size: 24, weight: .bold) } }
        .sheet(isPresented: $showSave) {
            SaveGeneratedPaletteView(colors: generated.map { UIColor($0) })
        }
    }
}

struct SaveGeneratedPaletteView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let colors: [UIColor]
    @State private var name: String = ""
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                AppNavTitle(text: "Save AI Palette", size: 24, weight: .bold)
                HStack(spacing: 0) { ForEach(colors.indices, id: \.self) { Color(uiColor: colors[$0]) } }
                    .frame(height: 80).clipShape(RoundedRectangle(cornerRadius: 12))
                TextField("Palette Name", text: $name).textFieldStyle(.roundedBorder)
                Button("Save to Library", systemImage: "bookmark.fill") {
                    let n = name.isEmpty ? "AI Generated Palette" : name
                    let p = SavedPalette(name: n, colors: colors)
                    modelContext.insert(p)
                    HapticManager.instance.notification(type: .success)
                    dismiss()
                }
                .buttonStyle(.borderedProminent).tint(.primary)
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .principal) { AppNavTitle(text: "Save", size: 22, weight: .bold) }
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
        }
    }
}

struct WebsiteExtractorView: View {
    @State private var urlString: String = ""
    @State private var colors: [UIColor] = []
    @State private var icon: UIImage?
    @State private var loading = false

    var body: some View {
        VStack(spacing: 20) {
            TextField("https://example.com", text: $urlString)
                .keyboardType(.URL)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)

            Button("Extract Colors", systemImage: "arrow.down.circle") { extract() }
                .buttonStyle(.borderedProminent)
                .tint(.primary)
                .disabled(urlString.isEmpty)

            if loading {
                ProgressView()
            } else if !colors.isEmpty {
                VStack {
                    if let icon {
                        Image(uiImage: icon).resizable().scaledToFit().frame(width: 80, height: 80).cornerRadius(12).shadow(radius: 2)
                    }
                    HStack(spacing: 0) { ForEach(colors.indices, id: \.self) { Color(uiColor: colors[$0]) } }
                        .frame(height: 100).clipShape(RoundedRectangle(cornerRadius: 12)).shadow(radius: 5)
                }
            }
            Spacer()
        }
        .padding()
        .toolbar { ToolbarItem(placement: .principal) { AppNavTitle(text: "Web Extractor", size: 24, weight: .bold) } }
    }

    private func extract() {
        guard let url = URL(string: urlString) else { return }
        loading = true; colors = []; icon = nil
        let provider = LPMetadataProvider()
        provider.startFetchingMetadata(for: url) { metadata, error in
            guard let metadata, let prov = metadata.imageProvider else {
                DispatchQueue.main.async { loading = false }
                return
            }
            prov.loadObject(ofClass: UIImage.self) { image, _ in
                guard let ui = image as? UIImage else {
                    DispatchQueue.main.async { loading = false }
                    return
                }
                Task {
                    let cols = ColorExtractor.extractProminentColors(from: ui, in: nil, count: 8, avoidDark: true)
                    await MainActor.run {
                        self.icon = ui
                        self.colors = cols
                        self.loading = false
                    }
                }
            }
        }
    }
}

// MARK: - Library

struct LibraryView: View {
    @Environment(\.ambitAccentColor) private var accentColor
    @Query(sort: \SavedPalette.timestamp, order: .reverse) private var savedPalettes: [SavedPalette]
    @Query(sort: \SavedCard.timestamp, order: .reverse) private var savedCards: [SavedCard]
    @Query(sort: \SavedGradient.timestamp, order: .reverse) private var savedGradients: [SavedGradient]
    @Binding var selectedTab: RootTab
    @State private var showCardCreator = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    libraryHero
                    statsSection
                    quickActions
                    if hasFavorites {
                        favoritesSpotlight
                    }

                    if savedPalettes.isEmpty && savedCards.isEmpty && savedGradients.isEmpty {
                        LibraryEmptyState(createAction: { showCardCreator = true },
                                          analyzeAction: { selectedTab = .analyzer })
                    } else {
                        if !savedColorSwatches.isEmpty {
                            savedColorsSection
                        }
                        if !savedPalettes.isEmpty {
                            paletteSection
                        }
                        if !savedGradients.isEmpty {
                            gradientSection
                        }
                        if !savedCards.isEmpty {
                            cardSection
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 32)
            }
            .toolbar { ToolbarItem(placement: .principal) { AppNavTitle(text: "Library", size: 26) } }
            .sheet(isPresented: $showCardCreator) { CardCreatorView(originalImage: nil, extractedColors: []) }
        }
    }

    private var recentPalettes: [SavedPalette] {
        Array(savedPalettes.prefix(6))
    }

    private var recentCards: [SavedCard] {
        Array(savedCards.prefix(6))
    }

    private var recentGradients: [SavedGradient] {
        Array(savedGradients.prefix(6))
    }

    private var favoritePalettes: [SavedPalette] {
        savedPalettes.filter(\.isFavorite)
    }

    private var favoriteCards: [SavedCard] {
        savedCards.filter(\.isFavorite)
    }

    private var favoriteGradients: [SavedGradient] {
        savedGradients.filter(\.isFavorite)
    }

    private var hasFavorites: Bool {
        !(favoritePalettes.isEmpty && favoriteCards.isEmpty && favoriteGradients.isEmpty)
    }

    private var savedColorSwatches: [LibraryColorSwatch] {
        var map: [String: (color: UIColor, count: Int)] = [:]
        for palette in savedPalettes {
            for color in palette.uiColors {
                let hex = color.hexString.uppercased()
                let entry = map[hex]
                map[hex] = (color, (entry?.count ?? 0) + 1)
            }
        }
        return map.map { key, value in
            LibraryColorSwatch(id: key, color: value.color, usageCount: value.count)
        }
        .sorted { lhs, rhs in
            if lhs.usageCount == rhs.usageCount {
                return lhs.id < rhs.id
            }
            return lhs.usageCount > rhs.usageCount
        }
    }

    private var lastSavedSummary: String {
        let latestDate = [savedPalettes.first?.timestamp, savedCards.first?.timestamp].compactMap { $0 }.max()
        return latestDate?.formatted(date: .abbreviated, time: .shortened) ?? "Never"
    }

    private var paletteColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 180, maximum: 240), spacing: 16)]
    }

    private var cardColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 180, maximum: 240), spacing: 16)]
    }

    private var gradientColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 180, maximum: 240), spacing: 16)]
    }

    private var swatchColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 84, maximum: 110), spacing: 14)]
    }

    private var libraryHero: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(LinearGradient(colors: [Color.indigo.opacity(0.2), Color.mint.opacity(0.16)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 90, height: 90)

                    Image(systemName: "books.vertical.fill")
                        .font(.system(size: 38))
                        .foregroundColor(.indigo)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Palette Vault")
                        .font(.system(.title2, design: .monospaced, weight: .bold))
                        .foregroundColor(.primary)
                    Text("Organize saved palettes, exported case studies, and remix them into new stories.")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Divider().blendMode(.overlay)

            HStack(spacing: 12) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.secondary)
                Text("Last updated \(lastSavedSummary)")
                    .font(.system(.footnote, design: .monospaced))
                    .foregroundColor(.secondary)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(LinearGradient(colors: [accentColor.opacity(0.2), accentColor.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(accentColor.opacity(0.15), lineWidth: 1)
        )
    }

    private var statsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                LibraryStatChip(icon: "paintpalette.fill", title: "\(savedPalettes.count)", subtitle: "Saved Palettes", tint: .purple)
                LibraryStatChip(icon: "square.stack.3d.down.right.fill", title: "\(savedCards.count)", subtitle: "Card Exports", tint: .orange)
                LibraryStatChip(icon: "aqi.medium", title: "\(savedGradients.count)", subtitle: "Saved Gradients", tint: .teal)
                LibraryStatChip(icon: "clock", title: lastSavedSummary, subtitle: "Latest Update", tint: .blue)
            }
            .padding(.horizontal, 2)
        }
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.system(.headline, design: .monospaced, weight: .semibold))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    LibraryActionButton(icon: "sparkles", title: "Import Palette", subtitle: "Jump back to Analyzer") {
                        selectedTab = .analyzer
                    }

                    LibraryActionButton(icon: "paintpalette", title: "Open Palettes", subtitle: "Remix saved colors") {
                        selectedTab = .palettes
                    }

                    LibraryActionButton(icon: "aqi.medium", title: "Open Gradients", subtitle: "Blend cinematic hues") {
                        selectedTab = .gradients
                    }

                    LibraryActionButton(icon: "plus.circle.fill", title: "New Showcase Card", subtitle: "Design from saved colors") {
                        showCardCreator = true
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    private var favoritesSpotlight: some View {
        VStack(alignment: .leading, spacing: 16) {
            LibrarySectionHeader(title: "Favorites", subtitle: "Pinned palettes, gradients, and cards.")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(favoritePalettes) { palette in
                        NavigationLink { PaletteDetailView(palette: palette) } label: {
                            FavoritePaletteTile(palette: palette)
                        }
                        .buttonStyle(.plain)
                    }

                    ForEach(favoriteGradients) { gradient in
                        FavoriteGradientTile(gradient: gradient)
                    }

                    ForEach(favoriteCards) { card in
                        FavoriteCardTile(card: card)
                    }
                }
                .padding(.horizontal, 4)
            }

            favoriteActionRow
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.85))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
    }

    private var favoriteActionRow: some View {
        ViewThatFits {
            HStack(spacing: 12) { favoriteActionButtons }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) { favoriteActionButtons }
                    .padding(.horizontal, 2)
            }
        }
    }

    @ViewBuilder
    private var favoriteActionButtons: some View {
        FavoriteActionChip(icon: "paintpalette.fill",
                           title: "Palettes",
                           count: favoritePalettes.count,
                           isDisabled: favoritePalettes.isEmpty,
                           action: { selectedTab = .palettes })

        FavoriteActionChip(icon: "aqi.medium",
                           title: "Gradients",
                           count: favoriteGradients.count,
                           isDisabled: favoriteGradients.isEmpty,
                           action: { selectedTab = .gradients })

        FavoriteActionChip(icon: "rectangle.portrait.on.rectangle",
                           title: "Cards",
                           count: favoriteCards.count,
                           isDisabled: favoriteCards.isEmpty,
                           action: { selectedTab = .cards })
    }

    private var paletteSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            LibrarySectionHeader(title: "Saved Palettes", subtitle: "Curated combinations ready to reuse.")

            LazyVGrid(columns: paletteColumns, spacing: 18) {
                ForEach(recentPalettes) { palette in
                    NavigationLink { PaletteDetailView(palette: palette) } label: {
                        PaletteLibraryItem(palette: palette)
                    }
                    .buttonStyle(.plain)
                }
            }

            if savedPalettes.count > recentPalettes.count {
                Text("Showing latest \(recentPalettes.count) of \(savedPalettes.count) palettes.")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.8))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
    }

    private var gradientSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            LibrarySectionHeader(title: "Saved Gradients", subtitle: "All your cinematic blends organized.")

            LazyVGrid(columns: gradientColumns, spacing: 18) {
                ForEach(recentGradients) { gradient in
                    LibraryGradientCard(gradient: gradient)
                }
            }

            if savedGradients.count > recentGradients.count {
                Text("Showing latest \(recentGradients.count) of \(savedGradients.count) gradients.")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.85))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
    }

    private var savedColorsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            LibrarySectionHeader(title: "Saved Colors", subtitle: "Every swatch you've saved across palettes.")

            LazyVGrid(columns: swatchColumns, spacing: 16) {
                ForEach(Array(savedColorSwatches.prefix(48))) { swatch in
                    LibraryColorSwatchTile(swatch: swatch)
                }
            }

            if savedColorSwatches.count > 48 {
                Text("Showing top 48 of \(savedColorSwatches.count) swatches by usage.")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.85))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
    }

    private var cardSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            LibrarySectionHeader(title: "Exported Cards", subtitle: "Shareable showcases for presentations and decks.")

            LazyVGrid(columns: cardColumns, spacing: 18) {
                ForEach(recentCards) { card in
                    CardLibraryItem(card: card)
                }
            }

            if savedCards.count > recentCards.count {
                Text("Showing latest \(recentCards.count) of \(savedCards.count) cards.")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground).opacity(0.85))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
    }
}

fileprivate struct LibraryStatChip: View {
    let icon: String
    let title: String
    let subtitle: String
    var tint: Color = .accentColor
    @Environment(\.ambitAccentColor) private var accentColor

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.18))
                    .frame(width: 38, height: 38)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(tint)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.headline, design: .monospaced, weight: .bold))
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(LinearGradient(colors: [accentColor.opacity(0.12), accentColor.opacity(0.04)],
                                     startPoint: .topLeading,
                                     endPoint: .bottomTrailing))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(accentColor.opacity(0.2), lineWidth: 1)
        )
    }
}
fileprivate struct LibraryActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    @Environment(\.ambitAccentColor) private var accentColor

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                    Text(title)
                        .font(.system(.headline, design: .monospaced, weight: .semibold))
                }
                .foregroundColor(.primary)

                Text(subtitle)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(LinearGradient(colors: [accentColor.opacity(0.08), Color(uiColor: .systemBackground)],
                                         startPoint: .topLeading,
                                         endPoint: .bottomTrailing))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(accentColor.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .frame(width: 220)
    }
}

fileprivate struct FavoriteStarButton: View {
    var isFavorite: Bool
    var action: () -> Void
    @Environment(\.ambitAccentColor) private var accentColor

    var body: some View {
        Button {
            HapticManager.instance.impact(style: .soft)
            action()
        } label: {
            Image(systemName: isFavorite ? "star.fill" : "star")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isFavorite ? .yellow : accentColor)
                .padding(8)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }
}

fileprivate struct FavoriteShareButton: View {
    var action: () -> Void
    @Environment(\.ambitAccentColor) private var accentColor

    var body: some View {
        Button(action: action) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(accentColor)
                .padding(8)
                .background(accentColor.opacity(0.12))
                .clipShape(Circle())
                .shadow(color: accentColor.opacity(0.25), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }
}

fileprivate struct FavoriteActionChip: View {
    let icon: String
    let title: String
    let count: Int
    var isDisabled: Bool = false
    let action: () -> Void
    @Environment(\.ambitAccentColor) private var accentColor

    private var subtitle: String {
        count == 1 ? "1 favorite" : "\(count) favorites"
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.18))
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(accentColor)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(.headline, design: .monospaced, weight: .semibold))
                        .foregroundColor(isDisabled ? .secondary : .primary)
                    Text(subtitle)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                Spacer(minLength: 0)
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(isDisabled ? .secondary.opacity(0.6) : accentColor)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(LinearGradient(colors: [accentColor.opacity(0.12), Color(uiColor: .systemBackground)],
                                         startPoint: .topLeading,
                                         endPoint: .bottomTrailing))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(accentColor.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.4 : 1)
    }
}

struct CapsuleTag: View {
    let text: String
    let icon: String
    var accentColor: Color?

    var body: some View {
        Label {
            NoHyphenationLabel(
                text: text,
                font: UIFont.monospacedSystemFont(ofSize: 11, weight: .semibold),
                color: UIColor.label,
                numberOfLines: 1,
                lineBreakMode: .byTruncatingTail
            )
        } icon: {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(
            Capsule()
                .fill(accentColor?.opacity(0.18) ?? Color(uiColor: .secondarySystemGroupedBackground))
        )
        .overlay(
            Capsule()
                .stroke(accentColor?.opacity(0.35) ?? Color.primary.opacity(0.08), lineWidth: 1)
        )
    }
}

fileprivate struct LibraryColorSwatch: Identifiable {
    let id: String
    let color: UIColor
    let usageCount: Int

    var usageLabel: String {
        usageCount == 1 ? "1 palette" : "\(usageCount) palettes"
    }
}

fileprivate struct LibraryColorSwatchTile: View {
    let swatch: LibraryColorSwatch

    var body: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(Color(uiColor: swatch.color))
                .frame(width: 54, height: 54)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.12), radius: 6, y: 4)

            Text(swatch.id)
                .font(.system(.caption, design: .monospaced, weight: .semibold))
                .foregroundColor(.primary)

            Text(swatch.usageLabel)
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(uiColor: .tertiarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .contextMenu {
            Button("Copy HEX", systemImage: "doc.on.doc") {
                UIPasteboard.general.string = swatch.id
            }
        }
    }
}

fileprivate struct LibrarySectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(.title3, design: .monospaced, weight: .bold))
                .foregroundColor(.primary)
            Text(subtitle)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

fileprivate struct LibraryEmptyState: View {
    let createAction: () -> Void
    let analyzeAction: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "paintbrush.pointed")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.accentColor)

            VStack(spacing: 8) {
                Text("No palettes saved yet")
                    .font(.system(.title3, design: .monospaced, weight: .bold))
                Text("Analyze an image or craft a new showcase card to start populating your library.")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 12) {
                Button(action: analyzeAction) {
                    Label("Import Palette", systemImage: "sparkles")
                        .font(.system(.headline, design: .monospaced, weight: .semibold))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                }
                .buttonStyle(.borderedProminent)

                Button(action: createAction) {
                    Label("New Card", systemImage: "plus.circle")
                        .font(.system(.headline, design: .monospaced, weight: .semibold))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(30)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(LinearGradient(colors: [Color.accentColor.opacity(0.14), Color.accentColor.opacity(0.06)], startPoint: .topLeading, endPoint: .bottomTrailing))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.accentColor.opacity(0.18), lineWidth: 1)
        )
    }
}

struct PaletteLibraryItem: View {
    let palette: SavedPalette
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let img = palette.uiImage {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .clipped()
            } else {
                Color.gray.opacity(0.2).frame(height: 120)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(palette.name)
                    .font(.system(.headline, design: .monospaced))
                Text(palette.timestamp.formatted())
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
                HStack(spacing: 0) {
                    ForEach(palette.uiColors.indices, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(uiColor: palette.uiColors[index]))
                            .frame(height: 20)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 12)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
        .overlay(alignment: .topTrailing) {
            FavoriteStarButton(isFavorite: palette.isFavorite) {
                palette.isFavorite.toggle()
            }
            .padding(8)
        }
    }
}

struct CardLibraryItem: View {
    let card: SavedCard
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let img = card.uiImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            } else {
                Color.gray.opacity(0.2)
                    .aspectRatio(1, contentMode: .fit)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
            }

            FavoriteStarButton(isFavorite: card.isFavorite) {
                card.isFavorite.toggle()
            }
            .padding(10)
        }
    }
}

struct LibraryGradientCard: View {
    let gradient: SavedGradient

    private var gradientColors: [Color] {
        let converted = gradient.colors.map { Color(uiColor: $0) }
        return converted.isEmpty ? [Color.gray, Color.gray.opacity(0.4)] : converted
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(LinearGradient(colors: gradientColors,
                                     startPoint: gradient.startPoint,
                                     endPoint: gradient.endPoint))
                .frame(height: 120)
                .overlay(alignment: .topTrailing) {
                    FavoriteStarButton(isFavorite: gradient.isFavorite) {
                        gradient.isFavorite.toggle()
                    }
                    .padding(10)
                }

            Text(gradient.name)
                .font(.system(.headline, design: .monospaced))
            HStack {
                Label("\(gradient.colors.count) stops", systemImage: "slider.horizontal.3")
                Spacer()
                Text(gradient.timestamp.formatted(date: .abbreviated, time: .omitted))
            }
            .font(.system(.caption, design: .monospaced))
            .foregroundColor(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }
}

struct FavoritePaletteTile: View {
    let palette: SavedPalette
    @State private var showShare = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 0) {
                ForEach(palette.uiColors.indices, id: \.self) { idx in
                    Color(uiColor: palette.uiColors[idx])
                }
            }
            .frame(height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            Text(palette.name)
                .font(.system(.subheadline, design: .monospaced, weight: .semibold))
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .multilineTextAlignment(.leading)
            Text(palette.timestamp.formatted(date: .abbreviated, time: .omitted))
                .font(.system(.caption2, design: .monospaced))
                .foregroundColor(.secondary)
        }
        .padding(14)
        .frame(width: 180, alignment: .leading)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.08), radius: 6, y: 4)
        .overlay(alignment: .topTrailing) {
            HStack(spacing: 6) {
                FavoriteShareButton {
                    showShare = true
                }
                FavoriteStarButton(isFavorite: palette.isFavorite) {
                    palette.isFavorite.toggle()
                }
            }
            .padding(8)
        }
        .sheet(isPresented: $showShare) {
            ShareSheet(items: [palette.shareSummary])
        }
    }
}

struct FavoriteGradientTile: View {
    let gradient: SavedGradient
    @State private var showShare = false

    private var colors: [Color] {
        let converted = gradient.colors.map { Color(uiColor: $0) }
        return converted.isEmpty ? [Color.gray.opacity(0.6), Color.gray.opacity(0.2)] : converted
    }

    private var shareSummary: String {
        let hexes = gradient.colors.map { $0.hexString }.joined(separator: ", ")
        return "\(gradient.name): \(hexes)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(LinearGradient(colors: colors,
                                     startPoint: gradient.startPoint,
                                     endPoint: gradient.endPoint))
                .frame(height: 64)

            Text(gradient.name)
                .font(.system(.subheadline, design: .monospaced, weight: .semibold))
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .multilineTextAlignment(.leading)
            Text("\(gradient.colors.count) swatches • \(gradient.timestamp.formatted(date: .abbreviated, time: .omitted))")
                .font(.system(.caption2, design: .monospaced))
                .foregroundColor(.secondary)
        }
        .padding(14)
        .frame(width: 180, alignment: .leading)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.08), radius: 6, y: 4)
        .overlay(alignment: .topTrailing) {
            HStack(spacing: 6) {
                FavoriteShareButton {
                    showShare = true
                }
                FavoriteStarButton(isFavorite: gradient.isFavorite) {
                    gradient.isFavorite.toggle()
                }
            }
            .padding(8)
        }
        .sheet(isPresented: $showShare) {
            ShareSheet(items: [shareSummary])
        }
    }
}

struct FavoriteCardTile: View {
    let card: SavedCard
    @State private var showShare = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let img = card.uiImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 160, height: 120)
                    .clipped()
                    .cornerRadius(20)
            } else {
                Color.gray.opacity(0.2)
                    .frame(width: 160, height: 120)
                    .cornerRadius(20)
            }

            HStack(spacing: 6) {
                FavoriteShareButton {
                    showShare = true
                }
                FavoriteStarButton(isFavorite: card.isFavorite) {
                    card.isFavorite.toggle()
                }
            }
            .padding(8)
        }
        .shadow(color: .black.opacity(0.08), radius: 6, y: 4)
        .sheet(isPresented: $showShare) {
            if let image = card.uiImage {
                ShareSheet(items: [image])
            } else {
                ShareSheet(items: ["Ambit card exported \(card.timestamp.formatted(date: .abbreviated, time: .shortened))"])
            }
        }
    }
}

struct PaletteDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let palette: SavedPalette
    @State private var showCardCreator = false
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                AppNavTitle(text: palette.name, size: 32, weight: .bold).padding(.top)
                if let img = palette.uiImage {
                    Image(uiImage: img).resizable().scaledToFit().cornerRadius(16).shadow(radius: 5)
                }
                AppNavTitle(text: "Colors", size: 22, weight: .bold)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))]) {
                    ForEach(palette.uiColors.indices, id: \.self) { ColorCardView(color: palette.uiColors[$0]) }
                }
                Button("Create Card from Palette", systemImage: "photo.on.rectangle") { showCardCreator = true }
                    .buttonStyle(.bordered).tint(.primary).font(.system(.body, design: .monospaced, weight: .bold))
                    .sheet(isPresented: $showCardCreator) { CardCreatorView(originalImage: palette.uiImage, extractedColors: palette.uiColors) }
                Button("Delete Palette", systemImage: "trash.fill") {
                    modelContext.delete(palette); dismiss()
                }
                .buttonStyle(.bordered).tint(.red).font(.system(.body, design: .monospaced, weight: .bold))
                Spacer()
            }
            .padding()
        }
        .toolbar { ToolbarItem(placement: .principal) { AppNavTitle(text: "Palette Details", size: 24, weight: .bold) } }
    }
}

// MARK: - Card Creator

struct CardCreatorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    static let defaultPalette: [UIColor] = [
        .systemRed, .systemOrange, .systemYellow, .systemGreen, .systemBlue, .systemPurple
    ]

    let originalImage: UIImage?
    let extractedColors: [UIColor]

    @State private var selectedImage: UIImage?
    @State private var palette: [UIColor] = []
    @State private var previewImage: UIImage?
    @State private var design = CardDesignOptions()
    @State private var customColor = Color.white
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var isLoadingCustomImage = false
    @State private var isAnalyzingImage = false

    @State private var preset: PresetTemplate = .defaultMinimal
    enum ExportWidth: String, CaseIterable, Identifiable { case w1080="1080", w1440="1440", w2048="2048"; var id:String{rawValue}; var value:CGFloat{CGFloat(Int(rawValue) ?? 1080)} }
    @State private var exportWidth: ExportWidth = .w1080
    @State private var showShare = false
    @State private var shareItem: UIImage?
    @State private var showReorder = false

    init(originalImage: UIImage?, extractedColors: [UIColor]) {
        self.originalImage = originalImage
        self.extractedColors = extractedColors
        _selectedImage = State(initialValue: originalImage)
        let seedPalette = extractedColors.isEmpty ? Self.defaultPalette : extractedColors
        _palette = State(initialValue: seedPalette)
    }

    private var typographySummary: String {
        let size = Int(design.titleSize.rounded())
        let weight = weightLabel(design.titleWeight)
        let alignment = alignmentLabel(design.titleAlignment)
        return "\(size)pt \(weight) · \(alignment)"
    }

    private var backgroundSummary: String {
        switch design.backgroundMode {
        case .solid:
            return "Solid · \(colorLabel(design.backgroundColor1))"
        case .gradient:
            return "Gradient Blend"
        case .image:
            return "Image Driven"
        }
    }

    private var frameSummary: String {
        var traits: [String] = []
        if design.frameStyle == .none {
            traits.append("No Frame")
        } else {
            traits.append(design.frameStyle.rawValue)
        }
        if design.borderWidth > 0.1 { traits.append("Border") }
        if design.shadowEnabled { traits.append("Shadow") }
        return traits.joined(separator: " · ")
    }

    private var exportSummary: String {
        "\(exportWidth.rawValue)px · \(design.aspect.rawValue)"
    }

    private func alignmentLabel(_ alignment: TextAlignment) -> String {
        switch alignment {
        case .leading: return "Left"
        case .center: return "Center"
        case .trailing: return "Right"
        @unknown default: return "Center"
        }
    }

    private func colorLabel(_ color: Color) -> String {
        UIColor(color).toHex() ?? "Custom"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 28) {
                    heroSection

                    CardCreatorSection(title: "Palette", icon: "paintpalette", subtitle: "Curate the colors that anchor your composition.", accent: .purple, trailing: {
                        CardCreatorStatusChip(text: "\(palette.count) colors")
                    }) {
                        paletteControls
                    }
                    .padding(.horizontal, 20)

                    CardCreatorSection(title: "Templates", icon: "wand.and.stars", subtitle: "Jump-start with pre-balanced layouts.", accent: .orange, trailing: {
                        CardCreatorStatusChip(text: preset.displayName)
                    }) {
                        templatesControls
                    }
                    .padding(.horizontal, 20)

                    CardCreatorSection(title: "Typography", icon: "textformat", subtitle: "Shape hierarchy, tone, and alignment.", accent: .cyan, trailing: {
                        CardCreatorStatusChip(text: typographySummary)
                    }) {
                        typographyControls
                    }
                    .padding(.horizontal, 20)

                    CardCreatorSection(title: "Layout", icon: "rectangle.grid.2x2", subtitle: "Control aspect ratio and palette presentation.", accent: .mint, trailing: {
                        CardCreatorStatusChip(text: design.aspect.rawValue)
                    }) {
                        layoutControls
                    }
                    .padding(.horizontal, 20)

                    CardCreatorSection(title: "Background", icon: "square.fill", subtitle: "Blend gradients, solids, or the source photo.", accent: .blue, trailing: {
                        CardCreatorStatusChip(text: backgroundSummary)
                    }) {
                        backgroundControls
                    }
                    .padding(.horizontal, 20)

                    CardCreatorSection(title: "Imagery", icon: "photo", subtitle: "Dial in how photography joins the palette.", accent: .pink, trailing: {
                        CardCreatorStatusChip(text: design.includeImage ? "Photo On" : "Photo Off")
                    }) {
                        imageryControls
                    }
                    .padding(.horizontal, 20)

                    CardCreatorSection(title: "Frame & Effects", icon: "square.dashed", subtitle: "Add borders, corner rounding, and depth.", accent: .teal, trailing: {
                        CardCreatorStatusChip(text: frameSummary)
                    }) {
                        frameControls
                    }
                    .padding(.horizontal, 20)

                    CardCreatorSection(title: "Output", icon: "square.and.arrow.up", subtitle: "Choose export dimensions before sharing.", accent: .indigo, trailing: {
                        CardCreatorStatusChip(text: exportSummary)
                    }) {
                        outputControls
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 28)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    AppNavTitle(text: "Create Card", size: 26, weight: .bold)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Reset Design", systemImage: "arrow.counterclockwise") {
                            resetToDefaults()
                        }
                        Divider()
                        if originalImage != nil {
                            Button("Use Original Photo", systemImage: "photo.on.rectangle") {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    selectedImage = originalImage
                                }
                            }
                        }
                        Button("Restore Extracted Palette", systemImage: "paintpalette") {
                            restoreExtractedPalette()
                        }
                        .disabled(extractedColors.isEmpty)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    HStack(spacing: 16) {
                        Button {
                            exportShare()
                        } label: {
                            Label("Export", systemImage: "square.and.arrow.up")
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)

                        Button {
                            saveCard()
                        } label: {
                            Label("Save to Library", systemImage: "archivebox")
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .onChange(of: selectedImage) { _, _ in generatePreview() }
            .onChange(of: palette) { _, _ in generatePreview() }
            .onChange(of: design) { _, _ in generatePreview() }
            .onChange(of: exportWidth) { _, _ in generatePreview() }
            .onChange(of: photoPickerItem) { _, newItem in
                guard let newItem else { return }
                loadCustomImage(from: newItem)
            }
            .task { generatePreview() }
            .sheet(isPresented: $showShare) { if let img = shareItem { ShareSheet(items: [img]) } }
            .sheet(isPresented: $showReorder) { ReorderPaletteView(colors: $palette) }
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(heroGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
                Group {
                    if let img = previewImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .padding(24)
                            .transition(.opacity.combined(with: .scale))
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "square.on.circle")
                                .font(.system(size: 34, weight: .medium))
                            Text("Adjust options below to watch your card come together.")
                                .multilineTextAlignment(.center)
                        }
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .padding(40)
                        .frame(maxWidth: .infinity)
                    }
                }
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        CapsuleTag(text: design.aspect.rawValue.uppercased(), icon: "rectangle.portrait.on.rectangle.portrait")
                        CapsuleTag(text: "\(palette.count) colors", icon: "paintpalette")
                        if selectedImage != nil {
                            CapsuleTag(text: design.includeImage ? "Photo On" : "Photo Off", icon: design.includeImage ? "photo" : "photo.slash")
                        }
                        Spacer()
                    }
                    paletteOverlay
                }
                .padding(24)
            }
            Text("Dial in palette, typography, layout, and framing. The live preview updates with every tweak.")
                .font(.system(.callout, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private var paletteOverlay: some View {
        if palette.isEmpty {
            Text("Add colors to build your palette.")
                .font(.system(.footnote, design: .monospaced))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        } else {
            VStack(alignment: .leading, spacing: 10) {
                Text("Active Palette")
                    .font(.system(.footnote, design: .monospaced))
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(palette.enumerated()), id: \.offset) { index, uiColor in
                            VStack(spacing: 6) {
                                Circle()
                                    .fill(Color(uiColor: uiColor))
                                    .frame(width: 34, height: 34)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                                    )
                                Text(uiColor.hexString.uppercased())
                                    .font(.system(.caption2, design: .monospaced))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .contextMenu {
                                Button("Copy HEX", systemImage: "doc.on.doc") {
                                    UIPasteboard.general.string = uiColor.hexString
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
    }

    private var paletteControls: some View {
        VStack(alignment: .leading, spacing: 18) {
            CardCreatorPaletteView(colors: $palette)
            Divider()
            VStack(alignment: .leading, spacing: 12) {
                ColorPicker("Custom Color", selection: $customColor, supportsOpacity: true)
                Button("Add Custom Color", systemImage: "plus.circle.fill") {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        palette.append(UIColor(customColor))
                    }
                }
                .buttonStyle(.bordered)
            }
            VStack(alignment: .leading, spacing: 10) {
                Text("Palette Tools")
                    .font(.system(.subheadline, design: .monospaced, weight: .semibold))
                    .foregroundStyle(.secondary)
                HStack {
                    Button("Restore Extracted", systemImage: "paintbrush") { restoreExtractedPalette() }
                        .buttonStyle(.bordered)
                        .disabled(extractedColors.isEmpty)
                    Button("Reorder", systemImage: "arrow.up.arrow.down") { showReorder = true }
                        .buttonStyle(.bordered)
                    Button("Shuffle", systemImage: "shuffle") {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                            palette.shuffle()
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .controlSize(.small)
            }
        }
    }

    private var templatesControls: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Start from a preset layout, then make it yours.")
                .font(.system(.callout, design: .monospaced))
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(PresetTemplate.allCases) { template in
                        Button {
                            applyPreset(template)
                        } label: {
                            CardCreatorTemplateCard(template: template, isSelected: preset == template)
                                .frame(width: 220)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(template.displayName)
                    }
                }
            }
        }
    }

    private var typographyControls: some View {
        VStack(alignment: .leading, spacing: 16) {
            TextField("Title", text: $design.title)
                .textFieldStyle(.roundedBorder)
            TextField("Subtitle (optional)", text: $design.subtitle)
                .textFieldStyle(.roundedBorder)
            SliderWithLabel(title: "Title Size", value: $design.titleSize, range: 12...48, step: 1)
            typographyRow(weight: $design.titleWeight, alignment: $design.titleAlignment, label: "Title Align", currentLabel: "Title Weight")
            SliderWithLabel(title: "Subtitle Size", value: $design.subtitleSize, range: 10...28, step: 1)
            typographyRow(weight: $design.subtitleWeight, alignment: $design.subtitleAlignment, label: "Sub Align", currentLabel: "Subtitle Weight")
        }
    }

    private var layoutControls: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("Aspect", selection: $design.aspect) {
                ForEach(CardAspect.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            Picker("Palette Layout", selection: $design.paletteLayout) {
                ForEach(PaletteLayout.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
        }
    }

    private var backgroundControls: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("Mode", selection: $design.backgroundMode) {
                ForEach(BackgroundMode.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            if design.backgroundMode == .solid {
                ColorPicker("Color", selection: $design.backgroundColor1)
            } else if design.backgroundMode == .gradient {
                ColorPicker("Color A", selection: $design.backgroundColor1)
                ColorPicker("Color B", selection: $design.backgroundColor2)
            } else {
                Toggle("Include Image Background", isOn: $design.includeImage)
                SliderWithLabelDouble(title: "Image Overlay", value: $design.imageOverlayOpacity, range: 0...0.9, step: 0.05, format: "%.2f")
            }
        }
    }

    private var imageryControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            PhotosPicker(selection: $photoPickerItem, matching: .images) {
                Label(selectedImage == nil ? "Add Photo" : "Replace Photo", systemImage: "photo.on.rectangle")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.bordered)

            if isLoadingCustomImage {
                ProgressView("Loading photo…")
                    .font(.system(.caption, design: .monospaced))
            }

            if let preview = selectedImage {
                Image(uiImage: preview)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
                    .shadow(radius: 6, y: 4)

                HStack(spacing: 12) {
                    Button {
                        analyzeSelectedImage()
                    } label: {
                        Label(isAnalyzingImage ? "Analyzing…" : "Analyze Colors", systemImage: "paintpalette")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.accentColor)
                    .disabled(isAnalyzingImage)

                    if originalImage != nil {
                        Button("Revert", systemImage: "arrow.uturn.backward") {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                selectedImage = originalImage
                                design.includeImage = originalImage != nil
                            }
                        }
                        .buttonStyle(.bordered)
                    }

                    Button("Remove", systemImage: "trash") {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                            selectedImage = nil
                            design.includeImage = false
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .controlSize(.small)

                if isAnalyzingImage {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.accentColor)
                }
            }

            Toggle("Include Photo", isOn: $design.includeImage)
            SliderWithLabel(title: "Corner Radius", value: $design.imageCornerRadius, range: 0...32, step: 1)
            SliderWithLabel(title: "Height Ratio", value: $design.imageHeightRatio, range: 0.25...0.75, step: 0.01, format: "%.2f")
        }
    }

    private var frameControls: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("Frame Style", selection: $design.frameStyle) {
                ForEach(FrameStyle.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            if design.frameStyle != .none {
                SliderWithLabel(title: "Corner Radius", value: $design.cornerRadius, range: 0...40, step: 1)
                SliderWithLabel(title: "Border Width", value: $design.borderWidth, range: 0...8, step: 0.5)
                ColorPicker("Border Color", selection: $design.borderColor)
            }
            Toggle("Shadow", isOn: $design.shadowEnabled)
            if design.shadowEnabled {
                SliderWithLabel(title: "Shadow Radius", value: $design.shadowRadius, range: 0...20, step: 1)
                SliderWithLabel(title: "Shadow X", value: $design.shadowX, range: -20...20, step: 1)
                SliderWithLabel(title: "Shadow Y", value: $design.shadowY, range: -20...20, step: 1)
            }
        }
    }

    private var outputControls: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("Width (px)", selection: $exportWidth) {
                ForEach(ExportWidth.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            Text(exportDimensionsDescription)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
        }
    }

    private var exportDimensionsDescription: String {
        let baseWidth = Int(exportWidth.value)
        let aspect = design.aspect.size
        let height: Int
        if aspect.width <= 0 {
            height = baseWidth
        } else {
            height = Int((exportWidth.value / aspect.width) * aspect.height)
        }
        return "\(baseWidth) × \(height) px • \(design.aspect.rawValue)"
    }

    private var heroGradient: LinearGradient {
        let source = palette.isEmpty ? Self.defaultPalette : palette
        let colors = source.prefix(2).map { Color(uiColor: $0) }
        let first = colors.first ?? Color.accentColor
        let second = colors.dropFirst().first ?? first
        return LinearGradient(colors: [first.opacity(0.85), second.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private func resetToDefaults() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
            design = CardDesignOptions()
            exportWidth = .w1080
            customColor = .white
            selectedImage = originalImage
        }
        restoreExtractedPalette()
        generatePreview()
    }

    private func restoreExtractedPalette() {
        let source = extractedColors.isEmpty ? Self.defaultPalette : extractedColors
        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
            palette = source
        }
    }

    private func loadCustomImage(from item: PhotosPickerItem) {
        isLoadingCustomImage = true
        Task {
            let data = try? await item.loadTransferable(type: Data.self)
            await MainActor.run {
                isLoadingCustomImage = false
                guard let data, let image = UIImage(data: data) else { return }
                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                    selectedImage = image
                    design.includeImage = true
                }
            }
        }
    }

    private func analyzeSelectedImage() {
        guard let selectedImage else { return }
        isAnalyzingImage = true
        Task {
            let colors = await Task.detached(priority: .userInitiated) {
                ColorExtractor.extractProminentColors(from: selectedImage, in: nil, count: 8, avoidDark: true)
            }.value

            await MainActor.run {
                let fallback = colors.isEmpty ? Self.defaultPalette : colors
                palette = fallback
                isAnalyzingImage = false
                HapticManager.instance.notification(type: .success)
            }
        }
    }

    private func applyPreset(_ template: PresetTemplate) {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
            preset = template
            design = CardDesignOptions.preset(template, currentImage: selectedImage != nil)
        }
        HapticManager.instance.impact(style: .medium)
    }

    private func generatePreview() {
        guard !palette.isEmpty else { previewImage = nil; return }
        let view = AdvancedPaletteCardView(image: selectedImage, colors: palette, design: design)
        let w: CGFloat = 400
        let s = design.aspect.size
        let h = max(300, w * s.height/s.width)
        let renderer = ImageRenderer(content: view.frame(width: w, height: h))
        previewImage = renderer.uiImage
    }

    private func saveCard() {
        renderExport { image in
            guard let data = image.jpegData(compressionQuality: 0.9) else { return }
            let newCard = SavedCard(imageData: data)
            modelContext.insert(newCard)
            HapticManager.instance.notification(type: .success)
        }
    }

    private func exportShare() {
        renderExport { image in
            shareItem = image
            showShare = true
        }
    }

    private func renderExport(_ completion: @escaping (UIImage) -> Void) {
        let targetW = exportWidth.value
        let s = design.aspect.size
        let scale = targetW / s.width
        let targetSize = CGSize(width: s.width * scale, height: s.height * scale)
        let content = AdvancedPaletteCardView(image: selectedImage, colors: palette, design: design)
            .frame(width: targetSize.width, height: targetSize.height)
        let renderer = ImageRenderer(content: content)
        renderer.scale = UIScreen.main.scale
        if let img = renderer.uiImage { completion(img) }
    }
}

private enum OnboardingPhase: Hashable {
    case marketing
    case tutorial
    case paywall
}

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var phase: OnboardingPhase = .marketing
    @State private var marketingIndex = 0
    @State private var selectedPlan: PaywallPlan = .monthly

    var body: some View {
        ZStack {
            switch phase {
            case .marketing:
                AnimatedOnboardingView(onContinue: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { phase = .paywall }
                }, onStartTutorial: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { phase = .tutorial }
                })

            case .paywall:
                PaywallView(selectedPlan: $selectedPlan) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                        phase = .tutorial
                    }
                }

            case .tutorial:
                InteractiveTutorialView(onFinish: {
                    PermissionManager.requestPermissions {
                        withAnimation(.easeInOut) { hasCompletedOnboarding = true }
                    }
                })
            }
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
        .animation(.easeInOut, value: phase)
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

private struct MarketingPager: View {
    @Binding var index: Int
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 24)
            TabView(selection: $index) {
                ForEach(Array(MarketingSlide.slides.enumerated()), id: \.offset) { offset, slide in
                    MarketingSlideView(slide: slide)
                        .tag(offset)
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(maxHeight: 520)

            PrimaryCTAButton(title: index == MarketingSlide.slides.count - 1 ? "View Membership Plans" : "Next") {
                onContinue()
            }
            .padding(.horizontal, 24)
            Spacer(minLength: 36)
        }
        .background(
            LinearGradient(colors: [Color.accentColor.opacity(0.08), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
        )
    }
}

private struct TutorialOverview: View {
    let onFinish: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                VStack(spacing: 12) {
                    Text("Welcome to Your Ambit Studio")
                        .font(.system(.title2, design: .monospaced, weight: .bold))
                        .italic()
                    Text("Start every project grounded in analysis, strategy, and a library that never loses your work.")
                        .font(.system(.subheadline, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)

                VStack(alignment: .leading, spacing: 16) {
                    ForEach(TutorialModel.steps) { step in
                        TutorialCard(step: step)
                    }
                }
                .padding(.horizontal, 20)

                PrimaryCTAButton(title: "Finish Setup", action: onFinish)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 36)
            }
            .padding(.top, 44)
        }
    }
}

private struct PaywallView: View {
    @Binding var selectedPlan: PaywallPlan
    let onPurchase: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                VStack(spacing: 12) {
                    Text("Unlock Ambit Pro")
                        .font(.system(.largeTitle, design: .monospaced, weight: .bold))
                        .italic()
                        .multilineTextAlignment(.center)
                    Text("Professional color intelligence for teams who ship at scale.")
                        .font(.system(.subheadline, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 16) {
                    ForEach(PaywallPlan.allCases) { plan in
                        PaywallPlanCard(plan: plan, isSelected: selectedPlan == plan)
                            .onTapGesture { withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) { selectedPlan = plan } }
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(PaywallBenefit.all) { benefit in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(benefit.text)
                                .font(.system(.subheadline, design: .monospaced))
                                .foregroundStyle(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }

                PrimaryCTAButton(title: selectedPlan.ctaTitle, action: onPurchase)

                Button("Restore Purchases", action: { /* Hook into StoreKit restore */ })
                    .font(.system(.footnote, design: .monospaced, weight: .medium))
                    .foregroundStyle(.secondary)

                Text("Payment will be charged to your Apple ID account. Cancel anytime in Settings. Lifetime access is a one-time purchase.")
                    .font(.system(.footnote, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 36)
        }
    }
}

private struct MarketingSlideView: View {
    let slide: MarketingSlide
    @State private var animate = false

    var body: some View {
        VStack(spacing: 22) {
            Image(systemName: slide.icon)
                .font(.system(size: 60, weight: .bold))
                .foregroundStyle(slide.tint)
                .scaleEffect(animate ? 1 : 0.85)
                .opacity(animate ? 1 : 0)
            Text(slide.title)
                .font(.system(.title, design: .monospaced, weight: .bold))
                .italic()
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
                .scaleEffect(animate ? 1 : 0.94)
            Text(slide.subtitle)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            VStack(alignment: .leading, spacing: 6) {
                ForEach(slide.highlights, id: \.self) { highlight in
                    Label(highlight, systemImage: "sparkles")
                        .labelStyle(.titleAndIcon)
                        .font(.system(.footnote, design: .monospaced, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(uiColor: .systemBackground).opacity(0.92))
                .shadow(color: slide.tint.opacity(0.25), radius: 24, y: 14)
        )
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                animate = true
            }
        }
    }
}

private struct TutorialCard: View {
    let step: TutorialModel

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(spacing: 6) {
                Text(String(format: "%02d", step.order))
                    .font(.system(.title3, design: .monospaced, weight: .bold))
                Image(systemName: step.icon)
                    .font(.system(size: 20, weight: .semibold))
            }
            .frame(width: 54)
            .padding(10)
            .background(step.tint.opacity(0.18))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 8) {
                Text(step.title)
                    .font(.system(.headline, design: .monospaced, weight: .bold))
                Text(step.detail)
                    .font(.system(.callout, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: step.tint.opacity(0.15), radius: 12, y: 6)
    }
}

private struct PaywallPlanCard: View {
    let plan: PaywallPlan
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(plan.title)
                    .font(.system(.headline, design: .monospaced, weight: .bold))
                Spacer()
                if plan.badge != nil {
                    Text(plan.badge!)
                        .font(.system(.caption2, design: .monospaced, weight: .heavy))
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(plan.tint.opacity(0.22))
                        .clipShape(Capsule())
                }
            }
            Text(plan.priceDescription)
                .font(.system(.title3, design: .monospaced, weight: .bold))
            Text(plan.subtitle)
                .font(.system(.footnote, design: .monospaced))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Divider()
                .opacity(0.15)
            VStack(alignment: .leading, spacing: 6) {
                ForEach(plan.features, id: \.self) { feature in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                        Text(feature)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(uiColor: .systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(isSelected ? plan.tint : Color.primary.opacity(0.08), lineWidth: isSelected ? 2 : 1)
                )
        )
        .shadow(color: plan.tint.opacity(isSelected ? 0.25 : 0.08), radius: isSelected ? 24 : 12, y: 8)
        .scaleEffect(isSelected ? 1.02 : 1)
    }
}

private struct PrimaryCTAButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.headline, design: .monospaced, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.primary)
                .foregroundColor(Color(uiColor: .systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct MarketingSlide: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let highlights: [String]
    let tint: Color

    static let slides: [MarketingSlide] = [
        MarketingSlide(
            icon: "sparkles",
            title: "Your Color Command Center",
            subtitle: "Ambit unifies analysis, storytelling, and asset management in one workspace.",
            highlights: [
                "Instant WCAG AA / AAA scoring on every swatch",
                "Strategy insights from 40+ benchmarked brands",
                "Library that keeps palettes, gradients, and cards in sync"
            ],
            tint: .indigo
        ),
        MarketingSlide(
            icon: "photo.on.rectangle.angled",
            title: "Analyze Assets in Seconds",
            subtitle: "Drop in photos, screenshots, or brand decks and generate usable palettes immediately.",
            highlights: [
                "Smart sampling preserves tonal balance",
                "Contrast heatmaps flag risky pairings",
                "Color-vision simulations ensure inclusive design"
            ],
            tint: .blue
        ),
        MarketingSlide(
            icon: "square.grid.2x2.fill",
            title: "Build Systems That Scale",
            subtitle: "Link palettes, gradients, and story cards so every deliverable stays on-brand.",
            highlights: [
                "Generate gradients and motion ramps from any palette",
                "Version history and duplication for rapid exploration",
                "Guided accessibility cues baked into every workspace"
            ],
            tint: .purple
        ),
        MarketingSlide(
            icon: "square.and.arrow.up",
            title: "Share With Total Confidence",
            subtitle: "Export production-ready kits and collaborate without leaving Ambit.",
            highlights: [
                "Figma, Adobe, and web exports in one tap",
                "Branded presentation cards for stakeholder reviews",
                "Team onboarding playbooks inside the Library hub"
            ],
            tint: .teal
        )
    ]
}

private struct TutorialModel: Identifiable {
    let id = UUID()
    let order: Int
    let icon: String
    let title: String
    let detail: String
    let tint: Color

    static let steps: [TutorialModel] = [
        TutorialModel(order: 1, icon: "photo.on.rectangle.angled", title: "Import & Analyze", detail: "Drag in photos, decks, or moodboards. Ambit extracts primary, support, and neutral tones with instant contrast checks.", tint: .orange),
        TutorialModel(order: 2, icon: "eyedropper.halffull", title: "Refine with Precision", detail: "Tune swatches, lock winning combinations, and flag accessibility issues before anything ships.", tint: .pink),
        TutorialModel(order: 3, icon: "paintpalette.fill", title: "Systemize Your Color", detail: "Spin up gradients, motion ramps, and story cards—all synced back to the same palette.", tint: .blue),
        TutorialModel(order: 4, icon: "archivebox.fill", title: "Grow the Library", detail: "Every palette, gradient, and card lives in the Library hub so your team never loses a deliverable.", tint: .indigo),
        TutorialModel(order: 5, icon: "square.and.arrow.up", title: "Share & Iterate", detail: "Export Figma, Adobe, and web kits in one tap, then version them right inside Ambit.", tint: .green)
    ]
}

private enum PaywallPlan: String, CaseIterable, Identifiable {
    case monthly
    case lifetime

    var id: String { rawValue }

    var title: String {
        switch self {
        case .monthly: return "Ambit Monthly"
        case .lifetime: return "Ambit Lifetime"
        }
    }

    var subtitle: String {
        switch self {
        case .monthly: return "Perfect for iterating with new palettes every month." 
        case .lifetime: return "Own the full studio forever with all future updates." 
        }
    }

    var priceDescription: String {
        switch self {
        case .monthly: return "$3.99 / month"
        case .lifetime: return "$25 one-time"
        }
    }

    var features: [String] {
        switch self {
        case .monthly:
            return [
                "Unlimited analyzer and library usage",
                "Linked palettes, gradients, and story cards",
                "Monthly brand library expansions"
            ]
        case .lifetime:
            return [
                "Everything in Ambit Monthly",
                "Priority access to new generators",
                "Lifetime updates and advanced playbooks"
            ]
        }
    }

    var badge: String? {
        switch self {
        case .monthly: return "Best start"
        case .lifetime: return "Best value"
        }
    }

    var tint: Color {
        switch self {
        case .monthly: return .blue
        case .lifetime: return .purple
        }
    }

    var ctaTitle: String {
        switch self {
        case .monthly: return "Subscribe for $3.99 / month"
        case .lifetime: return "Unlock Lifetime for $25"
        }
    }
}

private struct PaywallBenefit: Identifiable {
    let id = UUID()
    let text: String

    static let all: [PaywallBenefit] = [
        PaywallBenefit(text: "Unlimited analyzer sessions and library storage"),
        PaywallBenefit(text: "Accessibility dashboards with WCAG scoring"),
        PaywallBenefit(text: "Export-ready files for Figma, Adobe, and web"),
        PaywallBenefit(text: "Monthly brand drops and strategy playbooks")
    ]
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.1).ignoresSafeArea()
            ProgressView().controlSize(.large).padding(20).background(.ultraThinMaterial).cornerRadius(12)
        }
    }
}

struct PlaceholderView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.on.rectangle.angled").font(.system(size: 56)).foregroundStyle(.secondary)
            Text("Pick a photo to analyze").foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ScrollableTabBar: View {
    @Binding var selectedTab: RootTab
    @Environment(\.ambitAccentColor) private var accentColor
    @Environment(\.ambitTheme) private var theme
    
    private let tabs: [RootTab] = [.analyzer, .palettes, .gradients, .cards, .learning, .library, .settings]
    
    var body: some View {
        VStack(spacing: 0) {
            // Top separator line
            Rectangle()
                .fill(Color.primary.opacity(0.1))
                .frame(height: 0.5)

            // Tab buttons in scrollable view
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(tabs, id: \.self) { tab in
                        TabButton(
                            tab: tab,
                            selectedTab: selectedTab,
                            accentColor: accentColor
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = tab
                            }
                            HapticManager.instance.impact(style: .light)
                        }
                    }
                }
                .padding(.horizontal, 12)
            }
            .frame(height: 65)
        }
        .background(.ultraThinMaterial)
        .background(theme.cardBackgroundColor.opacity(0.5))
    }
}

struct TabButton: View {
    let tab: RootTab
    let selectedTab: RootTab
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: tab.icon)
                    .font(.system(size: 16, weight: .medium))
                    .symbolRenderingMode(.hierarchical)
                
                Text(tab.label)
                    .font(.system(size: 10, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                    .truncationMode(.middle)
                    .allowsTightening(true)
            }
            .foregroundColor(selectedTab == tab ? accentColor : .secondary)
            .frame(width: 88, height: 55)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selectedTab == tab ? accentColor.opacity(0.12) : Color.clear)
            .animation(.easeInOut(duration: 0.15), value: selectedTab == tab)
        )
        }
        .buttonStyle(.plain)
    }
}

// File-scope extensions consolidated
extension PaletteStyle: CaseIterable {
    static let allCases: [PaletteStyle] = [.adaptive, .harmonic, .monochromatic, .complementary, .triadic, .analogous]

    var displayName: String { rawValue }
}

extension PalettePurpose: CaseIterable {
    static let allCases: [PalettePurpose] = [.ui, .branding, .artistic, .accessible]

    var displayName: String {
        switch self {
        case .ui: return "UI"
        case .branding: return "Branding"
        case .artistic: return "Artistic"
        case .accessible: return "Accessible"
        }
    }

    var guidance: String {
        switch self {
        case .ui:
            return "Balances contrast and interaction states for multi-state UI surfaces."
        case .branding:
            return "Highlights hero tones while keeping supportive colors distinct and consistent."
        case .artistic:
            return "Allows expressive saturation shifts and cinematic range for storytelling visuals."
        case .accessible:
            return "Maximizes contrast ratios and legibility for WCAG-compliant experiences."
        }
    }
}


