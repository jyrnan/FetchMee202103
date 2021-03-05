//
//  ComposerOfHubView.swift
//  FetchMee
//
//  Created by yoeking on 2020/10/10.
//  Copyright © 2020 jyrnan. All rights reserved.
//

//
//  ComposerMoreView.swift
//  FetchMee
//
//  Created by jyrnan on 2020/7/29.
//  Copyright © 2020 jyrnan. All rights reserved.
//

import SwiftUI
import Combine
import Swifter
import UIKit
import CoreData

struct ComposerOfHubView: View {
    
    @EnvironmentObject var store: Store
    var swifter: Swifter {store.swifter}
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TweetDraft.createdAt, ascending: true)]) var draftsByCoreData: FetchedResults<TweetDraft>
    
    lazy var predicate = NSPredicate(format: "%K == %@", #keyPath(TwitterUser.userIDString), store.appState.setting.loginUser?.id as! CVarArg)
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TwitterUser.userIDString, ascending: true)]) var twitterUsers: FetchedResults<TwitterUser>
    
    @State var currentTweetDraft: TweetDraft? //用来接受从draft视图传递过来需要编辑的draft
    
    @Binding var tweetText: String
    @State var imageDatas: [ImageData] = []
    
    @State var isShowPhotoPicker: Bool = false
    @State var isShowAddPic: Bool = true
    @State var isTweetSentDone: Bool = true
    
    @State var replyIDString : String?
    @State var mediaIDs: [String] = [] //存储上传媒体/图片返回的ID号
    
    var isUsedAlone: Bool = false //用来区分这个推文发送视图是单独用还是在hubView使用
    
    @State var indicateText: String = "Tweet something below..."
    
    var body: some View {
        VStack{
            
            VStack {
                
                HStack {
                    Text(indicateText).font(.caption)
                        .foregroundColor(self.tweetText == "" ? .gray : .accentColor)
                        .padding(.leading)
                    Spacer()
                    if self.isTweetSentDone {
                        Text("\(tweetText.count)/140").font(.caption).foregroundColor(.gray).padding(.trailing, 16)
                    } else {
                        ActivityIndicator(isAnimating: self.$isTweetSentDone, style: .medium).padding(.trailing).frame(width: 12, height: 12, alignment: .center)
                    }
                }
                .padding(.top, 8)
                .onReceive(store.appState.setting.checker.autoMap, perform: {indicateText = $0})
                
                TextEditor(text: self.$tweetText)
//                CustomTextEditor(text: self.$tweetText, isFirstResponder: user.myInfo.setting.isFirsResponder)
                    .padding([.leading, .trailing, .bottom], 8)
            }
            .frame(minHeight: 50, idealHeight: 180, maxHeight: isUsedAlone ? 240 : .infinity, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            
            .background(isUsedAlone ? Color.init("BackGround") : Color.init("BackGroundLight"))
            .cornerRadius(18)
            .onAppear() {
                UITextView.appearance().backgroundColor = .clear
            }
            // 让TextEditor的背景是透明色
            
            //  按钮栏
            HStack(alignment: .center){
                if !self.imageDatas.isEmpty {
                    HStack {
                        ForEach(self.imageDatas, id: \.id) {
                            imageData in
                            Image(uiImage: (imageData.image ?? UIImage(systemName: "photo")!.alpha(0.2))) //用了对UIImage进行extention的代码
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 30, height: 30, alignment: .center).cornerRadius(15)
                                .onTapGesture {
                                    //点击图片则删除该图片数据
                                    self.imageDatas.remove(at: self.imageDatas.firstIndex {imageData.id == $0.id} ?? 0)
                                    //删除图片后将增加图片的按钮显示出来
                                    self.isShowAddPic = true
                                }
                        }
                    }
                    
                }
                Spacer()
                //增加图片按钮
                if self.isShowAddPic {
//
                    Button(action: {
                        withAnimation{
                            self.isShowPhotoPicker = true
                            self.imageDatas.append(ImageData())
                        }
                    }, label: {
                        Image(systemName: "rectangle.and.paperclip")
                            .font(.body)
                            .foregroundColor(.accentColor)
                            .padding(8)
//                            .padding([.leading, .trailing], 8)
                            })
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
                
                //载入草稿
                NavigationLink(
                    destination: DraftsViewCoreData(currentTweetDraft: self.$currentTweetDraft, tweetText: self.$tweetText, replyIDString: self.$replyIDString),label: {
                    Image(systemName: "tray.and.arrow.up")
                        .font(.body)
                        .foregroundColor(.accentColor)
                        .padding(8)
                        })
                
                //存储草稿按钮
                Button(action: {
                    saveOrUpdateDraft(draft: currentTweetDraft)
                    tweetText = ""
                    currentTweetDraft = nil
                }, label: {
                    Image(systemName: "tray.and.arrow.down")
                        .font(.body)
                        .foregroundColor(.accentColor)
                        .padding(8)
                }).disabled(tweetText == "")
                
                //发送按钮
                Button(action: {
                    self.isTweetSentDone = false
                    self.postMedia()
                }, label: {
                    Text("Send")
                        .font(.body).bold()
                        .foregroundColor(.white)
                        .padding(4)
                        .padding([.leading, .trailing], 8)
                        .background(Capsule().foregroundColor(.accentColor))
                        .padding(.trailing, 8)
                })
                .disabled(self.tweetText == "" && imageDatas.isEmpty) 
            }
            
            //如果单独使用则靠顶部
            if isUsedAlone {
                Spacer()
            }
        }.padding(isUsedAlone ? 16 : 0)
        
    }
}


