//
//  PlayButtonViewModel.swift
//  FetchMee
//
//  Created by jyrnan on 2020/11/29.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import Foundation

class PlayButtonViewModel: ObservableObject {
    var timeline: Timeline
    var mediaUrlString: String?
    var contextMenuButtons: [ButtonInfo] = []
    
    init(timeline: Timeline, url: String?) {
        self.timeline = timeline
        self.mediaUrlString = url
        
        makeContextMenuButton()
    }
    
    func downloadVideo() -> Void {
        timeline.videoDownloader(from: mediaUrlString,
                                 sh: {print("Saved")},
                                 fh: {print("UnSaved")})
    }
    
    func makeContextMenuButton() {
        let buttonInfo = ButtonInfo(action: downloadVideo, labelText: "Save Video", labelImage: "folder")
        contextMenuButtons.append(buttonInfo)
    }
    
}

extension PlayButtonViewModel {
    struct ButtonInfo {
        let action: () -> ()
        let labelText: String
        let labelImage: String
    }
}
