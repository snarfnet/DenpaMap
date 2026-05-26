import SwiftUI

struct StatsView: View {
    @ObservedObject var viewModel: MeasurementViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("サマリー / Summary") {
                    statRow("計測ポイント", value: "\(viewModel.measurements.count)")
                    statRow("平均レイテンシ", value: String(format: "%.0f ms", viewModel.averageLatency))
                    statRow("平均速度", value: String(format: "%.1f Mbps", viewModel.averageSpeed))
                }

                if let best = viewModel.bestSpot {
                    Section("ベストスポット / Best") {
                        statRow("レイテンシ", value: String(format: "%.0f ms", best.latencyMs))
                        statRow("速度", value: String(format: "%.1f Mbps", best.downloadSpeedMbps))
                        statRow("ネットワーク", value: best.networkType)
                    }
                }

                if let worst = viewModel.worstSpot {
                    Section("ワーストスポット / Worst") {
                        statRow("レイテンシ", value: String(format: "%.0f ms", worst.latencyMs))
                        statRow("速度", value: String(format: "%.1f Mbps", worst.downloadSpeedMbps))
                        statRow("ネットワーク", value: worst.networkType)
                    }
                }

                Section("品質分布 / Distribution") {
                    let dist = viewModel.qualityDistribution
                    qualityRow("Excellent", count: dist[.excellent] ?? 0, color: .green)
                    qualityRow("Good", count: dist[.good] ?? 0, color: Color(red: 0.4, green: 0.8, blue: 0.2))
                    qualityRow("Fair", count: dist[.fair] ?? 0, color: .yellow)
                    qualityRow("Poor", count: dist[.poor] ?? 0, color: .orange)
                    qualityRow("Dead", count: dist[.dead] ?? 0, color: .red)
                }

                Section {
                    Button("計測データをクリア", role: .destructive) {
                        viewModel.clearMeasurements()
                        dismiss()
                    }
                }
            }
            .navigationTitle("統計")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }

    private func statRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(.body, design: .monospaced))
                .fontWeight(.semibold)
        }
    }

    private func qualityRow(_ label: String, count: Int, color: Color) -> some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            Text(label)
            Spacer()
            Text("\(count)")
                .font(.system(.body, design: .monospaced))
                .fontWeight(.semibold)
        }
    }
}
