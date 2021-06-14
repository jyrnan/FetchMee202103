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
    var swifter: Swifter {store.fetcher.swifter}
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TweetDraft.createdAt, ascending: true)]) var draftsByCoreData: FetchedResults<TweetDraft>
    
    lazy var predicate = NSPredicate(format: "%K == %@", #keyPath(UserCD.userIDString), store.appState.setting.loginUser?.id ?? "")
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \UserCD.userIDString, ascending: true)]) var userCDs: FetchedResults<UserCD>
    
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
    
    @State var isShowAutoCompleteText: Bool = false
    @State var autoCompleteText: String = ""
    
    var body: some View {
        VStack{
            
            VStack {
                
                HStack {
                    Text(indicateText).font(.caption)
                        .foregroundColor(self.tweetText == "" ? .accentColor : .clear)
                        .padding(.leading)
                    Spacer()
                    if self.isTweetSentDone {
                        Text("\(tweetText.count)/140").font(.caption).foregroundColor(.gray).padding(.trailing, 16)
                    } else {
                        ActivityIndicator(isAnimating: self.$isTweetSentDone, style: .medium).padding(.trailing).frame(width: 12, height: 12, alignment: .center)
                    }
                }
                .padding(.top, 8)
                
                
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
                        .font(.callout).bold()
                        .foregroundColor(.white)
                        .padding(4)
                        .padding([.leading, .trailing], 8)
                        .background(Capsule().foregroundColor(.accentColor))
                        .padding(.trailing, 8)
                })
                .disabled(self.tweetText == "" && imageDatas.isEmpty) 
            }
            if store.appState.setting.autoCompleteText != "noTag" {
                HStack {
                    AutoCompleteVIew(autoCompletText: store.appState.setting.autoCompleteText)
                }
            }
            //如果单独使用则靠顶部
            if isUsedAlone {
                Spacer()
            }
        }.padding(isUsedAlone ? 16 : 0)
//        .onReceive(store.appState.setting.tweetInput.autoMapPublisher, perform: {text in
//            print(#line, #file, "sent a text \(text)")
//            if $0 != "noTag" {
//                autoCompleteText = $0
//                withAnimation{
//                    isShowAutoCompleteText = true}
//            } else {
//                withAnimation{
//                    isShowAutoCompleteText = false}}
//        })
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
            
            ///- Todo：- 所有的发布的内容保存一份
            if replyIDString == nil || count > 1 {
                let _ = StatusCD.JSON_Save(from: json)
                // 更新hub界面的status状态
                store.dipatch(.hubStatusRequest)
            }
            
            
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
        
        
        
        let TextCountMaxLimit: Int = 275
        guard string.realCount > TextCountMaxLimit else {return [string]}
        
        let subStrings = splitStingToSubstrings(string: string)
        var result: [String] = []
        var textCount: Int = 0
        var tempString: String = ""
        
        for subString in subStrings {
            if textCount +  subString.realCount < TextCountMaxLimit {
                tempString += subString
                textCount += subString.realCount
            } else {
                result.append(tempString)
                textCount = subString.realCount
                tempString = subString
            }
        }
        result.append(tempString) //把最后剩于部分添加到推文队列
        return result.enumerated().map{"\($0.0 + 1)/\(result.count) " + $0.1} //给推文添加编号
    }
    
    func splitStingToSubstrings(string: String) -> [String] {
        let separatorMark: Character = "※"
        let characterSetFollowedBySeparatorMark = "，。！：；？……\n., "
        //按照主要标点符号的位置分开
        return string.map{ characterSetFollowedBySeparatorMark.contains($0) ? "\($0)\(separatorMark)" : String($0)}
        .joined()
        .split(separator: separatorMark)
        .map(String.init)
    }
}

extension String {
    //返回字串长度，其中如果非ascii字符则计数为2
    var realCount: Int {
        self.reduce(0){$0 + ($1.isASCII ? 1: 2)}
    }
}

//MARK: -CoreData操作模块
extension ComposerOfHubView {
    
    func getCurrentUser() -> UserCD? {
        guard !userCDs.isEmpty else {return nil}
        
        let userIDString = store.appState.setting.loginUser?.id
        let result = userCDs.filter{$0.userIDString == userIDString}
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


