//
//  HubView.swift
//  sprint_1
//
//  Created by Sasha Jazmin Abuin on 10/12/25.
//

//Documentation used: https://developer.apple.com/documentation/swiftui/vstack

// https://developer.apple.com/documentation/Symbols

//View for hub --> nothing is functional yet.
import SwiftUI

struct HubView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    // VStack for the welcome card
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Welcome")
                            .font(.title3).bold()
                        Text("Put user's name here (sprint 2)")
                            .foregroundColor(.pink)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 1, y: 1)

                    // movie coming up rectangle
                    Spacer()
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Movie coming up on xx.xx!")
                            Text("From - group name").bold()
                        }
                        Spacer()
                        Image(systemName: "mappin.and.ellipse")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 1, y: 1)

                    Spacer()
                    // groups + info buttons rectangles
                    HStack(spacing: 12) {
                        Button("groups") { }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 1, y: 1)

                        Button("info") { }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 1, y: 1)
                    }
                    Spacer()
                    // trending movie rectalngle
                    VStack(alignment: .leading, spacing: 6) {
                        Text("trending movie")
                            .font(.headline)
                        Text("~ placeholder ~")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 1, y: 1)

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .navigationTitle("Hub")
            .background(Color.white)
        }
    }
}

#Preview {
    HubView()
}
