//
//  UserViewModel.swift
//  FetchMee
//
//  Created by jyrnan on 2020/12/6.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import UIKit
import Swifter

class UserViewModel: ObservableObject {
    var user: JSON
//    var userTimelineView: TimelineView?
    
    @Published var avataImage: UIImage!
    
    init(user: JSON) {
        self.user = user
        print(#line, #function, #file)
        
        let avatarUrlString = user["profile_image_url_https"].string
            getImage(avatarUrlString)
        
    }
    
    
    
    func makeAvatarImageView() -> ImageThumb {
        let avatarUrlString = user["profile_image_url_https"].string!
        print(#line, #function, avatarUrlString)
        return ImageThumb(imageUrl: avatarUrlString, width: 80, height: 80)
    }
    
    fileprivate func getImage(_ avatarUrlString: String?) {
        if var url = avatarUrlString {
            url = url.replacingOccurrences(of: "_normal", with: "")
        RemoteImageFromUrl.imageDownloaderWithClosure(imageUrl: url, sh: {image in
            DispatchQueue.main.async {
                self.avataImage = image
            }
        })
    }
    }
    
//    func makeUserTimelineView() -> Timelineview {
//        return TimelineView()
//    }
}
