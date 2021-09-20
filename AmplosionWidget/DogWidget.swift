//
//  DogWidget.swift
//  DogWidget
//
//  Created by Christian Selig on 2021-09-11.
//

import WidgetKit
import SwiftUI
import Intents

struct DogProvider: IntentTimelineProvider {
    typealias Entry = DogEntry
    
    func placeholder(in context: Context) -> DogEntry {
        DogEntry(date: Date(), state: DogWidgetState.generateRandomUniqueStates(total: 1).first!, showLightning: true, showText: true)
    }

    func getSnapshot(for configuration: DogConfigIntent, in context: Context, completion: @escaping (DogEntry) -> ()) {
        let entry = DogEntry(date: Date(), state: DogWidgetState.generateRandomUniqueStates(total: 1).first!, showLightning: configuration.showLightning?.boolValue ?? false, showText: configuration.showText?.boolValue ?? false)
        completion(entry)
    }

    func getTimeline(for configuration: DogConfigIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [DogEntry] = []

        let entriesToProvide = 10
        let dogStates = DogWidgetState.generateRandomUniqueStates(total: entriesToProvide)
        
        let currentDate = Date()
        for i in 0 ..< entriesToProvide {
            let entryDate = Calendar.current.date(byAdding: .minute, value: 15 * i, to: currentDate)!
            let entry = DogEntry(date: entryDate, state: dogStates[i], showLightning: configuration.showLightning?.boolValue ?? false, showText: configuration.showText?.boolValue ?? false)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct DogEntry: TimelineEntry {
    let date: Date
    let state: DogWidgetState
    let showLightning: Bool
    let showText: Bool
}

struct DogWidgetEntryView : View {
    var entry: DogProvider.Entry

    var body: some View {
        ZStack {
            Color(red: 215.0/255.0, green: 186.0/255.0, blue: 153.0/255.0)
            
            VStack(spacing: 3.0) {
                if entry.showText {
                    Text(entry.state.announcement)
                        .font(.system(size: 17.0, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 108.0/255.0, green: 93.0/255.0, blue: 77.0/255.0))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10.0)
                }
                
                entry.state.image
                    .interpolation(.none)
                    .resizable()
                    .frame(width: 75, height: 75)
            }
        }.overlay(
            Image("lightning-logo")
                .interpolation(.none)
                .resizable()
                .frame(width: 10.0, height: 17.0)
                .padding(EdgeInsets(top: 0.0, leading: 12.0, bottom: 12.0, trailing: 0.0))
                .opacity(entry.showLightning ? 1.0 : 0.0)
                .unredacted()
            , alignment: .bottomLeading)
    }
}

struct DogWidget: Widget {
    let kind: String = "DogWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: DogConfigIntent.self, provider: DogProvider()) { entry in
            DogWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("🐶 Lord Waffles")
        .description("Have his furry excellence make your home screen cuter")
        .supportedFamilies([.systemSmall])
    }
}

struct DogWidget_Previews: PreviewProvider {
    static var previews: some View {
        DogWidgetEntryView(entry: DogEntry(date: Date(), state: .walkUp, showLightning: false, showText: false))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

enum DogWidgetState: Int, CaseIterable {
    case digLeft, digRight, standLeft, standRight, sleep, walkUp, walkDown, walkLeft, walkRight, bark, happy, onGuard, sitFront, sitLeft, sitRight, sniff
    
    var image: Image {
        switch self {
        case .digLeft:
            return Image(uiImage: UIImage(named: "dig-right-1")!.withHorizontallyFlippedOrientation())
        case .digRight:
            return Image(uiImage: UIImage(named: "dig-right-1")!.withHorizontallyFlippedOrientation())
        case .standLeft:
            return Image(uiImage: UIImage(named: "walk-right-2\(bandanaSuffix(forBandana: Bandana.selectedBandana))")!.withHorizontallyFlippedOrientation())
        case .standRight:
            return Image(uiImage: UIImage(named: "walk-right-2\(bandanaSuffix(forBandana: Bandana.selectedBandana))")!)
        case .sleep:
            return Image(uiImage: UIImage(named: "sleep-1\(bandanaSuffix(forBandana: Bandana.selectedBandana))")!)
        case .walkUp:
            return Image(uiImage: UIImage(named: "walk-up-1\(bandanaSuffix(forBandana: Bandana.selectedBandana))")!)
        case .walkDown:
            return Image(uiImage: UIImage(named: "walk-down-1\(bandanaSuffix(forBandana: Bandana.selectedBandana))")!)
        case .walkLeft:
            return Image(uiImage: UIImage(named: "walk-right-3\(bandanaSuffix(forBandana: Bandana.selectedBandana))")!.withHorizontallyFlippedOrientation())
        case .walkRight:
            return Image(uiImage: UIImage(named: "walk-right-3\(bandanaSuffix(forBandana: Bandana.selectedBandana))")!)
        case .bark:
            return Image(uiImage: UIImage(named: "bark\(bandanaSuffix(forBandana: Bandana.selectedBandana))")!)
        case .happy:
            return Image(uiImage: UIImage(named: "happy-2\(bandanaSuffix(forBandana: Bandana.selectedBandana))")!)
        case .onGuard:
            return Image(uiImage: UIImage(named: "walk-right-1\(bandanaSuffix(forBandana: Bandana.selectedBandana))")!)
        case .sitFront:
            return Image(uiImage: UIImage(named: "sit-front-1\(bandanaSuffix(forBandana: Bandana.selectedBandana))")!)
        case .sitLeft:
            return Image(uiImage: UIImage(named: "sit-right-1\(bandanaSuffix(forBandana: Bandana.selectedBandana))")!.withHorizontallyFlippedOrientation())
        case .sitRight:
            return Image(uiImage: UIImage(named: "sit-right-1\(bandanaSuffix(forBandana: Bandana.selectedBandana))")!)
        case .sniff:
            return Image(uiImage: UIImage(named: "bend-down")!)
        }
    }
    
    var announcement: String {
        switch self {
        case .digLeft, .digRight:
            return ["i’m diggin", "dig dig dig"].randomElement()!
        case .standLeft, .standRight:
            return ["i’m lookin", "squirrel??"].randomElement()!
        case .sleep:
            return "i’m sleepin"
        case .walkUp:
            return ["i’m goin up here", "i’m prowlin"].randomElement()!
        case .walkDown:
            return ["i’m goin down here", "a tennis ball??"].randomElement()!
        case .walkLeft, .walkRight:
            return ["i’m goin for walk", "walk walk walk"].randomElement()!
        case .bark:
            return "boRk"
        case .happy:
            return ["i love u", "ur the best"].randomElement()!
        case .onGuard:
            return ["i’m on guard", "i protec", "i’m guardin ur \(UIDevice.current.userInterfaceIdiom == .pad ? "ipad" : "phone")", "SQUIRREL!!"].randomElement()!
        case .sitFront, .sitLeft, .sitRight:
            return ["i’m sittin", "i’m tuckered"].randomElement()!
        case .sniff:
            return "i’m sniffin"
        }
    }
    
    private func bandanaSuffix(forBandana bandana: Bandana?) -> String {
        guard let bandana = bandana else { return "" }
        return "-\(bandana.rawValue)"
    }
    
    static func generateRandomUniqueStates(total: Int) -> [DogWidgetState] {
        var states: [DogWidgetState] = []
        var availableOptions = DogWidgetState.allCases
        
        for _ in 0 ..< total {
            let diceRoll = availableOptions.randomElement()!
            states.append(diceRoll)
            let index = availableOptions.firstIndex(of: diceRoll)!
            availableOptions.remove(at: index)
        }
        
        return states
    }
}
