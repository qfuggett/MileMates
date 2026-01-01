//
//  Activities.swift
//  MileMates
//
//  Created by 31-third team on 12/9/25.
//

import SwiftUI
import SwiftData
import SwiftUIGIF
import PDFKit

struct Activities: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var imageData: Data? = nil
    @State private var showSuccessAlert = false
    @State private var showShareSheet = false
    @State private var navigateToTips = false
    @State private var pdfURL: URL?
    @Query(sort: \Activity.date, order: .reverse) private var activities: [Activity]
    @Environment(\.modelContext) private var context

    var body: some View {
        ZStack {
            // Background - GIF theme or system background
            if themeManager.shouldShowGIF, let data = imageData, !data.isEmpty {
                GIFImage(data: data)
                    .ignoresSafeArea()
            } else {
                Color(.systemBackground)
                    .ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                List {
                    ForEach(activities) { activity in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(activity.name)
                                    .font(.body)
                                Text(activity.date, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("\(activity.miles, specifier: "%.2f") mi")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .scrollContentBackground(themeManager.shouldShowGIF ? .hidden : .automatic)
                .background(themeManager.shouldShowGIF ? Color.clear : Color(.systemGroupedBackground))
                
                // Send All button
                VStack {
                    Button(action: {
                        generateAndSharePDF()
                    }) {
                        Label("Send All", systemImage: "paperplane.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 34)
                }
                .background {
                    if themeManager.shouldShowGIF {
                        Color.clear
                    } else {
                        Color(.systemGroupedBackground)
                    }
                }
            }
        }
        .navigationTitle("All Activities")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            // Load GIF only if theme is enabled
            if themeManager.shouldShowGIF && imageData == nil {
                if let gifData = NSDataAsset(name: "poleposition")?.data {
                    imageData = gifData
                }
            }
        }
        .onChange(of: themeManager.animatedGIFThemeEnabled) { _, enabled in
            // Load or unload GIF based on theme preference
            if themeManager.shouldShowGIF && imageData == nil {
                if let gifData = NSDataAsset(name: "poleposition")?.data {
                    imageData = gifData
                }
            } else if !themeManager.shouldShowGIF {
                imageData = nil
            }
        }
        .sheet(isPresented: $showShareSheet, onDismiss: {
            // Show success alert after share sheet is dismissed
            if pdfURL != nil {
                showSuccessAlert = true
            }
        }) {
            if let pdfURL = pdfURL {
                ShareSheet(activityItems: [pdfURL], onComplete: {
                    showShareSheet = false
                })
            } else {
                Text("Error generating PDF")
                    .padding()
            }
        }
        .alert("Data Sent Successfully", isPresented: $showSuccessAlert) {
            Button("OK") {
                navigateToTips = true
            }
        } message: {
            Text("Your activities have been exported successfully.")
        }
        .navigationDestination(isPresented: $navigateToTips) {
            TipsAndTricks()
        }
    }
    
    private func generateAndSharePDF() {
        guard !activities.isEmpty else {
            // Show alert if no activities
            return
        }
        
        let pdfMetaData = [
            kCGPDFContextCreator: "MileMates",
            kCGPDFContextAuthor: "MileMates App",
            kCGPDFContextTitle: "Mileage Activities"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            let titleFont = UIFont.boldSystemFont(ofSize: 24)
            let headerFont = UIFont.boldSystemFont(ofSize: 16)
            let bodyFont = UIFont.systemFont(ofSize: 14)
            
            var yPosition: CGFloat = 72
            
            // Title
            let title = "Mileage Activities Report"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: UIColor.black
            ]
            let titleSize = title.size(withAttributes: titleAttributes)
            title.draw(at: CGPoint(x: (pageWidth - titleSize.width) / 2, y: yPosition), withAttributes: titleAttributes)
            yPosition += titleSize.height + 20
            
            // Date
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .none
            let dateString = "Generated: \(dateFormatter.string(from: Date()))"
            let dateAttributes: [NSAttributedString.Key: Any] = [
                .font: bodyFont,
                .foregroundColor: UIColor.gray
            ]
            dateString.draw(at: CGPoint(x: 72, y: yPosition), withAttributes: dateAttributes)
            yPosition += 30
            
            // Headers
            let nameHeader = "Activity Name"
            let distanceHeader = "Distance (miles)"
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: headerFont,
                .foregroundColor: UIColor.black
            ]
            nameHeader.draw(at: CGPoint(x: 72, y: yPosition), withAttributes: headerAttributes)
            distanceHeader.draw(at: CGPoint(x: pageWidth - 200, y: yPosition), withAttributes: headerAttributes)
            yPosition += 25
            
            // Draw line
            context.cgContext.setStrokeColor(UIColor.lightGray.cgColor)
            context.cgContext.setLineWidth(1.0)
            context.cgContext.move(to: CGPoint(x: 72, y: yPosition))
            context.cgContext.addLine(to: CGPoint(x: pageWidth - 72, y: yPosition))
            context.cgContext.strokePath()
            yPosition += 15
            
            // Activities
            var totalMiles: Double = 0
            for activity in activities {
                if yPosition > pageHeight - 100 {
                    context.beginPage()
                    yPosition = 72
                }
                
                let nameAttributes: [NSAttributedString.Key: Any] = [
                    .font: bodyFont,
                    .foregroundColor: UIColor.black
                ]
                activity.name.draw(at: CGPoint(x: 72, y: yPosition), withAttributes: nameAttributes)
                
                let distanceText = String(format: "%.2f", activity.miles)
                let distanceAttributes: [NSAttributedString.Key: Any] = [
                    .font: bodyFont,
                    .foregroundColor: UIColor.black
                ]
                _ = distanceText.size(withAttributes: distanceAttributes)
                distanceText.draw(at: CGPoint(x: pageWidth - 200, y: yPosition), withAttributes: distanceAttributes)
                
                totalMiles += activity.miles
                yPosition += 20
            }
            
            // Total
            yPosition += 10
            context.cgContext.move(to: CGPoint(x: 72, y: yPosition))
            context.cgContext.addLine(to: CGPoint(x: pageWidth - 72, y: yPosition))
            context.cgContext.strokePath()
            yPosition += 15
            
            let totalText = "Total Mileage: \(String(format: "%.2f", totalMiles)) miles"
            let totalAttributes: [NSAttributedString.Key: Any] = [
                .font: headerFont,
                .foregroundColor: UIColor.black
            ]
            totalText.draw(at: CGPoint(x: 72, y: yPosition), withAttributes: totalAttributes)
        }
        
        // Save to temporary file
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("MileageActivities.pdf")
        do {
            try data.write(to: tempURL)
            pdfURL = tempURL
            showShareSheet = true
        } catch {
            print("Failed to save PDF: \(error)")
            // Don't show the share sheet if PDF generation failed
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let onComplete: () -> Void
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        // Configure for iPad
        if let popover = controller.popoverPresentationController {
            popover.sourceView = UIView()
            popover.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        controller.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            if completed || activityType == nil {
                onComplete()
            }
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        Activities()
    }
    .modelContainer(for: Activity.self, inMemory: true)
}
