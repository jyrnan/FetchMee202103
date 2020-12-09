//
//  ImageGrabView.swift
//  FetchMee
//
//  Created by yoeking on 2020/8/29.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI

//struct ImageGrabView: View {
//    @EnvironmentObject var alerts: Alerts
//    @EnvironmentObject var fetchMee: User //始终是登录用户的信息
//    @EnvironmentObject var downloader: Downloader
//    
//    var userIDString: String? //传入需查看的用户信息的ID
//    var userScreenName: String? //传入需查看的用户信息的Name
//    
////    @StateObject var checkingUser: AppData = AppData()
//    @ObservedObject var userTimeline: Timeline
//    
//    @State var isShowActionSheet: Bool = false
//   
////    @State var isSelectMode: Bool = true
//    @State var selectCount: Int = 0
//    @State var willSavedImageCount: Int = 0
//    @State var imageScale: CGFloat = 1 //图片放大倍数
//    @State var presentedImageViewer: Bool = false
//    @State var imageToBeView: UIImage = UIImage(systemName: "photo")! //用来传递图片到ImageViewer
//    
//    let columns = [GridItem(.adaptive(minimum: 100, maximum: 140),spacing: 2)]
//    
//    //计算属性用来获取带有图片的推文ID集合，但是不知道这个优化是否有用
//    var tweetWithImageIDStrings: [String]{
//        userTimeline.tweetIDStrings.filter{
//            userTimeline.tweetMedias[$0]?.images.count != 0
//        }
//    }
//    
//    init(userIDString: String? = nil, userScreenName: String? = nil, timeline: Timeline) {
//        self.userIDString = userIDString
//        self.userScreenName = userScreenName
//        self.userTimeline = timeline
//    }
//    
//    var body: some View {
//        ZStack{
//            ScrollView {
//                LazyVGrid(columns: columns,spacing: 2) {
//                   
//                    ForEach(tweetWithImageIDStrings, id: \.self) {tweetIDString in
//                        ForEach(0..<(userTimeline.tweetMedias[tweetIDString]?.images.count ?? 0) ) {index in
//                            ImageRectGrid(timeline: userTimeline, tweetIDString: tweetIDString, index: index)
//                                .aspectRatio(1, contentMode: .fill)
//                                .contextMenu(menuItems: /*@START_MENU_TOKEN@*/{
//                                    Button(action: {self.downloadAndSaveToPhoto(tweetIDString: tweetIDString, index: index)}, label: {
//                                        Text("Save To Photo")
//                                        Image(systemName: "folder")})
//                                    Button(action: {showImageViewer(tweetIDString: tweetIDString, index: index)}, label: {
//                                        Text("Show Detail")
//                                        Image(systemName: "folder")})
//                                }/*@END_MENU_TOKEN@*/)
//                                .id(UUID())
//                        }
//                    }
//                    Rectangle()
//                        .aspectRatio(1, contentMode: .fill)
//                        .foregroundColor(.clear)
//                        .overlay( HStack {
//                            Spacer()
//                            Button("More ...") {
//                                userTimeline.refreshFromBottom(for: userIDString)}
//                                .font(.caption)
//                                .foregroundColor(.gray)
//                            Spacer()
//                        } //下方载入更多按钮
//                        )
//                        .clipped()
//                
//                }
//            }
//           
//            VStack {
//
//                Spacer()
//                HStack{
//                    Spacer()
//                    Text("\(userTimeline.selectedImageCount) selected, " + "\(max((self.willSavedImageCount - userTimeline.selectedImageCount), 0)) saved!")
//                        .font(.caption).foregroundColor(.white).padding()
//                    //                    }
//                    Spacer()
//                }.background(LinearGradient(gradient: Gradient(colors: [Color.black, Color.clear]), startPoint: UnitPoint(x: 0, y: 1), endPoint: UnitPoint(x: 0, y: 0)).opacity(0.5))
//                
//            }.ignoresSafeArea()
//        }
////        .ignoresSafeArea()
//        .navigationTitle("@\(userScreenName ?? "userName")")
//        .navigationBarItems( trailing: Button(action: {self.selectAll()}, label: {
//            Text("Select & Save").font(.callout)
//                .navigationBarTitleDisplayMode(.inline)
//
//        })
//        .contextMenu(menuItems: /*@START_MENU_TOKEN@*/{
//            
//            Button(action: {self.selectAll()}, label: {
//                Text("Select All")
//                Image(systemName: "checkmark.square")
//            })
//            Button(action: {self.deSelectAll()}, label: {
//                Text("Unselect All")
//                Image(systemName: "square")
//            })
//            
//            Button(action: {self.saveSelected()}, label: {
//                Text("Save Seleted")
//                Image(systemName: "folder")
//            })
//        }/*@END_MENU_TOKEN@*/))
//        .onAppear{
//        }
//    }
//}
//
//extension ImageGrabView {
//    func selectToggle(tweetIDString: String, index: Int) {
//        if userTimeline.tweetMedias[tweetIDString]!.imagesSelected[index] == false {
//            userTimeline.tweetMedias[tweetIDString]!.imagesSelected[index] = true
//            userTimeline.selectedImageCount += 1
//        } else {
//            userTimeline.tweetMedias[tweetIDString]!.imagesSelected[index] = false
//            userTimeline.selectedImageCount -= 1
//        }
//    }
//    
//    func selectImage(tweetIDString: String, index: Int) {
//        if userTimeline.tweetMedias[tweetIDString]!.imagesSelected[index] == false {
//            userTimeline.tweetMedias[tweetIDString]!.imagesSelected[index] = true
//            userTimeline.selectedImageCount += 1
//        }
//    }
//    
//    func unSelectImage(tweetIDString: String, index: Int) {
//        if userTimeline.tweetMedias[tweetIDString]!.imagesSelected[index] == true {
//            userTimeline.tweetMedias[tweetIDString]!.imagesSelected[index] = false
//            userTimeline.selectedImageCount -= 1
//        }
//    }
//    
//    func selectAll() {
//        for idString in userTimeline.tweetIDStrings {
//            if !(userTimeline.tweetMedias[idString]?.imagesSelected.isEmpty)! {
//                for index in 0..<(userTimeline.tweetMedias[idString]?.imagesSelected.count)! {
//                    self.selectImage(tweetIDString: idString, index: index)
//                }
//            }
//        }
//    }
//    
//    func deSelectAll() {
//        for idString in userTimeline.tweetIDStrings {
//            if !(userTimeline.tweetMedias[idString]?.imagesSelected.isEmpty)! {
//                for index in 0..<(userTimeline.tweetMedias[idString]?.imagesSelected.count)! {
//                    self.unSelectImage(tweetIDString: idString, index: index)
//                }
//            }
//        }
//    }
//    
//    func saveSelected() {
//        self.willSavedImageCount = userTimeline.selectedImageCount
//        for idString in userTimeline.tweetIDStrings {
//            if !(userTimeline.tweetMedias[idString]?.imagesSelected.isEmpty)! {
//                for index in 0..<(userTimeline.tweetMedias[idString]?.imagesSelected.count)! {
//                    if userTimeline.tweetMedias[idString]?.imagesSelected[index] == true {
//                        self.downloadAndSaveToPhoto(tweetIDString: idString, index: index)
//                    }
//                }
//            }
//        }
//    }
//    
//    func downloadAndSaveToPhoto(tweetIDString: String, index: Int) -> Void {
//        if let urlString = userTimeline.tweetMedias[tweetIDString]?.urlStrings![index] {
//           
//            downloader.taskCount += 1 //下载任务数量加1
//            downloader.download(url: URL(string: urlString + ":large")!, completionHandler: {
//                URL in
//                if let data = try? Data(contentsOf: URL), let image = UIImage(data: data) {
//                    self.saveToPhoto(image: image)
//                    downloader.taskCount -= 1
//                }
//            })
//        }
//    }
//    
//    func saveToPhoto(image: UIImage) {
//        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//    }
//    
//    func showImageViewer(tweetIDString: String, index: Int) {
//        
//        if let urlString = userTimeline.tweetMedias[tweetIDString]?.urlStrings![index] {
//            userTimeline.imageDownloaderWithClosure(from: urlString + ":large", sh: { im in
////                self.imageToBeView = im
////                self.presentedImageViewer = true
//                DispatchQueue.main.async {
//                    
//                    let imageViewer = ImageViewer(image: im)
//                    alerts.presentedView = AnyView(imageViewer)
//                    withAnimation{alerts.isShowingPicture = true}                                }
//            })
//        }
//    }
//}
//struct ImageGrabView_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageGrabView(timeline: Timeline(type: .user))
//    }
//}
//
//struct ImageRectGrid: View {
//    @ObservedObject var timeline: Timeline
//    var tweetIDString: String = "0000"
//    var index: Int = 0
//  
//    var uiImage: UIImage {timeline.tweetMedias[tweetIDString]?.images[index] ?? UIImage(named: "defaultImage")!}
//    
//    var body: some View {
//        GeometryReader {geometry in
//            Rectangle()
//                .aspectRatio(1, contentMode: .fill)
//                .foregroundColor(.clear)
//                .overlay(
//                    Image(uiImage: uiImage)
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .frame(width: geometry.size.width
//                               , height: geometry.size.height, alignment: .center)
//                        .clipped()
//                        .contentShape(Rectangle()))
//                
//                
//                .overlay(Image(systemName:
//                                (timeline.tweetMedias[tweetIDString]?.imagesSelected[index]) ?? false ? "checkmark.square.fill" : "square")
//                            .offset(x: 50, y: 50)
//                            .foregroundColor((timeline.tweetMedias[tweetIDString]?.imagesSelected[index]) ?? false ? Color.accentColor : Color.clear)
//                )
////
//                .onTapGesture{
//                    if timeline.tweetMedias[self.tweetIDString]?.imagesSelected[index] == false {
//                        timeline.tweetMedias[self.tweetIDString]?.imagesSelected[index].toggle()
//                        timeline.selectedImageCount += 1
//                    } else {
//                        timeline.tweetMedias[self.tweetIDString]?.imagesSelected[index].toggle()
//                        timeline.selectedImageCount -= 1
//                    }
//                }
//                .clipped()
//        }
//    }
//}