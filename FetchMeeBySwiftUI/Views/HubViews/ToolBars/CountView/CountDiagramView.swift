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
    var userInfo: UserInfo
    var viewContext: NSManagedObjectContext
    
    @State var countValue: CountValue
    
    init(userInfo: UserInfo, context: NSManagedObjectContext) {
        self.userInfo = userInfo
        self.viewContext = context
        _countValue = State(wrappedValue: Count.updateCount(for: userInfo, in: viewContext))
    }
   
    var body: some View {
        HStack{
//        Text("hello\(countValue.followerOfLastDay)")
//            Text("hello\(countValue.followerOfLastThreeDays)")
//            Text("hello\(countValue.followerOfLastSevenDays)")
//            Text("hello\(countValue.tweetsOfLastDay)")
//                Text("hello\(countValue.tweetsOfLastThreeDays)")
//                Text("hello\(countValue.tweetsOfLastSevenDays)")
            subCountDiagramView(lastDay: countValue.followerOfLastDay, lastThreeDays: countValue.followerOfLastThreeDays, lastSevenDays: countValue.followerOfLastSevenDays)
            Divider()
            subCountDiagramView(lastDay: countValue.tweetsOfLastDay, lastThreeDays: countValue.tweetsOfLastThreeDays, lastSevenDays: countValue.tweetsOfLastSevenDays)
        }
    }
}

struct subCountDiagramView: View {
    var lastDay: Int
    var lastThreeDays: Int
    var lastSevenDays: Int
    
    var roomForText: CGFloat = 30 //给字体留下的空间
    
    var maxCount: Int {
        get {
            max(lastDay, lastThreeDays, lastSevenDays)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom) {
                Spacer()
                
                countDiagramRectangle(days: 7, count: lastSevenDays, height: (geometry.size.height - roomForText) * CGFloat(lastSevenDays) /  CGFloat(maxCount))
                    
                Spacer()
                
                countDiagramRectangle(days: 3, count: lastThreeDays, height: (geometry.size.height - roomForText) * CGFloat(lastThreeDays) /  CGFloat(maxCount))
                    
                Spacer()
                
                countDiagramRectangle(days: 1, count: lastDay, height: (geometry.size.height - roomForText) * CGFloat(lastDay) /  CGFloat(maxCount))
                 
                Spacer()
            }
            
        }
    }
}

struct countDiagramRectangle: View {
    var days: Int = 1
    var count: Int = 0
    var maxCount: Int = 1
    var height: CGFloat = 0
    
    let fill = LinearGradient(gradient: Gradient(colors: [Color.white, .red]), startPoint: .center , endPoint: .bottom)
    
    var body: some View {
        ZStack{
        VStack{
            
            Spacer()
            Rectangle().background(fill)
                .frame(width: 35, height: height)
                
                .opacity(0.3)
                .padding(0)
                .shadow(radius: 3 )
            Text(days != 1 ? "\(days)Days" : "Today").font(.caption2).bold().foregroundColor(.white)
        }
            Text("\(count)").font(.caption2).bold()
                .foregroundColor(.white).padding(0).shadow(radius: 1)
        }
    }
}

struct subCountDiagramView_Previews: PreviewProvider {
    static var previews: some View {
        subCountDiagramView(lastDay: 10, lastThreeDays: 20, lastSevenDays: 30).background(Color.blue).frame(height: 100).padding()
    }
}
