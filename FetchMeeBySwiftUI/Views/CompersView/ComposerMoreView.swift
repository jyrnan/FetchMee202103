//
//  ComposerMoreView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/7/29.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Combine
import SwifteriOS
import UIKit

struct ComposerMoreView: View {
    @EnvironmentObject var user: User
    
    @Binding var isShowCMV: Bool 
    
    @State var tweetText: String = ""
    @State var imageDatas: [ImageData] = []
    
    @State var isShowPhotoPicker: Bool = false
    @State var isShowAddPic: Bool = true
    @State var isTweetSentDone: Bool = true
    
    @State var replyIDString : String?
    @State var mediaIDs: [String] = [] //存储上传媒体/图片返回的ID号
   
    var body: some View {
        NavigationView {
            if #available(iOS 14.0, *) {
                List{
                    
                    HStack(alignment: .top) {
                        Image(uiImage: (self.user.myInfo.avatar ?? UIImage(systemName: "person.circle.fill")!))
                            .resizable().frame(width: 32, height: 32, alignment: .center)
                            .clipShape(Circle()).padding(.top, 20)
                        
                        VStack(alignment: .leading) {
                            Spacer()
                                HStack {
                                    Text("Tweet something below...").font(.body)
                                        .foregroundColor(self.tweetText == "" ? .gray : .clear)
                                Spacer()
                                    Text(String(self.tweetText.count)).font(.body)
                                        .foregroundColor(self.tweetText == "" ? .clear : .accentColor)
                                }.padding(0)

                            Divider()
                            TextEditor(text: self.$tweetText).frame(height: 150)
                            Divider()
                            HStack {
                                ForEach(self.imageDatas, id: \.id) {
                                    imageData in
                                    Image(uiImage: (imageData.image ?? UIImage(systemName: "photo")!.alpha(0.2))) //用了对UIImage进行extention的代码
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 64, height: 64, alignment: .center).cornerRadius(16)
                                        .onTapGesture {
                                            //点击图片则删除该图片数据
                                            self.imageDatas.remove(at: self.imageDatas.firstIndex {imageData.id == $0.id} ?? 0)
                                            //删除图片后将增加图片的按钮显示出来
                                            self.isShowAddPic = true
                                        }
                                }
                                if self.isShowAddPic {
                                    Image(systemName: "plus.rectangle.fill.on.rectangle.fill")
                                        .resizable().aspectRatio(contentMode: .fill)
                                        .padding(20)
                                        .frame(width: 48, height: 64, alignment: .center)
                                        .foregroundColor(.accentColor)
                                        .onTapGesture {
                                            self.isShowPhotoPicker = true
                                            self.imageDatas.append(ImageData())
                                            
                                        }
                                        .sheet(isPresented: self.$isShowPhotoPicker, onDismiss: {
                                            if self.imageDatas.count == 4 { //选择图片视图消失后检查是否已经有四张选择，如果是则设置增加图片按钮不显示
                                                self.isShowAddPic = false
                                            }
                                            if self.imageDatas.last?.image == nil {
                                                self.imageDatas.removeLast() //如果选择图片的时候选择了取消，也就是最后一个图片数据依然是nil，则移除该数据
                                            }
                                        }) {
                                            PhotoPicker(imageData: self.$imageDatas[self.imageDatas.count - 1], isShowPhotoPicker: self.$isShowPhotoPicker)
                                        }
                                }
                                Spacer()
                            }.fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .navigationBarTitle("Tweet")
                    .navigationBarItems(trailing:
                                            HStack{
                                                Spacer()
                                                
                                                if self.isTweetSentDone {
                                                    Text("Send")
                                                        .foregroundColor(self.tweetText != "" || !self.imageDatas.isEmpty ? Color.accentColor : Color.gray)
                                                        .onTapGesture {
                                                            self.isTweetSentDone = false
                                                            self.postMedia()
                                                        }
                                                } else {
                                                    ActivityIndicator(isAnimating: self.$isTweetSentDone, style: .medium)
                                                }
                                            })
                }
                .listStyle(InsetGroupedListStyle())
                .onAppear() {
                    UITextView.appearance().backgroundColor = .clear // 让TextEditor的背景是透明色
                }
                
            } else {
                // Fallback on earlier versions
            }
        }
        
    }
}


