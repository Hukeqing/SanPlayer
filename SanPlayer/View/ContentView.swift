import SwiftUI
import AVKit

struct ContentView: View {
    
    let recordManager = RecordManager()

    @State var recordList: [HistoryRecord] = []
    @State var selectRecord: HistoryRecord?
    @State var lastSelectRecord: HistoryRecord?
    @State var curAVPlayer: AVPlayer = AVPlayer()
    @State var urlIndex: [URL: HistoryRecord] = [:]

    @State var missingVideo: Bool = false

    var body: some View {
        NavigationSplitView {
            List(recordList, selection: $selectRecord) {
                HistoryView(record: $0)
            }.onAppear {
                self.recordList = recordManager.read()
                urlIndex = Dictionary.init(self.recordList.map{($0.url, $0)}) {$1}
            }.onChange(of: selectRecord) { newValue in
                curAVPlayer.pause()
                saveRecord()
                lastSelectRecord = newValue
                if newValue == nil {
                    return
                }
                let newPlayerItem = newValue!.getPlayerItem
                if newPlayerItem == nil {
                    missingVideo = true
                    return
                }
                curAVPlayer.replaceCurrentItem(with: newPlayerItem)
            }.onDisappear {
                saveRecord()
            }.alert("Sorry, This video is missing...", isPresented: $missingVideo) {
                Button {
                    let index = recordList.firstIndex {$0.url == lastSelectRecord?.url}
                    if index != nil {
                        deleteRecord(index: index!)
                    }
                    lastSelectRecord = nil
                } label: {
                    Text("delete from history")
                }
            }
        } detail: {
            if selectRecord != nil {
                VideoPlayer(player: curAVPlayer)
            } else {
                Text("Select file...")
            }
        }.toolbar {
            Button {
                addNewVideo()
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

    func addNewVideo() {
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
            if let sameFile = urlIndex[newFile] {
                selectRecord = sameFile
                saveRecord()
                return
            }
            
            let newRecord = HistoryRecord(name: newFile.lastPathComponent, url: newFile)
            recordList.append(newRecord)
            recordManager.save(recordList: recordList)
            urlIndex[newRecord.url] = newRecord
            Task {
                await newRecord.initTitleImage(titleImageUrl: recordManager.createImageUrl())
                recordManager.save(recordList: recordList)
            }
        }
    }
    
    func deleteRecord(index: Int) {
        let removedRecord = recordList.remove(at: index)
        urlIndex.removeValue(forKey: removedRecord.url)
        recordManager.save(recordList: recordList)
    }
}
