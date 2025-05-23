@preconcurrency import BenchmarkKit
import PlaygroundSupport
import SwiftUI

struct ContentView: View {
    @State var wrapper: MeasureResultWrapper?
    var body: some View {
        VStack(alignment: .leading) {
            if let wrapper {
                ReportFormView(formTitle: "Report", wrappedResult: wrapper)
            }
            Spacer()
        }
        .padding()
        .frame(width: 320, height: 480)
        .onAppear {
            Task {
                for i in 0..<5 {
                    for j in 0..<5 {
                        BenchmarkKit.measureWork(
                            .init(
                                label: "Type \(i)",
                                subLabel: "SubType \(j)",
                                identifier: "Identi",
                                performQueue: .main,
                                performTimes: 1,
                                prepare: { prepareDoneCallback in
                                    prepareDoneCallback(1)
                                },
                                syncWork: { _ in
                                },
                                finishedHandler: { _ in
                                }
                            )
                        )
                    }
                }
                let results = await BenchmarkKit.main()
                wrapper = MeasureResultWrapper(results: results)
            }
        }
    }
}

PlaygroundPage.current.setLiveView(ContentView())