struct ComposerMoreView_Previews: PreviewProvider {
    static var previews: some View {
        ComposerMoreView(isShowCMV: .constant(true), tweetText: "Text", replyIDString: nil)
    }
}

//MARK: - 发帖模块
extension ComposerMoreView {
    
    func postTweet() {
        //通用的推文发送函数，媒体文件数据在mdiaIDs里
        let text: String = self.tweetText
        
        let texts: [String] = splitToTexts(string: text) //分割长文
        multiPost(tweetTexts: texts)
    }
    
    /**
     这是发推的起始函数
     */
    func postMedia() {
        var sentCount: Int = 0 //上传图片的计数器
        if self.imageDatas.count != 0 {//图片数量不为零时，先将图片发送给twitter，保留图片的mediaID
            for i in 0..<self.imageDatas.count {
                swifter.postMedia((self.imageDatas[i].data)!, success: { json in
                    let mediaIDString = json["media_id_string"].string!
                    sentCount += 1 //每上传一张图片则计数器加1
                    self.mediaIDs.append(mediaIDString)
                    
                    if sentCount == self.imageDatas.count {//计数器达到图片数目，则调用推文发送函数
                        self.postTweet()
                    }
                })
            }
        } else {
            self.postTweet()
        }
    }
    /**
     把分割好的推文依次发送，通过回复前一条推文，形成一条完整的thread
     */
    func multiPost(tweetTexts: [String]) {
        var count: Int = 1 //设置发送条数计数器
        func sh(json: JSON) -> (){
            //定义successHandler，如果前一条发送成功，则在前一条基础上回复推文
            
            self.replyIDString = json["id_str"].string //获取前一条发送成功推文的ID作为回复的对象
            
            guard count < tweetTexts.count else {
                self.isTweetSentDone = true
                self.isShowCMV = false
                return}
            swifter.postTweet(
                status: tweetTexts[count],
                inReplyToStatusID: self.replyIDString,
                autoPopulateReplyMetadata: true,
                mediaIDs: self.mediaIDs,
                attachmentURL: nil,
                success: sh)
            
            count += 1 //发送条数计数器增加
        }
        
        swifter.postTweet(
            status: tweetTexts[count - 1],
            inReplyToStatusID: self.replyIDString,
            autoPopulateReplyMetadata: true,
            mediaIDs: self.mediaIDs,
            attachmentURL: nil,
            success: sh)
        
    }
    
    /**
     实现把一条超过140字的字串转变成低于134字以下，并增加序号
     */
    func splitToTexts(string: String) -> [String] {
        
        func splitStingToSubstrings(string: String) -> [Substring] {
            //按照主要标点符号的位置分开
            let strings: [String] = string.map{
                if "，。！：；？……".contains($0) {//定义主要标点符号
                    return String($0) + "/" //在主要标点符号位置后面增加分割符
                } else {
                    return String($0)
                }
            }
            return strings.joined().split(separator: "/") //将字节组合起来，并在分割符处进行分割
        }
        
        //以下内容将按语句分割好的句子按顺序组合起来，并保证组合后每条字数不超过134，
        guard string.count > 140 else {return [string]}
        var result: [String] = [] //定义一个空的推文队列
        var textCount: Int = 0
        var tempString: String = ""
        let substrings = splitStingToSubstrings(string: string)
        
        for sub in substrings {
            if textCount +  sub.count < 134 {
                tempString += String(sub)
                textCount += sub.count
            } else {
                result.append(tempString)
                textCount = sub.count
                tempString = String(sub)
            }
        }
        if tempString != "" {
            result.append(tempString) //把最后剩于部分添加到推文队列
        }
        for i in 0..<result.count {//在每天推文数据前增加序号
            result[i] = "\(i + 1)/\(result.count) " + result[i]
        }
        return result
    }
}

extension UIImage {
    func alpha(_ value:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
