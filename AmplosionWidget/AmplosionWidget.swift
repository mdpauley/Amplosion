//
//  AmplosionWidget.swift
//  AmplosionWidget
//
//  Created by Christian Selig on 2021-09-11.
//

import WidgetKit
import SwiftUI
import Intents

@main
struct AmplosionWidgets: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        StatsWidget()
        DogWidget()
    }
}
