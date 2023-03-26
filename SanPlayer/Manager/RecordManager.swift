import Foundation

struct RecordManager {
    
    static let recordFileName = "record.json"

    let recordFileURL: URL?
    let cacheURL: URL?

    init() {
        let fileManager = FileManager.default
        let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        self.cacheURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
        self.recordFileURL = appSupportURL?.appendingPathComponent(RecordManager.recordFileName)
    }

    public func save(recordList: [HistoryRecord]) -> Void {
        if let url = recordFileURL {
            let jsonValue = try! JSONEncoder().encode(recordList)
            try! jsonValue.write(to: url)
        }
    }

    func read() ->  [HistoryRecord] {
        if recordFileURL != nil, let data = try? Data(contentsOf: recordFileURL!), let objectValue = try? JSONDecoder().decode([HistoryRecord].self, from: data) {
            return objectValue
        }

        return []
    }
    
    func createImageUrl() -> URL? {
        return cacheURL?.appendingPathComponent(UUID().uuidString).appendingPathExtension("png") ?? nil
    }
}
