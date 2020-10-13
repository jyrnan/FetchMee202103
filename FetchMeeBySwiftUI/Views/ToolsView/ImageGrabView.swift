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
    @EnvironmentObject var downloader: Downloader
    
    var userIDString: String? //传入需查看的用户信息的ID
    var userScreenName: String? //传入需查看的用户信息的Name
    
    @StateObject var checkingUser: User = User()
    @StateObject var timeline: Timeline = Timeline(type: .user)
    
    @State var isShowActionSheet: Bool = false
    //    @State var presentedImageViewer: Bool = false //是否显示大图浏览
    @State var isSelectMode: Bool = true
    @State var selectCount: Int = 0
    @State var willSavedImageCount: Int = 0
    @State var imageScale: CGFloat = 1 //图片放大倍数
    @State var presentedImageViewer: Bool = false
    @State var imageToBeView: UIImage = UIImage(systemName: "photo")! //用来传递图片到ImageViewer
    
    let columns = [GridItem(.adaptive(minimum: 100, maximum: 140),spacing: 2)]
    
    //计算属性用来获取带有图片的推文ID集合，但是不知道这个优化是否有用
    var tweetWithImageIDStrings: [String]{
        timeline.tweetIDStrings.filter{
            timeline.tweetMedias[$0]?.images.count != 0
        }
    }
    var body: some View {
        ZStack{
            ScrollView {
                LazyVGrid(columns: columns,spacing: 2) {
                   
                    ForEach(tweetWithImageIDStrings, id: \.self) {tweetIDString in
                        ForEach(0..<(timeline.tweetMedias[tweetIDString]?.images.count ?? 0) ) {index in
                            ImageRectGrid(timeline: timeline, tweetIDString: tweetIDString, index: index)
                                .aspectRatio(1, contentMode: .fill)
                                .contextMenu(menuItems: /*@START_MENU_TOKEN@*/{
                                    Button(action: {self.downloadAndSaveToPhoto(tweetIDString: tweetIDString, index: index)}, label: {
                                        Text("Save To Photo")
                                        Image(systemName: "folder")})
                                    Button(action: {showImageViewer(tweetIDString: tweetIDString, index: index)}, label: {
                                        Text("Show Detail")
                                        Image(systemName: "folder")})
                                }/*@END_MENU_TOKEN@*/)
                                .id(UUID())
                        }
                    }
                    Rectangle()
                        .aspectRatio(1, contentMode: .fill)
                        .foregroundColor(.clear)
                        .overlay( HStack {
                            Spacer()
                            Button("More ...") {
                                self.timeline.refreshFromButtom(for: userIDString)}
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                        } //下方载入更多按钮
                        )
                        .clipped()
                
                }
            }
            .fullScreenCover(isPresented: self.$presentedImageViewer) {
                ImageViewer(image: imageToBeView,
                            presentedImageViewer: $presentedImageViewer)
            }
            VStack {
                HStack{
                    Text("@\(self.userScreenName ?? "UserName")").foregroundColor(.white).font(.title2).bold().padding().shadow(radius: 3)
                    
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
                            Text("Unselect All")
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
                    Text("\(self.timeline.selectedImageCount) selected, " + "\(max((self.willSavedImageCount - self.timeline.selectedImageCount), 0)) saved!")
                        .font(.caption).foregroundColor(.white).padding()
                    //                    }
                    Spacer()
                }.background(LinearGradient(gradient: Gradient(colors: [Color.black, Color.clear]), startPoint: UnitPoint(x: 0, y: 1), endPoint: UnitPoint(x: 0, y: 0)).opacity(0.5))
                
            }
        }
        .ignoresSafeArea()
        .onAppear{
            self.timeline.refreshFromTop(for: userIDString)
        }
        
    }
}

extension ImageGrabView {
    func selectToggle(tweetIDString: String, index: Int) {
        if self.timeline.tweetMedias[tweetIDString]!.imagesSelected[index] == false {
            self.timeline.tweetMedias[tweetIDString]!.imagesSelected[index] = true
            self.timeline.selectedImageCount += 1
        } else {
            self.timeline.tweetMedias[tweetIDString]!.imagesSelected[index] = false
            self.timeline.selectedImageCount -= 1
        }
    }
    
    func selectImage(tweetIDString: String, index: Int) {
        if self.timeline.tweetMedias[tweetIDString]!.imagesSelected[index] == false {
            self.timeline.tweetMedias[tweetIDString]!.imagesSelected[index] = true
            self.timeline.selectedImageCount += 1
        }
    }
    
