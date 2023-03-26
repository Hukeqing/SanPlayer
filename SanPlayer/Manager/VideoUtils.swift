import Foundation
import AVKit
import AppKit

struct VideoUtils {
    static func makeTitleImage(videoUrl: URL, imageUrl: URL) async -> Void {
        let avAsset = AVAsset(url: videoUrl)
        let generator = AVAssetImageGenerator(asset: avAsset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(0.0, preferredTimescale: 600)
        var actualTime:CMTime = CMTimeMake(value: 0, timescale: 0)
        let cgImage = try! generator.copyCGImage(at: time, actualTime: &actualTime)
        let uiImage = NSImage(cgImage: cgImage, size: CGSize(width: cgImage.width, height: cgImage.height))
        try! uiImage.tiffRepresentation?.write(to: imageUrl)
    }
}
