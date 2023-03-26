import SwiftUI
import AVKit

struct ContentView: View {
    
    let recordManager = RecordManager()

    @State var recordList: [HistoryRecord] = []
    @State var selectRecord: HistoryRecord?
    @State var lastSelectRecord: HistoryRecord?
    @State var curAVPlayer: AVPlayer = AVPlayer()

    var body: some View {
        NavigationSplitView {
            List(recordList, selection: $selectRecord) {
                HistoryView(record: $0)
            }.onAppear {
                self.recordList = recordManager.read()
            }.onChange(of: selectRecord) { newValue in
                saveRecord()
                lastSelectRecord = newValue
                if newValue != nil {
                    curAVPlayer.replaceCurrentItem(with: newValue!.getPlayerItem)
                    curAVPlayer.pause()
                }
            }.onDisappear {
                saveRecord()
            }
        } detail: {
            if selectRecord != nil {
                VideoPlayer(player: curAVPlayer)
            } else {
                Text("Select file...")
            }
        }.toolbar {
            Button {
                let open = NSOpenPanel()
                open.allowsMultipleSelection = false
                open.canChooseFiles = true
                open.canChooseDirectories = false
                open.allowedContentTypes = [
                    .mpeg4Movie,
                    .avi,
                    .mpeg2Video,
                    .video,
                    .movie,
                    .quickTimeMovie
                ]
                open.runModal()
                if let newFile = open.url {
                    let newRecord = HistoryRecord(name: newFile.lastPathComponent, url: newFile)
                    recordList.append(newRecord)
                    recordManager.save(recordList: recordList)
                    Task {
                        await newRecord.initTitleImage(titleImageUrl: recordManager.createImageUrl())
                        recordManager.save(recordList: recordList)
                    }
                }
            } label: {
                Image(systemName: "plus")
            }
        }
    }
    
    func saveRecord() {
        if lastSelectRecord != nil, curAVPlayer.currentItem != nil {
            let item = curAVPlayer.currentItem!
            let currentTime = item.currentTime()
            let durationTime = item.duration
            lastSelectRecord!.totalTimeSecond = Int(durationTime.seconds)
            lastSelectRecord!.currentTimeSecond =  Int(currentTime.seconds)
            recordManager.save(recordList: recordList)
        }
    }
}