    func unSelectImage(tweetIDString: String, index: Int) {
        if self.timeline.tweetMedias[tweetIDString]!.imagesSelected[index] == true {
            self.timeline.tweetMedias[tweetIDString]!.imagesSelected[index] = false
            self.timeline.selectedImageCount -= 1
        }
    }
    
    func selectAll() {
        for idString in self.timeline.tweetIDStrings {
            if !(self.timeline.tweetMedias[idString]?.imagesSelected.isEmpty)! {
                for index in 0..<(self.timeline.tweetMedias[idString]?.imagesSelected.count)! {
                    self.selectImage(tweetIDString: idString, index: index)
                }
            }
        }
    }
    
    func deSelectAll() {
        for idString in self.timeline.tweetIDStrings {
            if !(self.timeline.tweetMedias[idString]?.imagesSelected.isEmpty)! {
                for index in 0..<(self.timeline.tweetMedias[idString]?.imagesSelected.count)! {
                    self.unSelectImage(tweetIDString: idString, index: index)
                }
            }
        }
    }
    
    func saveSelected() {
        self.willSavedImageCount = self.timeline.selectedImageCount
        for idString in self.timeline.tweetIDStrings {
            if !(self.timeline.tweetMedias[idString]?.imagesSelected.isEmpty)! {
                for index in 0..<(self.timeline.tweetMedias[idString]?.imagesSelected.count)! {
                    if self.timeline.tweetMedias[idString]?.imagesSelected[index] == true {
                        self.downloadAndSaveToPhoto(tweetIDString: idString, index: index)
                    }
                }
            }
        }
    }
    
    func downloadAndSaveToPhoto(tweetIDString: String, index: Int) -> Void {
        if let urlString = self.timeline.tweetMedias[tweetIDString]?.urlStrings![index] {
            //            self.isImageDownloaded = false
//            self.timeline.imageDownloaderWithClosure(from: urlString + ":large", sh: { im in
//                self.saveToPhoto(image: im)
//                self.unSelectImage(tweetIDString: tweetIDString, index: index)
//            })
            downloader.taskCount += 1 //下载任务数量加1
            downloader.download(url: URL(string: urlString + ":large")!, completionHandler: {
                URL in
                if let data = try? Data(contentsOf: URL), let image = UIImage(data: data) {
                    self.saveToPhoto(image: image)
                    downloader.taskCount -= 1
                }
            })
        }
    }
    
    func saveToPhoto(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    func showImageViewer(tweetIDString: String, index: Int) {
        
        if let urlString = timeline.tweetMedias[tweetIDString]?.urlStrings![index] {
            timeline.imageDownloaderWithClosure(from: urlString + ":large", sh: { im in
                self.imageToBeView = im
                self.presentedImageViewer = true
            })
        }
    }
}
struct ImageGrabView_Previews: PreviewProvider {
    static var previews: some View {
        ImageGrabView()
    }
}

struct ImageRectGrid: View {
    @ObservedObject var timeline: Timeline
    var tweetIDString: String = "0000"
    var index: Int = 0
  
    var uiImage: UIImage {self.timeline.tweetMedias[tweetIDString]?.images[index] ?? UIImage(named: "defaultImage")!}
    
    var body: some View {
        GeometryReader {geometry in
            Rectangle()
                .aspectRatio(1, contentMode: .fill)
                .foregroundColor(.clear)
                .overlay(
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width
                               , height: geometry.size.height, alignment: .center)
                        .clipped()
                        .contentShape(Rectangle()))
                
                
                .overlay(Image(systemName:
                                (timeline.tweetMedias[tweetIDString]?.imagesSelected[index]) ?? false ? "checkmark.square.fill" : "square")
                            .offset(x: 50, y: 50)
                            .foregroundColor((timeline.tweetMedias[tweetIDString]?.imagesSelected[index]) ?? false ? Color.accentColor : Color.clear)
                )
//
                .onTapGesture{
                    if self.timeline.tweetMedias[self.tweetIDString]?.imagesSelected[index] == false {
                        self.timeline.tweetMedias[self.tweetIDString]?.imagesSelected[index].toggle()
                        self.timeline.selectedImageCount += 1
                    } else {
                        self.timeline.tweetMedias[self.tweetIDString]?.imagesSelected[index].toggle()
                        self.timeline.selectedImageCount -= 1
                    }
                }
                .clipped()
        }
    }
}