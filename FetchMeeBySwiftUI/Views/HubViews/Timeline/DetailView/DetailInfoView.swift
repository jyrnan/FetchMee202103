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
    let status: Status

    var body: some View {
        GeometryReader {proxy in
           
            VStack{
               
                HStack{
                    Text(updateTime(createdTime: status.createdAt))
                    Text(String((status.source.split(separator: ">").last?.dropLast(3)) ?? "unknow"))
                        .foregroundColor(.accentColor)
                    Spacer()
                }
                
                Divider().padding(0)
                
                HStack{
                    HStack{
                        Text("Retweeted : \(status.retweet_count)")
                        Spacer()
                    }.frame(width: proxy.size.width / 2)
                    
                    Divider().padding(0).frame(maxHeight: 12)
                   
                    HStack{
                        Text("Favorited : \(status.favorite_count)")
                        Spacer()
                    }
                }
            }
            .padding(.top, 16)
            .font(.callout)
            .foregroundColor(.gray)
        }
    }
    
    func updateTime(createdTime: Date?) -> String {
        guard createdTime != nil else {
            return "N/A"
        }
        
            let df = DateFormatter()
            df.dateStyle = .short
            df.timeStyle = .short
            
            let result = df.string(from: createdTime!)  + " · "
        return result
    }
    
}

struct DetailInfoView_Previews: PreviewProvider {
    static var previews: some View {
        DetailInfoView(status: Status())
    }
}
