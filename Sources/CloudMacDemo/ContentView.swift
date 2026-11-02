import SwiftUI

struct ContentView: View {
    private let buildTimestamp = Date()

    private var architecture: String {
        #if arch(arm64)
        return "Apple Silicon (arm64)"
        #elseif arch(x86_64)
        return "Intel (x86_64)"
        #else
        return "unknown"
        #endif
    }

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "applelogo")
                .font(.system(size: 44))
                .foregroundStyle(.tint)

            Text("Hello from the cloud")
                .font(.largeTitle.weight(.semibold))

            Text("This app was compiled by GitHub Actions on a real Apple Silicon Mac, then delivered to you as a .dmg.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 380)

            GroupBox {
                VStack(alignment: .leading, spacing: 6) {
                    LabeledContent("Architecture") {
                        Text(architecture)
                    }
                    LabeledContent("Built") {
                        Text(buildTimestamp.formatted(date: .abbreviated, time: .standard))
                    }
                    LabeledContent("macOS") {
                        Text(ProcessInfo.processInfo.operatingSystemVersionString)
                    }
                }
            }
            .frame(maxWidth: 380)
        }
        .padding(28)
    }
}
