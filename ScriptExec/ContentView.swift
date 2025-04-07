//
//  ContentView.swift
//  ScriptExec
//
//  Created by Bartosz Strzecha on 06/03/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var scriptCode: String = ""
    @State private var outputText: String = ""
    @State private var isRunning: Bool = false
    @State private var exitCode: Int? = nil
    @State private var autoClearOutput: Bool = true

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .trailing) {
                CodeEditor(text: $scriptCode)
                    .frame(minWidth: 550, minHeight: 700)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                    .onAppear {
                            print("CodeEditor appeared in SwiftUI")
                        }

                HStack {
                    Button(action: runScript) {
                        Text(isRunning ? "Running..." : "Run Script")
                    }
                    .disabled(isRunning)
                }
                .frame(height: 20)
            }
            
            VStack {
                TextEditor(text: .constant(outputText))
                    .foregroundColor(.blue)
                    .font(.system(size: 13, design: .monospaced))
                    .lineSpacing(5)
                    .kerning(1.5)
                    .frame(minWidth: 550, minHeight: 700)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))

                HStack {
                    Spacer()
                    
                    Toggle("Auto Clearing", isOn: $autoClearOutput)
                        .toggleStyle(SwitchToggleStyle())

                    Button(action: { outputText = "" }) {
                        Text("Clear Output")
                    }
                    .disabled(autoClearOutput)
                }
                .frame(height: 20)
            }
        }
        .padding()
    }
    
    func runScript() {
        if autoClearOutput {
            outputText = ""
        }
        
        let filePath = FileManager.default.temporaryDirectory.appendingPathComponent("script.swift")

        do {
            try scriptCode.write(to: filePath, atomically: true, encoding: .utf8)
            print("Script saved successfully at: \(filePath.path)")
        } catch {
            print("Error saving file: \(error.localizedDescription)")
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["swift", filePath.path]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        let fileHandle = pipe.fileHandleForReading
        fileHandle.readabilityHandler = { handle in
            if let output = String(data: handle.availableData, encoding: .utf8) {
                DispatchQueue.main.async {
                    outputText += output
                }
            }
        }

        do {
            try process.run()
            isRunning = true
        } catch {
            outputText = "Error running script: \(error.localizedDescription)"
            return
        }

        DispatchQueue.global().async {
            process.waitUntilExit()
            DispatchQueue.main.async {
                isRunning = false
                exitCode = Int(process.terminationStatus)
                outputText += "\nExit code: \(exitCode ?? -1)\n\n\n"
            }
        }
    }
}

#Preview {
    ContentView()
}