struct ComposerOfHubView_Previews: PreviewProvider {
    static var previews: some View {
        ComposerOfHubView(tweetText: .constant(""), replyIDString: nil)
    }
}

//MARK: - 发帖模块
extension ComposerOfHubView {
    
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
                    
                    //图片如果发送成功则显示成checkmark
                    self.imageDatas[i].image = UIImage(systemName: "checkmark.circle.fill")?.alpha(0.5)
                    
                    if sentCount == self.imageDatas.count {//计数器达到图片数目，则调用推文发送函数
                        self.postTweet()
                        self.imageDatas.removeAll()
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
        
        
        /// 定义successHandler，如果前一条发送成功，则在前一条基础上回复推文
        func sh(json: JSON) -> (){
            
            //获取前一条发送成功推文的ID作为回复的对象
            self.replyIDString = json["id_str"].string
            
            //如果推文附有媒体文件，则在推文发送成功处理闭包里检测并清空。
            if !self.mediaIDs.isEmpty {self.mediaIDs.removeAll()}
            
            guard count < tweetTexts.count else {
               
                //如果是最后一条推文，则执行如下操作
                self.tweetText = "" //发送成功后把推文文字重新设置成空的
                self.replyIDString = nil //发送成功后把回复的推文对象设置成nil
                
                self.isTweetSentDone = true
                
                deleteDraft(draft: currentTweetDraft)
                currentTweetDraft = nil
                
//                self.alerts.stripAlert.alertText = "Tweet sent!"
//                self.alerts.stripAlert.isPresentedAlert = true
                
                store.dipatch(.alertOn(text: "Tweet sent!", isWarning: false))
                
                hideKeyboard()
                return
                
            }
            
            //如果推文分割后不是发送完最后一条，则继续发送。
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
            success: sh,
            failure: {_ in
                saveOrUpdateDraft(draft: currentTweetDraft)
            })
        
    }
    
    /**
     实现把一条超过字数的字串转变成符合单条推文限制，并增加序号，根据是否含有中文自动识别
     */
    func splitToTexts(string: String) -> [String] {
        
        //根据是否含有中文设置单条推文的字数上限
        let countLimit: Int = {
            switch  isIncludeChineseIn(string: string) {
            case true:
                return 140
            case false:
                return 280
            }
        }()
        
        //判断字符串中是否含有中文
        func isIncludeChineseIn(string: String) -> Bool {

            for value in string {
                
                if ("\u{4E00}" <= value  && value <= "\u{9FA5}") {
                    return true
                }
            }

            return false
        }
        
        func splitStingToSubstrings(string: String) -> [Substring] {
           
            //按照主要标点符号的位置分开
            let strings: [String] = string.map{
                if "，。！：；？……\n ".contains($0) {//定义主要标点符号
                    return String($0) + "※" //在主要标点符号位置后面增加分割符
                } else {
                    return String($0)
                }
            }
            return strings.joined().split(separator: "※") //将字节组合起来，并在分割符处进行分割
        }
        
        //以下内容将按语句分割好的句子按顺序组合起来，并保证组合后每条字数不超过134，
        guard string.count > countLimit else {return [string]}
        var result: [String] = [] //定义一个空的推文队列
        var textCount: Int = 0
        var tempString: String = ""
        let substrings = splitStingToSubstrings(string: string)
        
        for sub in substrings {
            if textCount +  sub.count < countLimit - 6 {
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

//MARK: -CoreData操作模块
extension ComposerOfHubView {
    
    func getCurrentUser() -> TwitterUser? {
        guard !twitterUsers.isEmpty else {return nil}
        
        let userIDString = store.appState.setting.loginUser?.id
        let result = twitterUsers.filter{$0.userIDString == userIDString}
        return result.first
    }
    
    private func saveOrUpdateDraft(draft: TweetDraft? = nil){
        
        withAnimation {
            let draft = draft ?? TweetDraft(context: viewContext) //如果没有当前编辑的draft则新生成一个空的draft
            draft.createdAt = Date()
            draft.text = tweetText
            draft.id = currentTweetDraft?.id ?? UUID()
            draft.replyIDString = replyIDString
            
            draft.user = getCurrentUser()
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print(nsError.description)
                
            }
        }
    }
    
    private func deleteDraft(draft: TweetDraft?) {
        guard draft != nil else {return}
        
        viewContext.delete(draft!)
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print(nsError.description)
        }
    }
    
}

extension ComposerOfHubView {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


