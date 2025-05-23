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
                for i in 0 ..< 3 {
                    for j in 0 ..< 3 {
                        BenchmarkKit.measureWork(
                            MeasureInput(
                                taskName: "x \(i)",
                                impLabel: "sync y \(j)",
                                resourceCaseLabel: "zzz",
                                performQueue: .main,
                                performTimes: 3,
                                prepare: { done in
                                    done("some prepared input")
                                },
                                syncWork: { prepared in
//                                    print("this is prepared data.", prepared)
                                    // do some sync work.
                                    for _ in 0 ..< 100000 {
                                        _ = 1 + 1
                                    }
                                },
                                finishedHandler: { _ in }
                            )
                        )

                        BenchmarkKit.measureWork(
                            MeasureInput(
                                taskName: "x \(i)",
                                impLabel: "async y \(j)",
                                resourceCaseLabel: "zzz",
                                performQueue: .main,
                                performTimes: 3,
                                prepare: { done in done("some prepared input") },
                                asyncWork: { prepared, done in
//                                    print("this is prepared data.", prepared)
                                    DispatchQueue.global().async {
                                        for _ in 0 ..< 100000 {
                                            _ = 1 + 1
                                        }
                                        done()
                                    }
                                },
                                finishedHandler: { _ in }
                            )
                        )
                    }
                }
                let results = await BenchmarkKit.main()
                let report = BenchmarkKit.report(results: results)
                print(report)
                let formView = BenchmarkKit.formView(results: results, title: "some title")
                wrapper = MeasureResultWrapper(results: results)
            }
        }
    }
}

PlaygroundPage.current.setLiveView(ContentView())
