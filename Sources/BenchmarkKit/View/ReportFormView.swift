//
//  ReportFormView.swift
//  BenchmarkKit
//
//  Created by xuyunshi on 2025/5/22.
//

import SwiftUI

public struct ReportFormView: View {
    let formTitle: String
    let wrappedResult: MeasureResultWrapper

    public init(formTitle: String, wrappedResult: MeasureResultWrapper) {
        self.formTitle = formTitle
        self.wrappedResult = wrappedResult
        let dataColumns = wrappedResult.cols.map { _ in
            GridItem(.fixed(66), spacing: 0, alignment: .center)
        }
        columns = [GridItem(.fixed(66), spacing: 0, alignment: .center)] + dataColumns
    }

    let columns: [GridItem]

    public var body: some View {
        ScrollView([.horizontal, .vertical]) {
            formView()
        }
    }

    func headerView(_ text: String) -> some View {
        Text(text)
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.1))
            .fontWeight(.semibold)
            .border(.gray, width: 0.3)
    }

    func formView() -> some View {
        VStack(spacing: 0) {
            Text(formTitle)
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
            LazyVGrid(columns: columns, spacing: 0, pinnedViews: [.sectionHeaders]) {
                Text("\\")
                    .frame(alignment: .center)

                ForEach( wrappedResult.cols, id: \.self) {
                    headerView($0)
                }
                

                ForEach(0 ..< wrappedResult.rows.count, id: \.self) { rowIndex in
                    headerView(wrappedResult.rows[rowIndex])
                    ForEach(arrayForRow(rowIndex)) { cellIndex in
                        let m = wrappedResult.cells[cellIndex]
                        if let m {
                            Text(wrappedResult.timeString(for: m))
                        } else {
                            Text("N")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.gray.opacity(0.05))
                                .foregroundStyle(Color.black.opacity(0.3))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .border(.gray, width: 0.3)
                }
            }
            .font(.system(size: 12))
        }
    }
    
    func arrayForRow(_ rowIndex: Int) -> Range<Int> {
        let start = rowIndex * wrappedResult.cols.count
        let end = start + wrappedResult.cols.count
        return start ..< end
    }
}
