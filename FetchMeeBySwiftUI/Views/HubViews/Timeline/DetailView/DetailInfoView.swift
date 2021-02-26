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
    var source: String {String((status["source"].string?.split(separator: ">").last?.dropLast(3)) ?? "unknow")}
    
    var retweet_count: String {String(status["retweet_count"].integer ?? 0)}
    var favorite_count: String {String(status["favorite_count"].integer ?? 0)}
    
    init(status: JSON) {
        self.status = status
    }
    
    var body: some View {
        GeometryReader {proxy in
           
            VStack{
               
                HStack{
                    Text(created_at)
                    Text(source).foregroundColor(.accentColor)
                    Spacer()
                }
                
                Divider().padding(0)
                
                HStack{
                    HStack{
                        Text("Retweeted : ") + Text(retweet_count)
                        Spacer()
                    }.frame(width: proxy.size.width / 2)
                    
                    Divider().padding(0)
                   
                    HStack{
                        Text("Favorited : ") + Text(favorite_count)
                        Spacer()
                    }
                }
//               Spacer()
            }
            .padding(.top, 16)
            .font(.callout)
            .foregroundColor(.gray)
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
            df.timeStyle = .short
            
            result = df.string(from: date)  + " · "
            
        }
        return result
    }
    
}

struct DetailInfoView_Previews: PreviewProvider {
    static var previews: some View {
        DetailInfoView(status: JSON.init(""))
    }
}
