import SwiftUI

struct HistoryView: View {
    
    @ObservedObject var record: HistoryRecord
    var titleImage: Image = Image(systemName: "film")
    
    var body: some View {
        HStack {
            titleImage
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
            VStack (alignment: .leading) {
                Text(record.name)
                Text(String(format: "%@/%@", record.getCurrentTime(), record.getTotalTime()))
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
    }

    init(record: HistoryRecord) {
        self.record = record
        if record.titleImageUrl == nil {
            return
        }
        
        if let data = try? Data(contentsOf: record.titleImageUrl!) {
            let nsImage = NSImage(data: data)
            if nsImage != nil {
                titleImage = Image(nsImage: nsImage!)
            }
        }
    }
}
