import Foundation
import Testing
@testable import SwiftTerm

#if (os(macOS) || os(iOS) || os(visionOS)) && canImport(MetalKit)
@Suite("Metal native scale")
struct MetalNativeScaleTests {
    @Test func gridFitsTheNativeDrawableWhenUIKitDownsamples() throws {
        // A 527-point detail column at UIKit scale 3 requests 71 cells of
        // 22/3 points each. At the Duo's native scale only 1479 pixels fit.
        // Multiplying cell coordinates by UIKit scale would crop 4 columns.
        let geometry = MetalSurfaceGeometry(
            bounds: CGRect(x: 0, y: 0, width: 527, height: 528),
            drawableSize: CGSize(width: 1479, height: 1482), contentsScale: 3)
        let scale = try #require(geometry.renderingScale)
        let gridWidth = 71.0 * (22.0 / 3)
        #expect(gridWidth * 3 > geometry.drawableSize.width)
        #expect(gridWidth * scale <= geometry.drawableSize.width)
        #expect(abs(scale - 1479.0 / 527) < 0.000001)
    }

    @Test(arguments: [0.75, 1, 2, 2670.0 / 951, 3])
    func usesDrawableScaleIndependentlyOfLayerScale(_ scale: CGFloat) throws {
        let geometry = MetalSurfaceGeometry(
            bounds: CGRect(x: 0, y: 0, width: 400, height: 200),
            drawableSize: CGSize(width: 400 * scale, height: 200 * scale), contentsScale: 3)
        let actual = try #require(geometry.renderingScale)
        #expect(abs(actual - scale) < 0.000000001)
    }

    @Test func anUnconfiguredSurfaceHasNoRenderingScale() {
        for (bounds, drawable) in [(CGSize.zero, CGSize(width: 100, height: 100)),
                                   (CGSize(width: 100, height: 100), CGSize.zero)] {
            let geometry = MetalSurfaceGeometry(bounds: CGRect(origin: .zero, size: bounds),
                                                drawableSize: drawable, contentsScale: 3)
            #expect(geometry.renderingScale == nil)
        }
    }
}
#endif
