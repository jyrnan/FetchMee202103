//
//  DetailInfoView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/12/9.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Swifter

struct DetailInfoView: View {
    let status: JSON
    
    var created_at:String {updateTime(createdTime: status["created_at"].string)}
    let source: String = "Twitter for iPhone"
    
    let retweet_count: String = "34"
    let favorite_count: String = "345"
    
    init(status: JSON) {
        self.status = status
    }
    
    var body: some View {
        GeometryReader {proxy in
            
            VStack{
                Divider().padding(0)
                HStack{
                    Text(created_at)
                    Text("source").foregroundColor(.blue)
                    Spacer()
                }
                Divider().padding(0)
                HStack{
                    HStack{
                        Text("Retweeted: ") + Text("44")
                        Spacer()
                    }.frame(width: proxy.size.width / 2)
                    
                    Divider().padding(0)
                    HStack{
                        Text("Favorited: ") + Text("favorite_count")
                        Spacer()
                    }
                }
                Divider().padding(0)
            }
            .frame(height: 60)
            .font(.callout)
        }
    }
    
    func updateTime(createdTime: String?) -> String {
        guard createdTime != nil else {
            return "N/A"
        }
        var result : String = "N/A"
        let timeString = createdTime!
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        if let date = timeFormat.date(from: timeString) {
            let df = DateFormatter()
            df.dateStyle = .short
            df.timeStyle = .none
            
            result = "· " + df.string(from: date)
            
        }
        return result
    }
    
}

struct DetailInfoView_Previews: PreviewProvider {
    static var previews: some View {
        DetailInfoView(status: JSON.init(""))
    }
}
