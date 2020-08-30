//
//  ImageGrabView.swift
//  FetchMee
//
//  Created by yoeking on 2020/8/29.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

struct ImageGrabView: View {
    @EnvironmentObject var alerts: Alerts
    @EnvironmentObject var user: User //始终是登录用户的信息
    
    var userIDString: String? //传入需查看的用户信息的ID
    var userScreenName: String? //传入需查看的用户信息的Name
    
    @StateObject var checkingUser: User = User()
    @StateObject var userTimeline: Timeline = Timeline(type: .user)
    
    @State var isShowActionSheet: Bool = false
    @State var isSelectMode: Bool = true
    @State var selectCount: Int = 0
    @State var willSavedImageCount: Int = 0
    
    let columns = [GridItem(.adaptive(minimum: 100, maximum: 140),spacing: 2)]
    
    var body: some View {
        ZStack{
            ScrollView {
                LazyVGrid(columns: columns,spacing: 2) {
                    
                    ForEach(self.userTimeline.tweetIDStrings, id: \.self) {idString in
                        ForEach(0..<self.userTimeline.tweetMedias[idString]!.images.count) {index in
                                Rectangle()
                                    .aspectRatio(1, contentMode: .fill)
                                    .foregroundColor(.clear)
                                    .overlay(
                                        ImageThumb(timeline: self.userTimeline, tweetIDString: idString, number: index, isSelectMode: true , width: 140, height: 140))
                                    .onLongPressGesture{
                                        print(#line, "longPress")
                                    }
                                    .overlay(Image(systemName:
                                                    self.userTimeline.tweetMedias[idString]!.imagesSelected[index] ? "checkmark.square.fill" : "square")
                                                .offset(x: 50, y: 50)
                                                .foregroundColor(self.userTimeline.tweetMedias[idString]!.imagesSelected[index] ? Color.accentColor : Color.clear)
                                    )
                                    .clipped()
                                    .id(UUID())
                        }
                    }
                    Rectangle()
                        .aspectRatio(1, contentMode: .fill)
                        .foregroundColor(.clear)
                        .overlay( HStack {
                            Spacer()
                            Button("More ...") {
                                self.userTimeline.refreshFromButtom(for: userIDString)}
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                        } //下方载入更多按钮
                        )
                        .clipped()
                    
                }
            }
            VStack {
                HStack{
                    Text("\(self.userScreenName ?? "UserName")").foregroundColor(.white).font(.title2).bold().padding().shadow(radius: 3)
                    
                    Spacer()
                    Button(action: {self.selectAll()}, label: {
                        Text("Select & Save")
                            .bold()
                            .padding()
                    })
                    .contextMenu(menuItems: /*@START_MENU_TOKEN@*/{
                        
                        Button(action: {self.selectAll()}, label: {
                                Text("Select All")
                            Image(systemName: "checkmark.square")
                        })
                        Button(action: {self.deSelectAll()}, label: {
                                Text("Deselect All")
                            Image(systemName: "square")
                        })
                       
                        Button(action: {self.saveSelected()}, label: {
                            Text("Save Seleted")
                            Image(systemName: "folder")
                        })
                    }/*@END_MENU_TOKEN@*/)
                    
                }.background(LinearGradient(gradient: Gradient(colors: [Color.black, Color.clear]), startPoint: UnitPoint(x: 0, y: 0), endPoint: UnitPoint(x: 0, y: 1)).opacity(0.7))
                Spacer()
                HStack{
                    Spacer()
                    Text("\(self.userTimeline.selectedImageCount) selected, " + "\(max((self.willSavedImageCount - self.userTimeline.selectedImageCount), 0)) saved!")
                        .font(.caption).foregroundColor(.white).padding()
//                    }
                    Spacer()
                }.background(LinearGradient(gradient: Gradient(colors: [Color.black, Color.clear]), startPoint: UnitPoint(x: 0, y: 1), endPoint: UnitPoint(x: 0, y: 0)).opacity(0.5))
                
            }
        }
        .ignoresSafeArea()
        .onAppear{
            self.userTimeline.refreshFromTop(for: userIDString)
        }
        
    }
}

extension ImageGrabView {
    func selectImage(tweetIDString: String, index: Int) {
        if self.userTimeline.tweetMedias[tweetIDString]!.imagesSelected[index] == false {
            self.userTimeline.tweetMedias[tweetIDString]!.imagesSelected[index] = true
            self.userTimeline.selectedImageCount += 1
        }
    }
    
    func deSelectImage(tweetIDString: String, index: Int) {
        if self.userTimeline.tweetMedias[tweetIDString]!.imagesSelected[index] == true {
            self.userTimeline.tweetMedias[tweetIDString]!.imagesSelected[index] = false
            self.userTimeline.selectedImageCount -= 1
        }
    }
    
    func selectAll() {
        for idString in self.userTimeline.tweetIDStrings {
            if !(self.userTimeline.tweetMedias[idString]?.imagesSelected.isEmpty)! {
                for index in 0..<(self.userTimeline.tweetMedias[idString]?.imagesSelected.count)! {
                    self.selectImage(tweetIDString: idString, index: index)
                }
            }
        }
    }
    
    func deSelectAll() {
        for idString in self.userTimeline.tweetIDStrings {
            if !(self.userTimeline.tweetMedias[idString]?.imagesSelected.isEmpty)! {
                for index in 0..<(self.userTimeline.tweetMedias[idString]?.imagesSelected.count)! {
                    self.deSelectImage(tweetIDString: idString, index: index)
                }
            }
        }
    }
    
    func saveSelected() {
        self.willSavedImageCount = self.userTimeline.selectedImageCount
        for idString in self.userTimeline.tweetIDStrings {
            if !(self.userTimeline.tweetMedias[idString]?.imagesSelected.isEmpty)! {
                for index in 0..<(self.userTimeline.tweetMedias[idString]?.imagesSelected.count)! {
                    if self.userTimeline.tweetMedias[idString]?.imagesSelected[index] == true {
                        self.downloadAndSaveToPhoto(tweetIDString: idString, index: index)
                    }
                }
            }
        }
    }
    
    func downloadAndSaveToPhoto(tweetIDString: String, index: Int) -> Void {
        if let urlString = self.userTimeline.tweetMedias[tweetIDString]?.urlStrings![index] {
            //            self.isImageDownloaded = false
            self.userTimeline.imageDownloaderWithClosure(from: urlString + ":large", sh: { im in
                self.saveToPhoto(image: im)
                self.deSelectImage(tweetIDString: tweetIDString, index: index)
            })
        }
    }
    
    func saveToPhoto(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}
struct ImageGrabView_Previews: PreviewProvider {
    static var previews: some View {
        ImageGrabView()
    }
}
