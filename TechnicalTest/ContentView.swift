//
//  ContentView.swift
//  TechnicalTest
//
//  Created by Vedran Burojevic on 16.04.2025..
//

import App
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                StoryListView(viewModel: StoryListViewModel())
                    .padding(.top)

                Spacer()

                Text("Rest of the app content...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    ContentView()
}
