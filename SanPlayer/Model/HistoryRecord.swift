import Foundation
import AVKit
import AppKit

class HistoryRecord : Codable, Identifiable, ObservableObject, Equatable, Hashable {

    var id: HistoryRecord {
        get { return self }
    }

    @Published var name: String
    @Published var url: URL
    @Published var titleImageUrl: URL?
    @Published var totalTimeSecond: Int?
    @Published var currentTimeSecond: Int?
    
    var playerItem: AVPlayerItem?
    var getPlayerItem: AVPlayerItem {
        get {
            if playerItem == nil {
                playerItem = AVPlayerItem(url: url)
                var cmTime = playerItem?.currentTime()
                if cmTime != nil, currentTimeSecond != nil {
                    cmTime!.value = CMTimeValue(Int32(currentTimeSecond!) * cmTime!.timescale)
                    playerItem!.seek(to: cmTime!) {
                        if !$0 {
                            self.totalTimeSecond = nil
                            self.currentTimeSecond = nil
                        }
                    }
                }
            }
            
            return playerItem!
        }
    }

    enum CodingKeys: String, CodingKey {
        case name, url, titleImageUrl, totalTimeSecond, currentTimeSecond
    }

    init(name: String, url: URL) {
        self.name = name
        self.url = url
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        url = try values.decode(URL.self, forKey: .url)
        titleImageUrl = try? values.decode(URL.self, forKey: .titleImageUrl)
        totalTimeSecond = try? values.decode(Int.self, forKey: .totalTimeSecond)
        currentTimeSecond = try? values.decode(Int.self, forKey: .currentTimeSecond)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(url, forKey: .url)
        try container.encode(titleImageUrl, forKey: .titleImageUrl)
        try container.encode(totalTimeSecond, forKey: .totalTimeSecond)
        try container.encode(currentTimeSecond, forKey: .currentTimeSecond)
    }

    static func == (lhs: HistoryRecord, rhs: HistoryRecord) -> Bool {
        return lhs.url == rhs.url
    }

    func hash(into hasher: inout Hasher) {
        return hasher.combine(url)
    }

    func initTitleImage(titleImageUrl: URL?) async {
        if titleImageUrl == nil {
            self.titleImageUrl = nil;
            return
        }

        await VideoUtils.makeTitleImage(videoUrl: url, imageUrl: titleImageUrl!)
        self.titleImageUrl = titleImageUrl
    }
    
    func getTotalTime() -> String {
        return HistoryRecord.getTimeFormat(time: totalTimeSecond)
    }

    func getCurrentTime() -> String {
        return HistoryRecord.getTimeFormat(time: currentTimeSecond)
    }

    static func getTimeFormat(time: Int?) -> String {
        if time == nil {
            return "--:--"
        }
        let hour = Int(time! / 3600)
        let minute = Int((time! % 3600) / 60)
        let second = Int(time! % 60)
        
        if hour == 0 {
            return String(format: "%02d:%02d", minute, second)
        }
        
        return String(format: "%02d:%02d:%02d", hour, minute, second)
    }
}
