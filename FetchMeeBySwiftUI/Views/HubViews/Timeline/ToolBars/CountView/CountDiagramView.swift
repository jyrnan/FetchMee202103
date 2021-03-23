//
//  CountDiagramView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/11/16.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import CoreData

struct CountDiagramView: View {
    
    var type: CountDiagramView.CountDiagramType
    var counts: [Int]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            HStack{
                Text(type.rawValue).font(.caption).foregroundColor(.white).padding(0)
            Spacer()
                Text("Max: \(counts.max() ?? 100)").font(.caption).foregroundColor(.init(UIColor.darkGray)).padding(0)
            }
            HStack(spacing: 0) {
                ForEach(counts, id: \.self) {count in
                    //如果当日熟知为零，则设置成1，
                    //以保证当日柱状图有一点高度
                    CountDiagramRectangle(count: count == 0 ? 1 : count,
                        maxCount: counts.max() ?? 100,
                        number: count,
                        colors: type.colors).padding(0)
                }
                
            }
        }
        
        
    }
}


struct CountDiagramRectangle: View {
    var count: Int = Int(arc4random_uniform(100))
    var maxCount: Int = 100
    var number: Int
    
    var colors:[Color] = [.red, .orange]
    
    var fill: LinearGradient { LinearGradient(gradient: Gradient(colors: colors), startPoint: .center , endPoint: .bottom)}
    
    var body: some View {
        GeometryReader {proxy in
            ZStack {
                Rectangle()
                    .fill(fill)
                    .frame(width: proxy.size.width / 1.5, height: proxy.size.height * CGFloat( count ) / CGFloat(maxCount), alignment: .center)
                    .frame(width: proxy.size.width, height: proxy.size.height, alignment: .bottom)
                Rectangle()
                    .foregroundColor(.gray)
                    .frame(width: number.isMultiple(of: 7) ? 1 : 0.5,
                           height: proxy.size.height, alignment: .center)
                    .frame(width: proxy.size.width, height: proxy.size.height, alignment: .trailing)
                
                
            }.padding(0)
        }
    
    }
}


struct CountDiagramView_Previews: PreviewProvider {
    static var previews: some View {
        CountDiagramView(type: .follower, counts: []).frame(height: 76)
    }
}

extension CountDiagramView {
    enum CountDiagramType: String {
        case follower = "New Followers"
        case tweet = "New Tweets"
        
        var colors: [Color] {
            switch self {
            case .follower:
                return [.red, .orange]
            case .tweet:
                return [.green, .white]
            }
        }
    }
    
}
