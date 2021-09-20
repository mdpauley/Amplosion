//
//  StatsWidget.swift
//  StatsWidget
//
//  Created by Christian Selig on 2021-09-11.
//

import WidgetKit
import SwiftUI
import Intents

struct StatsProvider: TimelineProvider {
    func placeholder(in context: Context) -> StatsEntry {
        StatsEntry(date: Date(), showPlaceholderAmount: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (StatsEntry) -> ()) {
        let entry = StatsEntry(date: Date(), showPlaceholderAmount: true)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StatsEntry>) -> ()) {
        var entries: [StatsEntry] = []

        // All values are computed on the fly in the widget itself, so the timeline entries are just treated as opportunities to update
        let currentDate = Date()
        for minuteOffset in 0 ..< 15 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset * 15, to: currentDate)!
            let entry = StatsEntry(date: entryDate, showPlaceholderAmount: false)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct StatsEntry: TimelineEntry {
    let date: Date
    let showPlaceholderAmount: Bool
}

struct StatsWidgetEntryView : View {
    var entry: StatsProvider.Entry

    var body: some View {
        AmplosionFlipCounter(showPlaceholderAmount: entry.showPlaceholderAmount)
    }
}

struct StatsWidget: Widget {
    let kind: String = "StatsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StatsProvider()) { entry in
            StatsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("⚡️ Total Amplosions")
        .description("A counter of how many times Amplosion has activated")
        .supportedFamilies([.systemSmall])
    }
}

struct StatsWidget_Previews: PreviewProvider {
    static var previews: some View {
        StatsWidgetEntryView(entry: StatsEntry(date: Date(), showPlaceholderAmount: true))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

struct AmplosionFlipCounter: View {
    let showPlaceholderAmount: Bool
    
    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .inset(by: 5.0)
                .fill(Color(white: 0.13))
            
            VStack {
                Spacer()
                    .overlay (
                        Image("stats-lightning")
                            .unredacted()
                    )
                
                FlipCounterNumbers(showPlaceholderAmount: showPlaceholderAmount)
                
                Spacer()
            }
        }.background(Color(white: 0.3))
    }
}

struct FlipCounterNumbers: View {
    let showPlaceholderAmount: Bool
    
    var digits: [Int] {
        guard !showPlaceholderAmount else {
            return 481.digits
        }
        
        let count = UserDefaults.groupSuite.totalAmplosions()
        
        let max = 9_999
        
        if count > max {
            return max.digits
        } else if count < 10 {
            // If only one digit, add a 0 spacer
            return [0, count]
        } else {
            return count.digits
        }
    }
    
    var body: some View {
        HStack(spacing: 3.0) {
            ForEach(digits, id: \.self) {
                FlipCounterDigit(digit: $0)
            }
        }
        .padding(.horizontal, 10.0)
        .background(
            Color(white: 0.22)
                .padding(EdgeInsets(top: -5.0, leading: 5.0, bottom: -5.0, trailing: 5.0))
        )
    }
}

struct FlipCounterDigit: View {
    let digit: Int
    
    var body: some View {
        ZStack {
            Rectangle()
                .cornerRadius(5.0)
                .foregroundColor(Color(white: 0.1))
                .frame(height: 64.0)
                .overlay(
                    Text("\(digit)")
                        .font(.system(size: 31.0, weight: .medium, design: .rounded))
                        .foregroundColor(Color(white: 0.95))
                )
            
            Color(white: 0.22)
                .frame(height: 2.0)
            
            HStack {
                FlipCounterCoil()
                Spacer()
                FlipCounterCoil()
            }.padding(.horizontal, 2.0)
        }
    }
}

struct FlipCounterCoil: View {
    var body: some View {
        Rectangle()
            .frame(width: 3.0, height: 6.0, alignment: .center)
            .cornerRadius(1.5)
            .foregroundColor(Color("flip-counter-coil"))
    }
}
