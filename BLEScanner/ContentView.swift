//
//  ContentView.swift
//  BLEScanner
//
//  Created by Hishara Dilshan on 2024-01-08.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel: ContentViewModel = ContentViewModel()
    @State var isSheetPresented = false
    
    var body: some View {
        VStack {
            Text("Scan Results")
                .font(.title2)
            VStack {
                Spacer()
                HStack {
                    TextField("Selected BLE 1", text: $viewModel.selectedId1)
                        .disabled(true)
                        .frame(maxWidth: .infinity)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    Button {
                        viewModel.selectionType = .first
                        isSheetPresented = true
                    } label: {
                        Text("Select")
                    }
                    .buttonStyle(.borderedProminent)

                }
                HStack {
                    TextField("Selected BLE 2", text: $viewModel.selectedId2)
                        .disabled(true)
                        .frame(maxWidth: .infinity)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    Button {
                        viewModel.selectionType = .second
                        isSheetPresented = true
                    } label: {
                        Text("Select")
                    }
                    .buttonStyle(.borderedProminent)

                }
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $isSheetPresented) {
            NavigationView {
                ScanResultList(results: $viewModel.scanResults, onItemSelected: viewModel.handleSelectedItem)
                    .toolbar {
                        ToolbarItem {
                            Button("Cancel") {
                                isSheetPresented = false
                            }
                        }
                    }
            }
        }
    }
}

struct ScanResultList: View {
    @Environment (\.dismiss) var dismiss
    @Binding var results: [ScanResult]
    let onItemSelected: (ScanResult) -> (Void)
    var body: some View {
        VStack {
            Text("Select BLE Device")
                .font(.title3)
            Text("Bring your device closer to your iPhone. The RSSI value will be decreased when the device is closer")
                .font(.system(size: 14))
                .lineSpacing(8)
                .padding()
            List(results, id: \.identifier) { item in
                ScanResultView(data: item)
                    .onTapGesture {
                        NSLog("Selected: \(item.name ?? "???")")
                        onItemSelected(item)
                        dismiss()
                    }
            }
        }
    }
}

struct ScanResultView: View {
    let data: ScanResult
    var body: some View {
        VStack(alignment:.leading, spacing: 6) {
            Text("UUID: \(data.identifier)")
            Text("Name: \(data.name ?? "---")")
            Text(String(format: "RSSI: %.2f", data.rssi))
        }
        .font(.system(size: 13))
    }
}

#Preview {
    ContentView()
}
